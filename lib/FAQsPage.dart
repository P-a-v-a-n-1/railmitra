import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: FAQsPage(),
  ));
}

class FAQsPage extends StatefulWidget {
  @override
  _FAQsPageState createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  List<Item> _data = generateItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: _data.map<Widget>((Item item) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              },
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF004080), Color(0xFF0066B2)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.question,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      if (item.isExpanded)
                        Text(
                          item.answer,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.justify,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Item {
  Item({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  String question;
  String answer;
  bool isExpanded;
}

List<Item> generateItems() {
  return [
    Item(
      question: 'What happens if the app shows no seat availability for my chosen route or train?',
      answer: 'If there\'s no availability, consider trying alternative dates or trains. Seat availability is dynamic and can change based on demand.',
    ),
    Item(
      question: 'I would like to transfer my ticket to a friend. What is the process?',
      answer: 'The rail ticket can’t be transferred to a friend. It can be transferred to blood relations (including father, mother, brother, sister, son, daughter, husband or wife) only. For transfer of ticket, an application must be submitted at least 48 hrs to 24 hours in advance of the scheduled departure of the train to the division office Assistant Commercial Manager or Area officer.',
    ),
    Item(
      question: 'How many days before can a reservation be done?',
      answer: 'Both the online and offline mode of reservation starts 120 days before the date of journey.',
    ),
    Item(
      question: 'Is it mandatory to carry a “Proof of Identity” while travelling?',
      answer: 'Yes, it is mandatory to carry a “Proof of Identity” while travelling in reserved class.',
    ),
    Item(
      question: 'What documents can be used as “proof of identity”? Will a photocopy be sufficient?',
      answer: 'The following shall be accepted as proof of identity:\n'
          '- Voter Photo identity card issued by Election Commission of India.\n'
          '- Passport.\n'
          '- PAN Card issued by Income Tax Department\n'
          '- Driving Licence issued by RTO\n'
          '- Photo identity card having serial number issued by Central/State Government\n'
          '- Student Identity Card with photograph issued by recognized School/College for their students\n'
          '- Nationalized Bank Passbook with photograph\n'
          '- Credit cards issued by banks with laminated photograph\n'
          '- Unique Identification Card “Aadhaar”.\n'
          '- Photo identity cards having serial number issued by Public Sector Undertaking of State/Central Government, District Administration, Municipal bodies and Penchant Administration\n'
          '- Only attested photocopy of ration card with photograph and nationalized bank passbook with photographs. No other Photocopy will be accepted.',
    ),
    Item(
      question: 'Can I take a pet along with me on the train?',
      answer: 'Yes, a passenger can take a pet along with him in AC First Class or First Class only, provided he/she reserves either a two-berth or a four-berth compartment exclusively for his/her use, paying the due charges depending upon the type of train. Passengers travelling in other classes are not permitted to carry the pet along with them. But the pet can be booked and carried in the Luggage/Brake Van paying the charges depending upon the type of train. Specially designed Boxes are available in the Brake Van for this purpose. Passengers may contact the Parcel Office to book their pet.',
    ),
    Item(
      question: 'Can I use the Seat Availability App on multiple devices?',
      answer: 'Yes, you can access the app on multiple devices. Just log in using your credentials, and your account information will be synchronized.',
    ),
    Item(
      question: 'Can I share my feedback anonymously?',
      answer: 'Yes, you have the option to provide feedback anonymously if you prefer not to disclose your identity.',
    ),
    Item(
      question: 'What if I encounter technical issues or errors while using the app?',
      answer: 'In case of technical issues, please reach out to our support team through the provided contact options. We\'ll be happy to assist you.',
    ),
    Item(
      question: 'Is my personal information secure on the Seat Availability App?',
      answer: 'Yes, we prioritize user privacy. Our app employs robust security measures to safeguard your personal information.',
    ),
    Item(
      question: 'Is it possible to check seat availability using a specific train number?',
      answer: 'Absolutely! Just go to the seat availability section, provide the train number, and submit to get detailed seat availability for that train.',
    ),
  ];
}

