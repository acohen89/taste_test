import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Pages/fullRecipePageView.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/constants.dart';
import 'package:taste_test/Shared/globalFunctions.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final Function removeFunc;
  final Function setFocusRecipe;
  final Function deleteInProgressToggle;
  final Function resetDeleteIndex;
  final Function loadingError;
  final int deleteIPIndex;
  final bool forceReload;

  final int index;
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.removeFunc,
    required this.index,
    required this.setFocusRecipe,
    required this.deleteInProgressToggle,
    required this.deleteIPIndex,
    required this.resetDeleteIndex,
    required this.forceReload,
    required this.loadingError,
  });
  static const double imageHeight = 84;
  static const double imageWidth = 150;
  static const double sidePadding = 26;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  late Future<Recipe?>? recsReturn;
  @override
  void initState() {
    super.initState();
    recsReturn = getRecipeFinalVersion(widget.recipe.id.toString(), widget.loadingError, widget.forceReload);
  }

  //Padding
  final titlePadding = const EdgeInsets.only(top: 12, left: RecipeCard.sidePadding, right: 12);

  final sidePadding = 26.0;
  final procandIngPadding = const EdgeInsets.only(left: RecipeCard.sidePadding, top: 8, bottom: 4, right: RecipeCard.sidePadding);

  final lastEditedPadding = const EdgeInsets.only(right: 12, bottom: 8);

  //Style
  final titleStyle = GoogleFonts.merriweatherSans(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.8);

  final cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

  final deleteRecipeAnimation = const SpinKitCubeGrid(color: lightBlue, size: 200);

  final dt = DateFormat('h:mm a M-d');
  final lastEditedTexStyle = const TextStyle(fontSize: 11, fontStyle: FontStyle.italic);

  static const double cardElevation = 8;
  bool deletingRecipe = false;

  @override
  Widget build(BuildContext context) {
    final disableButtons = widget.deleteIPIndex != -1;

    final blurValue = widget.deleteIPIndex == -1 || widget.deleteIPIndex == widget.index ? 0.0 : 4.0;

    return FutureBuilder<Recipe?>(
        future: recsReturn,
        builder: (context, snapshot) {
          Recipe recipe;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SpinKitWave(color: lightBlue, size: 50);
          }
          recipe = snapshot.data == null ? widget.recipe : snapshot.data!;

          return ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3.5,
              child: deletingRecipe
                  ? deleteRecipeAnimation
                  : GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FullRecipePageView(recipe: recipe))),
                      // {if (!disableButtons) widget.setFocusRecipe(recipe)},
                      child: Card(
                          shape: cardShape,
                          elevation: cardElevation,
                          shadowColor: greyColor,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: titlePadding,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      recipe.title,
                                      style: titleStyle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                    padding: procandIngPadding,
                                    height: 200,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: ListView.builder(
                                                itemCount: recipe.ingredients.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  return Text(bullet + recipe.ingredients[i]);
                                                })),
                                        Expanded(
                                            child: ListView.builder(
                                                itemCount: recipe.procedure.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  return Text("${i + 1}. ${recipe.procedure[i]}");
                                                })),
                                      ],
                                    )),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        if (!disableButtons) {
                                          widget.deleteInProgressToggle(widget.index);
                                          await confirmDelete(context, recipe.title).then((delete) async {
                                            if (delete) {
                                              setState(() => deletingRecipe = true);
                                              String token = await getToken(null, "delete recipe in recipe card");
                                              bool success = await deleteRecipe(token, recipe.id.toString());
                                              if (!success) {
                                                deleteRecipeErrorPopUp("Error deleting recipe");
                                              } else {
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                deleteBeginningRecipeFromPrefs(prefs, (recipe.parentRID ?? recipe.id).toString());
                                                widget.removeFunc();
                                              }
                                              setState(() => deletingRecipe = false);
                                            }
                                          });
                                          widget.resetDeleteIndex();
                                        }
                                      },
                                      icon: const Icon(Icons.delete)),
                                  Padding(
                                    padding: lastEditedPadding,
                                    child: Text(
                                      "Last edited ${dt.format(DateTime.parse(recipe.last_edited))}",
                                      style: lastEditedTexStyle,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )),
                    ),
            ),
          );
        });
  }

  void deleteRecipeErrorPopUp(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
