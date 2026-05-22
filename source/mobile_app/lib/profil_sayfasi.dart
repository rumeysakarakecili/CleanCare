import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});

  void yakindaGelecek(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$title feature will be added later.'),
    ),
  );
}

  Future<void> gelenTalepBildirimleriniTemizle() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('booking_requests')
      .where('providerId', isEqualTo: user.uid)
      .where('providerSeen', isEqualTo: false)
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({
      'providerSeen': true,
    });
  }
}

Future<void> kendiTalepBildirimleriniTemizle() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('booking_requests')
      .where('customerId', isEqualTo: user.uid)
      .where('customerSeen', isEqualTo: false)
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({
      'customerSeen': true,
    });
  }
}

  @override
  Widget build(BuildContext context) {
    const Color temaYesil = Color(0xFF0B7A53);
    const Color kartYesili = Color(0xFF168A61);

    return Scaffold(
      backgroundColor: temaYesil,
      appBar: AppBar(
        backgroundColor: temaYesil,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          menuKutusu(
            'Account Info',
            kartYesili,
            onTap: () {
              Navigator.pushNamed(context, '/accountInfo');
            },
          ),
          menuKutusu(
            'Past Services',
            kartYesili,
            onTap: () {
              Navigator.pushNamed(context, '/gecmisHizmetler');
            },
          ),
          menuKutusu(
            'My Listings',
            kartYesili,
            onTap: () {
              Navigator.pushNamed(context, '/ilanlarim');
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseAuth.instance.currentUser == null
                ? null
                : FirebaseFirestore.instance
                    .collection('booking_requests')
                    .where(
                      'customerId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .where(
                      'customerSeen',
                      isEqualTo: false,
                    )
                    .snapshots(),
            builder: (context, snapshot) {
              final bool hasNotification =
                  snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return menuKutusu(
                'My Requests',
                kartYesili,
                bildirimVar: hasNotification,
                onTap: () async {
                  await kendiTalepBildirimleriniTemizle();

                  if (!context.mounted) return;

                  Navigator.pushNamed(context, '/taleplerim');
                },
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseAuth.instance.currentUser == null
                ? null
                : FirebaseFirestore.instance
                    .collection('booking_requests')
                    .where(
                      'providerId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .where(
                      'providerSeen',
                      isEqualTo: false,
                    )
                    .snapshots(),
            builder: (context, snapshot) {
              final bool hasNotification =
                  snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return menuKutusu(
                'Incoming Requests',
                kartYesili,
                bildirimVar: hasNotification,
                onTap: () async {
                  await gelenTalepBildirimleriniTemizle();

                  if (!context.mounted) return;

                  Navigator.pushNamed(context, '/gelenTalepler');
                },
              );
            },
          ),
          menuKutusu(
            'Favorites',
            kartYesili,
            onTap: () {
              Navigator.pushNamed(context, '/favorilerim');
            },
          ),
        menuKutusu(
          'Reviews',
          kartYesili,
          onTap: () {
            Navigator.pushNamed(context, '/yorumlarim');
          },
        ),
      ],
              ),
    );
  }

  Widget menuKutusu(
    String baslik,
    Color renk, {
    VoidCallback? onTap,
    bool bildirimVar = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: renk,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          baslik,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bildirimVar)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}