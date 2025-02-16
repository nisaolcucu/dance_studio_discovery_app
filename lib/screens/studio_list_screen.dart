import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'studio_detail_screen.dart';
import '../widgets/gradient_background.dart'; // GradientBackground ekleniyor

class StudioListScreen extends StatefulWidget {
  @override
  _StudioListScreenState createState() => _StudioListScreenState();
}

class _StudioListScreenState extends State<StudioListScreen> {
  String searchQuery = "";
  String? selectedStyle; // To hold the selected style
  List<String> styleOptions = [];

  @override
  void initState() {
    super.initState();
    selectedStyle = "All"; // Set default as "All"
    fetchStyles();
  }

  /// Fetch the styles from Firestore in studios
  Future<void> fetchStyles() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('studios').get();
    Set<String> uniqueStyles = {};

    // Extract unique styles from studios in Firestore
    for (var doc in snapshot.docs) {
      List<String> styles = List<String>.from(doc['style']);
      uniqueStyles.addAll(styles);
    }

    setState(() {
      styleOptions = uniqueStyles.toList();
    });
  }

  /// Reset the selected style and search query
  void resetFilters() {
    setState(() {
      selectedStyle = "All"; // Reset to "All"
      searchQuery = ""; // Clear search query
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Dance Studios"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search studios...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    "Style",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedStyle,
                    onChanged: (newStyle) {
                      setState(() {
                        selectedStyle = newStyle;
                      });
                    },
                    items: ["All", ...styleOptions].map((style) {
                      return DropdownMenuItem<String>(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Reset Filters Button
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: resetFilters,
                child: Text("Reset Filters"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('studios')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No studios available"));
                  }

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    final name = doc['name'].toString().toLowerCase();
                    final styles = List<String>.from(doc['style']);

                    final matchesSearch = name.contains(searchQuery);
                    final matchesStyle = selectedStyle == "All" ||
                        styles.contains(selectedStyle);

                    return matchesSearch && matchesStyle;
                  }).toList();

                  return ListView(
                    children: filteredDocs.map((doc) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                        child: ListTile(
                          title: Text(doc['name']),
                          subtitle: Text(doc['address']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudioDetailScreen(
                                  studioId: doc.id,
                                  name: doc['name'],
                                  address: doc['address'],
                                  description: doc['description'],
                                  style: List<String>.from(doc['style']),
                                  latitude: (doc['latitude'] as num).toDouble(),
                                  longitude:
                                      (doc['longitude'] as num).toDouble(),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
