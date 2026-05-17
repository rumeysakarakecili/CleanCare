import 'package:flutter/material.dart';

class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});

  void yakindaGelecek(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$title feature will be added later.'),
    ),
  );
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
              yakindaGelecek(context, '/hesapBilgileri');
            },
          ),
          menuKutusu('Past Services', kartYesili),
          menuKutusu(
            'My Listings',
            kartYesili,
            onTap: () {
              Navigator.pushNamed(context, '/ilanlarim');
            },
          ),
          menuKutusu(
            'My Requests',
            kartYesili,
            onTap: () {
              Navigator.pushNamed(context, '/taleplerim');
            },
          ),
          menuKutusu(
            'Incoming Requests',
            kartYesili,
            onTap: () {
              Navigator.pushNamed(context, '/gelenTalepler');
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
            'Past Services',
            kartYesili,
            onTap: () {
              yakindaGelecek(context, '/gecmisHizmetler');
            },
          ),

          menuKutusu(
            'Reviews',
            kartYesili,
            onTap: () {
              yakindaGelecek(context, '/yorumlar');
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
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}