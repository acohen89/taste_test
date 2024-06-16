import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taste_test/Recipe/FullRecipeCard/FullRecipeCard.dart';

class LastEdited extends StatelessWidget {
  const LastEdited({
    super.key,
    required this.widget,
  });

  final FullRecipeCard widget;

  @override
  Widget build(BuildContext context) {
    return Text("Edited ${DateFormat('h:mma M/d').format(DateTime.parse(widget.recipe.last_edited))}",
        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic));
  }
}
