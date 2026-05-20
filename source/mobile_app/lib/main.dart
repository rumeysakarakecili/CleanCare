import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'filtreleme_sayfasi.dart';
import 'giris_sayfasi.dart';
import 'kayit_sayfasi.dart';
import 'booking_menu_sayfasi.dart';
import 'profil_sayfasi.dart';
import 'ilan_olusturma_sayfasi.dart';
import 'ilanlarim_sayfasi.dart';
import 'favorilerim_sayfasi.dart';
import 'mesaj_listesi_sayfasi.dart';
import 'talep_listesi_sayfasi.dart';
import 'gelen_talepler_sayfasi.dart';
import 'sifre_resetleme_sayfasi.dart';
import 'account_info_sayfasi.dart';
import 'yorumlarim_sayfasi.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CleanCareApp());
}

class CleanCareApp extends StatelessWidget {
  const CleanCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CleanCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9514),
        ),
        useMaterial3: true,
      ),
      home: const BaslangicSayfasi(),
      routes: {
        '/giris': (context) => const GirisSayfasi(),
        '/kayit': (context) => const KayitSayfasi(),
        '/bookingMenu': (context) => const BookingMenuSayfasi(),
        '/filtreleme': (context) => const FiltrelemeSayfasi(),
        '/profil': (context) => const ProfilSayfasi(),
        '/ilanOlustur': (context) => const IlanOlusturmaSayfasi(),
        '/ilanlarim': (context) => const IlanlarimSayfasi(),
        '/favorilerim': (context) => const FavorilerimSayfasi(),
        '/mesajlarim': (context) => const MesajListesiSayfasi(),
        '/taleplerim': (context) => const TalepListesiSayfasi(),
        '/gelenTalepler': (context) => const GelenTaleplerSayfasi(),
        '/sifreResetleme': (context) => const SifreResetlemeSayfasi(),     
        '/accountInfo': (context) => const AccountInfoSayfasi(),
        '/yorumlarim': (context) => const YorumlarimSayfasi(),
      },
    );
  }
}

class BaslangicSayfasi extends StatelessWidget {
  const BaslangicSayfasi({super.key});

  static const Color TemaYesil = Color(0xFF0F6B46);
  static const Color YaziRenk = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaYesil,
      body: SafeArea(
        child: Stack(
          children: [
            // Arka plan halkaları
            Positioned(
              top: 300,
              left: 20,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
             Positioned(
              top: 500,
              left: 30,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: 20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            Positioned(
              top: 350,
              left: 60,
              child: Image.asset(
                'assets/images/temizlikci.png',
                width: 180,
                height: 140,
              ),
            ),
            //Baloncuklar
            const Positioned(
              top: 160,
              left: 30,
              child: Baloncuklar(
                yazi: 'Trusted\nCleaners',
                boyut: 110,
              ),
            ),
            const Positioned(
              top: 200,
              left: 160,
              child: Baloncuklar(
                yazi: 'Ratings &\nReviews',
                boyut: 100,
              ),
            ),
            const Positioned(
              bottom: 495,
              left: 270,
              child: Baloncuklar(
                yazi: 'Secure\nPayment',
                boyut: 95,
              ),
            ),
            const Positioned(
              bottom: 380,
              right: 17,
              child: Baloncuklar(
                yazi: 'Easy\nBooking',
                boyut: 90,
              ),
            ),

            // Ana içerik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'CleanCare',
                        style: TextStyle(
                          color: YaziRenk,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Cleaning services made simple,\nfast and reliable.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.20),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome to CleanCare',
                          style: TextStyle(
                            color: YaziRenk,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Book cleaning services, manage appointments,\nand enjoy a smoother home care experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/giris');
                              }, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: TemaYesil,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/kayit');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Baloncuklar extends StatelessWidget {
  final String yazi;
  final double boyut;

  const Baloncuklar({
    super.key,
    required this.yazi,
    required this.boyut,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boyut,
      height: boyut,
      child: Stack(
        children: [
          // Ana balon gövdesi
          Container(
            width: boyut,
            height: boyut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.40),
                  Colors.white.withOpacity(0.16),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.38),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.10),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(3, 6),
                ),
              ],
            ),
          ),


          // Küçük ikinci yansıma
          Positioned(
            top: boyut * 0.20,
            left: boyut * 0.26,
            child: Container(
              width: boyut * 0.10,
              height: boyut * 0.10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.30),
              ),
            ),
          ),


          

          // Alt tarafta hafif iç parlaklık
          Positioned(
            bottom: boyut * 0.12,
            right: boyut * 0.18,
            child: Container(
              width: boyut * 0.18,
              height: boyut * 0.18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
          ),

          // Yazı
          Center(
            child: Padding(
              padding: EdgeInsets.all(boyut * 0.10),
              child: Text(
                yazi,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: boyut * 0.13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}