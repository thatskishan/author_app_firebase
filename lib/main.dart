import 'package:author_app/views/screens/home_page.dart';
import 'package:author_app/views/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        'home_page': (context) => const HomePage(),
      },
    ),
  );
}
