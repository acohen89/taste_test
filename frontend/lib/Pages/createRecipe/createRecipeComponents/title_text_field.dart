import 'package:flutter/material.dart';
import 'package:taste_test/Shared/constants.dart';

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.titleController,
    required this.inputBoxRadius,
  });

  final TextEditingController titleController;
  final double inputBoxRadius;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.bottom,
      maxLines: null,
      controller: titleController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.title),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBoxRadius),
          borderSide: const BorderSide(color: greyColor),
        ),
        hintText: 'enter recipe title',
      ),
    );
  }
}
