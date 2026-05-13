import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({super.key});

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();

  bool girisYapiliyor = false;

  @override
  void dispose() {
    emailController.dispose();
    sifreController.dispose();
    super.dispose();
  }

  Future<void> girisYap() async {
    final String email = emailController.text.trim();
    final String password = sifreController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
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
        girisYapiliyor = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/bookingMenu');
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Please try again.';

      if (e.code == 'user-not-found') {
        message = 'No account was found for this email address.';
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect password. Please try again.';
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
        girisYapiliyor = false;
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
          'Login',
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
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  TextField(
                    controller: sifreController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
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
                onPressed: girisYapiliyor ? null : girisYap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: mainGreen,
                ),
                child: Text(
                  girisYapiliyor ? 'Logging in...' : 'Login',
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