import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/widgets/gradient_background.dart';

class BookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("My Bookings")),
        body: Center(child: Text("Please log in!")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("My Bookings")),
      body: GradientBackground(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .doc(user.uid)
              .collection('reservations')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("You don't have a reservation yet."));
            }

            var bookings = snapshot.data!.docs;

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index].data() as Map<String, dynamic>;
                String bookingId = bookings[index].id;

                String formattedDate = "No date";
                if (booking['timestamp'] != null) {
                  DateTime dateTime =
                      (booking['timestamp'] as Timestamp).toDate();
                  formattedDate =
                      DateFormat("dd/MM/yyyy - HH:mm").format(dateTime);
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(booking['studioName'] ?? "unknown studio"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['address'] ?? "no address information"),
                        Text("Date: $formattedDate"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () =>
                          _cancelBooking(context, user.uid, bookingId),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// cancelling reservations
  void _cancelBooking(
      BuildContext context, String userId, String bookingId) async {
    bool confirm = await _showConfirmationDialog(context);
    if (!confirm) return;

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(userId)
        .collection('reservations')
        .doc(bookingId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("The reservation has been cancelled!")),
      );
    }
  }

  /// to ask the user is sure or not about cancelling
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Cancel Reservation"),
            content: Text("Are you sure you want to cancel this reservation?"),
            actions: [
              TextButton(
                child: Text("No"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text("Yes"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
