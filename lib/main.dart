import 'package:flutter/material.dart';
import 'loginPage.dart'; // Import the LoginPage class
import 'package:flutter/material.dart';
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
      home: LoginPage(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Color(0xFF004080), // Replace with your custom hex color
        ),
      ),
    );
  }
}
