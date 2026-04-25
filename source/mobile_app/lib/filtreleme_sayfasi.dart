import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FiltrelemeSayfasi extends StatefulWidget {
  const FiltrelemeSayfasi({super.key});

  @override
  State<FiltrelemeSayfasi> createState() => Filtreleme();
}

class Filtreleme extends State<FiltrelemeSayfasi> {
  DateTime? secilenTarih;
  String? secilenSaat;
  String? secilenSehir;
  String? secilenIlce;
  String? fiyatAraligi;

  bool secilenleriGoster = false;
  bool kaydediliyor = false;

  final TextEditingController adresKontrol =
      TextEditingController();

  final DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  late final List<DateTime> aylar = [
    DateTime(today.year, today.month, 1),
    DateTime(today.year, today.month + 1, 1),
    DateTime(today.year, today.month + 2, 1),
  ];

  final List<String> saatler = List.generate(
    19,
    (index) {
      final hour = (6 + index) % 24;
      return '${hour.toString().padLeft(2, '0')}.00';
    },
  );

  Map<String, List<String>> addressData = {
    
  };
  final List<String> fiyatAralik = [
    '₺0 - ₺1000',
    '₺1000 - ₺3000',
    '₺3000 - ₺4000',
    '₺5000+',
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
  }

  @override
  void dispose() {
    adresKontrol.dispose();
    super.dispose();
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
  Future<void> bookingKaydet() async {
  if (secilenTarih == null ||
      secilenSaat == null ||
      secilenSehir == null ||
      secilenIlce == null ||
      fiyatAraligi == null ||
      adresKontrol.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in all booking fields.'),
      ),
    );
    return;
  }

  try {

    print("BOOKING KAYDET BASLADI");

    if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
     print("BOOKING ICIN FIREBASE INIT TAMAM");
     
    }
    setState(() {
      kaydediliyor = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user?.uid,
      'userEmail': user?.email,
      'date': Timestamp.fromDate(secilenTarih!),
      'dateText': tarihGuncelleme(secilenTarih!),
      'time': secilenSaat,
      'city': secilenSehir,
      'county': secilenIlce,
      'addressDescription': adresKontrol.text.trim(),
      'priceRange': fiyatAraligi,
      'serviceType': 'Home Cleaning',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking saved successfully.'),
      ),
    );

    setState(() {
      secilenTarih = null;
      secilenSaat = null;
      secilenSehir = null;
      secilenIlce = null;
      fiyatAraligi = null;
      secilenleriGoster = false;
      adresKontrol.clear();
    });
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
      ),
    );
  } finally {
    if (!mounted) return;

    setState(() {
      kaydediliyor = false;
    });
  }
}

  String ayAdi(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String kisaAyAdi(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String gunAdi(int weekday) {
    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return days[weekday - 1];
  }

  String tarihGuncelleme(DateTime date) {
    return '${gunAdi(date.weekday)}, ${date.day} ${kisaAyAdi(date.month)} ${date.year}';
  }

  List<DateTime> daysInMonth(DateTime monthDate) {
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0);
    final List<DateTime> days = [];

    for (int day = 1; day <= lastDay.day; day++) {
      final current = DateTime(monthDate.year, monthDate.month, day);

      if (monthDate.month == today.month &&
          monthDate.year == today.year &&
          current.isBefore(today)) {
        continue;
      }

      days.add(current);
    }

    return days;
  }

  void showDatePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B7A53),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: SizedBox(
            height: 520,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Select a date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: aylar
                      .map((month) => Tab(text: ayAdi(month.month)))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: aylar.map((month) {
                      final monthDays = daysInMonth(month);

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          itemCount: monthDays.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.25,
                          ),
                          itemBuilder: (context, index) {
                            final date = monthDays[index];
                            final isSelected =
                                secilenTarih != null &&
                                secilenTarih!.year == date.year &&
                                secilenTarih!.month == date.month &&
                                secilenTarih!.day == date.day;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  secilenTarih = date;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      gunAdi(date.weekday),
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF0B7A53)
                                            : Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF0B7A53)
                                            : Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showTimePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B7A53),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: 500,
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Select the time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: saatler.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.1,
                    ),
                    itemBuilder: (context, index) {
                      final time = saatler[index];
                      final isSelected = secilenSaat == time;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            secilenSaat = time;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0B7A53)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF168A61),
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
    const Color mainGreen = Color(0xFF0B7A53);
    const Color cardGreen = Color(0xFF168A61);

    return Scaffold(
      backgroundColor: mainGreen,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Home Cleaning',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Select the date, time, address, and budget range',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: showDatePickerSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          secilenTarih == null
                              ? 'Select a date'
                              : tarihGuncelleme(secilenTarih!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: showTimePickerSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          secilenSaat == null
                              ? 'Select the time'
                              : secilenSaat!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              buildDropdown(
                hint: 'Select a city',
                value: secilenSehir,
                items: cities,
                onChanged: (value) {
                  setState(() {
                    secilenSehir = value;
                    secilenIlce = null;
                  });
                },
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
                },
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                  ),
                ),
                child: TextField(
                  controller: adresKontrol,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter the address description',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Price range',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: fiyatAralik.map((range) {
                  final isSelected = fiyatAraligi == range;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        fiyatAraligi = range;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.14),
                        ),
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          color: isSelected ? mainGreen : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      secilenleriGoster = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: mainGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'List the selected ones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (secilenleriGoster)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Date: ${secilenTarih == null ? 'not selected' : tarihGuncelleme(secilenTarih!)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Time: ${secilenSaat ?? 'not selected'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'City: ${secilenSehir ?? 'not selected'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'County: ${secilenIlce ?? 'not selected'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Address description: ${adresKontrol.text.isEmpty ? 'could not be entered' : adresKontrol.text}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Price range: ${fiyatAraligi ?? 'not selected'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: kaydediliyor ? null : bookingKaydet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: mainGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              kaydediliyor ? 'Saving...' : 'Confirm Booking',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}