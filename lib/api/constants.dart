import 'dart:convert';

String appKey = '5suxg8ba9tsgoim';
String appSecret = 'm3czqh6p10pyvjv';
String basicAuth = 'Basic ${base64.encode(utf8.encode('$appKey:$appSecret'))}';
