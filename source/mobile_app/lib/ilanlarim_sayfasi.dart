import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IlanlarimSayfasi extends StatelessWidget {
  const IlanlarimSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    const Color temaYesil = Color(0xFF0B7A53);
    const Color acikGri = Color.fromARGB(255, 204, 205, 205);
    const Color siyahYazi = Color.fromARGB(255, 6, 6, 6);
    const Color beyazYazi = Colors.white;
    
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: temaYesil,
      appBar: AppBar(
        backgroundColor: temaYesil,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Listings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'No user found.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .where('createdBy', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have not created any listings yet.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                     final data = doc.data() as Map<String, dynamic>;

                    final String title = data['title'] ?? '';
                    final String description = data['description'] ?? '';
                    final String city = data['city'] ?? '';
                    final String county = data['county'] ?? '';
                    final String price = data['price'] ?? '';
                    final String time = data['time'] ?? '';
                    final String dateText = data['dateText'] ?? '';

                   
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: beyazYazi,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title.isEmpty ? 'Untitled Listing' : title,
                                  style: const TextStyle(
                                    color: siyahYazi,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                color: Colors.white,
                               onSelected: (value) async {
                                  if (value == 'edit') {
                                    final TextEditingController titleController =
                                        TextEditingController(text: title);
                                    final TextEditingController descriptionController =
                                        TextEditingController(text: description);
                                    final TextEditingController priceController =
                                        TextEditingController(text: price);
                                    final TextEditingController dateController =
                                        TextEditingController(text: dateText);
                                    final TextEditingController timeController =
                                        TextEditingController(text: time);

                                    final confirmEdit = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Edit Listing'),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: titleController,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Title',
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: descriptionController,
                                                  maxLines: 3,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Description',
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: priceController,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Price',
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: dateController,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Date',
                                                    hintText: 'Example: 2026-05-23',
                                                  ),
                                                ),

                                                TextField(
                                                  controller: timeController,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Time',
                                                    hintText: 'Example: 14:30',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmEdit == true) {
                                      await FirebaseFirestore.instance
                                          .collection('listings')
                                          .doc(doc.id)
                                          .update({
                                        'title': titleController.text.trim(),
                                        'description': descriptionController.text.trim(),
                                        'price': priceController.text.trim(),
                                        'dateText': dateController.text.trim(),
                                        'time': timeController.text.trim(),
                                        'updatedAt': FieldValue.serverTimestamp(),
                                      });

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Listing updated successfully.'),
                                          ),
                                        );
                                      }
                                    }
                                  }

                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete Listing'),
                                          content: const Text(
                                            'Are you sure you want to delete this listing?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection('listings')
                                          .doc(doc.id)
                                          .update({
                                        'isActive': false,
                                        'deletedAt': FieldValue.serverTimestamp(),
                                      });

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Listing deleted successfully.'),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: siyahYazi,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              color: siyahYazi,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'City: $city',
                            style: const TextStyle(color: siyahYazi),
                          ),
                          if (county.isNotEmpty)
                            Text(
                              'County: $county',
                              style: const TextStyle(color: siyahYazi),
                            ),
                          if (dateText.isNotEmpty)
                            Text(
                              'Date: $dateText',
                              style: const TextStyle(color: siyahYazi),
                            ),
                          if (time.isNotEmpty)
                            Text(
                              'Time: $time',
                              style: const TextStyle(color: siyahYazi),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: $price',
                            style: const TextStyle(
                              color: siyahYazi,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}