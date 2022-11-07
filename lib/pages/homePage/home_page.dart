import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:word_bank/pages/words_page.dart';
import 'package:word_bank/helpers/has_network.dart';
import 'package:word_bank/api/auth_api.dart';

import 'components/key_value_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool hasConnection = false;
  String? authorizationCode = '';
  String? refreshToken = '';
  String? accessToken = '';

  TextEditingController textController = TextEditingController();

  Future<void> setHasConnection() async {
    final res = await hasNetwork();
    setState(() {
      hasConnection = res;
    });
  }

  Future<void> setTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authorizationCode = prefs.getString('authorization_code');
      refreshToken = prefs.getString('refresh_token');
      accessToken = prefs.getString('access_token');
    });
  }

  Future<void> onSendCode() async {
    final code = textController.text;
    textController.text = '';
    await sendAuthorizationCode(code);
    await setTokens();
  }

  Future<void> onUpdateAccessToken() async {
    await getAccessTokenByRefreshToken();
    await setTokens();
  }

  @override
  void initState() {
    setHasConnection();
    setTokens();
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
            SizedBox(height: 10),
            KeyValueText(
              textKey: 'Has Internet connection',
              textValue: hasConnection.toString(),
            ),
            SizedBox(height: 10),
            KeyValueText(
              textKey: 'Authorization code',
              textValue: authorizationCode,
            ),
            SizedBox(height: 10),
            KeyValueText(
              textKey: 'Refresh token',
              textValue: refreshToken,
            ),
            SizedBox(height: 10),
            KeyValueText(
              textKey: 'Access token',
              textValue: accessToken,
            ),
            SizedBox(height: 10),
            OutlinedButton(
                onPressed: launchAuthorizeUrl,
                child: Text('Authorize')
            ),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter an authorization code',
              ),
            ),
            OutlinedButton(
                onPressed: onSendCode,
                child: Text('Send an authorization code'),
            ),
            OutlinedButton(
              onPressed: onUpdateAccessToken,
              child: Text('Update access token using refresh token'),
            ),
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