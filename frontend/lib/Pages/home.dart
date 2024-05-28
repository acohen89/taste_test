import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Recipe/FullRecipeCard.dart';
import 'package:taste_test/Recipe/RecipeCard.dart';
import 'package:taste_test/Components/BottomNavBar.dart';
import 'package:taste_test/Components/noRecipe.dart';
import 'package:taste_test/Shared/globalFunctions.dart';
import 'package:taste_test/Shared/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name;
  String? token;
  double blurValue = 0;
  int deleteIPIndex = -1;
  List<Recipe>? recipes;
  Recipe? focusedRecipe;
  bool loadingRecipes = false;
  static const recipePadding = EdgeInsets.only(left: 10, right: 10, bottom: 8);
  late Future<List<Recipe>?> recs;
  @override
  void initState() {
    super.initState();
    recs = loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
              child: Scaffold(
                  backgroundColor: const Color.fromARGB(255, 251, 234, 234),
                  appBar: AppBar(
                    title: const Text("Your Recipes"),
                    actions: [
                      IconButton(
                          onPressed: () => Navigator.pushNamed(context, "createRecipe"), icon: const Icon(Icons.add))
                    ],
                  ),
                  drawer: Drawer(
                      child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                        ),
                        child: Text('Hello $name'),
                      ),
                      ListTile(
                        title: const Text('Logout'),
                        onTap: () async {
                          deleteUserDetails();
                          Navigator.pop(context);
                          if (context.mounted) Navigator.of(context).pushNamed("login");
                        },
                      ),
                    ],
                  )),
                  body: FutureBuilder<List<Recipe>?>(
                      future: recs,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SpinKitWave(color: lightBlue, size: 50);
                        }
                        var nullOrEmpty = snapshot.data != null ? snapshot.data!.isEmpty : true;
                        if (nullOrEmpty) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NoRecipes(text: "No finished recipes"),
                            ],
                          );
                        }
                        List<Recipe> recps = snapshot.data!;
                        return ListView(
                          children: List.generate(recps.length, (i) {
                            return Padding(
                              padding: recipePadding,
                              child: RecipeCard(
                                  recipe: recps[i],
                                  removeFunc: removeRecipe,
                                  index: i,
                                  setFocusRecipe: setFocusRecipe,
                                  deleteInProgressToggle: deleteInProgressOnIndex,
                                  deleteIPIndex: deleteIPIndex,
                                  resetDeleteIndex: resetDeleteIndex),
                            );
                          }),
                        );
                      })),
            ),
            focusedRecipe != null
                ? Scaffold(
                    backgroundColor: Colors.transparent,
                    body: FullRecipeCard(
                      recipe: focusedRecipe!,
                      exitFocusedRecipe: exitFocusedRecipe,
                    ))
                : Container(),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(startIndex: 2));
  }

  Future<List<Recipe>?> loadRecipes() async {
    await retrieveUserDetails();
    if (token == null) throw Exception("Null token");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? recipesFromPrefs = prefs.getStringList("recipes"); 
    List<Recipe>? result = recipesFromPrefs == null ? await getRecipesAndSetPrefs(token!, prefs, loadingError) :  Recipe.stringsToRecipes(recipesFromPrefs); 
    return result?.where((r) => r.in_progress == false).toList();
  }

  Future<void> retrieveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('first_name') ?? '';
      token = prefs.getString('token') ?? '';
    });
    return;
  }

  void deleteUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('id');
    prefs.remove('username');
    prefs.remove('first_name');
    prefs.remove('last_name');
    prefs.remove('email');
  }

  void deleteInProgressOnIndex(int index) {
    setState(() => deleteIPIndex = index);
  }

  void resetDeleteIndex() {
    setState(() => deleteIPIndex = -1);
  }

  void setFocusRecipe(Recipe r) {
    setState(() {
      focusedRecipe = r;
      blurValue = 8;
    });
  }

  void exitFocusedRecipe() {
    setState(() {
      focusedRecipe = null;
      blurValue = 0;
    });
  }

  void removeRecipe(int index) {
    setState(() {
      recipes!.removeAt(index);
    });
  }

  void loadingError(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}

class createRecipeButton extends StatelessWidget {
  const createRecipeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () async {
        Navigator.pushNamed(context, "createRecipe");
      },
      elevation: 2.0,
      fillColor: Colors.white,
      padding: EdgeInsets.all(15.0),
      shape: const CircleBorder(),
      child: const Icon(
        Icons.edit_note_rounded,
        size: 30.0,
      ),
    );
  }
}
