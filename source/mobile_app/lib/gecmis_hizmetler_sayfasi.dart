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
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('booking_requests')
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

                  final docs = snapshot.data?.docs ?? [];

                  final receivedServices = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['customerId'] == user.uid;
                  }).toList();

                  final providedServices = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['providerId'] == user.uid;
                  }).toList();

                  return TabBarView(
                    children: [
                      hizmetListesi(
                        receivedServices,
                        cardGreen,
                        emptyText: 'No received services yet.',
                        isReceived: true,
                      ),
                      hizmetListesi(
                        providedServices,
                        cardGreen,
                        emptyText: 'No provided services yet.',
                        isReceived: false,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget hizmetListesi(
    List<QueryDocumentSnapshot> services,
    Color cardGreen, {
    required String emptyText,
    required bool isReceived,
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
          doc.data() as Map<String, dynamic>,
          cardGreen,
          isReceived: isReceived,
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
    Map<String, dynamic> data,
    Color cardGreen, {
    required bool isReceived,
  }) {
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
        color: cardGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (city.isNotEmpty)
            Text(
              'City: $city',
              style: const TextStyle(color: Colors.white70),
            ),
          if (county.isNotEmpty)
            Text(
              'County: $county',
              style: const TextStyle(color: Colors.white70),
            ),
          if (price.isNotEmpty)
            Text(
              'Price: $price',
              style: const TextStyle(color: Colors.white70),
            ),
          const SizedBox(height: 8),
          Text(
            isReceived
                ? 'Provider: $providerEmail'
                : 'Customer: $customerEmail',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Completed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}