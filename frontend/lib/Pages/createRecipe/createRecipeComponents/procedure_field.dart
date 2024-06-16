import 'package:flutter/material.dart';

class ProcedureField extends StatelessWidget {
  const ProcedureField({
    super.key,
    required this.procedureController,
    required this.procedureMinLines,
    required this.procedureMaxLines,
  });

  final TextEditingController procedureController;
  final int procedureMinLines;
  final int procedureMaxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
        textAlignVertical: TextAlignVertical.bottom,
        decoration: const InputDecoration(hintText: "enter the steps you took to create this recipe", hintStyle: TextStyle(fontSize: 10)),
        minLines: procedureMinLines,
        maxLines: procedureMaxLines,
        controller: procedureController);
  }
}
