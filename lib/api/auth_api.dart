import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:word_bank/helpers/show_toast.dart';

import 'constants.dart';

/*
  AUTHORIZATION CODE and ACCESS TOKEN work for a short time
  REFRESH TOKEN is eternal
*/

/*
  Authorization flow is:
  1. User gets AUTHORIZATION CODE by opening a page and copy+paste the code
  2. Sending the code returns REFRESH TOKEN and ACCESS TOKEN
  3. ACCESS TOKEN cab be used to call any method
  4. When ACCESS TOKEN expires, you can get new one using REFRESH TOKEN
*/

Map<String, String> getHeaders() {
  return {
    'Content-Type': 'application/x-www-form-urlencoded',
    'authorization': basicAuth
  };
}

Future<void> launchAuthorizeUrl() async {
  const url = "https://www.dropbox.com/oauth2/authorize?response_type=code&client_id=5suxg8ba9tsgoim&token_access_type=offline";
  final uri = Uri.parse(url);
  await launchUrl(uri);
}

Future<void> sendAuthorizationCode(String code) async {
  var headers = getHeaders();

  var request = http.Request('POST', Uri.parse('https://api.dropbox.com/oauth2/token'));
  request.bodyFields = {
    'code': code,
    'grant_type': 'authorization_code'
  };
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final result = await response.stream.bytesToString();
    final json = jsonDecode(result);

    final refreshToken = json['refresh_token'];
    final accessToken = json['access_token'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authorization_code', code);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('access_token', accessToken);

    showToast('Authorization code has been successfully sent');
    showToast('New refresh and access tokens have been saved');
  }
  else {
    showToast(response.reasonPhrase ?? 'Unknown error');
  }
}

Future<void> getAccessTokenByRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString('refresh_token');
  if (refreshToken == null) {
    showToast('Refresh token does not exist');
    return;
  }

  var headers = getHeaders();

  var request = http.Request('POST', Uri.parse('https://api.dropbox.com/oauth2/token'));
  request.bodyFields = {
    'refresh_token': refreshToken,
    'grant_type': 'refresh_token'
  };

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final result = await response.stream.bytesToString();
    final json = jsonDecode(result);

    final accessToken = json['access_token'];

    await prefs.setString('access_token', accessToken);

    showToast('Successfully received access token');
  }
  else {
    showToast(response.reasonPhrase ?? 'Unknown error');
  }
}