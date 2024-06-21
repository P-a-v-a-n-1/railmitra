import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EwalletPage extends StatefulWidget {
  @override
  _EwalletPageState createState() => _EwalletPageState();
}

class _EwalletPageState extends State<EwalletPage> {
  late User? user;
  double balance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadUserData(user!.uid);
    } else {
      print('No user logged in');
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          balance = userDoc['balance'];
        });
        _loadTransactions(userId);
        _loadCards(userId);
      } else {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({'balance': 0.0});
        setState(() {
          balance = 0.0;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadTransactions(String userId) async {
    try {
      QuerySnapshot transactionDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();
      setState(() {
        transactions = transactionDocs.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  Future<void> _loadCards(String userId) async {
    try {
      QuerySnapshot cardDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cards')
          .get();
      setState(() {
        cards = cardDocs.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    } catch (e) {
      print('Error loading cards: $e');
    }
  }

  Future<void> _updateBalance(double amount, String type, String cardId) async {
    if (user != null) {
      try {
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
        DocumentSnapshot userDoc = await userRef.get();
        if (userDoc.exists) {
          double newBalance = userDoc['balance'] + amount;
          await userRef.update({'balance': newBalance});
          DocumentReference cardRef = userRef.collection('cards').doc(cardId);
          DocumentSnapshot cardDoc = await cardRef.get();
          if (cardDoc.exists) {
            String cardNumber = cardDoc['cardNumber'];
            await userRef.collection('transactions').add({
              'date': Timestamp.now(),
              'description': type == 'Credit' ? 'Added Funds' : 'Removed Funds',
              'amount': amount.abs(),
              'type': type,
              'cardNumber': cardNumber,
            });
            setState(() {
              balance = newBalance;
            });
          }
        }
      } catch (e) {
        print('Error updating balance: $e');
      }
    }
  }


  Future<void> _makePayment(double amount) async {
    if (user != null) {
      try {
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
        DocumentSnapshot userDoc = await userRef.get();
        if (userDoc.exists) {
          double currentBalance = userDoc['balance'];
          if (currentBalance >= amount) {
            double newBalance = currentBalance - amount;
            await userRef.update({'balance': newBalance});
            await userRef.collection('transactions').add({
              'date': Timestamp.now(),
              'description': 'Payment',
              'amount': amount,
              'type': 'Debit',
              'cardNumber': 'E-Wallet',
            });
            _loadUserData(user!.uid);
            _showConfirmationMessage(amount);
          } else {
            _showErrorMessage('Insufficient balance.');
          }
        }
      } catch (e) {
        print('Error making payment: $e');
      }
    }
  }

  void _showConfirmationMessage(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful'),
        content: Text('₹$amount has been debited from your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance: ₹$balance',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: transactions.map((transaction) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(transaction['description']),
                      subtitle: Text(transaction['date'].toDate().toString()),
                      trailing: Text('₹${transaction['amount']}'),
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      String? selectedCard = await _selectCard(context);
                      if (selectedCard != null) {
                        double? amount = await _enterAmount(context, 'Add Funds');
                        if (amount != null) {
                          _updateBalance(amount, 'Credit', selectedCard);
                        }
                      }
                    },
                    child: Text('Add Funds'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      String? selectedCard = await _selectCard(context);
                      if (selectedCard != null) {
                        double? amount = await _enterAmount(context, 'Remove Funds');
                        if (amount != null) {
                          _updateBalance(-amount, 'Debit', selectedCard);
                        }
                      }
                    },
                    child: Text('Remove Funds'),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                double? amount = await _enterAmount(context, 'Enter Payment Amount');
                if (amount != null) {
                  _makePayment(amount);
                }
              },
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddCardModal(onCardAdded: () => _loadCards(user!.uid)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<String?> _selectCard(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: cards.map((card) {
            return ListTile(
              title: Text(card['cardNumber']),
              onTap: () => Navigator.of(context).pop(card['cardNumber']),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<double?> _enterAmount(BuildContext context, String action) async {
    TextEditingController amountController = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(double.tryParse(amountController.text));
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class AddCardModal extends StatefulWidget {
  final VoidCallback onCardAdded;

  AddCardModal({required this.onCardAdded});

  @override
  _AddCardModalState createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  TextEditingController cardNumberController = TextEditingController();

  void _addCard() async {
    if (cardNumberController.text.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cards')
            .add({'cardNumber': cardNumberController.text});
        widget.onCardAdded();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Card'),
      content: TextField(
        controller: cardNumberController,
        decoration: InputDecoration(labelText: 'Card Number'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _addCard,
          child: Text('Add'),
        ),
      ],
    );
  }
}
