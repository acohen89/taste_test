import 'package:flutter/material.dart';
import 'package:taste_test/Shared/constants.dart';

class IngredientTextField extends StatelessWidget {
  const IngredientTextField({
    super.key,
    required this.ingredientsController,
    required this.hintTextStyle,
    required this.ingredientInputRadius,
  });

  final TextEditingController ingredientsController;
  final TextStyle hintTextStyle;
  final double ingredientInputRadius;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlignVertical: TextAlignVertical.bottom,
      controller: ingredientsController,
      decoration: InputDecoration(
        hintStyle: hintTextStyle,
        isDense: true,
        contentPadding: const EdgeInsets.all(8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ingredientInputRadius),
          borderSide: const BorderSide(color: greyColor),
        ),
        hintText: 'ingredient',
      ),
    );
  }
}
