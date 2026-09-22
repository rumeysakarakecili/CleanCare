import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountInfoSayfasi extends StatelessWidget {
  const AccountInfoSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    const Color temaYesili = Color(0xFF0B7A53);
    const Color kartYesili = Color(0xFF168A61);

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: temaYesili,
      appBar: AppBar(
        backgroundColor: temaYesili,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Account Info',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: user == null
            ? const Center(
                child: Text(
                  'No user found.',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map<String, dynamic>?;

                  final String fullName =
                      data?['fullName'] ?? user.displayName ?? 'Unknown';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kartYesili,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.account_circle_outlined,
                          color: Colors.white,
                          size: 56,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'User Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Name Surname: $fullName',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Email: ${user.email ?? 'Unknown'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'User ID: ${user.uid}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Email Verified: ${user.emailVerified ? 'Yes' : 'No'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}