import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Components/BottomNavBar.dart';
import 'package:taste_test/Shared/constants.dart';
import 'package:taste_test/Shared/globalFunctions.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? fname;
  String? lname;

  void initState() {
    super.initState();
    retrieveUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(startIndex: 3),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.13),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Hi, $fname $lname",
                  style: const TextStyle(fontSize: 30),
                ),
              ],
            ),
              Row(
                children: [
                  LogoutButton(context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  OutlinedButton LogoutButton(BuildContext context) {
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

  Future<void> retrieveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fname = capitalizeFirstLetter(prefs.getString('first_name') ?? ''); 
      lname = capitalizeFirstLetter(prefs.getString('last_name') ?? ''); 
    });
    return;
  }
  String capitalizeFirstLetter(String s){
    if(s.isEmpty) return s; 
    if(s.length == 1) return s.toUpperCase();
    return s[0].toUpperCase() + s.substring(1, s.length); 
  }
}
