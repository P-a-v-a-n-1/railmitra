import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SeatAvailabilityPage extends StatefulWidget {
  @override
  _SeatAvailabilityPageState createState() => _SeatAvailabilityPageState();
}

class _SeatAvailabilityPageState extends State<SeatAvailabilityPage> {
  DateTime? _selectedDate;

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
            _buildInputField('From Station'),
            SizedBox(height: 20),
            _buildInputField('To Station'),
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

  Widget _buildInputField(String label) {
    return TextFormField(
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
    if (_selectedDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatAvailabilityDisplayPage(
            selectedDate: _selectedDate,
          ),
        ),
      );
    } else {
      // Handle the case when _selectedDate is null
      // You might want to show a message or take appropriate action
    }
  }
}

class SeatAvailabilityDisplayPage extends StatelessWidget {
  final DateTime? selectedDate;

  SeatAvailabilityDisplayPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: selectedDate != null ? fetchSeatAvailabilityInfo(selectedDate) : null,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
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
          List<String> seatAvailabilityInfo = snapshot.data ?? [];

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
                  SizedBox(height: 20),
                  if (seatAvailabilityInfo.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Seats:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        for (String seatInfo in seatAvailabilityInfo)
                          Text(seatInfo, style: TextStyle(fontSize: 16)),
                      ],
                    )
                  else
                    Text('No seat availability information available.'),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<String>> fetchSeatAvailabilityInfo(DateTime? selectedDate) async {
    try {
      CollectionReference availabilityCollection = FirebaseFirestore.instance.collection('availability');

      DocumentSnapshot snapshot = await availabilityCollection.doc(selectedDate!.toLocal().toString()).get();

      if (snapshot.exists) {
        return List<String>.from((snapshot.data() as Map<String, dynamic>)['seats']);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching seat availability info: $e');
      throw 'Error fetching seat availability info';
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: SeatAvailabilityPage(),
  ));
}
