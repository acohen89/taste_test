import 'package:flutter/material.dart';
import 'package:taste_test/Shared/constants.dart';
import 'package:taste_test/Shared/globalFunctions.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.5, color: greyColor), // Small border with blue color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Slightly circular border
              ),
              backgroundColor: Colors.transparent, // No background color
            ),
            child: const Text("Logout", style: TextStyle(color: lightBlue),),
            onPressed: () {
              deleteUserDetails();
              Navigator.pop(context);
              if (context.mounted) Navigator.of(context).pushNamed("login");
            },
          );
  }
}
