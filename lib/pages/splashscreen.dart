import 'package:flutter/material.dart';
import 'dart:async';
import 'signuppage.dart';
import 'package:yesnomaybeapp/widget_tree.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to signup page after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WidgetTree()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark teal background color
      backgroundColor: const Color(0xFF1A4D4D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom painted geometric shapes
            SizedBox(
              width: 400,
              height: 700,
              child: Stack(
                children: [
                  // Large purple circle at bottom
                  Positioned(
                    top: 250,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8A6D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Yellow-green semi-circle at top
                  Positioned(
                    left: 105,
                    bottom: 370,
                    child: Transform.rotate(
                      angle: 1.1,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topRight,
                          widthFactor: 0.5,
                          heightFactor: 1.0,
                          child: Container(
                            width: 350,
                            height: 350,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCEF45E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Small green circle on the right
                  Positioned(
                    right: 0,
                    top: 165,
                    child: Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4EE06D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // App name text with custom font style
            const Text(
              'YesNoMaybe',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'cursive', // You can change this to your preferred font
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}