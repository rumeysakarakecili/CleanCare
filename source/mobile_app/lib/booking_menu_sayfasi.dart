import 'package:flutter/material.dart';

class BookingMenuSayfasi extends StatelessWidget {
  const BookingMenuSayfasi({super.key});

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
              Navigator.pushNamed(context, '/profil');
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                    'Create a booking by selecting date, time, address and price range.',
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
          ],
        ),
      ),
    );
  }
}