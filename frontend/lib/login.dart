import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
    bool _isLoggedIn = false;
    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      passwordController.dispose();
      usernameController.dispose();
      super.dispose();
    }

    if (_isLoggedIn) {
    } else {
      return Scaffold(
          body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Center(
                child: Text(
              "Welcome back",
              style: TextStyle(fontSize: 30),
            )),
            const Text("Login to your account"),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: 'Username',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.password),
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
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
                    Navigator.of(context).pushNamed("home");
                  } else {}
                },
                child: const Text("login"))
          ],
        ),
      ));
    }
  }
}
