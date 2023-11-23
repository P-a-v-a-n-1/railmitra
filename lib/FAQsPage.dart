import 'package:flutter/material.dart';

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
        child: SingleChildScrollView(
          child: ExpansionPanelList(
            elevation: 1,
            expandedHeaderPadding: EdgeInsets.all(0),
            children: _data.map<ExpansionPanel>((Item item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      item.question,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004080),
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item.answer,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                isExpanded: item.isExpanded,
              );
            }).toList(),
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _data[index].isExpanded = !isExpanded;
              });
            },
          ),
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
      question: 'Your Custom Question',
      answer: 'Your Custom Answer',
      isExpanded: true, // Set this to true if you want it to be initially expanded
    ),
    Item(
      question: 'Question 2',
      answer: 'Answer 2',
    ),
    // Add more items as needed
  ];
}

void main() {
  runApp(MaterialApp(
    home: FAQsPage(),
  ));
}
