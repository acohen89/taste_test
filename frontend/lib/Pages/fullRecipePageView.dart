import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:taste_test/Recipe/InProgress/inProgressRecipeCard.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';

class FullRecipePageView extends StatefulWidget {
  final Recipe recipe;
  const FullRecipePageView({super.key, required this.recipe});

  @override
  State<FullRecipePageView> createState() => _FullRecipePageViewState();
}

class _FullRecipePageViewState extends State<FullRecipePageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 16, right: 16, left: 16),
      child: Column(
        children: [
          TopBar(context),
          const Divider(),
          Expanded(child: inProgressRecipeCard(recipe: widget.recipe, horizontalCardPadding: 0)),
        ],
      ),
    ));
  }

  Stack TopBar(BuildContext context) {
    return Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                widget.recipe.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                minFontSize: 14,
                maxLines: 3,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    size: 32,
                  )),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                  
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 24,
                  )),
            )
          ],
        );
  }
}
