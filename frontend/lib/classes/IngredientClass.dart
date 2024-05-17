import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:taste_test/constants.dart" as constants;

enum Unit { g, ml, cup, tsp, tbs, gal, L, oz }

class Ingredient {
  double quantity;
  Unit unit;
  String food;

  Ingredient(this.quantity, this.unit, this.food);

  @override
  String toString() {
    return "$quantity ${unit.name} $food";
  }
}

class AddedIngredient extends StatelessWidget {
  AddedIngredient({
    super.key,
    required this.unit,
    required this.food,
    required this.quantity,
    required this.deleteFunction,
    required this.index,
  });

  final Unit unit;
  final String food;
  final double quantity;
  final deleteFunction;
  final int index;
  var fontStyle = GoogleFonts.merriweatherSans(
    color: constants.greyColor,
    fontSize: 18,
  );
  @override
  Widget build(BuildContext context) {
    final double textSpaceing = MediaQuery.of(context).size.width * 0.02;
    final double unitSpacing = MediaQuery.of(context).size.width * 0.01;
    String q = quantity % 1.0 == 0.0
        ? quantity.truncate().toString()
        : quantity.toStringAsFixed(2);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(q, style: fontStyle),
            SizedBox(width: unitSpacing),
            Text(unit.name, style: fontStyle),
            SizedBox(width: textSpaceing),
            Expanded(child: AutoSizeText(food, style: fontStyle, maxLines: 3)),
            IconButton(
                onPressed: () {
                  deleteFunction(index);
                },
                icon: const Icon(Icons.delete))
          ],
        ),
        const Divider()
      ],
    );
  }
}
