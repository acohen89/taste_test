import 'package:flutter/material.dart';

class createRecipeButton extends StatelessWidget {
  const createRecipeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () async {
        Navigator.pushNamed(context, "createRecipe");
      },
      elevation: 2.0,
      fillColor: Colors.white,
      padding: EdgeInsets.all(15.0),
      shape: const CircleBorder(),
      child: const Icon(
        Icons.edit_note_rounded,
        size: 30.0,
      ),
    );
  }
}
