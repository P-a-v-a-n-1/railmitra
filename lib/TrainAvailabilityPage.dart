import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainAvailabilityPage extends StatefulWidget {
  @override
  _TrainAvailabilityPageState createState() => _TrainAvailabilityPageState();
}

class _TrainAvailabilityPageState extends State<TrainAvailabilityPage> {
  TextEditingController _trainNumberController = TextEditingController();
  String _trainNumber = '';
  String _trainName = ''; // New variable to store the train name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seat Availability by Train Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInputField('Enter Train Number', _trainNumberController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _fetchTrainDetails();
              },
              child: Text('Get Train Details'),
            ),
            SizedBox(height: 20),
            if (_trainNumber.isNotEmpty && _trainName.isNotEmpty) // Show only if both are not empty
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Train Details:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.blue,
                            child: Text(
                              '$_trainNumber',
                              style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.w900),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ' $_trainName',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _fetchTrainDetails() async {
    String trainNumber = _trainNumberController.text.trim();

    if (trainNumber.isNotEmpty) {
      try {
        CollectionReference trainsCollection = FirebaseFirestore.instance.collection('Trains');

        // Print the train number for debugging
        print('Fetching details for train number: $trainNumber');

        DocumentSnapshot snapshot = await trainsCollection.doc(trainNumber).get();

        if (snapshot.exists) {
          setState(() {
            _trainNumber = trainNumber; // Assign the train number to the variable
            _trainName = snapshot['name']; // Fetch and assign the train name
          });
        } else {
          // Handle the case when the document for the given train number does not exist
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Train Not Found'),
                content: Text('No train found for the given number.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Error fetching train details: $e');
        // Handle the error
      }
    } else {
      // Handle the case when the user did not provide a train number
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Invalid Train Number'),
            content: Text('Please enter a valid train number.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: TrainAvailabilityPage(),
  ));
}
