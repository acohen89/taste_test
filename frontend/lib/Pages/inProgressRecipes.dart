import 'package:flutter/material.dart';
import 'package:taste_test/Components/BottomNavBar.dart';

class inProgressRecipes extends StatefulWidget {
  const inProgressRecipes({super.key});

  @override
  State<inProgressRecipes> createState() => _inProgressRecipesState();
}

class _inProgressRecipesState extends State<inProgressRecipes> {
  @override
  Widget build(BuildContext context) {
     return const Scaffold(
      bottomNavigationBar: BottomNavBar(startIndex: 2,),
    );
  }
}