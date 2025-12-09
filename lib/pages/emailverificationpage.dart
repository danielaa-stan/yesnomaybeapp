import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'interestspage.dart';
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // update user token
      await user.reload();

      // double check
      if (user.emailVerified) {
        // success -> go to InterestsPage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InterestsPage()),
          );
        }
      } else {
        // Email hasn't been confirmed yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not verified yet. Please check your inbox.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4D4D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.email, size: 80, color: Color(0xFF4EE06D)),
              const SizedBox(height: 30),
              const Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'We sent a verification link to your email. Please click the link before continuing.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // status check button
              ElevatedButton(
                onPressed: _checkEmailVerified,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4EE06D),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('I HAVE VERIFIED', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),

              // resend button
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email resent!')));
                },
                child: const Text('Resend Email', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}