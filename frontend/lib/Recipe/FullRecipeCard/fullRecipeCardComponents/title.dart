import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:taste_test/Recipe/FullRecipeCard/FullRecipeCard.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.widget,
  });

  final FullRecipeCard widget;

  @override
  Widget build(BuildContext context) {
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
