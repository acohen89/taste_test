import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Ingredient/IngredientClass.dart';
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

Future<Recipe?>? getRecipeFinalVersion(String id, Function loadingError, bool forceReload) async {
SharedPreferences sp = await SharedPreferences.getInstance(); 
String? token = sp.getString("token");
if(token == null) throw Exception("Null token");
String? recipe = await getIterationAndSetPrefs(id, sp, token, loadingError, forceReload); 
if(recipe == null) return null; 
return Recipe.stringsToRecipes([recipe])!.first;


}

Future<String> getIterationAndSetPrefs(String id, SharedPreferences sp, String token, Function loadingError, bool forceReload) async {
  if (sp.containsKey("$id iterations") && !forceReload) {
    List<String>? strRecipes = sp.getStringList("$id iterations");
    if (strRecipes == null) throw Exception("Null recipe");
    return strRecipes.last;
  } else {
    List<String>? recipeIterations = await getRecipeIterationsAndSetPrefs(token, int.parse(id), sp, loadingError);
    if (recipeIterations == null) throw Exception("null recipe");
    return recipeIterations.last;
  }
}

Future<List<String>?> getRecipeIterationsAndSetPrefs(String token, int id, SharedPreferences sp, Function loadingError) async {
  Response response = await getRecipeIterations(token, id);
  if (response.statusCode != 202) {
    loadingError("Error loading recipes");
    return null;
  }
  final List<String> strRecipes = [for (var r in jsonDecode(response.body)["iterations"]) jsonEncode(r)];
  sp.setStringList("${id.toString()} iterations", strRecipes);
  return strRecipes;
}

Future<List<Recipe>?> getMainRecipes(Function filter, SharedPreferences prefs, String token, Function loadingError, bool forceReload) async {
  // if forceReload is true, we want to hit the api so we set the recipeFromPrefs to null to force that functionality
  List<String>? recipesFromPrefs = forceReload ? null : getMainRecipesFromPrefs(prefs);
  List<Recipe>? result;
  if (recipesFromPrefs == null || recipesFromPrefs.isEmpty) {
    result = await getRecipesAndSetPrefs(token, prefs, loadingError);
  } else {
    result = Recipe.stringsToRecipes(recipesFromPrefs);
  }
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
  List<String>? idList = sp.getStringList("recipeIDList"); 
  if (idList == null) throw Exception("recipeIDList not in sp, in deleteBeginningRecipeFromPrefs");
  bool hasId = idList.remove(id); 
  if (!hasId) throw Exception("recipeIDList does not contain $id, in deleteBeginningRecipeFromPrefs");
  sp.setStringList("recipeIDList", idList); 
  await sp.remove(id);
  await sp.remove("$id iterations");
}

void deleteUserDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}


Future<String> getToken([SharedPreferences? sp, String errorLocation=""]) async {
  if(sp == null){
    SharedPreferences sp = await SharedPreferences.getInstance();
  }
  String? token = sp!.getString("token");
  if(token == null) throw Exception("Null token in $errorLocation");
  return token; 
}