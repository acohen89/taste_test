import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Recipe/InProgress/inProgressRecipeCard.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:taste_test/Pages/createRecipe.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/constants.dart';
import 'package:taste_test/Shared/globalFunctions.dart';

class inProgressRecipeBuilder extends StatefulWidget {
  final Recipe recipe;
  final double horizontalCardPadding;
  final double dotHeight;
  final double dotSize;

  const inProgressRecipeBuilder({super.key, required this.dotHeight, required this.dotSize, required this.recipe, required this.horizontalCardPadding});

  @override
  State<inProgressRecipeBuilder> createState() => _inProgressRecipeBuilderState();
}

class _inProgressRecipeBuilderState extends State<inProgressRecipeBuilder> {
  final PageController _controller = PageController();
  List<Recipe>? recipeIterations;
  late Future<List<Recipe>?> recsReturn;
  @override
  void initState() {
    super.initState();
    recsReturn = loadRecipeIterations(widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>?>(
        future: recsReturn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SpinKitWave(color: lightBlue, size: 50);
          }
          if (snapshot.data == null) {
            return const Center(child: Text("Add button "));
          }
          recipeIterations = snapshot.data;
          // do this so the initial recipe can be displayed first
          if (recipeIterations!.isEmpty) recipeIterations!.add(widget.recipe);
          if (recipeIterations?[0] != widget.recipe) recipeIterations?.insert(0, widget.recipe);
          if (recipeIterations == null) throw Exception("Recipe iterations null");
          List<Recipe> recps = recipeIterations!;
          return Column(
            children: [
              Expanded(
                child: Card(
                  elevation: 20,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          scrollDirection: Axis.horizontal,
                          itemCount: recps.length + 1,
                          itemBuilder: (context, index) {
                            return index == recps.length ? 
                            AddIteration(recps[index-1])
                            : inProgressRecipeCard(
                              horizontalCardPadding: widget.horizontalCardPadding,
                              recipe: recps[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               Padding(
                 padding: EdgeInsets.symmetric(vertical: widget.dotHeight),
                 child: SmoothPageIndicator(
                  controller: _controller,
                  count: recps.length + 1,
                  effect: WormEffect(dotWidth: widget.dotSize, dotHeight: 8, activeDotColor: lightBlue, dotColor: greyColor),
                               ),
               ),
            ],
          );
        });
  }

  Container AddIteration(Recipe r) {
    return  Container(
      // color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.18, vertical:  MediaQuery.of(context).size.height * 0.38),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
           side: const BorderSide(width: 2.0, color: lightBlue), 
           shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), 
            )        ),
        onPressed: () {
          Navigator.push(context,   MaterialPageRoute(
            builder: (context) => CreateRecipe(isIteration: true,
              id: r.id,
             title: r.title, parentRID: r.parentRID, ingredientList: [for(var i in r.ingredients) i.toString()], procedureList: [for(var p in r.procedure) p.toString()], notes: r.notes
             )));
        }, child: 
        Text("Add a new iteration")),
    ); 
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
