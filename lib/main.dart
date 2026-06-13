import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_vs/routes.dart';
import 'package:flutter_application_vs/screens/splash.dart';

import 'firebase_options.dart';

/// ================== MAIN ==================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

/// ================== APP ROOT ==================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Lost and Found',

      /// START FROM SPLASH (YOU KEEP THIS)
      home: const SplashScreen(),

      /// ROUTES SYSTEM (you already have it)
      routes: routes,

      /// OPTIONAL (recommended for clean navigation debugging)
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
    );
  }
}