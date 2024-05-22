

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:taste_test/constants.dart" as constants;


class BottomNavBar extends StatefulWidget {
  final int startIndex;
  
   const BottomNavBar({
    required this.startIndex,
    super.key,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child:  Padding(
        padding: EdgeInsets.all(4),
        child: GNav(
          selectedIndex: widget.startIndex,
          onTabChange: (value) {
            switch (value) {
              case 0: //Finished Recipes
                Navigator.pushNamed(context, "home");
              case 1: // Create
                Navigator.pushNamed(context, "createRecipe");
              case 2: // In Progress Recipes
                Navigator.pushNamed(context, "inProgressRecipes");
              case 3: // Settings
                Navigator.pushNamed(context, "settings");
                
            }
          },
         backgroundColor: Colors.white,
         color: constants.greyColor, 
         activeColor: Colors.white,
         tabBackgroundColor: constants.greyColor,
         gap: 8, 
         padding: EdgeInsets.all(8),
          tabs: [
            GButton(
              icon: Icons.done,
              text: 'Finished Recipes',
            ),
            GButton(
              icon: Icons.create,
              text: 'Create',
            ),
            GButton(
              icon: Icons.edit,
              text: 'Recipes In Progress',
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
            )
          ]
        ),
      ),
    );
  }
}

