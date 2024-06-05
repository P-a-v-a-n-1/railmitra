import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: SeatAvailabilityPage(),
  ));
}

class SeatAvailabilityPage extends StatefulWidget {
  @override
  _SeatAvailabilityPageState createState() => _SeatAvailabilityPageState();
}

class _SeatAvailabilityPageState extends State<SeatAvailabilityPage> {
  DateTime? _selectedDate;
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  List<String> trainNumbers = [
    '01139',
    '01140',
    '07335',
    '07336',
    '07377',
    '07378',
    '10105',
    '10106',
    '12217',
    '12218',
    '12431',
    '12432',
    '12609',
    '12610',
    '12629',
    '12630',
    '12845',
    '12846',
    '14553',
    '14554',
    '16591',
    '16592',
    '16594',
    '16595',
    '17415',
    '17416',
    '18111',
    '18112',
    '22887',
    '22888'
  ];

  final List<String> stationsList = [
    'Guntkal',
    'Ballari',
    'Torangallu',
    'Hosapete',
    'Gadag',
    'Koppala',
    'SSS Hubballi',
    'Dharwad',
    'Kazipet',
    'Mantralayam',
    'Belagavi',
    'Kazipet',
    'Mantralayam',
    'Guntkal',
    'Ballari',
    'Torangallu',
    'Hosapete',
    'Koppala',
    'Gadag',
    'SSS Hubballi',
    'Dharwad',
    'Belagavi',
    'Nagpur',
    'Bandera',
    'Sheagon',
    'Nashik Road',
    'Panvel',
    'Ratnagiri',
    'Kudal',
    'Thivim',
    'Karmali',
    'Madagaon',
    'Madagaon',
    'Karmali',
    'Thivim',
    'Kudal',
    'Ratnagiri',
    'Panvel',
    'Nashik Road',
    'Sheagon',
    'Bandera',
    'Nagpur',
    'Vijayapura',
    'Bagalkote',
    'BADAMI',
    'Gadag',
    'SSS Hubballi',
    'Haveri',
    'Birur',
    'Hassan',
    'Subrahmnya rd',
    'Mangaluru Junction',
    'Vijayapura',
    'Bagalkote',
    'Badami',
    'Gadag',
    'SSS Hubballi',
    'Haveri',
    'Birur',
    'Hassan',
    'Subrahmnya rd',
    'Mangaluru Junction',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seat Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeAhead('From Station', _fromController, stationsList),
              SizedBox(height: 20),
              _buildTypeAhead('To Station', _toController, stationsList),
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
      ),
    );
  }

  Widget _buildTypeAhead(
      String label, TextEditingController controller, List<String> suggestionsList) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
      suggestionsCallback: (pattern) {
        return suggestionsList
            .where((station) => station.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion;
      },
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
    var seatNumbersQuery = await FirebaseFirestore.instance
        .collection('seats')
        .where('stationName', whereIn: [_fromController.text, _toController.text])
        .get();

    trainNumbers =
        seatNumbersQuery.docs.map((doc) => doc['trainNumber'] as String).toList();

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
    if (_selectedDate != null &&
        _fromController.text.isNotEmpty &&
        _toController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatAvailabilityDisplayPage(
            selectedDate: _selectedDate,
            sourceStation: _fromController.text,
            destinationStation: _toController.text,
            trainNumbers: trainNumbers,
          ),
        ),
      );
    } else {
      print('Please fill in all the details.');
    }
  }
}

String _getMonthAbbreviation(int month) {
  const List<String> months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec'
  ];
  return months[month - 1];
}
class SeatAvailabilityDisplayPage extends StatelessWidget {
  final DateTime? selectedDate;
  final String sourceStation;
  final String destinationStation;
  final List<String> trainNumbers;

  SeatAvailabilityDisplayPage({
    Key? key,
    required this.selectedDate,
    required this.sourceStation,
    required this.destinationStation,
    required this.trainNumbers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Train Availability'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              FutureBuilder<List<TrainAvailability>>(
                future: fetchSeatAvailabilityInfo(
                  selectedDate,
                  sourceStation,
                  destinationStation,
                  trainNumbers,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    List<TrainAvailability> trainAvailabilityList = snapshot.data ?? [];

                    if (trainAvailabilityList.isEmpty) {
                      return Center(
                          child: Text(
                            'No train available for the specified date and route.',
                            style: TextStyle(fontSize: 18),
                          ),
                      );
                    }

                    return Column(
                      children: trainAvailabilityList.map((trainAvailability) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Train Number: ${trainAvailability.trainNumber}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Train Name: ${trainAvailability.trainName}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),

                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


Future<List<TrainAvailability>> fetchSeatAvailabilityInfo(
    DateTime? selectedDate,
    String sourceStation,
    String destinationStation,
    List<String> trainNumbers,
    ) async {
  try {
    print('Fetching seat availability info for:');
    print('Source Station: $sourceStation');
    print('Destination Station: $destinationStation');

    CollectionReference seatsCollection =
    FirebaseFirestore.instance.collection('seats');

    String formattedDate = selectedDate != null
        ? "${selectedDate.day}-${_getMonthAbbreviation(selectedDate.month)}-${selectedDate.year}"
        : "";
    print('Selected Date: $formattedDate');

    if (formattedDate != '15-jul-2024') {
      print('No train available for the specified date: $formattedDate');
      return [];
    }

    QuerySnapshot<Object?> seatsQuerySnapshot = await seatsCollection
        .where('station name', whereIn: [sourceStation, destinationStation])
        .get();

    print('Raw data from seats collection:');
    seatsQuerySnapshot.docs.forEach((seatDoc) {
      print(seatDoc.data());
    });

    List<String> trainNumbers = [];
    seatsQuerySnapshot.docs.forEach((seatDoc) {
      var trainNumber = seatDoc['train number'] as String?;
      if (trainNumber != null) {
        trainNumbers.add(trainNumber);
      }
    });
    print('Extracted train numbers: $trainNumbers');

    if (trainNumbers.isNotEmpty) {
      CollectionReference trainsCollection =
      FirebaseFirestore.instance.collection('Trains');
      QuerySnapshot<Object?> trainsQuerySnapshot = await trainsCollection
          .where(FieldPath.documentId, whereIn: trainNumbers)
          .get();

      print('Raw data from trains collection:');
      trainsQuerySnapshot.docs.forEach((trainDoc) {
        print(trainDoc.data());
      });

      List<TrainAvailability> trainAvailabilityList =
      trainsQuerySnapshot.docs.map((trainDoc) {
        Map<String, dynamic> trainData =
        trainDoc.data() as Map<String, dynamic>;

        return TrainAvailability(
          trainNumber: trainDoc.id,
          trainName: trainData['name'],
          generalSeatsAvailable: 1,
          acSeatsAvailable: 2,
          sleeperSeatsAvailable: 3,
        );
      }).toList();

      print('Extracted train availability information:');
      trainAvailabilityList.forEach((trainAvailability) {
        print(trainAvailability);
      });

      return trainAvailabilityList;
    } else {
      print(
          'No matching seats found for date: $formattedDate, source: $sourceStation, destination: $destinationStation');
      return [];
    }
  } catch (e) {
    print('Error fetching seat availability info: $e');
    throw 'Error fetching seat availability info';
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
