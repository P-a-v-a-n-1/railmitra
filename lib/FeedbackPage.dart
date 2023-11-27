import 'package:flutter/material.dart';
import 'dart:ui';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with SingleTickerProviderStateMixin {
  TextEditingController _feedbackController = TextEditingController();
  int _selectedEmotionIndex = -1; // Default: no emoji selected
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Define a list of emoji icons representing emotions
  final List<String> _emojiList = ['😟','🙁', '😐', '😊', '😄'];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200), // Adjust the duration as needed
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Your opinion matters!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _emojiList.length; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmotionIndex = i;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          transform: Matrix4.identity()
                            ..scale((i == _selectedEmotionIndex) ? 1.2 : 1.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _emojiList[i],
                              style: TextStyle(
                                fontSize: 36,
                                color: i == _selectedEmotionIndex
                                    ? Color(0xFF004080)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Share your thoughts',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedEmotionIndex == -1) {
                      // Show an error message if no emoji is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select an emoji.'),
                        ),
                      );
                    } else {
                      // Show the feedback submission dialog with animation
                      _showFeedbackDialogWithAnimation();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF004080),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text(
                    'Submit Feedback',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialogWithAnimation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _animationController.reset();
        _animationController.forward();

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: Row(
              children: [
                Text('Thank You!'),
                SizedBox(width: 10),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Text('✅', style: TextStyle(fontSize: 24, color: Colors.green)),
                    );
                  },
                ),
              ],
            ),
            content: Text('Thank you for your feedback.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Reset the page state when the user clicks OK
                  Navigator.of(context).pop();
                  _resetPage();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetPage() {
    // Reset the state of the page
    setState(() {
      _selectedEmotionIndex = -1;
      _feedbackController.clear();
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: FeedbackPage(),
  ));
}
