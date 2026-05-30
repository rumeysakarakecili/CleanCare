import 'package:flutter/material.dart';
import 'gelen_talepler_sayfasi.dart';
import 'talep_listesi_sayfasi.dart';
import 'favorilerim_sayfasi.dart';
import 'profil_sayfasi.dart';
import 'booking_menu_sayfasi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AltBarSayfasi extends StatefulWidget {
  const AltBarSayfasi({super.key});

  @override
  State<AltBarSayfasi> createState() => _AltBarSayfasiState();
}

class _AltBarSayfasiState extends State<AltBarSayfasi> {
   int seciliIndex = 0;

  final List<Widget> sayfalar = const [
    BookingMenuSayfasi(),
    GelenTaleplerSayfasi(),
    TalepListesiSayfasi(),
    FavorilerimSayfasi(),
    ProfilSayfasi(),
  ];

  Widget bildirimliIkon({
    required IconData icon,
    required Stream<QuerySnapshot>? stream,
  }) {
    if (stream == null) {
      return Icon(icon);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final bool bildirimVar =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon),
            if (bildirimVar)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: IndexedStack(
        index: seciliIndex,
        children: sayfalar,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: seciliIndex,
        onTap: (index) {
          setState(() {
            seciliIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: bildirimliIkon(
              icon: Icons.call_received,
              stream: user == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('booking_requests')
                      .where('providerId', isEqualTo: user.uid)
                      .where('providerSeen', isEqualTo: false)
                      .snapshots(),
            ),
            label: 'Incoming',
          ),
          BottomNavigationBarItem(
            icon: bildirimliIkon(
              icon: Icons.north_east,
              stream: user == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('booking_requests')
                      .where('customerId', isEqualTo: user.uid)
                      .where('customerSeen', isEqualTo: false)
                      .snapshots(),
            ),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}