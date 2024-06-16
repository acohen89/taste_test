import 'package:flutter/material.dart';
import 'package:taste_test/Recipe/FullRecipeCard/FullRecipeCard.dart';

class Procedure extends StatelessWidget {
  const Procedure({
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
}
