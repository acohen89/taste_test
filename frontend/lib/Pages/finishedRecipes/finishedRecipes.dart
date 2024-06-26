import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Recipe/RecipeCard.dart';
import 'package:taste_test/Components/BottomNavBar.dart';
import 'package:taste_test/Components/noRecipe.dart';
import 'package:taste_test/Shared/globalFunctions.dart';
import 'package:taste_test/Shared/constants.dart';

class FinishedRecipes extends StatefulWidget {
  final bool forceReload;
  const FinishedRecipes({super.key, this.forceReload = false});

  @override
  State<FinishedRecipes> createState() => _FinishedRecipesState();
}

class _FinishedRecipesState extends State<FinishedRecipes> {
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
    recs = loadRecipeFinalVersion(widget.forceReload);
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
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: const Text("Your Recipes"),
                    actions: [IconButton(onPressed: () => Navigator.pushNamed(context, "createRecipe"), icon: const Icon(Icons.add))],
                  ),
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
                        recipes = snapshot.data!; // needs a second non future to not display
                        List<Recipe> recps = snapshot.data!;
                        return ListView(
                          children: List.generate(recps.length, (i) {
                            return Padding(
                              padding: recipePadding,
                              child: RecipeCard(
                                recipe: recps[i],
                                removeFunc: updateRecipes,
                                index: i,
                                setFocusRecipe: setFocusRecipe,
                                deleteInProgressToggle: deleteInProgressOnIndex,
                                deleteIPIndex: deleteIPIndex,
                                resetDeleteIndex: resetDeleteIndex,
                                forceReload: widget.forceReload,
                                loadingError: loadingError,
                              ),
                            );
                          }),
                        );
                      })),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(startIndex: 2));
  }

  void loadingError(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<List<Recipe>?> loadRecipeFinalVersion(bool forceReload) async {
    List<Recipe>? filter(List<Recipe>? result) => result?.where((r) => r.in_progress == false).toList();
    await retrieveUserDetails();
    if (token == null) throw Exception("Null token");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await getMainRecipes(filter, prefs, token!, loadingError, forceReload);
  }

  Future<void> retrieveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('first_name') ?? '';
      token = prefs.getString('token') ?? '';
    });
    return;
  }
  updateRecipes(){
    recs = loadRecipeFinalVersion(false); 
  }

  void deleteUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
}
