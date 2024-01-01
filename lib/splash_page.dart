import 'dart:async';
import 'package:flutter/material.dart';
import 'loginPage.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 3), // Set the duration of your animation
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 2.5,
    ).animate(_controller);

    _controller.forward();

    Timer(
      Duration(seconds: 3), // Set the duration of your splash screen
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0.0, -100 * (1 - _animation.value)), // Adjust the offset as needed
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/chat.png', // Path to your image asset
                    width: 150, // Adjust the width as needed
                    height: 150, // Adjust the height as needed
                  ),
                  SizedBox(height: 16),
                  Text(
                    'RAILMITRA', // Add your app name or logo here
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
