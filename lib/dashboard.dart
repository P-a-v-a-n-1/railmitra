import 'package:flutter/material.dart';
import 'SeatAvailabilityPage.dart';
import 'TrainAvailabilityPage.dart';
import 'FAQsPage.dart';
import 'AboutUsPage.dart';
import 'FeedbackPage.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(child: Container()),
            Text('Dashboard'),
            Expanded(child: Container()),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDashboardSection(context, 'Seat Availability by Source and Destination', 'SeatAvailabilityPage'),
                  SizedBox(width: 10),
                  _buildDashboardSection(context, 'Seat Availability by Train Number', 'TrainAvailabilityPage'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDashboardSection(context, 'FAQs', 'FAQsPage'),
                  SizedBox(width: 10),
                  _buildDashboardSection(context, 'About Us', 'AboutUsPage'),
                ],
              ),
              SizedBox(height: 10),
              _buildFeedbackSection(context, 'Feedback', 'FeedbackPage'),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildDashboardSection(BuildContext context, String title, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => getRoute(route)));
      },
      child: Container(
        width: 150,
        height: 150,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF004080),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context, String title, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => getRoute(route)));
      },
      child: Container(
        width: 300,
        height: 150,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF004080),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget getRoute(String route) {
    switch (route) {
      case 'SeatAvailabilityPage':
        return SeatAvailabilityPage();
      case 'TrainAvailabilityPage':
        return TrainAvailabilityPage();
      case 'FAQsPage':
        return FAQsPage();
      case 'AboutUsPage':
        return AboutUsPage();
      case 'FeedbackPage':
        return FeedbackPage();
      default:
        return SeatAvailabilityPage();
    }
  }
}
