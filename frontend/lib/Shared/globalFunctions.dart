import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/constants.dart';

Future<List<Recipe>?> getRecipesAndSetPrefs(
  String token,
  SharedPreferences prefs,
  Function loadingError,
) async {
  try {
    final response = await getUserRecipes(token);
    if (response.statusCode >= 300) {
      loadingError("Error loading recipes");
      return null;
    }
    var recipes = jsonDecode(response.body)
        .map<Recipe>((r) => Recipe.fromJson(r))
        .toList();

    await setPrefs(response.body, prefs);
    return recipes;
  } catch (e) {
    print(e);
    loadingError("Error loading recipes");
    return null;
  }
}

Future<void> setPrefs(String responseBody, SharedPreferences prefs) async {
  List<String> strRecipes = [
    for (var r in jsonDecode(responseBody)) jsonEncode(r)
  ];
  prefs.setStringList("recipes", strRecipes);
}

SnackBar snackBarError(String text, int duration) {
  return SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    duration: Duration(milliseconds: duration),
    backgroundColor: errorRedColor,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(4),
  );
}
