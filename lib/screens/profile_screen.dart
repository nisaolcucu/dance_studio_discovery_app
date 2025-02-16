import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/screens/loginscreen.dart';
import 'package:flutter_application/widgets/gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> favoriteStudios = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  /// fetch the favorites of user from firestore
  Future<void> fetchFavorites() async {
    if (user == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(user!.uid)
        .collection('studios')
        .get();

    setState(() {
      favoriteStudios = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  /// log out
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: GradientBackground(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 Kullanıcı Bilgileri
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : AssetImage('assets/profile_placeholder.png')
                              as ImageProvider,
                    ),
                    SizedBox(height: 10),
                    Text(user?.displayName ?? "User name",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? "e-mail address"),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Text("My favorites",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),

              Expanded(
                child: favoriteStudios.isEmpty
                    ? Center(child: Text("No favorites added yet."))
                    : ListView.builder(
                        itemCount: favoriteStudios.length,
                        itemBuilder: (context, index) {
                          var studio = favoriteStudios[index];
                          return Card(
                            child: ListTile(
                              title: Text(studio['studioName']),
                              subtitle: Text(studio['address']),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('favorites')
                                      .doc(user!.uid)
                                      .collection('studios')
                                      .doc(studio['studioId'])
                                      .delete();

                                  setState(() {
                                    favoriteStudios.removeAt(index);
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Removed from favorites!")),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),

              /// log out button
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _logout,
                  child: Text("Log out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
