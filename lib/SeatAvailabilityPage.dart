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
      print('Please fill in all the details.');
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
    return FutureBuilder<List<TrainAvailability>>(
      future: fetchSeatAvailabilityInfo(selectedDate, sourceStation, destinationStation),
      builder: (context, snapshot) {
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
      // Print parameters being sent to the function
      print('Fetching seat availability info for:');
      print('Selected Date: $selectedDate');
      print('Source Station: $sourceStation');
      print('Destination Station: $destinationStation');

      CollectionReference seatsCollection = FirebaseFirestore.instance.collection('seats');

      // Format the selected date to match the Firestore document key
      String formattedDate = selectedDate != null
          ? "${selectedDate.day}-${_getMonthAbbreviation(selectedDate.month)}-${selectedDate.year}"
          : "";

      // Query availability based on date and stations
      QuerySnapshot<Object?> seatsQuerySnapshot = await seatsCollection
          .where('station name', whereIn: [sourceStation, destinationStation])
          .where('date', isEqualTo: formattedDate)
          .get();

      // Print raw data from seats collection
      print('Raw data from seats collection:');
      seatsQuerySnapshot.docs.forEach((seatDoc) {
        print(seatDoc.data());
      });

      // Extract train numbers from the seats query result
      List<String> trainNumbers = [];
      seatsQuerySnapshot.docs.forEach((seatDoc) {
        trainNumbers.add(seatDoc['train number']);
      });

      // Print extracted train numbers
      print('Extracted train numbers: $trainNumbers');

      if (trainNumbers.isNotEmpty) {
        // Query trains based on the obtained train numbers
        CollectionReference trainsCollection = FirebaseFirestore.instance.collection('Trains');
        QuerySnapshot<Object?> trainsQuerySnapshot = await trainsCollection
            .where(FieldPath.documentId, whereIn: trainNumbers)
            .get();

        // Print raw data from trains collection
        print('Raw data from trains collection:');
        trainsQuerySnapshot.docs.forEach((trainDoc) {
          print(trainDoc.data());
        });

        // Extract train availability information
        List<TrainAvailability> trainAvailabilityList = trainsQuerySnapshot.docs.map((trainDoc) {
          Map<String, dynamic> trainData = trainDoc.data() as Map<String, dynamic>;

          return TrainAvailability(
            trainNumber: trainDoc.id,
            trainName: trainData['trainName'],
            generalSeatsAvailable: trainData['genSeats'][0] ?? 0,
            acSeatsAvailable: trainData['genSeats'][1] ?? 0,
            sleeperSeatsAvailable: trainData['genSeats'][2] ?? 0,
          );
        }).toList();

        // Print extracted train availability information
        print('Extracted train availability information:');
        trainAvailabilityList.forEach((trainAvailability) {
          print(trainAvailability);
        });

        return trainAvailabilityList;
      } else {
        // No matching seats found
        print('No matching seats found for date: $formattedDate, source: $sourceStation, destination: $destinationStation');
        return [];
      }
    } catch (e) {
      print('Error fetching seat availability info: $e');
      throw 'Error fetching seat availability info';
    }
  }

  // Helper function to get the abbreviated month name
  String _getMonthAbbreviation(int month) {
    const List<String> months = ['jan', 'feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
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
