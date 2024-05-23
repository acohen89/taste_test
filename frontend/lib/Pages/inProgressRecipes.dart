import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Components/BottomNavBar.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';

import 'package:taste_test/Shared/globalFunctions.dart';

class inProgressRecipes extends StatefulWidget {
  const inProgressRecipes({super.key});

  @override
  State<inProgressRecipes> createState() => _inProgressRecipesState();
}

class _inProgressRecipesState extends State<inProgressRecipes> {
  List<Recipe>? recipes;
  bool loadingRecipes = false;
  @override
  void initState() {
    super.initState();
    loadRecipes();

  }

  @override
  Widget build(BuildContext context) {
    print(recipes.toString());
    return const Scaffold(
      bottomNavigationBar: BottomNavBar(
        startIndex: 2,
      ),
    );
  }

  void loadingError(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void loadRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? strRecipes = prefs.getStringList("recipes");
    if (strRecipes == null) {
      String? token = prefs.getString("token");
      if (token == null) throw Exception("Null token");
      updateState(bool state) => setState(() => loadingRecipes = state);
      setRecipes(List<Recipe> recps) => setState(() => recipes = recps);
      getRecipesAndSetPrefs(token, prefs, loadingError, updateState, setRecipes);
    } else {
      List<Recipe>? ret = Recipe.stringsToRecipes(strRecipes);
      if (ret == null) throw Exception("Error converting string recipes to object");
      setState(() => recipes = ret);
    }
  }
}
