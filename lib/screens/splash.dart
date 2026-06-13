import 'dart:async';
import 'package:flutter/material.dart';

/// ================== CONSTANTS ==================
const Color kPrimaryColor = Color(0xFF6C5CE7);

/// ================== SPLASH SCREEN ==================
class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/sign_in");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// GIF BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/my.gif",
              fit: BoxFit.fitWidth,
            ),
          ),

          /// CONTENT ON TOP
          const Scaffold(
            backgroundColor: Colors.transparent,
            body: AppBy(),
          ),
        ],
      ),
    );
  }
} // ✅ THIS BRACE WAS MISSING


/// ================== APP BY ==================
class AppBy extends StatelessWidget {
  const AppBy({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "By",
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Momina & Safa",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}