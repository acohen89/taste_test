import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/api_calls.dart';
import 'package:taste_test/classes/RecipeClass.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name;
  String? token;
  bool _hasRecipes = false;
  @override
  void initState() {
    super.initState();
    retrieveUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Your Recipes")),
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Hello $name'),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                Navigator.pop(context);
                if (context.mounted) Navigator.of(context).pushNamed("login");
              },
            ),
          ],
        )),
        body: Builder(builder: (context) {
          if (_hasRecipes) {
            //
            return Container(
                // display recipes
                );
          }
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06),
                  child: Center(
                      child: Text(
                    "Create your first recipe",
                    style: TextStyle(
                      fontSize: 60.0,
                      color: Color.fromARGB(160, 120, 120, 115),
                      fontWeight: FontWeight.w300,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(
                              0.2), // Reduced opacity for a more subtle shadow
                          offset: Offset(2, 2), // Adjusted offset
                          blurRadius: 5, // Reduced blur radius
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  )),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                createRecipeButton()
              ],
            ),
          );
        }));
  }

  void retrieveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('first_name') ?? '';
      token = prefs.getString('token') ?? '';
    });
  }
}

class createRecipeButton extends StatelessWidget {
  const createRecipeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () async {
        // var r = await getUserRecipes("826848d8a0a9d06ca1daf110bbd11cd3d098e6c0");
        // Recipe rec = Recipe.fromJson(jsonDecode(r.body)[0]);
        // print(rec.title);
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
