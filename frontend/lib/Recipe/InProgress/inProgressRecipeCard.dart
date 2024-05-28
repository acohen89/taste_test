import 'package:flutter/material.dart';
import 'package:taste_test/Recipe/InProgress/inProgressRecipeBuilder.dart';

import 'package:taste_test/Recipe/RecipeClass.dart';

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width - (widget.horizontalCardPadding * 2),
      child: const Column(
        children: [
          Center(
              child: Text(
            "Really long string such that it overflows and I can see what happens",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25),
          )),
        ],
      ),
    );
  }
}
