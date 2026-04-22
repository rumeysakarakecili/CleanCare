import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'booking_menu_sayfasi.dart';

class KayitSayfasi extends StatefulWidget {
  const KayitSayfasi({super.key});

  @override
   State<KayitSayfasi> createState() => _KayitSayfasiState();
}
class _KayitSayfasiState extends State<KayitSayfasi> {
  final TextEditingController adSoyadController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();

  @override
  void dispose() {
    adSoyadController.dispose();
    emailController.dispose();
    sifreController.dispose();
    super.dispose();
  }

  Future<void> kayitOlustur() async {
  try {
    print("KAYIT BAŞLADI");

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("KAYIT ICIN FIREBASE INIT TAMAM");
    }

    final FirebaseAuth auth = FirebaseAuth.instance;

    await auth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: sifreController.text.trim(),
    );

    print("KAYIT BASARILI");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingMenuSayfasi(),
      ),
    );
  } catch (e) {
    print("GENEL HATA: $e");
  }
}

   @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF0B7A53);
    const Color cardGreen = Color(0xFF168A61);

    return Scaffold(
      backgroundColor: mainGreen,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: adSoyadController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(color: Colors.white24),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(color: Colors.white24),
                  TextField(
                    controller: sifreController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  kayitOlustur();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: mainGreen,
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}