import 'package:flutter/material.dart';
import 'splash_page.dart'; // Import your SplashPage
//import 'login_page.dart'; // Import the LoginPage class
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rail Mitra',
      home: SplashPage(), // Show SplashPage initially
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          // Replace with your custom hex color
          backgroundColor: Color(0xFF004080),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
