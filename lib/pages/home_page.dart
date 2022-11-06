import 'package:flutter/material.dart';

import 'package:word_bank/pages/words_page.dart';
import 'package:word_bank/helpers/has_network.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool hasConnection = false;

  void setHasConnection() async {
    final res = await hasNetwork();
    setState(() {
      hasConnection = res;
    });
  }

  @override
  void initState() {
    setHasConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Has Internet connection: $hasConnection'),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordsPage(title: 'Mega title from props')),
                );
              },
              child: Text('Open words page')
            )
          ]
        ),
      ),
    );
  }
}