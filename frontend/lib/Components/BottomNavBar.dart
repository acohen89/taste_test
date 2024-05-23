

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:taste_test/Shared/constants.dart" as constants;
import 'package:taste_test/Shared/constants.dart';


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
    const containerPadding = 4.0; 
    const iconPadding = EdgeInsets.only(top: 2, left: 4, right: 4, bottom: 2);
    return Container(
      color: Colors.white,
      child:  Container(
        padding: const EdgeInsets.only(bottom:containerPadding, left: containerPadding, right: containerPadding, top:containerPadding),
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
         color: greyColor, 
         activeColor: Colors.white,
         tabBackgroundColor: greyColor,
         gap: 4, 
         padding: iconPadding, 
          tabs: const [
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

