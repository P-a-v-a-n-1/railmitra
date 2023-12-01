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
            Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  _buildDashboardSection(context, 'Seat Availability by Source and Destination', 'SeatAvailabilityPage', Colors.blue),
                  SizedBox(width: 20),
                  _buildDashboardSection(context, 'Seat Availability by Train Number', 'TrainAvailabilityPage', Colors.green),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDashboardSection(context, 'FAQs', 'FAQsPage', Colors.orange),
                  SizedBox(width: 20),
                  _buildDashboardSection(context, 'About Us', 'AboutUsPage', Colors.purple),
                ],
              ),
              SizedBox(height: 20),
              _buildFeedbackSection(context, 'Feedback', 'FeedbackPage', Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSection(BuildContext context, String title, String route, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => getRoute(route),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInToLinear;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              // Add a scale transition
              var scaleAnimation = animation.drive(Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve)));

              return ScaleTransition(
                scale: scaleAnimation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: child,
                  ),
                ),
              );
            },
            transitionDuration: Duration(milliseconds: 350),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 160,
          height: 160,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Color(0xFF0077B6), Color(0xFF023E8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context, String title, String route, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => getRoute(route),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              // Add a scale transition
              var scaleAnimation = animation.drive(Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve)));

              return ScaleTransition(
                scale: scaleAnimation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: child,
                  ),
                ),
              );
            },
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: double.infinity,
          height: 160,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Color(0xFF0077B6), Color(0xFF023E8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
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
