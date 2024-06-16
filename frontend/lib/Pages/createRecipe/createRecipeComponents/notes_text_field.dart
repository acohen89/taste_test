import 'package:flutter/material.dart';
import 'package:taste_test/Shared/constants.dart';

class NotesTextField extends StatelessWidget {
  const NotesTextField({
    super.key,
    required this.notesController,
    required this.inputBoxRadius,
  });

  final TextEditingController notesController;
  final double inputBoxRadius;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlignVertical: TextAlignVertical.bottom,
      maxLines: null,
      controller: notesController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.notes),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBoxRadius),
          borderSide: const BorderSide(color: greyColor),
        ),
        hintText: 'any notes on this recipe',
      ),
    );
  }
}
