import 'package:flutter/material.dart';
import 'account_info_sayfasi.dart';
import 'gecmis_hizmetler_sayfasi.dart';
import 'ilanlarim_sayfasi.dart';

class MenuSayfasi extends StatelessWidget {
  const MenuSayfasi({super.key});

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
          'Menu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          menuKutusu(
            context,
            'Account Info',
            kartYesili,
            const AccountInfoSayfasi(),
          ),
          menuKutusu(
            context,
            'Past Services',
            kartYesili,
            const GecmisHizmetlerSayfasi(),
          ),
          menuKutusu(
            context,
            'My Listings',
            kartYesili,
            const IlanlarimSayfasi(),
          ),
        ],
      ),
    );
  }

  Widget menuKutusu(
    BuildContext context,
    String baslik,
    Color renk,
    Widget sayfa,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: renk,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => sayfa,
            ),
          );
        },
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