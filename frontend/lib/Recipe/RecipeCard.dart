import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final int deleteIPIndex;
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
  });
  static const double imageHeight = 84;
  static const double imageWidth = 150;
  static const double sidePadding = 26;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  //Padding
  final titlePadding =
      const EdgeInsets.only(top: 12, left: RecipeCard.sidePadding, right: 12);

  final sidePadding = 26.0;
  final procandIngPadding = const EdgeInsets.only(
      left: RecipeCard.sidePadding,
      top: 8,
      bottom: 4,
      right: RecipeCard.sidePadding);

  final lastEditedPadding = const EdgeInsets.only(right: 12, bottom: 8);

  //Style
  final titleStyle = GoogleFonts.merriweatherSans(
      fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.8);

  final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: lightBlue, width: 4));

  final deleteRecipeAnimation =
      const SpinKitCubeGrid(color: lightBlue, size: 200);

  final dt = DateFormat('h:mm a M-d');
  final lastEditedTexStyle = const TextStyle(fontSize: 11, fontStyle: FontStyle.italic);

  static const double cardElevation = 8;
  bool deletingRecipe = false;

  @override
  Widget build(BuildContext context) {
    final disableButtons = widget.deleteIPIndex != -1;

    final blurValue =
        widget.deleteIPIndex == -1 || widget.deleteIPIndex == widget.index
            ? 0.0
            : 4.0;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 3.5,
        child: deletingRecipe
            ? deleteRecipeAnimation
            : GestureDetector(
                onTap: () =>
                    {if (!disableButtons) widget.setFocusRecipe(widget.recipe)},
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
                                widget.recipe.title,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount:
                                              widget.recipe.ingredients.length,
                                          itemBuilder:
                                              (BuildContext context, int i) {
                                            return Text(bullet +
                                                widget.recipe.ingredients[i]);
                                          })),
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount:
                                              widget.recipe.procedure.length,
                                          itemBuilder:
                                              (BuildContext context, int i) {
                                            return Text(
                                                "${i + 1}. ${widget.recipe.procedure[i]}");
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
                                    await confirmDelete(
                                            context, widget.recipe.title)
                                        .then((delete) {
                                      if (delete) {
                                        setState(() => deletingRecipe = true);
                                        SharedPreferences.getInstance()
                                            .then((prefs) {
                                          return prefs.getString('token') ?? "";
                                        }).then((key) {
                                          if (key == "") {
                                            throw Exception("Empty key");
                                          }
                                          return deleteRecipe(
                                              key, widget.recipe.id.toString());
                                        }).then((res) {
                                          if (res.statusCode >= 300) {
                                            deleteRecipeErrorPopUp(
                                                "Error deleting recipe");
                                          } else {
                                            widget.removeFunc(widget.index);
                                          }
                                          setState(
                                              () => deletingRecipe = false);
                                        });
                                      }
                                    });
                                    widget.resetDeleteIndex();
                                  }
                                },
                                icon: const Icon(Icons.delete)),
                            Padding(
                              padding: lastEditedPadding,
                              child: Text(
                                "Last edited ${dt.format(DateTime.parse(widget.recipe.last_edited))}",
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
  }

  void deleteRecipeErrorPopUp(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: lightBlue, width: 1.2)),
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
                child:
                    const Text("Yes", style: TextStyle(color: Colors.white))),
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
}
