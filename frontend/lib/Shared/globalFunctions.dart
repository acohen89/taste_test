import 'dart:async';
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

Future<bool> confirmDelete(BuildContext context, String title) {
  final Completer<bool> completer = Completer<bool>();
  final yesButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: lightBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );
  final noButtonStyle = OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), side: const BorderSide(color: lightBlue, width: 1.2)),
  );

  final snack = SnackBar(
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Are you sure you want to delete $title?",
          style: const TextStyle(color: Colors.black),
          maxLines: 2,
          overflow: TextOverflow.clip,
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
              style: yesButtonStyle,
              onPressed: () {
                completer.complete(true);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white))),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
              style: noButtonStyle,
              onPressed: () {
                completer.complete(false);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: const Text("No")),
        ),
      ],
    ),
    duration: const Duration(seconds: 99999999999),
    backgroundColor: Colors.white,
    elevation: 20,
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snack);
  return completer.future;
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
