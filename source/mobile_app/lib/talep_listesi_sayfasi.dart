import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TalepListesiSayfasi extends StatelessWidget {
  const TalepListesiSayfasi({super.key});

  Color durumRengi(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return Colors.greenAccent;
    case 'rejected':
      return Colors.redAccent;
    case 'completed':
      return Colors.lightBlueAccent;
    default:
      return Colors.orangeAccent;
  }
}

IconData durumIkonu(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return Icons.check_circle;
    case 'rejected':
      return Icons.cancel;
    case 'completed':
      return Icons.done_all;
    default:
      return Icons.hourglass_top;
  }
}

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF0B7A53);
    const Color cardGreen = Color(0xFF168A61);

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: mainGreen,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Requests',
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
                  .collection('booking_requests')
                  .where('customerId', isEqualTo: user.uid)
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
                      'No requests yet.',
                      style: TextStyle(
                        color: Colors.white70,
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

                    final String title =
                        (data['listingTitle'] ?? '').toString();
                    final String city = (data['city'] ?? '').toString();
                    final String county = (data['county'] ?? '').toString();
                    final String price = (data['price'] ?? '').toString();
                    final String status = (data['status'] ?? '').toString();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isEmpty ? 'Untitled Request' : title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (city.isNotEmpty)
                            Text(
                              'City: $city',
                              style: const TextStyle(color: Colors.white),
                            ),
                          if (county.isNotEmpty)
                            Text(
                              'County: $county',
                              style: const TextStyle(color: Colors.white),
                            ),
                          if (price.isNotEmpty)
                            Text(
                              'Price: $price',
                              style: const TextStyle(color: Colors.white),
                            ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: durumRengi(status.isEmpty ? 'pending' : status).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: durumRengi(status.isEmpty ? 'pending' : status),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  durumIkonu(status.isEmpty ? 'pending' : status),
                                  color: durumRengi(status.isEmpty ? 'pending' : status),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status: ${status.isEmpty ? 'pending' : status}',
                                  style: TextStyle(
                                    color: durumRengi(status.isEmpty ? 'pending' : status),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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