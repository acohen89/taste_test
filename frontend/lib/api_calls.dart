import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:taste_test/classes/IngredientClass.dart';

const ep = 'http://127.0.0.1:8000/';

Future<http.Response> createRecipe(String token, String title,
    List<String> ingredients, List<String> procedure, String notes) async {
  return await http.post(
    Uri.parse("${ep}recipe/create_recipe"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'token $token'
    },
    body: jsonEncode(<String, dynamic>{
      "title": title,
      "beginningRecipe": true,
      "parentRID": null,
      "created": DateTime.now().toString(),
      "last_edited": DateTime.now().toString(),
      // "ingredients": ingredients,
      "ingredients": ingredients,
      "image_url": null,
      "procedure": procedure,
      "notes": notes,
      "in_progress": true,
    }),
  );
}

Future<http.Response> getUserRecipes(String token) async {
  return await http.get(
    Uri.parse("${ep}recipe/get_user_recipes"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'token $token'
    },
  );
}

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

Future<http.Response> signup(String username, String password, String fname,
    String lname, String email) async {
  return await http.post(
    Uri.parse("${ep}signup"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "username": username,
      "first_name": fname,
      "last_name": lname,
      "email": email,
      "password": password,
    }),
  );
}
