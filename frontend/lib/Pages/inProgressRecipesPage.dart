
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Components/BottomNavBar.dart';
import 'package:taste_test/Components/noRecipe.dart';
import 'package:taste_test/Recipe/InProgress/inProgressRecipeBuilder.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/constants.dart';

import 'package:taste_test/Shared/globalFunctions.dart';

class inProgressRecipes extends StatefulWidget {
  const inProgressRecipes({super.key});

  @override
  State<inProgressRecipes> createState() => _inProgressRecipesState();
}

class _inProgressRecipesState extends State<inProgressRecipes> {
  bool loadingRecipes = false;
  late Future<List<Recipe>?> recs;
  @override
  void initState() {
    super.initState();
    recs = loadMainRecipes();
  }
  @override
  Widget build(BuildContext context) {
    final double horizontalCardPadding = MediaQuery.of(context).size.width * 0.05;
    final cardPadding =
        EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.08, horizontal: horizontalCardPadding);
    return PopScope(
      canPop: false,
      child: Scaffold(
          bottomNavigationBar: const BottomNavBar(
            startIndex: 0,
          ),
          body: FutureBuilder<List<Recipe>?>(
              future: recs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SpinKitWave(color: lightBlue, size: 50);
                }
                //TODO: Show dots on side of the screen idicating how many recipes there are
                var nullOrEmpty = snapshot.data != null ? snapshot.data!.isEmpty : true;
                if (!nullOrEmpty) {
                  List<Recipe>? recipes = snapshot.data;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: recipes!.length,
                          itemBuilder: (context, index) {
                            return Container(
                                color: Colors.white,
                                padding: cardPadding,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: inProgressRecipeBuilder(
                                    recipe: recipes[index], horizontalCardPadding: horizontalCardPadding),
                              );
                              }
                      )
                  )],
                  );
                }
                return const NoRecipes(text: "No In Progress Recipes");
              })),
    );
  }

  void loadingError(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<List<Recipe>?> loadMainRecipes() async {
    List<Recipe> filter(List<Recipe> recps) => recps.where((r) => r.in_progress == true).toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? strRecipes = prefs.getStringList("recipes");
    strRecipes = null;
    if (strRecipes == null) {
      String? token = prefs.getString("token");
      if (token == null) throw Exception("Null token");
      List<Recipe>? recipeReturn = await getRecipesAndSetPrefs(token, prefs, loadingError);
      if (recipeReturn == null) throw Exception("Null recipes");
      return filter(recipeReturn);
    } else {
      List<Recipe>? recipes = Recipe.stringsToRecipes(strRecipes);
      if (recipes == null) throw Exception("Error converting string recipes to object");
      return filter(recipes);
    }
  }

}
