import 'package:http/http.dart' as http;
import 'dart:convert';

const ep = 'http://127.0.0.1:8000/';

Future<http.Response> login(String username, String password) async {
  return await http.post(
    Uri.parse("${ep}login"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "username": username,
      "password": password,
    }),
  );
}
