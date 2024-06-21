import 'package:flutter/material.dart';

class CommunityChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Chat'),
      ),
      body: Center(
        child: Text(
          'Community Chat Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
