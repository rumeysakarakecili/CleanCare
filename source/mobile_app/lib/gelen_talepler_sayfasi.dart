import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'alt_bar_sayfasi.dart';

class GelenTaleplerSayfasi extends StatelessWidget {
  const GelenTaleplerSayfasi({super.key});

  Color durumRengi(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return  Color(0xFF00A651);
      case 'rejected':
        return Colors.redAccent;
      case 'completed':
        return Colors.lightBlueAccent;
      case 'cancelled':
        return Colors.grey;
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
    case 'cancelled':
      return Icons.block;  
    default:
      return Icons.hourglass_top;
  }
}

  @override
  Widget build(BuildContext context) {
    const Color temaYesil = Color(0xFF0B7A53);
    const Color kartYesili = Color(0xFF168A61);
    const Color beyazYazi =  Colors.white;
    const Color siyahYazi =  Color.fromARGB(255, 6, 6, 6);

    final user = FirebaseAuth.instance.currentUser;

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
          'Incoming Requests',
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
                  .where('providerId', isEqualTo: user.uid)
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
                      'No incoming requests yet.',
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
                    final String customerEmail =
                        (data['customerEmail'] ?? '').toString();
                    final String paymentStatus =
                        (data['paymentStatus'] ?? 'unpaid').toString();
                    final String escrowStatus =
                        (data['escrowStatus'] ?? '').toString();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: beyazYazi,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isEmpty ? 'Untitled Request' : title,
                            style: const TextStyle(
                              color: siyahYazi,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (customerEmail.isNotEmpty)
                            Text(
                              'Customer: $customerEmail',
                              style: const TextStyle(color: siyahYazi),
                            ),
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
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'Status: ${status.isEmpty ? 'pending' : status}',
                              style: TextStyle(
                                color: durumRengi(status.isEmpty ? 'pending' : status),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (paymentStatus == 'paid')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                escrowStatus == 'held'
                                    ? 'Payment received and held.'
                                    : 'Payment received.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          if ((status.isEmpty ? 'pending' : status) == 'accepted' &&
                              paymentStatus != 'paid')
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Waiting for customer payment.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          if ((status.isEmpty ? 'pending' : status) == 'pending') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await docs[index].reference.update({
                                          'status': 'accepted',
                                          'customerSeen': false,
                                        });

                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Request accepted.'),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Update error: $e'),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: temaYesil,
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await docs[index].reference.update({
                                          'status': 'rejected',
                                          'customerSeen': false,
                                        });

                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Request rejected.'),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Update error: $e'),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ),
                              ],
                            ),
                            ] else if ((status.isEmpty ? 'pending' : status) == 'accepted' &&
                                paymentStatus == 'paid') ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await docs[index].reference.update({
                                        'status': 'completed',
                                        'customerSeen': false,
                                      });

                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request marked as completed.'),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Update error: $e'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black26,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Mark as Completed'),
                                ),
                              ),
                            ],
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