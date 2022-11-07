import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';
import '../helpers/show_toast.dart';

class WordsPage extends StatefulWidget {
  const WordsPage({super.key, required this.title});

  final String title;

  @override
  State<WordsPage> createState() => WordsPageState();
}

class WordsPageState extends State<WordsPage> {
  late Future<Store> store;
  int _selectedIndex = 0;
  bool _isFromFile = false;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store = fetchWordsAsStore();
    _isFromFile = false;
  }

  Column getWordComponent(Word word) {
    return Column(
      children: [
        Text(word.value, style: TextStyle(fontWeight: FontWeight.bold)),
        ...word.examples.map((example) => Text(example)).toList(),
        SizedBox(height: 30),
      ],
    );
  }

  void updateWords() async {
    setState(() {
      store = fetchWordsAsStore();
    });
    await writeDataToFile(await fetchWordsAsString());
  }

  // void sendCode() async {
  //   await sendAuthorizedCode(textController.text);
  //   final prefs = await SharedPreferences.getInstance();
  //   final refreshToken = prefs.getString('refresh_token');
  //   if (refreshToken == null) {
  //     showToast('Unable to get refresh token');
  //     return;
  //   }
  //   final accessToken = await getAccessTokenByRefreshToken(refreshToken);
  //   showToast('Access token is:\n$accessToken');
  //   prefs.setString('access_token', accessToken);
  // }

  Column getWordsContainer(List<Word> words) {
    return Column(
        children: [
          Text(_isFromFile ? 'from file' : 'from cloud'),
          SizedBox(height: 30),
          ...words.map((word) => getWordComponent(word)).toList(),
          // OutlinedButton(onPressed: authorize, child: Text('Authorize')),
          TextField(
            controller: textController,
          ),
          // OutlinedButton(onPressed: sendCode, child: Text('Send Code')),
          OutlinedButton(onPressed: updateWords, child: Text('Update words')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go back!'),
          ),
        ]
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  late final List<Widget> _widgetOptions = <Widget>[
    FutureBuilder<Store>(
      future: store,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return getWordsContainer(snapshot.data!.words);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: Settings',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
