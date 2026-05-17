import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SifreResetlemeSayfasi extends StatefulWidget {
  const SifreResetlemeSayfasi({super.key});

  @override
  State<SifreResetlemeSayfasi> createState() => _SifreResetlemeSayfasiState();
}

class _SifreResetlemeSayfasiState extends State<SifreResetlemeSayfasi> {
  final TextEditingController emailController = TextEditingController();

  bool gonderiliyor = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sifreSifirlamaMailiGonder() async {
  final String email = emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your email address.'),
      ),
    );
    return;
  }

  if (!email.contains('@') || !email.contains('.')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid email address.'),
      ),
    );
    return;
  }

  try {
    setState(() {
      gonderiliyor = true;
    });

    final userCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userCheck.docs.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No account was found for this email address.'),
        ),
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A password reset link has been sent to your email address.',
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/giris');
  } on FirebaseAuthException catch (e) {
    String message = 'Password reset failed. Please try again.';

    if (e.code == 'user-not-found') {
      message = 'No account was found for this email address.';
    } else if (e.code == 'invalid-email') {
      message = 'Please enter a valid email address.';
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
      gonderiliyor = false;
    });
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
          'Forgot Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Enter your email address and we will send you a password reset link.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Email',
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
                onPressed:
                    gonderiliyor ? null : sifreSifirlamaMailiGonder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: mainGreen,
                ),
                child: Text(
                  gonderiliyor ? 'Sending...' : 'Send Reset Link',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}