import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'odeme_sayfasi.dart';
import 'alt_bar_sayfasi.dart';

class TalepListesiSayfasi extends StatelessWidget {
  const TalepListesiSayfasi({super.key});

  Color durumRengi(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return const Color(0xFF22B573);
    case 'rejected':
      return const Color(0xFFE85D5D);
    case 'completed':
      return const Color(0xFF4FA3E3);
    case 'cancelled':
      return const Color(0xFF8A8A8A);
    default:
      return const Color(0xFFFFA640);
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
    const Color acikGri = Color.fromARGB(255, 204, 205, 205);
    const Color siyahYazi = Color.fromARGB(255, 6, 6, 6);
    const Color beyazYazi = Colors.white;
    const Color acikMavi = Color.fromARGB(255, 78, 118, 183);

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
                        (data['listingTitle'] ?? 'Untitled Service').toString();
                    final String city = (data['city'] ?? '').toString();
                    final String county = (data['county'] ?? '').toString();
                    final String price = (data['price'] ?? '').toString();
                    final String status = (data['status'] ?? 'pending').toString();
                    final String paymentStatus =
                        (data['paymentStatus'] ?? 'unpaid').toString();
                    final String escrowStatus =
                        (data['escrowStatus'] ?? '').toString();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                              color: durumRengi(status).withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: durumRengi(status),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  durumIkonu(status),
                                  color: durumRengi(status),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    color: durumRengi(status),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (paymentStatus == 'paid')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                escrowStatus == 'held'
                                    ? 'Payment: Paid and held'
                                    : 'Payment: Paid',
                                style: const TextStyle(
                                  color: temaYesil,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            if ((status == 'pending' || status == 'accepted') &&
                                paymentStatus != 'paid')
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final bool? confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Cancel Request'),
                                            content: const Text(
                                              'Are you sure you want to cancel this request?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: const Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text('Yes, Cancel'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirm != true) return;

                                      try {
                                        await docs[index].reference.update({
                                          'status': 'cancelled',
                                          'cancelledBy': user.uid,
                                          'cancelledAt': FieldValue.serverTimestamp(),
                                          'providerSeen': false,
                                        });

                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Request cancelled.'),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Cancel error: $e'),
                                          ),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white),
                                      backgroundColor: kartYesili,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel Request',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),

                          if (status == 'accepted' && paymentStatus != 'paid')
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OdemeSayfasi(
                                          requestId: docs[index].id,
                                          listingTitle: title,
                                          price: price,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: acikMavi,
                                    foregroundColor: beyazYazi,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Pay Now',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
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