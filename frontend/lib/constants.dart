import 'package:flutter/material.dart';

const Color lightBlue = Color.fromARGB(255, 13, 193, 242);
const Color greyColor = Color.fromARGB(255, 114, 115, 116);
const Color errorRedColor = Color.fromARGB(255, 228, 88, 88);

ColorScheme greyColorScheme =
    ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 114, 115, 116));

SnackBar snackBarError(String text) {
  return SnackBar(
    content: Text(text, textAlign: TextAlign.center,),
    duration: const Duration(milliseconds: 2250),
    backgroundColor: errorRedColor,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(4),
  );
}
