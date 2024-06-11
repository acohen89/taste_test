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
    var recipes = jsonDecode(response.body).map<Recipe>((r) => Recipe.fromJson(r)).toList();
    await setMainRecipePrefs(response.body, prefs);
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: lightBlue, width: 1.2)),
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

Future<List<Recipe>?> getMainRecipes(Function filter, SharedPreferences prefs, String token, Function loadingError) async {
  List<String>? recipesFromPrefs = getMainRecipesFromPrefs(prefs);
  recipesFromPrefs = null;
  List<Recipe>? result = (recipesFromPrefs == null || recipesFromPrefs.isEmpty)
      ? await getRecipesAndSetPrefs(token, prefs, loadingError)
      : Recipe.stringsToRecipes(recipesFromPrefs);
  return filter(result);
}

List<String>? getMainRecipesFromPrefs(SharedPreferences sp) {
  List<String>? recipeIds = sp.getStringList("recipeIDList");
  if (recipeIds == null || recipeIds.isEmpty) return recipeIds;
  List<String>? strRecipes = [];
  try {
    for (int i = 0; i < recipeIds.length; i++) {
      var r = sp.getString(recipeIds[i]);
      if (r == null) throw Exception("Recipe null");
      strRecipes.add(r);
    }
  } catch (e) {
    print(e);
  }
  if (strRecipes.isEmpty) print("No recipes");
  return strRecipes;
}

Future<void> setMainRecipePrefs(String responseBody, SharedPreferences prefs) async {
  try {
    var resMap = jsonDecode(responseBody);
    Map<String, dynamic> recipeIDs = {};
    resMap.forEach((recipe) => recipeIDs[recipe["id"].toString()] = recipe);
    List<String> idList = [];
    recipeIDs.forEach((id, recipe) {
      idList.add(id);
      prefs.setString(id, jsonEncode(recipe));
    });
    prefs.setStringList("recipeIDList", idList);
  } catch (e) {
    throw Exception("$e, trying to set main recipe prefs");
  }
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

void deleteIterationFromPrefs(SharedPreferences sp, String parentRID, String id) {
  if (!sp.containsKey("$parentRID iterations")) throw Exception("sp does contain parentRID $parentRID, trying to deleteIterationFromPrefs");
  List<String>? iterationList = sp.getStringList("$parentRID iterations");
  if (iterationList == null) throw Exception("parentRID $parentRID iteration list is null, trying to deleteIterationFromPrefs");
  bool removed = false;
  for (String strRecipe in iterationList) {
    var mapRecipe = jsonDecode(strRecipe);
    if (mapRecipe["id"].toString() == id) {
      iterationList.remove(strRecipe);
      removed = true;
      break;
    }
  }
  if (!removed) throw Exception("Could not find $id in $parentRID list, trying to deleteIterationFromPrefs ");
  sp.setStringList("$parentRID iterations", iterationList);
}

Future<void> deleteBeginningRecipeFromPrefs(SharedPreferences sp, String id) async {
  if (!sp.containsKey("$id iterations")) throw Exception("sp does contain beginning $id iterations, trying to deleteBeginningRecipeFromPrefs");
  if (!sp.containsKey(id)) throw Exception("sp does contain recipe $id, trying to deleteBeginningRecipeFromPrefs");
  await sp.remove(id); 
  await sp.remove("$id iterations"); 
}


void deleteUserDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
