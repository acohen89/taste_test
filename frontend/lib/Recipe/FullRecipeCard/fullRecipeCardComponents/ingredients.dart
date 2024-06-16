import 'package:flutter/material.dart';
import 'package:taste_test/Recipe/FullRecipeCard/FullRecipeCard.dart';
import 'package:taste_test/Shared/constants.dart';

class Ingredients extends StatelessWidget {
  const Ingredients({
    super.key,
    required this.widget,
    required this.context,
  });

  final FullRecipeCard widget;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
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
}
