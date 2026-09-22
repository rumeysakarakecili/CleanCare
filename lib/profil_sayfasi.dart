import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mesaj_sayfasi.dart';
import 'alt_bar_sayfasi.dart';

class ProfilSayfasi extends StatelessWidget {
  final String? profileUserId;
  final String? profileEmail;
  final String? profileName;

  const ProfilSayfasi({
    super.key,
    this.profileUserId,
    this.profileEmail,
    this.profileName,
  });

  Future<void> bookingTalebiGonder(
    BuildContext context,
    Map<String, dynamic> ilan,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('booking_requests').add({
        'listingId': ilan['docId'],
        'listingTitle': ilan['title'],
        'providerId': ilan['createdBy'],
        'providerEmail': ilan['createdByEmail'],
        'customerId': user.uid,
        'customerEmail': user.email,
        'city': ilan['city'],
        'county': ilan['county'],
        'price': ilan['price'],
        'status': 'pending',
        'providerSeen': false,
        'customerSeen': true,
        'paymentStatus': 'unpaid',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request sent.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color temaYesil = Color(0xFF0B7A53);
    const Color sayfaArkaPlan = Color(0xFFF5F7F6);

    final currentUser = FirebaseAuth.instance.currentUser;
    final String? hedefUserId = profileUserId ?? currentUser?.uid;
    final String? hedefEmail = profileEmail ?? currentUser?.email;
    final bool kendiProfilim = currentUser?.uid == hedefUserId;

    return Scaffold(
      backgroundColor: temaYesil,
      appBar: AppBar(
        backgroundColor: temaYesil,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const AltBarSayfasi(),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: hedefUserId == null
          ? const Center(
              child: Text(
                'No user found.',
                style: TextStyle(color: Color(0xFF1F2937)),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(hedefUserId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;

                final String fullName =
                    (userData?['fullName'] ??
                            profileName ??
                            'Name Surname')
                        .toString();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    profilBaslikKarti(
                      context: context,
                      fullName: fullName,
                      email: hedefEmail ?? '',
                      hedefUserId: hedefUserId,
                      kendiProfilim: kendiProfilim,
                    ),
                    const SizedBox(height: 20),
                    yorumlarBolumu(hedefUserId),
                    const SizedBox(height: 20),
                    ilanlarBolumu(
                      hedefUserId,
                      kendiProfilim: kendiProfilim,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget profilBaslikKarti({
    required BuildContext context,
    required String fullName,
    required String email,
    required String hedefUserId,
    required bool kendiProfilim,
  }) {
    const Color temaYesil = Color(0xFF0B7A53);
    const Color kartArkaPlan = Colors.white;
    const Color yaziKoyu = Color(0xFF1F2937);
    const Color yaziYumusak = Color(0xFF6B7280);
    const Color kenarlik = Color(0xFFD8E0DB);
    const Color kartYesili = Color(0xFF168A61);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kartArkaPlan,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kenarlik),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: temaYesil.withAlpha(25),
                child: const Icon(
                  Icons.person,
                  color: temaYesil,
                  size: 44,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: yaziKoyu,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        color: yaziYumusak,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!kendiProfilim) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser == null) return;

                  final members = [currentUser.uid, hedefUserId]..sort();
                  final chatId = '${members[0]}_profile_${members[1]}';

                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .set({
                    'members': members,
                    'memberEmails': [currentUser.email, email],
                    'listingTitle': 'Profile Chat',
                    'lastMessage': '',
                    'lastMessageAt': FieldValue.serverTimestamp(),
                    'createdAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MesajSayfasi(
                        chatId: chatId,
                        listingTitle: 'Profile Chat',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: temaYesil,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget yorumlarBolumu(String userId) {
    const Color kartArkaPlan = Colors.white;
    const Color yaziKoyu = Color(0xFF1F2937);
    const Color yaziYumusak = Color(0xFF6B7280);
    const Color kenarlik = Color(0xFFD8E0DB);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('providerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        double average = 0;

        if (docs.isNotEmpty) {
          double total = 0;

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            total += double.tryParse((data['rating'] ?? 0).toString()) ?? 0;
          }

          average = total / docs.length;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kartArkaPlan,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kenarlik),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  color: yaziKoyu,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < average.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 25,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    docs.isEmpty
                        ? 'No reviews yet'
                        : '${average.toStringAsFixed(1)} / 5',
                    style: const TextStyle(color: yaziYumusak),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (docs.isEmpty)
                const Text(
                  'No comments have been added yet.',
                  style: TextStyle(color: yaziYumusak),
                )
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final String comment = (data['comment'] ?? '').toString();
                  final String rating = (data['rating'] ?? '').toString();

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kenarlik),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating: $rating / 5',
                          style: const TextStyle(
                            color: yaziKoyu,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (comment.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            comment,
                            style: const TextStyle(color: yaziYumusak),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget ilanlarBolumu(
    String userId, {
    required bool kendiProfilim,
  }) {
    const Color kartArkaPlan = Color(0xFF168A61);
    const Color yaziKoyu = Color(0xFF1F2937);
    const Color yaziYumusak = Color(0xFF6B7280);
    const Color kenarlik = Color(0xFFD8E0DB);
    const Color kartYesili = Color(0xFF168A61);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('createdBy', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kartArkaPlan,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kenarlik),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Listings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                const Text(
                  'No active listings yet.',
                  style: TextStyle(color: yaziYumusak),
                )
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['docId'] = doc.id;
                  data['createdBy'] = userId;
                  data['createdByEmail'] = profileEmail ?? '';
                  data['createdByName'] = profileName ?? '';

                  final String title =
                      (data['title'] ?? 'Untitled Listing').toString();
                  final String description =
                      (data['description'] ?? '').toString();
                  final String city = (data['city'] ?? '').toString();
                  final String county = (data['county'] ?? '').toString();
                  final String dateText = (data['dateText'] ?? '').toString();
                  final String time = (data['time'] ?? '').toString();
                  final String price = (data['price'] ?? '').toString();

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kenarlik),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: yaziKoyu,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (kendiProfilim)
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: yaziKoyu,
                                ),
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
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: timeController,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Time',
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
                              ),
                          ],
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: yaziYumusak),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (city.isNotEmpty)
                          Text(
                            'City: $city',
                            style: const TextStyle(color: yaziYumusak),
                          ),
                        if (county.isNotEmpty)
                          Text(
                            'County: $county',
                            style: const TextStyle(color: yaziYumusak),
                          ),
                        if (dateText.isNotEmpty)
                          Text(
                            'Date: $dateText',
                            style: const TextStyle(color: yaziYumusak),
                          ),
                        if (time.isNotEmpty)
                          Text(
                            'Time: $time',
                            style: const TextStyle(color: yaziYumusak),
                          ),
                        if (price.isNotEmpty)
                          Text(
                            'Price: $price',
                            style: const TextStyle(
                              color: yaziKoyu,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!kendiProfilim) ...[
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                bookingTalebiGonder(context, data);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 78, 118, 183),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Request Booking',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}