import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Components/noRecipe.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/constants.dart';
import 'package:taste_test/Shared/globalFunctions.dart';

class inProgressRecipeCard extends StatefulWidget {
  final Recipe recipe;

  inProgressRecipeCard({super.key, required this.recipe});

  @override
  State<inProgressRecipeCard> createState() => _inProgressRecipeCardState();
}

class _inProgressRecipeCardState extends State<inProgressRecipeCard> {
  List<Recipe>? recipeIterations;
  late Future<List<Recipe>?> recsReturn;
  @override
  void initState() {
    super.initState();
    recsReturn = loadRecipeIterations(widget.recipe.id);
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>?>(
        future: recsReturn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SpinKitWave(color: lightBlue, size: 50);
          }
          var nullOrEmpty = snapshot.data != null ? snapshot.data!.isEmpty : true;
          if (nullOrEmpty) {
            return Container(child: const Center(child: Text("Add bitton ")));
          }
          recipeIterations = snapshot.data;
          // do this so the initial recipe can be displayed first
          if (recipeIterations?[0] != widget.recipe) recipeIterations?.insert(0, widget.recipe);
          if (recipeIterations == null) throw Exception("Recipe iterations null");
          List<Recipe> recps = recipeIterations!;
          return Card(
            elevation: 20,
            child: Row(
              children: [
                Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recps.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.white,
                            // padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: const Column(
                              children: [
                                Center(
                                    child: Text(
                                  "Really long string such that it overflows and I can see what happens",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 25),
                                )),
                              ],
                            ),
                          );
                        })),
              ],
            ),
          );
        });
  }

  Future<List<Recipe>?> loadRecipeIterations(int id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<Recipe>? recipesFromPrefs = getRecipeFromPrefs(id, sp);
    if (recipesFromPrefs != null) return recipesFromPrefs;
    final String? token = sp.getString("token");
    if (token == null) throw Exception("Null token");
    Response response = await getRecipeIterations(token, id);
    if (response.statusCode != 202) {
      loadingError("Error loading recipes");
      return null;
    }
    try {
      final List<String> strRecipes = [for (var r in jsonDecode(response.body)["iterations"]) jsonEncode(r)];
      sp.setStringList(id.toString(), strRecipes);
      return Recipe.stringsToRecipes(strRecipes);
    } catch (e) {
      throw Exception("$e, could not parse iterations body");
    }
  }

  List<Recipe>? getRecipeFromPrefs(int id, SharedPreferences prefs) {
    List<String>? recipeFromPrefs = prefs.getStringList(id.toString());
    if (recipeFromPrefs == null) return null;
    return Recipe.stringsToRecipes(recipeFromPrefs);
  }

  void loadingError(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
