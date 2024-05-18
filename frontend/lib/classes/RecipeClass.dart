import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/api_calls.dart';
import 'package:taste_test/classes/IngredientClass.dart';
import "package:taste_test/constants.dart" as constants;
import 'package:intl/intl.dart';
import "package:taste_test/home.dart";

class Recipe {
  final int id;
  final String title;
  final bool beginningRecipe;
  final String? parentRID;
  final String created;
  final String last_edited;
  final List ingredients;
  final String? image_url;
  final List procedure;
  final String? notes;
  final bool in_progress;
  final List iteration_ids;

  Recipe(
      this.id,
      this.title,
      this.beginningRecipe,
      this.parentRID,
      this.created,
      this.last_edited,
      this.ingredients,
      this.image_url,
      this.procedure,
      this.notes,
      this.in_progress,
      this.iteration_ids);

  Recipe.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        title = json['title'] as String,
        beginningRecipe = json['beginningRecipe'] as bool,
        parentRID = json['parentRID'] as String?,
        created = json['created'] as String,
        last_edited = json['last_edited'] as String,
        ingredients = json['ingredients'] as List,
        image_url = json['image_url'] as String?,
        procedure = json['procedure'] as List,
        notes = json['notes'] as String?,
        in_progress = json['in_progress'] as bool,
        iteration_ids = json['iteration_ids'] as List;

  @override
  String toString() {
    return title;
  }
}

class FullRecipeCard extends StatefulWidget {
  final Recipe recipe;
  final Function exitFocusedRecipe;
  const FullRecipeCard(
      {super.key, required this.recipe, required this.exitFocusedRecipe});

  @override
  State<FullRecipeCard> createState() => _FullRecipeCardState();
}

class _FullRecipeCardState extends State<FullRecipeCard> {
  //style
  final titleStyle = GoogleFonts.merriweatherSans(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      letterSpacing: -0.8);
  final titlePadding = const EdgeInsets.symmetric(horizontal: 24);
  final borderMargin =
      const EdgeInsets.only(left: 28, right: 28, bottom: 48, top: 60);
  final boxStyle = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: constants.greyColor,
        width: 4,
      ));
  final backIcon = const Icon(size: 35, Icons.arrow_back_rounded);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: borderMargin, // 12 px padding on all sides
      decoration: boxStyle,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () => widget.exitFocusedRecipe(), icon: backIcon)
            ],
          ),
          Padding(
            padding: titlePadding,
            child: Text(
              widget.recipe.title,
              style: titleStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

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
  static const bullet = "\u2022 ";
  static const double imageHeight = 84;
  static const double imageWidth = 150;
  static const double ingLeftPadding = 25;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  //Padding
  final titlePadding = const EdgeInsets.only(
      top: 12, left: RecipeCard.ingLeftPadding, right: 12);

  final individualIngPadding = const EdgeInsets.only(bottom: 4);

  final ingPadding =
      const EdgeInsets.only(left: RecipeCard.ingLeftPadding, top: 8);

  final lastEditedPadding = const EdgeInsets.only(right: 12, bottom: 8);

  //Style
  final titleStyle = GoogleFonts.merriweatherSans(
      fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.8);

  final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: constants.lightBlue, width: 4));

  final deleteRecipeAnimation =
      const SpinKitCubeGrid(color: constants.lightBlue, size: 200);

  final dt = DateFormat('h:mm a M-d');
  final lastEditedTexStyle = const TextStyle(fontSize: 11);

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
                onTap: () => {
                  if(!disableButtons)
                  widget.setFocusRecipe(widget.recipe)
                  },
                child: Card(
                    shape: cardShape,
                    elevation: cardElevation,
                    shadowColor: constants.greyColor,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: titlePadding,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            Padding(
                              padding: ingPadding,
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: List.generate(
                                    widget.recipe.ingredients.length, (i) {
                                  return Padding(
                                    padding: individualIngPadding,
                                    child: Text(RecipeCard.bullet +
                                        widget.recipe.ingredients[i]),
                                  );
                                }),
                              ),
                            ),
                          ],
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

  void deleteRecipeErrorPopUp(String text) {
    final snack = constants.snackBarError(text);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<bool> confirmDelete(BuildContext context, String title) {
    final Completer<bool> completer = Completer<bool>();
    final yesButtonStyle = OutlinedButton.styleFrom(
      backgroundColor: constants.lightBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
    final noButtonStyle = OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: constants.lightBlue, width: 1.2)),
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
