import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Pages/inProgressRecipe/inProgressRecipesPage.dart';
import 'package:taste_test/Recipe/FullRecipeCard/fullRecipeCardComponents/ingredients.dart';
import 'package:taste_test/Recipe/FullRecipeCard/fullRecipeCardComponents/last_edited.dart';
import 'package:taste_test/Recipe/FullRecipeCard/fullRecipeCardComponents/procedure.dart';
import 'package:taste_test/Recipe/FullRecipeCard/fullRecipeCardComponents/title.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/globalFunctions.dart';
import 'package:taste_test/Shared/constants.dart';

class FullRecipeCard extends StatefulWidget {
  const FullRecipeCard({
    super.key,
    required this.recipe,
    required this.horizontalCardPadding,
    required this.isFinished,
  });

  final Recipe recipe;
  final double horizontalCardPadding;
  final bool isFinished;
  @override
  State<FullRecipeCard> createState() => _FullRecipeCardState();
}

class _FullRecipeCardState extends State<FullRecipeCard> {
  @override
  Widget build(BuildContext context) {
    final double verticalSpacing = !widget.isFinished ? 24 : 0;
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
                  if (!widget.isFinished) TitleWidget(widget: widget),
                  if (!widget.isFinished) const Divider(),
                  const SizedBox(height: 8),
                  const Text("Ingredients", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
                  Ingredients(widget: widget, context: context),
                  const SizedBox(height: 8),
                  const Text("Procedure", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
                  Procedure(widget: widget, context: context),
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
                          final String token = await getToken(sp, "deleteRecipe in fullRecipeCard");
                          if (token == null) return deleteRecipeErrorPopUp("Error deleting recipe", "Null Token ");
                          bool success = await deleteRecipe(token, widget.recipe.id.toString());
                          if (!success) {
                            return deleteRecipeErrorPopUp("Error deleting recipe", "");
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
                  LastEdited(widget: widget),
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
}
