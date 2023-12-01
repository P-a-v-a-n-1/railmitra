import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SeatAvailabilityPage extends StatefulWidget {
  @override
  _SeatAvailabilityPageState createState() => _SeatAvailabilityPageState();
}

class _SeatAvailabilityPageState extends State<SeatAvailabilityPage> {
  DateTime? _selectedDate;
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seat Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInputField('From Station', _fromController),
            SizedBox(height: 20),
            _buildInputField('To Station', _toController),
            SizedBox(height: 20),
            _buildDateInputField(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateToAvailabilityPage();
              },
              child: Text('Check Availability'),
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

  Widget _buildDateInputField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Journey',
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
        ),
        child: Text(
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : '',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _navigateToAvailabilityPage() {
    if (_selectedDate != null && _fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatAvailabilityDisplayPage(
            selectedDate: _selectedDate,
            sourceStation: _fromController.text,
            destinationStation: _toController.text,
          ),
        ),
      );
    } else {
      // Handle the case when _selectedDate, source station, or destination station is null or empty
      // You might want to show a message or take appropriate action
    }
  }
}

class SeatAvailabilityDisplayPage extends StatelessWidget {
  final DateTime? selectedDate;
  final String sourceStation;
  final String destinationStation;

  SeatAvailabilityDisplayPage({
    Key? key,
    required this.selectedDate,
    required this.sourceStation,
    required this.destinationStation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchSeatAvailabilityInfo(selectedDate, sourceStation, destinationStation),
      builder: (context, AsyncSnapshot<List<TrainAvailability>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Seat Availability'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Seat Availability'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          List<TrainAvailability> trainAvailabilityList = snapshot.data ?? [];

          return Scaffold(
            appBar: AppBar(
              title: Text('Seat Availability'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seat Availability for ${selectedDate != null ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'No Date Selected'}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Trains from $sourceStation to $destinationStation:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (trainAvailabilityList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: trainAvailabilityList.map((trainAvailability) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Train Number: ${trainAvailability.trainNumber}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Train Name: ${trainAvailability.trainName}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'General Seats Available: ${trainAvailability.generalSeatsAvailable}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'AC Seats Available: ${trainAvailability.acSeatsAvailable}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Sleeper Seats Available: ${trainAvailability.sleeperSeatsAvailable}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    )
                  else
                    Text('No available trains for the selected route and date.'),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<TrainAvailability>> fetchSeatAvailabilityInfo(
      DateTime? selectedDate,
      String sourceStation,
      String destinationStation,
      ) async {
    try {
      CollectionReference trainsCollection = FirebaseFirestore.instance.collection('Trains');

      // Format the selected date to match the Firestore document key
      String formattedDate = selectedDate != null
          ? "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
          : "";

      // Query availability based on date and stations
      DocumentSnapshot snapshot = await trainsCollection.doc(formattedDate).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        print('Data from Firestore: $data');

        List<TrainAvailability> trainAvailabilityList = [];

        // Extract train availability information
        data['Trains']?.forEach((trainNumber, trainData) {
          print('Checking train: $trainNumber');

          if (trainData['schedule'] != null &&
              trainData['schedule'].contains(sourceStation) &&
              trainData['schedule'].contains(destinationStation)) {
            print('Found matching train: $trainNumber');

            trainAvailabilityList.add(
              TrainAvailability(
                trainNumber: trainNumber,
                trainName: trainData['trainName'],
                generalSeatsAvailable: trainData['genSeats'][0] ?? 0,
                acSeatsAvailable: trainData['genSeats'][1] ?? 0,
                sleeperSeatsAvailable: trainData['genSeats'][2] ?? 0,
              ),
            );
          }
        });

        return trainAvailabilityList;
      } else {
        print('No document found for date: $formattedDate');
        return [];
      }
    } catch (e) {
      print('Error fetching seat availability info: $e');
      throw 'Error fetching seat availability info';
    }
  }


}

class TrainAvailability {
  final String trainNumber;
  final String trainName;
  final int generalSeatsAvailable;
  final int acSeatsAvailable;
  final int sleeperSeatsAvailable;

  TrainAvailability({
    required this.trainNumber,
    required this.trainName,
    required this.generalSeatsAvailable,
    required this.acSeatsAvailable,
    required this.sleeperSeatsAvailable,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: SeatAvailabilityPage(),
  ));
}
