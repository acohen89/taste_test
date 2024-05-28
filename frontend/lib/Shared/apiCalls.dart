import 'package:http/http.dart' as http;
import 'dart:convert';

const ep = 'http://127.0.0.1:8000/';

Future<http.Response> deleteRecipe(String token, String id) async {
  final body = jsonEncode(<String, dynamic>{"id": id});
  try {
    return await http.delete(
      Uri.parse("${ep}recipe/delete_recipe"),
      headers: authHeader(token),
      body: body,
    );
  } catch (e) {
    return http.Response("", 503, reasonPhrase: e.toString());
  }
}

Future<http.Response> createRecipe(String token, String title,
    List<String> ingredients, List<String> procedure, String notes) async {
  final body = jsonEncode(<String, dynamic>{
    "title": title,
    "beginningRecipe": true,
    "parentRID": null,
    "created": DateTime.now().toString(),
    "last_edited": DateTime.now().toString(),
    "ingredients": ingredients,
    "image_url": null,
    "procedure": procedure,
    "notes": notes.isEmpty ? null : notes, 
    "in_progress": true,
  });
  try {
    return await http.post(Uri.parse("${ep}recipe/create_recipe"),
        headers: authHeader(token), body: body);
  } catch (e) {
    return http.Response("", 503, reasonPhrase: e.toString());
  }
}
Future<http.Response> getRecipe(String token, int id,) async {
  try {
    return await http.get(Uri.parse("${ep}recipe/get_recipe/?id=$id"),
        headers: authHeader(token));
  } catch (e) {
    return http.Response("", 503, reasonPhrase: e.toString());
  }
}
Future<http.Response> getRecipeIterations(String token, int id,) async {
  try {
    return await http.get(Uri.parse("${ep}recipe/get_recipe_iterations/?id=$id"),
        headers: authHeader(token));
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
    return await http.post(Uri.parse("${ep}login"),
        headers: defaultHeader(), body: body);
  } catch (e) {
    return http.Response(jsonEncode(body), 503, reasonPhrase: e.toString());
  }
}

Future<http.Response> signup(String username, String password, String fname,
    String lname, String email) async {
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
  return {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'token $token'
  };
}

Map<String, String> defaultHeader() {
  return {
    'Content-Type': 'application/json; charset=UTF-8',
  };
}
