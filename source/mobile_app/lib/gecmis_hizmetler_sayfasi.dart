import 'package:flutter/material.dart';

class GecmisHizmetlerSayfasi extends StatelessWidget {
  const GecmisHizmetlerSayfasi({super.key});

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
          'Past Services',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Completed services will be shown here in the future.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}