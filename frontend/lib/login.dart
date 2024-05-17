import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/api_calls.dart';
import 'package:taste_test/constants.dart' as constants;

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
                horizontal: MediaQuery.of(context).size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.width * 0.45),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                        child: Text(
                      "Welcome back",
                      style: TextStyle(fontSize: 30),
                    )),
                    Text("Login to your account"),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                        hintText: 'Username',
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.04),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                        hintText: 'Password',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                });
                            Response res = await login(usernameController.text,
                                passwordController.text);
                            Navigator.of(context).pop();
                              if (res.statusCode < 300) {
                                setPrefs(res.body);
                                Navigator.of(context).pushNamed("home"); 
                                return; 
                              }
                              if(res.statusCode == 404){
                                loginErrorPopUp(
                                    "Username or password does not match");
                                return; 
                              } if(res.statusCode >= 500){
                                loginErrorPopUp(
                                    "Error logging in, please try again later");
                                return;
                              }
                          },
                          child: const Text("Login")),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed("signUp");
                            },
                            child: const Text("Sign Up"))
                      ],
                    ),
                  ],
                ),
              ],
            )));
  }

  void setPrefs(String res) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map body = json.decode(res);
    prefs.setString('token', body["token"]);
    prefs.setInt('id', body["user"]["id"]);
    prefs.setString('username', body["user"]["username"]);
    prefs.setString('first_name', body["user"]["first_name"]);
    prefs.setString('last_name', body["user"]["last_name"]);
    prefs.setString('email', body["user"]["email"]);
  }

  void loginErrorPopUp(String text) {
    final snack = constants.snackBarError(text);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
