import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/http.dart';

const ep = 'https://taste-test.up.railway.app/';
// const ep = 'http://127.0.0.1:8000/';

Future<bool> deleteRecipe(String token, String id) async {
  final body = jsonEncode(<String, dynamic>{"id": id});
  try {
    Response res = await http.delete(
      Uri.parse("${ep}recipe/delete_recipe"),
      headers: authHeader(token),
      body: body,
    );
    if (res.statusCode == 404) {
      log(jsonDecode(res.body));
      return false;
    }
    return true;
  } catch (e) {
    log(jsonDecode(e.toString()));
    return false;
  }
}

Future<http.Response> createRecipe(String token, String title, List<String> ingredients, List<String> procedure, String notes, bool beginningRecipe,
    {int? parentRID}) async {
  final body = jsonEncode(<String, dynamic>{
    "title": title,
    "parentRID": parentRID,
    "beginningRecipe": beginningRecipe,
    "created": DateTime.now().toString(),
    "last_edited": DateTime.now().toString(),
    "ingredients": ingredients,
    "image_url": null,
    "procedure": procedure,
    "notes": notes.isEmpty ? null : notes,
    "in_progress": true,
  });
  try {
    return await http.post(Uri.parse("${ep}recipe/create_recipe"), headers: authHeader(token), body: body);
  } catch (e) {
    return http.Response("", 503, reasonPhrase: e.toString());
  }
}

Future<http.Response> getRecipe(
  String token,
  int id,
) async {
  try {
    return await http.get(Uri.parse("${ep}recipe/get_recipe/?id=$id"), headers: authHeader(token));
  } catch (e) {
    return http.Response("", 503, reasonPhrase: e.toString());
  }
}

Future<bool> updateRecipeProgress(
  String token,
  int id,
) async {
  try {
    Response res =  await http.post(Uri.parse("${ep}recipe/update_recipe_progress/?id=$id"), headers: authHeader(token));
    switch (res.statusCode) {
      case 404:
        log("Id $id not found: ${res.body}");
        return false;
      case 406:
        log("Id param not properly given: ${res.body}");
        return false;
      case 500:
        log("500: ${res.body}");
        return false;
      default:  
        return true; 
    }
  } catch (e) {
    log(e.toString()); 
    return false;
  }
}

Future<http.Response> getRecipeIterations(
  String token,
  int id,
) async {
  try {
    return await http.get(Uri.parse("${ep}recipe/get_recipe_iterations/?id=$id"), headers: authHeader(token));
  } catch (e) {
    return http.Response("", 503, reasonPhrase: e.toString());
  }
}

Future<http.Response> getUserRecipes(String token) async {
  try {
    return await http.get(
      Uri.parse("${ep}recipe/get_user_recipes"),
      headers: authHeader(token),
    );
  } catch (e) {
    return http.Response("", 503, reasonPhrase: e.toString());
  }
}

Future<http.Response> login(String username, String password) async {
  final body = jsonEncode(<String, String>{
    "username": username,
    "password": password,
  });
  try {
    return await http.post(Uri.parse("${ep}login"), headers: defaultHeader(), body: body);
  } catch (e) {
    return http.Response(jsonEncode(body), 503, reasonPhrase: e.toString());
  }
}

Future<http.Response> signup(String username, String password, String fname, String lname, String email) async {
  final body = jsonEncode(<String, String>{
    "username": username,
    "first_name": fname,
    "last_name": lname,
    "email": email,
    "password": password,
  });
  try {
    return await http.post(
      Uri.parse("${ep}signup"),
      headers: defaultHeader(),
      body: body,
    );
  } catch (e) {
    return http.Response(jsonEncode(body), 503, reasonPhrase: e.toString());
  }
}

Map<String, String> authHeader(String token) {
  return {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token $token'};
}

Map<String, String> defaultHeader() {
  return {
    'Content-Type': 'application/json; charset=UTF-8',
  };
}
