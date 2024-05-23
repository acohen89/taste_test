import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import "package:taste_test/Shared/constants.dart"; 

class FullRecipeCard extends StatefulWidget {
  final Recipe recipe;
  final Function exitFocusedRecipe;
  const FullRecipeCard(
      {super.key, required this.recipe, required this.exitFocusedRecipe});

  @override
  State<FullRecipeCard> createState() => _FullRecipeCardState();
}

class _FullRecipeCardState extends State<FullRecipeCard> {

  final titleStyle = GoogleFonts.merriweatherSans(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      letterSpacing: -0.8);

  final titlePadding = const EdgeInsets.symmetric(horizontal: 24);

  final borderMargin =
      const EdgeInsets.only(left: 28, right: 28, bottom: 40, top: 40);

  final boxStyle = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: greyColor,
        width: 4,
      ));

  final backIcon = const Icon(size: 35, Icons.arrow_back_rounded);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: borderMargin,
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
