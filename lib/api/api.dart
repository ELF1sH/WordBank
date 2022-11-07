import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Word {
  String value = '';
  List<String> examples = [];

  Word(this.value, this.examples);
}

class Store {
  List<Word> words = [];

  Store(this.words);

  factory Store.fromJson(dynamic json) {
    var wordsJsArray = json['words'];
    List<Word> wordsList = [];
    for (int i = 0; i < wordsJsArray.length; i++) {
      var currentJsWord = wordsJsArray[i];
      var examplesJs = currentJsWord['examples'];
      List<String> examplesString = [];
      for (int j = 0; j < examplesJs.length; j++) {
        print(examplesJs[j].runtimeType.toString());
        examplesString.add(examplesJs[j].toString());
      }
      var word = Word(currentJsWord['value'], examplesString);
      wordsList.add(word);
    }
    return Store(wordsList);
  }
}

Future<Store> fetchWordsAsStore () async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  if (accessToken == null) {
    print('Access token does not exist');
    throw Exception('Access token does not exist');
  }

  Map<String, String> headers = {
    "Content-Type": "text/plain",
    "Accept": "application/json",
    "Authorization": "Bearer $accessToken",
    "Dropbox-API-Arg": '{"path":"/WordBank/en.json"}',
    "Dropbox-Api-Select-User": "",
  };

  var response = await http.get(
      Uri.parse('https://content.dropboxapi.com/2/files/download'),
      headers: headers
  );

  if (response.statusCode == 200) {
    Store store = Store.fromJson(jsonDecode(response.body));
    return store;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    throw Exception('Server error');
  }
}




// ------------------------------
// AUTHORIZATION
// ------------------------------




// ------------------------------
// SAVING DATA INSIDE A FILE
// ------------------------------
Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();
  if (directory == null) throw Exception('directory not found');
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/en.json');
}

Future<void> writeDataToFile(String data) async {
  final file = await _localFile;
  file.writeAsString(data);
}

Future<String> fetchWordsAsString () async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  if (accessToken == null) {
    print('Access token does not exist');
    return "";
  }

  Map<String, String> headers = {
    "Content-Type": "text/plain",
    "Accept": "application/json",
    "Authorization": "Bearer $accessToken",
    "Dropbox-API-Arg": '{"path":"/WordBank/en.json"}',
    "Dropbox-Api-Select-User": "",
  };

  var response = await http.get(
      Uri.parse('https://content.dropboxapi.com/2/files/download'),
      headers: headers
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return "";
  }
}

Future<Store> readStoreFromFile() async {
  try {
    final file = await _localFile;
    final contents = await file.readAsString();

    Store store = Store.fromJson(jsonDecode(contents));
    return store;
  } catch (e) {
    throw Exception('file was not found');
  }
}

Future<bool> isLocalStoreExists() async {
  try {
    final file = await _localFile;
    final contents = await file.readAsString();
    if (contents.isNotEmpty) {
      return true;
    }
    return false;
  } catch(e) {
    return false;
  }
}
