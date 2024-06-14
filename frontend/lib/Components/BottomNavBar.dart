import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final double hoPadding = width / 30.7;
    final double bottomPadding = height / 38.83;
    final double topPadding = height / 66.57;
    const iconPadding = EdgeInsets.only(top: 2, left: 4, right: 4, bottom: 2);
    return Container(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: bottomPadding, top: topPadding, right: hoPadding, left: hoPadding),
        child: GNav(
            selectedIndex: widget.startIndex,
            onTabChange: (value) {
              switch (value) {
                case 0: // In Progress Recipes
                  Navigator.pushNamed(context, "inProgressRecipes");
                case 1: // Create
                  Navigator.pushNamed(context, "createRecipe");
                case 2: // Finished recipes
                  Navigator.pushNamed(context, "finishedRecipes");
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
                icon: Icons.notes,
                text: 'Recipes In Progress',
              ),
              GButton(
                icon: Icons.add,
                text: 'Create Recipe',
              ),
              GButton(
                icon: Icons.edit_note,
                text: 'Finished Recipes',
              ),
              GButton(
                icon: Icons.settings,
                text: 'Settings',
              )
            ]),
      ),
    );
  }
}
