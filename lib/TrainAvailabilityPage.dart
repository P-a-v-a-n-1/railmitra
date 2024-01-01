import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TrainAvailabilityPage extends StatefulWidget {
  @override
  _TrainAvailabilityPageState createState() => _TrainAvailabilityPageState();
}

class _TrainAvailabilityPageState extends State<TrainAvailabilityPage> {
  TextEditingController _trainNumberController = TextEditingController();
  String _trainNumber = '';
  String _trainName = '';
  bool _isButtonClicked = false;

  final List<String> trainNumbersList = [
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
    '22888',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seat Availability by Train Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInputField(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_trainNumber.isNotEmpty) {
                    _fetchTrainDetails();
                    setState(() {
                      _isButtonClicked = true;
                    });
                  } else {
                    // Handle case where train number is empty
                    print('Train number is empty');
                  }
                },
                child: Text('Get Train Details'),
              ),
              SizedBox(height: 20),
              _isButtonClicked && _trainNumber.isNotEmpty
                  ? FutureBuilder<DocumentSnapshot<Object?>>(
                future: FirebaseFirestore.instance
                    .collection('Trains')
                    .doc(_trainNumber)
                    .get(),
                builder: (context, snapshot) {
                  return _buildTrainDetails(snapshot);
                },
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return TypeAheadFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _trainNumberController,
        onChanged: (value) {
          setState(() {
            _trainNumber = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Enter Train Number',
          border: OutlineInputBorder(),
        ),
      ),
      suggestionsCallback: (pattern) {
        return trainNumbersList
            .where((trainNumber) =>
        trainNumber.contains(pattern) || pattern.isEmpty)
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        setState(() {
          _trainNumber = suggestion;
          _trainNumberController.text = suggestion; // Populate the input box
        });
      },
    );
  }

  Widget _buildTrainDetails(AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasData) {
      final DocumentSnapshot<Object?> trainSnapshot = snapshot.data!;
      print('Train document data: ${trainSnapshot.data()}');

      return Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Train Details:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Train Number: $_trainNumber\nTrain Name: $_trainName',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Object?>>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('seats')
                    .where('train number', isEqualTo: _trainNumber)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    final List<DocumentSnapshot<Object?>> seatDocs =
                        snapshot.data!.docs;
                    print(
                        'Number of documents in seats collection: ${seatDocs.length}');

                    if (seatDocs.isNotEmpty) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Station Name')),
                                DataColumn(label: Text('AC')),
                                DataColumn(label: Text('Sleeper')),
                                DataColumn(label: Text('General')),
                              ],
                              rows: seatDocs.map<DataRow>((seat) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(
                                        '${seat['station name'] ?? 'N/A'}')),
                                    DataCell(
                                        Text('${seat['ac'] ?? 0}')),
                                    DataCell(
                                        Text('${seat['sleeper'] ?? 0}')),
                                    DataCell(
                                        Text('${seat['general'] ?? 0}')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    } else {
                      print('No seats available - empty collection');
                      return Text('No seats available');
                    }
                  } else {
                    print('Error fetching seats data: ${snapshot.error}');
                    return Text('Something went wrong');
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Text('Something went wrong');
    }
  }


  void _fetchTrainDetails() {
    FirebaseFirestore.instance
        .collection('Trains')
        .doc(_trainNumber)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          _trainName = doc['name'];
        });
      } else {
        setState(() {
          _trainName = '';
        });
        print('Train not found');
      }
    });
  }
}