import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Pages/finishedRecipes.dart';
import 'package:taste_test/Recipe/fullRecipeCard.dart';
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
  bool deletingRecipe = false;
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
                  color: Colors.transparent,
                  elevation: 15,
                  child: deletingRecipe
                      ? const SpinKitWave(color: lightBlue, size: 50)
                      : Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _controller,
                                scrollDirection: Axis.horizontal,
                                itemCount: recps.length + 1,
                                itemBuilder: (context, index) {
                                  return index == recps.length
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AddIterationButton(recps[index - 1]),
                                            CompleteRecipe(context, recps),
                                          ],
                                        )
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

  OutlinedButton CompleteRecipe(BuildContext context, List<Recipe> recps) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 2.0, color: lightBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            )),
        onPressed: () async {
          final navigator = Navigator.of(context);
          setState(() => deletingRecipe = true);
          final String token = await getToken(null, "Complete Recipe in IPRecipeBuilder");
          Response response = await updateRecipeProgress(token, recps[0].id);
          if (response.statusCode == 404) throw Exception("Id ${recps[0].id} not found");
          if (response.statusCode == 406) throw Exception("Id param not properly given");
          if (response.statusCode == 500) throw Exception("500 response");
          setState(() => deletingRecipe = false);
          navigator.pushNamed("finishedRecipesWithReload");
        },
        child: const Text("Complete Recipe"));
  }

  OutlinedButton AddIterationButton(Recipe r) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 2.0, color: lightBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            )),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateRecipe(
                      isIteration: true,
                      id: r.id,
                      title: r.title,
                      parentRID: r.parentRID,
                      ingredientList: [for (var i in r.ingredients) i.toString()],
                      procedureList: [for (var p in r.procedure) p.toString()],
                      notes: r.notes)));
        },
        child: Text("Add a new iteration"));
  }

  Future<List<Recipe>?> loadRecipeIterations(int id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<Recipe>? recipesFromPrefs = getIterationRecipeFromPrefs(id, sp);
    if (recipesFromPrefs != null) return recipesFromPrefs;
    final String token = await getToken(sp, "loadRecipeIterations in ipRecipeBuilder");
    try {
      List<String>? strRecipes = await getRecipeIterationsAndSetPrefs(token, id, sp, loadingError);
      if (strRecipes == null) throw Exception("Recipes null");
      return Recipe.stringsToRecipes(strRecipes);
    } catch (e) {
      throw Exception("$e, could not parse iterations body");
    }
  }

  List<Recipe>? getIterationRecipeFromPrefs(int id, SharedPreferences prefs) {
    List<String>? recipeFromPrefs = prefs.getStringList("${id.toString()} iterations");
    if (recipeFromPrefs == null) return null;
    return Recipe.stringsToRecipes(recipeFromPrefs);
  }

  void loadingError(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
