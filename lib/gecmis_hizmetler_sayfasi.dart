import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GecmisHizmetlerSayfasi extends StatelessWidget {
  const GecmisHizmetlerSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF0B7A53);
    const Color cardGreen = Color(0xFF168A61);

    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: mainGreen,
        appBar: AppBar(
          backgroundColor: mainGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Past Services',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Provided'),
            ],
          ),
        ),
        body: user == null
            ? const Center(
                child: Text(
                  'No user found.',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : TabBarView(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('booking_requests')
                        .where('customerId', isEqualTo: user.uid)
                        .where('status', isEqualTo: 'completed')
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

                      final receivedServices = snapshot.data?.docs ?? [];

                      return hizmetListesi(
                        receivedServices,
                        cardGreen,
                        emptyText: 'No received services yet.',
                        isReceived: true,
                        context: context,
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('booking_requests')
                        .where('providerId', isEqualTo: user.uid)
                        .where('status', isEqualTo: 'completed')
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

                      final providedServices = snapshot.data?.docs ?? [];

                      return hizmetListesi(
                        providedServices,
                        cardGreen,
                        emptyText: 'No provided services yet.',
                        isReceived: false,
                        context: context,
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget hizmetListesi(
    List<QueryDocumentSnapshot> services,
    Color cardGreen, {
    required String emptyText,
    required bool isReceived,
    required BuildContext context,
  }) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: bosKart(emptyText, cardGreen),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: services.map((doc) {
        return hizmetKarti(
          doc.id,
          doc.data() as Map<String, dynamic>,
          cardGreen,
          isReceived: isReceived,
          context: context,
        );
      }).toList(),
    );
  }

  Widget bosKart(String text, Color cardGreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget hizmetKarti(
    String requestId,
    Map<String, dynamic> data,
    Color cardGreen, {
    required bool isReceived,
    required BuildContext context,
  }) {

    const Color siyahYazi = Color.fromARGB(255, 6, 6, 6);
    const Color beyazYazi =  Colors.white;
    const Color temaYesil = Color(0xFF0B7A53);
    const Color kartYesili = Color(0xFF168A61);
    const Color acikMavi = Color.fromARGB(255, 78, 118, 183);
    


    final String title = (data['listingTitle'] ?? 'Untitled Service').toString();
    final String city = (data['city'] ?? '').toString();
    final String county = (data['county'] ?? '').toString();
    final String price = (data['price'] ?? '').toString();
    final String customerEmail = (data['customerEmail'] ?? '').toString();
    final String providerEmail = (data['providerEmail'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: siyahYazi,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (city.isNotEmpty)
            Text(
              'City: $city',
              style: const TextStyle(color: siyahYazi),
            ),
          if (county.isNotEmpty)
            Text(
              'County: $county',
              style: const TextStyle(color: siyahYazi),
            ),
          if (price.isNotEmpty)
            Text(
              'Price: $price',
              style: const TextStyle(color: siyahYazi),
            ),
          const SizedBox(height: 8),
          Text(
            isReceived
                ? 'Provider: $providerEmail'
                : 'Customer: $customerEmail',
            style: const TextStyle(color: siyahYazi),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: acikMavi,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: acikMavi,
                width: 1.5,
              ),
            ),
            child: const Text(
              'Completed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isReceived) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: data['reviewDone'] == true
                    ? null
                    : () {
                        degerlendirmePenceresiAc(
                          context,
                          requestId,
                          data,
                        );
                      },
                icon: const Icon(Icons.star),
                label: Text(
                  data['reviewDone'] == true
                      ? 'Reviewed'
                      : 'Evaluate Service',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: acikMavi,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  disabledForegroundColor: Colors.white,
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
  Future<void> degerlendirmePenceresiAc(
    BuildContext context,
    String requestId,
    Map<String, dynamic> data,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int secilenYildiz = 0;
    final TextEditingController yorumController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Evaluate Service'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (data['listingTitle'] ?? 'Completed Service').toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rating',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        final selected = starNumber <= secilenYildiz;

                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              if (secilenYildiz == starNumber) {
                                secilenYildiz = 0;
                              } else {
                                secilenYildiz = starNumber;
                              }
                            });
                          },
                          icon: Icon(
                            selected ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: yorumController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Comment optional',
                        hintText: 'Write your comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('reviews')
                          .doc(requestId)
                          .set({
                        'requestId': requestId,
                        'listingId': data['listingId'],
                        'listingTitle': data['listingTitle'],
                        'providerId': data['providerId'],
                        'providerEmail': data['providerEmail'],
                        'customerId': user.uid,
                        'customerEmail': user.email,
                        'rating': secilenYildiz,
                        'comment': yorumController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      await FirebaseFirestore.instance
                          .collection('booking_requests')
                          .doc(requestId)
                          .update({
                        'reviewDone': true,
                        'reviewRating': secilenYildiz,
                        'reviewedAt': FieldValue.serverTimestamp(),
                      });
                    

                      if (!context.mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Review saved successfully.'),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Review error: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}