import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Pages/inProgressRecipesPage.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/globalFunctions.dart';
import 'package:taste_test/Shared/constants.dart';

class inProgressRecipeCard extends StatefulWidget {
  const inProgressRecipeCard({
  super.key,
    required this.recipe,
    required this.horizontalCardPadding,
  });

  final Recipe recipe;
  final double horizontalCardPadding;
  @override
  State<inProgressRecipeCard> createState() => _inProgressRecipeCardState();
}

class _inProgressRecipeCardState extends State<inProgressRecipeCard> {
  @override
  Widget build(BuildContext context) {
  final double verticalSpacing = widget.recipe.in_progress ? 24 : 0; 
    return Column(
      children: [
        Flexible(
          flex: 42,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: verticalSpacing, horizontal: 24),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - (widget.horizontalCardPadding * 2),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(widget.recipe.in_progress) Title(),
                  if (widget.recipe.in_progress) const Divider(),
                  const SizedBox(height: 8),
                  const Text("Ingredients", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
                  Ingredients(context),
                  const SizedBox(height: 8),
                  const Text("Procedure", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
                  Procedure(context),
                  const SizedBox(height: 8),
                  const Text("Notes", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
                  widget.recipe.notes == null
                      ? const Text(
                          "none",
                          style: TextStyle(color: greyColor, fontStyle: FontStyle.italic),
                        )
                      : Text(
                          widget.recipe.notes!,
                          maxLines: null,
                        ),
                ],
              ),
            ),
          ),
        ),
        Flexible(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () async {
                        final String deleteText = widget.recipe.title + (widget.recipe.beginningRecipe ? " and all of it's iterations" : "");
                        bool delete = await confirmDelete(context, deleteText);
                        if (delete) {
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          String? token = sp.getString("token");
                          if (token == null) return deleteRecipeErrorPopUp("Error deleting recipe", "Null Token ");
                          Response res = await deleteRecipe(token, widget.recipe.id.toString());
                          if (res.statusCode >= 300) {
                            return deleteRecipeErrorPopUp("Error deleting recipe", res.body);
                          } else {
                            if (widget.recipe.beginningRecipe) {
                              await deleteBeginningRecipeFromPrefs(sp, widget.recipe.id.toString()); 
                            } else {
                              deleteIterationFromPrefs(sp, widget.recipe.parentRID.toString(), widget.recipe.id.toString());
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const inProgressRecipes()));
                          }
                        }
                      },
                      icon: const Icon(size: 18, Icons.delete)),
                  LastEdited(),
                ],
              ),
            ))
      ],
    );
  }

  void deleteRecipeErrorPopUp(String text, String exception, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
    throw Exception(exception);
  }

  Text LastEdited() {
    return Text("Edited ${DateFormat('h:mma M/d').format(DateTime.parse(widget.recipe.last_edited))}",
        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic));
  }

  Column Procedure(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.recipe.procedure.length; i++)
          RichText(
            text: TextSpan(
              text: "${i + 1}. ",
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(text: widget.recipe.procedure[i], style: const TextStyle(fontSize: 16)),
              ],
            ),
            maxLines: null,
          )
      ],
    );
  }

  Column Ingredients(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (String ingredient in widget.recipe.ingredients)
          RichText(
            text: TextSpan(
              text: bullet,
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(text: ingredient, style: const TextStyle(fontSize: 16)),
              ],
            ),
            maxLines: null,
          )
      ],
    );
  }

  Center Title() {
    return Center(
        child: AutoSizeText(
      widget.recipe.title,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      minFontSize: 14,
      maxLines: 3,
    ));
  }
}
