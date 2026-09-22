import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mesaj_sayfasi.dart';
import 'profil_sayfasi.dart';
import 'alt_bar_sayfasi.dart';

class FavorilerimSayfasi extends StatelessWidget {
  const FavorilerimSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF0B7A53);

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: mainGreen,
      appBar: AppBar(
        backgroundColor: mainGreen,
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
          'Favorites',
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
                .collection('favorites')
                .where('userId', isEqualTo: user.uid)
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
                      'No favorites yet.',
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
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String listingId = (data['listingId'] ?? '').toString();

                   
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('listings')
                          .doc(listingId)
                          .get(),
                      builder: (context, listingSnapshot) {
                        if (!listingSnapshot.hasData) {
                          return const SizedBox();
                        }

                        if (!listingSnapshot.data!.exists) {
                          return const SizedBox();
                        }

                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('listings')
                              .doc(listingId)
                              .snapshots(),
                          builder: (context, listingSnapshot) {
                            if (listingSnapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox();
                            }

                            if (!listingSnapshot.hasData || !listingSnapshot.data!.exists) {
                              return const SizedBox();
                            }

                            final ilan = listingSnapshot.data!.data() as Map<String, dynamic>;
                            ilan['docId'] = listingSnapshot.data!.id;

                            final bool isActive = ilan['isActive'] == true;

                            if (!isActive) {
                              return const SizedBox();
                            }

                            return ilanKarti(
                              context,
                              ilan,
                              docs[index].reference,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> mesajBaslat(
    BuildContext context,
    Map<String, dynamic> ilan,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String providerId = (ilan['createdBy'] ?? '').toString();
    if (providerId.isEmpty) return;

    final members = [user.uid, providerId]..sort();
    final chatId = '${members[0]}_${ilan['docId']}_${members[1]}';

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'members': members,
      'memberEmails': [
        user.email,
        ilan['createdByEmail'],
      ],
      'listingId': ilan['docId'],
      'listingTitle': ilan['title'],
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
          listingTitle: (ilan['title'] ?? 'Chat').toString(),
        ),
      ),
    );
  }

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

  Widget ilanKarti(
    BuildContext context,
    Map<String, dynamic> ilan,
    DocumentReference favoriteRef,
  ) {
    const Color temaYesil = Color(0xFF0B7A53);
    const Color acikMavi = Color.fromARGB(255, 78, 118, 183);
    const Color kartArkaPlan = Colors.white;
    const Color yaziKoyu = Color(0xFF1F2937);
    const Color yaziYumusak = Color(0xFF6B7280);
    const Color yeniYesil = Color(0xFF00A651);
    const Color favoriRed = Color.fromARGB(255, 217, 3, 3);

    final String title = (ilan['title'] ?? '').toString();
    final String description = (ilan['description'] ?? '').toString();
    final String city = (ilan['city'] ?? '').toString();
    final String county = (ilan['county'] ?? '').toString();
    final String price = (ilan['price'] ?? '').toString();
    final String dateText = (ilan['dateText'] ?? '').toString();
    final String time = (ilan['time'] ?? '').toString();

    final String providerId = (ilan['createdBy'] ?? '').toString();
    final String providerEmail = (ilan['createdByEmail'] ?? '').toString();
    final String providerName = (ilan['createdByName'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kartArkaPlan,
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
                    color: yaziKoyu,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Remove Favorite'),
                        content: const Text(
                          'Are you sure you want to remove this listing from your favorites?',
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
                            child: const Text('Remove'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) return;

                  await favoriteRef.delete();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removed from favorites.'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                  color: favoriRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                color: yaziYumusak,
                height: 1.4,
              ),
            ),

          const SizedBox(height: 12),

          if (city.isNotEmpty)
            Text(
              'City: $city',
              style: const TextStyle(color: yaziKoyu),
            ),

          if (county.isNotEmpty)
            Text(
              'County: $county',
              style: const TextStyle(color: yaziKoyu),
            ),

          if (dateText.isNotEmpty)
            Text(
              'Date: $dateText',
              style: const TextStyle(color: yaziKoyu),
            ),

          if (time.isNotEmpty)
            Text(
              'Time: $time',
              style: const TextStyle(color: yaziKoyu),
            ),

          const SizedBox(height: 8),

          if (price.isNotEmpty)
            Text(
              'Price: $price',
              style: const TextStyle(
                color: yaziKoyu,
                fontWeight: FontWeight.w700,
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    mesajBaslat(context, ilan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yeniYesil,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    bookingTalebiGonder(context, ilan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acikMavi,
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
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: providerId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilSayfasi(
                            profileUserId: providerId,
                            profileEmail: providerEmail,
                            profileName:
                                providerName.isEmpty ? null : providerName,
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.person_search),
              label: const Text(
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: yeniYesil,
                side: const BorderSide(color: yeniYesil),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}