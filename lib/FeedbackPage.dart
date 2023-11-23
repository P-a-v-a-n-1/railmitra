import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                          duration: Duration(milliseconds: 500),
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
                  onPressed: () async {
                    if (_selectedEmotionIndex == -1) {
                      // Show an error message if no emoji is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select an emoji.'),
                        ),
                      );
                    } else {
                      // Submit feedback immediately
                      await FeedbackService().submitFeedback(
                        _feedbackController.text,
                        _selectedEmotionIndex,
                      );

                      // Show the feedback submission dialog
                      _showFeedbackDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF004080),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text(
                    'Submit Feedback',

                    style: TextStyle(fontSize: 18,color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: ListTile(
              leading: _AnimatedCheckMark(),
              title: Text('Thank You!'),
            ),
            content: Text('Thank you for your feedback.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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
    print('Resetting page...');
    setState(() {
      _selectedEmotionIndex = -1;
      _feedbackController.clear();
    });
  }
}

class FeedbackService {
  final CollectionReference feedbackCollection =
  FirebaseFirestore.instance.collection('FeedBack');

  Future<void> submitFeedback(String message, int rating) async {
    try {
      await feedbackCollection.add({
        'message': message,
        'rating': rating + 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }
}

class _AnimatedCheckMark extends StatefulWidget {
  @override
  _AnimatedCheckMarkState createState() => _AnimatedCheckMarkState();
}

class _AnimatedCheckMarkState extends State<_AnimatedCheckMark>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 36.0,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: FeedbackPage(),
  ));
}
