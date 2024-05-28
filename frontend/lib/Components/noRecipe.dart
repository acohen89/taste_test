import 'package:flutter/material.dart';

class NoRecipes extends StatelessWidget {
  final String text;
  const NoRecipes({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
      child: Center(
          child: Text(
        text,
        style: TextStyle(
          fontSize: 60.0,
          color: const Color.fromARGB(160, 120, 120, 115),
          fontWeight: FontWeight.w300,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.2), // Reduced opacity for a more subtle shadow
              offset: Offset(2, 2), // Adjusted offset
              blurRadius: 5, // Reduced blur radius
            ),
          ],
        ),
        textAlign: TextAlign.center,
      )),
    );
  }
}
