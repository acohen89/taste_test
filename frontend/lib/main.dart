import 'package:flutter/material.dart';
import 'package:taste_test/home.dart';
import 'package:taste_test/login.dart';
import 'package:taste_test/signUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getString('token') == null ? false : true;
  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn; 

  const MyApp({
    super.key,
    required this.loggedIn 
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: const Color.fromARGB(255, 103, 212, 227),
          useMaterial3: true,
        ),
        routes: {
          'home': (context) => const Home(),
          'login': (context) => const LoginPage(),
          'signUp': (context) => const SignUp(),
        },
        home: loggedIn ? const Home() : const LoginPage() 
        );
  }
}
