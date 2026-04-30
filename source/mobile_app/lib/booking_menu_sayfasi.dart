import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mesaj_sayfasi.dart';

class BookingMenuSayfasi extends StatefulWidget {
  const BookingMenuSayfasi({super.key});

  @override
  State<BookingMenuSayfasi> createState() => _BookingMenuSayfasiState();
}

class _BookingMenuSayfasiState extends State<BookingMenuSayfasi> {
  List<Map<String, dynamic>> tumIlanlar = [];
  List<Map<String, dynamic>> gosterilenIlanlar = [];
  bool yukleniyor = false;
  Set<String> favoriIlanIdleri = {};

  String? secilenSehir;
  String? secilenIlce;
  String? secilenSiralama;

  Map<String, List<String>> addressData = {};

  final List<String> siralamaSecenekleri = [
    'A to Z',
    'Z to A',
    'Price Low to High',
    'Price High to Low',
  ];

  List<String> get cities => addressData.keys.toList();

  List<String> get districts {
    if (secilenSehir == null) return [];
    return addressData[secilenSehir!] ?? [];
  }

  @override
  void initState() {
    super.initState();
    adresVerileriniYukle();
    ilanlariGetir();
    favorileriGetir();
  }
  Future<void> adresVerileriniYukle() async {
  final String jsonString =
      await rootBundle.loadString('assets/data/il_ilce.json');

  final Map<String, dynamic> jsonData = json.decode(jsonString);

  final Map<String, List<String>> loadedData = {};

  jsonData.forEach((city, districts) {
    loadedData[city] = List<String>.from(districts as List);
  });

  setState(() {
    addressData = loadedData;
  });
}

Future<void> ilanlariGetir() async {
  try {
    setState(() {
      yukleniyor = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('listings')
        .where('isActive', isEqualTo: true)
        .get();

    final ilanlar = snapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id;
      return data;
    }).toList();

    ilanlar.shuffle(Random());

    setState(() {
      tumIlanlar = List<Map<String, dynamic>>.from(ilanlar);
      gosterilenIlanlar = List<Map<String, dynamic>>.from(ilanlar);
    });
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading listings: $e'),
      ),
    );
  } finally {
    if (!mounted) return;
    setState(() {
      yukleniyor = false;
    });
  }
}

int fiyatDegeri(dynamic price) {
  final text = (price ?? '').toString();
  return int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

void filtreVeSirala() {
  List<Map<String, dynamic>> sonuc = List.from(tumIlanlar);

  if (secilenSehir != null && secilenSehir!.isNotEmpty) {
    sonuc = sonuc.where((ilan) => ilan['city'] == secilenSehir).toList();
  }

  if (secilenIlce != null && secilenIlce!.isNotEmpty) {
    sonuc = sonuc.where((ilan) => ilan['county'] == secilenIlce).toList();
  }

  switch (secilenSiralama) {
    case 'A to Z':
      sonuc.sort((a, b) => (a['title'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((b['title'] ?? '').toString().toLowerCase()));
      break;
    case 'Z to A':
      sonuc.sort((a, b) => (b['title'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((a['title'] ?? '').toString().toLowerCase()));
      break;
    case 'Price Low to High':
      sonuc.sort((a, b) =>
          fiyatDegeri(a['price']).compareTo(fiyatDegeri(b['price'])));
      break;
    case 'Price High to Low':
      sonuc.sort((a, b) =>
          fiyatDegeri(b['price']).compareTo(fiyatDegeri(a['price'])));
      break;
  }

  setState(() {
    gosterilenIlanlar = sonuc;
  });
}
  Future<void> favorileriGetir() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      final ids = snapshot.docs
          .map((doc) => (doc.data()['listingId'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();

      setState(() {
        favoriIlanIdleri = ids;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading favorites: $e'),
        ),
      );
    }
  }

  Future<void> favoriToggle(Map<String, dynamic> ilan) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final String listingId = (ilan['docId'] ?? '').toString();
  if (listingId.isEmpty) return;

  try {
    final mevcutFavori = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('listingId', isEqualTo: listingId)
        .get();

    if (mevcutFavori.docs.isNotEmpty) {
      for (final doc in mevcutFavori.docs) {
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(doc.id)
            .delete();
      }

      setState(() {
        favoriIlanIdleri.remove(listingId);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites.'),
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': user.uid,
        'userEmail': user.email,
        'listingId': listingId,
        'title': ilan['title'],
        'description': ilan['description'],
        'city': ilan['city'],
        'county': ilan['county'],
        'price': ilan['price'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        favoriIlanIdleri.add(listingId);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to favorites.'),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Favorite error: $e'),
      ),
    );
  }
}

Future<void> bookingTalebiGonder(Map<String, dynamic> ilan) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    await FirebaseFirestore.instance.collection('booking_requests').add({
      'listingId': ilan['docId'],
      'listingTitle': ilan['title'],
      'providerId': ilan['createdBy'],
      'providerEmail': ilan['createdByEmail'],
      'customerId': user.uid,
      'customerEmail': user.email,
      'city': ilan['city'],
      'county': ilan['county'],
      'price': ilan['price'],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking request sent.'),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request error: $e'),
      ),
    );
  }
}

Future<void> mesajBaslat(Map<String, dynamic> ilan) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final providerId = (ilan['createdBy'] ?? '').toString();
  final providerEmail = (ilan['createdByEmail'] ?? '').toString();
  final listingId = (ilan['docId'] ?? '').toString();
  final listingTitle = (ilan['title'] ?? '').toString();

  if (providerId.isEmpty || listingId.isEmpty) return;

  try {
    final members = [user.uid, providerId]..sort();
    final chatId = '${members[0]}_${listingId}_${members[1]}';

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.set({
      'listingId': listingId,
      'listingTitle': listingTitle,
      'members': members,
      'memberEmails': [user.email, providerEmail],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MesajSayfasi(
          chatId: chatId,
          listingTitle: listingTitle,
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message error: $e'),
      ),
    );
  }
}

Widget buildDropdown({
  required String hint,
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
  Color color = const Color(0xFF168A61),
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        dropdownColor: color,
        isExpanded: true,
        hint: Text(
          hint,
          style: const TextStyle(color: Colors.white70),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
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
        title: const Text(
          'Booking Menu',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mesajlarim');
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
              ),
            ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profil');
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
         body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kartYesili,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Home Cleaning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Browse listings, filter them, and create a booking.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/filtreleme');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: temaYesil,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ilanOlustur');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kartYesili,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Create Listing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            buildDropdown(
              hint: 'Select a city',
              value: secilenSehir,
              items: cities,
              onChanged: (value) {
                setState(() {
                  secilenSehir = value;
                  secilenIlce = null;
                });
                filtreVeSirala();
              },
              color: kartYesili,
            ),

            const SizedBox(height: 12),

            buildDropdown(
              hint: 'Select a county',
              value: secilenIlce,
              items: districts,
              onChanged: (value) {
                setState(() {
                  secilenIlce = value;
                });
                filtreVeSirala();
              },
              color: kartYesili,
            ),

            const SizedBox(height: 12),

            buildDropdown(
              hint: 'Sort listings',
              value: secilenSiralama,
              items: siralamaSecenekleri,
              onChanged: (value) {
                setState(() {
                  secilenSiralama = value;
                });
                filtreVeSirala();
              },
              color: kartYesili,
            ),
            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Existing Listings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (yukleniyor)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (gosterilenIlanlar.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kartYesili,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'No listings available right now.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              Column(
                children: gosterilenIlanlar.map((ilan) {
                  final String title = (ilan['title'] ?? '').toString();
                  final String description = (ilan['description'] ?? '').toString();
                  final String city = (ilan['city'] ?? '').toString();
                  final String county = (ilan['county'] ?? '').toString();
                  final String price = (ilan['price'] ?? '').toString();

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kartYesili,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title.isEmpty ? 'Untitled Listing' : title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              favoriToggle(ilan);
                            },
                            icon: Icon(
                              favoriIlanIdleri.contains((ilan['docId'] ?? '').toString())
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                                              const SizedBox(height: 8),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        const SizedBox(height: 10),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    mesajBaslat(ilan);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: kartYesili,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Message',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    bookingTalebiGonder(ilan);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: temaYesil,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Request Booking',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}