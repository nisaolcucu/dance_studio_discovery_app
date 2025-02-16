import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/widgets/gradient_background.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StudioDetailScreen extends StatefulWidget {
  final String studioId;
  final String name;
  final String address;
  final String description;
  final List<String> style;
  final double latitude;
  final double longitude;

  StudioDetailScreen({
    required this.studioId,
    required this.name,
    required this.address,
    required this.description,
    required this.style,
    required this.latitude,
    required this.longitude,
  });

  @override
  _StudioDetailScreenState createState() => _StudioDetailScreenState();
}

class _StudioDetailScreenState extends State<StudioDetailScreen> {
  DateTime? selectedDateTime;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  /// check if it is favorite or not from firebase
  Future<void> checkFavoriteStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .collection('studios')
        .doc(widget.studioId)
        .get();

    setState(() {
      isFavorite = doc.exists;
    });
  }

  /// favorites function
  Future<void> toggleFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference favRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .collection('studios')
        .doc(widget.studioId);

    if (isFavorite) {
      // remove from the favorites
      await favRef.delete();
      setState(() {
        isFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Removed from favorites!")),
      );
    } else {
      // add to the favorites
      await favRef.set({
        'studioId': widget.studioId,
        'studioName': widget.name,
        'address': widget.address,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        isFavorite = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to favorites!")),
      );
    }
  }

  /// choosing time and date for user
  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Reservation adding
  Future<void> _bookNow() async {
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select date and time!")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in!")),
      );
      return;
    }

    DocumentReference userBookingRef = FirebaseFirestore.instance
        .collection('bookings')
        .doc(user.uid)
        .collection('reservations')
        .doc(widget.studioId);

    DocumentSnapshot bookingSnapshot = await userBookingRef.get();

    if (bookingSnapshot.exists) {
      await userBookingRef.update({
        'timestamp': Timestamp.fromDate(selectedDateTime!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reservation updated!")),
      );
    } else {
      await userBookingRef.set({
        'studioId': widget.studioId,
        'studioName': widget.name,
        'address': widget.address,
        'timestamp': Timestamp.fromDate(selectedDateTime!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reservation successful!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.name),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: toggleFavorite,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${widget.name}',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Address: ${widget.address}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Description: ${widget.description}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Styles: ${widget.style.join(', ')}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _selectDateTime(context),
                    child: Text(selectedDateTime == null
                        ? "Choose date and time"
                        : "${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} - ${selectedDateTime!.hour}:${selectedDateTime!.minute}"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _bookNow,
                    child: Text("Book Now"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.latitude, widget.longitude),
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.studioId),
                    position: LatLng(widget.latitude, widget.longitude),
                    infoWindow: InfoWindow(title: widget.name),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
