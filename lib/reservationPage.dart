import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: ReservationPage(),
  ));
}

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passengerNameController = TextEditingController();
  final TextEditingController passengerAgeController = TextEditingController();
  final TextEditingController trainNumberController = TextEditingController();
  final TextEditingController departureStationController = TextEditingController();
  final TextEditingController arrivalStationController = TextEditingController();
  final TextEditingController journeyDateController = TextEditingController();
  String classOfTravel = '';
  String berthPreference = '';
  String paymentMethod = '';

  double ticketPrice = 0.0;
  int distance = 0;

  @override
  void initState() {
    super.initState();

    trainNumberController.addListener(_calculateFare);
    departureStationController.addListener(_calculateFare);
    arrivalStationController.addListener(_calculateFare);
  }

  @override
  void dispose() {
    trainNumberController.dispose();
    departureStationController.dispose();
    arrivalStationController.dispose();
    passengerNameController.dispose();
    passengerAgeController.dispose();
    journeyDateController.dispose();
    super.dispose();
  }

  Future<void> _calculateFare() async {
    print('Calculating fare...');
    String trainNumber = trainNumberController.text.trim();
    String departureStation = departureStationController.text.trim();
    String arrivalStation = arrivalStationController.text.trim();

    print('Train Number: $trainNumber');
    print('Departure Station: $departureStation');
    print('Arrival Station: $arrivalStation');

    if (trainNumber.isNotEmpty && departureStation.isNotEmpty && arrivalStation.isNotEmpty) {
      try {
        // Query for departure station distance
        final departureQuerySnapshot = await FirebaseFirestore.instance
            .collection('seats')
            .where('train number', isEqualTo: trainNumber)
            .where('station name', isEqualTo: departureStation)
            .get();

        // Query for arrival station distance
        final arrivalQuerySnapshot = await FirebaseFirestore.instance
            .collection('seats')
            .where('train number', isEqualTo: trainNumber)
            .where('station name', isEqualTo: arrivalStation)
            .get();

        if (departureQuerySnapshot.docs.isNotEmpty && arrivalQuerySnapshot.docs.isNotEmpty) {
          final departureData = departureQuerySnapshot.docs.first.data();
          final arrivalData = arrivalQuerySnapshot.docs.first.data();

          print('Departure Station Data: $departureData');
          print('Arrival Station Data: $arrivalData');

          final departureDistance = int.parse(departureData['distance']);
          final arrivalDistance = int.parse(arrivalData['distance']);

          if (departureDistance != null && arrivalDistance != null) {
            setState(() {
              distance = (arrivalDistance - departureDistance).abs();
              print('Distance: $distance');
              ticketPrice = _calculatePrice(distance, classOfTravel);
              print('Calculated Ticket Price: $ticketPrice');
            });
          } else {
            print('Distance not found for one or both stations');
          }
        } else {
          print('One or both station documents do not exist');
        }
      } catch (e) {
        print('Error fetching distance: $e');
      }
    } else {
      print('One or more required fields are empty');
    }
  }

  double _calculatePrice(int distance, String classOfTravel) {
    print('Calculating price for distance: $distance and class: $classOfTravel');
    double basePricePerKm;
    switch (classOfTravel) {
      case 'AC':
        basePricePerKm = 3.0;
        break;
      case 'Sleeper Class (SL)':
        basePricePerKm = 1.5;
        break;
      case 'General (2S)':
        basePricePerKm = 1.0;
        break;
      default:
        basePricePerKm = 1.0; // Fallback to General (2S) rate if unknown class
    }
    return distance * basePricePerKm;
  }

  Future<void> _reduceSeatNumbers(String trainNumber, String classOfTravel, String departureStation) async {
    final journeyDate = journeyDateController.text.trim();
    print('Reducing seat numbers for train: $trainNumber, class: $classOfTravel, station: $departureStation, date: $journeyDate');

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('seats')
          .where('train number', isEqualTo: trainNumber)
          .where('station name', isEqualTo: departureStation)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final seatData = doc.data();
        int updatedSeats;

        switch (classOfTravel) {
          case 'AC':
            updatedSeats = int.parse(seatData['ac']) - 1;
            await FirebaseFirestore.instance.collection('seats').doc(doc.id).update({'ac': updatedSeats.toString()});
            print('AC seat updated');
            break;
          case 'Sleeper Class (SL)':
            updatedSeats = int.parse(seatData['sleeper']) - 1;
            await FirebaseFirestore.instance.collection('seats').doc(doc.id).update({'sleeper': updatedSeats.toString()});
            print('Sleeper seat updated');
            break;
          case 'General (2S)':
            updatedSeats = int.parse(seatData['general']) - 1;
            await FirebaseFirestore.instance.collection('seats').doc(doc.id).update({'general': updatedSeats.toString()});
            print('General seat updated');
            break;
          default:
            print('Invalid class of travel: $classOfTravel');
        }
      } else {
        print('No seats found for train $trainNumber at $departureStation on $journeyDate');
      }
    } catch (e) {
      print('Error updating seat count: $e');
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (classOfTravel.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select class of travel')));
        return;
      }
      if (berthPreference.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select berth preference')));
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please log in to make a reservation.')));
        return;
      }
      final userId = user.uid;

      final trainNumber = trainNumberController.text.trim();
      final departureStation = departureStationController.text.trim();
      final arrivalStation = arrivalStationController.text.trim();
      final passengerName = passengerNameController.text.trim();
      final passengerAge = passengerAgeController.text.trim();
      final journeyDate = journeyDateController.text.trim();

      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (!userDoc.exists) {
          print('User data not found.');
          return;
        }

        final userData = userDoc.data()!;
        final currentBalance = userData['balance'];
        if (currentBalance < ticketPrice) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insufficient balance.')));
          return;
        }

        final newBalance = currentBalance - ticketPrice;
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'balance': newBalance,
          'transactions': FieldValue.arrayUnion([{
            'amount': ticketPrice,
            'date': Timestamp.now(),
            'description': 'Ticket reservation for train $trainNumber from $departureStation to $arrivalStation',
            'type': 'Debit',
          }])
        });

        await FirebaseFirestore.instance.collection('reservations').add({
          'user_id': userId,
          'passenger_name': passengerName,
          'passenger_age': passengerAge,
          'journey_date': journeyDate,
          'train_number': trainNumber,
          'departure_station': departureStation,
          'arrival_station': arrivalStation,
          'class_of_travel': classOfTravel,
          'ticket_price': ticketPrice,
        });

        await _reduceSeatNumbers(trainNumber, classOfTravel, departureStation);

        _showConfirmationDialog(context);
        print('Reservation successful. Ticket reserved for train $trainNumber from $departureStation to $arrivalStation.');
      } catch (e) {
        print('Error during reservation: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reserve ticket: $e')));
      }
    }
  }


  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservation Confirmed'),
          content: Text('Your ticket has been successfully reserved.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectJourneyDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        journeyDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ticket Reservation')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: passengerNameController,
                  decoration: InputDecoration(labelText: 'Passenger Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the passenger name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passengerAgeController,
                  decoration: InputDecoration(labelText: 'Passenger Age'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the passenger age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: trainNumberController,
                  decoration: InputDecoration(labelText: 'Train Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the train number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: departureStationController,
                  decoration: InputDecoration(labelText: 'Departure Station'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the departure station';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: arrivalStationController,
                  decoration: InputDecoration(labelText: 'Arrival Station'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the arrival station';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: journeyDateController,
                  decoration: InputDecoration(
                    labelText: 'Journey Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        await _selectJourneyDate(context);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the journey date';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: classOfTravel.isNotEmpty ? classOfTravel : null,
                  items: [
                    DropdownMenuItem(value: 'AC', child: Text('AC')),
                    DropdownMenuItem(value: 'Sleeper Class (SL)', child: Text('Sleeper Class (SL)')),
                    DropdownMenuItem(value: 'General (2S)', child: Text('General (2S)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      classOfTravel = value ?? '';
                      _calculateFare();
                    });
                  },
                  decoration: InputDecoration(labelText: 'Class of Travel'),
                ),
                DropdownButtonFormField<String>(
                  value: berthPreference.isNotEmpty ? berthPreference : null,
                  items: [
                    DropdownMenuItem(value: 'Upper', child: Text('Upper')),
                    DropdownMenuItem(value: 'Middle', child: Text('Middle')),
                    DropdownMenuItem(value: 'Lower', child: Text('Lower')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      berthPreference = value ?? '';
                    });
                  },
                  decoration: InputDecoration(labelText: 'Berth Preference'),
                ),
                DropdownButtonFormField<String>(
                  value: paymentMethod.isNotEmpty ? paymentMethod : null,
                  items: [
                    DropdownMenuItem(value: 'E-wallet', child: Text('E-wallet')),
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value ?? '';
                    });
                  },
                  decoration: InputDecoration(labelText: 'Payment Method'),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ticket Price: \₹${ticketPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Class of Travel: $classOfTravel',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Distance: ${distance} km',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _submitForm(context);
                  },
                  child: Text('Reserve Ticket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
