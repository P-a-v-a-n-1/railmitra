import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  final Color highlightColor = Color(0xFF004080);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'About Rail Mitra',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004080),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to Rail Mitra – your trusted companion for a seamless and enjoyable train travel experience! At Rail Mitra, we are dedicated to providing you with a user-friendly platform that simplifies your journey from login to destination.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'What Sets Rail Mitra Apart:',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: highlightColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Real-Time Updates: Rail Mitra delivers up-to-the-minute information on seat availability based on source, destination, and train number, ensuring you have the latest details for a smooth trip.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'User-Friendly Interface: Designed with you in mind, Rail Mitra\'s intuitive interface makes navigating through the various features a breeze, giving you quick access to the information you need.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 10),
              Text(
                'Transparent and Reliable: Trust is paramount in travel planning. With Rail Mitra, you can rely on accurate data sourced directly from the railway database. We believe in transparency, providing you with the most reliable information to plan your journey confidently.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Our Mission:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: highlightColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Our mission at Rail Mitra is to simplify and enhance your train travel experience. Whether you\'re a seasoned traveler or embarking on your first journey, we\'re here to make the process straightforward, informative, and enjoyable.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Contact Rail Mitra:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: highlightColor,
                ),
              ),
              SizedBox(height: 10),
              buildClickableEmailText(context, 'Have questions, suggestions, or feedback? We value your input! Contact us at railmitra2@gmail.com.'),
              SizedBox(height: 20),
              Text(
                'Thank you for choosing Rail Mitra. We look forward to being your trusted partner on your travel adventures!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildClickableEmailText(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        // Handle the action you want when the email is clicked
        // For example, you can open the default email app
      },
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: highlightColor, decoration: TextDecoration.underline),
      ),
    );
  }
}
