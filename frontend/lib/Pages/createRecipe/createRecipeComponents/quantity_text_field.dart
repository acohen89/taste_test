import 'package:flutter/material.dart';
import 'package:taste_test/Shared/constants.dart';

class QuantityTextField extends StatelessWidget {
  const QuantityTextField({
    super.key,
    required this.quantityController,
    required this.hintTextStyle,
    required this.ingredientInputRadius,
  });

  final TextEditingController quantityController;
  final TextStyle hintTextStyle;
  final double ingredientInputRadius;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: quantityController,
      decoration: InputDecoration(
          hintStyle: hintTextStyle,
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ingredientInputRadius),
            borderSide: const BorderSide(color: greyColor),
          ),
          hintText: "quantity"),
    );
  }
}
