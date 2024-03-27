import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/api_calls.dart';
import 'package:taste_test/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      passwordController.dispose();
      usernameController.dispose();
      super.dispose();
    }

    return Scaffold(
        body: Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Center(
                    child: Text(
                  "Welcome back",
                  style: TextStyle(fontSize: 30),
                )),
                const Text("Login to your account"),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0)),
                    hintText: 'Username',
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0)),
                    hintText: 'Password',
                  ),
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Center(child: CircularProgressIndicator());
                      });
                  Response res = (await login(
                      usernameController.text, passwordController.text));
                  Navigator.of(context).pop();
                  if (res.statusCode >= 200 && res.statusCode < 300) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('token', json.decode(res.body)["token"]);
                    Navigator.of(context).pushNamed("home");
                  } else {}
                },
                child: const Text("login")),
            Row(
              children: [
                const Text("Don't have an account?"),
                TextButton(onPressed: () {
                  Navigator.of(context).pushNamed("signUp");
                }, child: const Text("Sign Up"))
              ],
            ),
          ],
      )));
  }
}
