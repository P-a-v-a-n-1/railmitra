import 'package:flutter/material.dart';
import 'dart:ui';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController _feedbackController = TextEditingController();
  int _selectedEmotionIndex = -1; // Default: no emoji selected

  // Define a list of emoji icons representing emotions
  final List<String> _emojiList = ['🙁', '😐', '😐', '😊', '😄'];

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
                      // Show the feedback submission dialog
                      _showFeedbackDialog();
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

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: Text('Thank You!'),
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
