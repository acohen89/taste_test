import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/constants.dart';

void getRecipesAndSetPrefs(String token, SharedPreferences prefs, loadingError, Function updateLoadingState, Function setRecipes) async {
    getUserRecipes(token).then((response) {
        if (response.statusCode >= 300) {
          loadingError("Error loading recipes");
          updateLoadingState(false); 
          return;
        }
          var recipes = jsonDecode(response.body)
              .map<Recipe>((r) => Recipe.fromJson(r))
              .toList();
          setRecipes(recipes); 
          updateLoadingState(false); 
          List<String> strRecipes = [for (var r in jsonDecode(response.body)) jsonEncode(r)];
          prefs.setStringList("recipes", strRecipes); 

      }).catchError((e) {
        print(e);
        loadingError("Error loading recipes");
        updateLoadingState(false); 
      });
  }

SnackBar snackBarError(String text, int duration) {
  return SnackBar(
    content: Text(text, textAlign: TextAlign.center,),
    duration:  Duration(milliseconds: duration),
    backgroundColor: errorRedColor,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(4),
  );
}
