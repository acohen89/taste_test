import 'package:flutter/material.dart';
import 'package:taste_test/Pages/finishedRecipes.dart';
import 'package:taste_test/Pages/settings.dart';
import 'package:taste_test/Pages/inProgressRecipesPage.dart';
import 'package:taste_test/Pages/login.dart';
import 'package:taste_test/Pages/createRecipe.dart';
import 'package:taste_test/signUp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "Shared/constants.dart" as constants;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getString('token') == null ? false : true;
  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Taste Test',
        theme: ThemeData(
            colorScheme: constants.greyColorScheme,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            textTheme: GoogleFonts.anekTeluguTextTheme(Theme.of(context).textTheme)
            ),
        routes: {
          'finishedRecipes': (context) => const FinishedRecipes(),
          'finishedRecipesWithReload': (context) => const FinishedRecipes(forceReload: true),
          'login': (context) => const LoginPage(),
          'signUp': (context) => const SignUp(),
          'createRecipe': (context) => const CreateRecipe(),
          'settings': (context) => const Settings(),
          'inProgressRecipes': (context) => const inProgressRecipes(),
          'inProgressRecipesWithReload': (context) => const inProgressRecipes(forceReload: true,),
        },
        home: loggedIn ? const inProgressRecipes(): const LoginPage());
  }
}
