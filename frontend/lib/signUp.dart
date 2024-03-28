import 'dart:convert';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/api_calls.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final emailController = TextEditingController();
  final password2Controller = TextEditingController();
  final double space = 0.02;
  String? _passErrorTxt = null;
  String? _lnameErrorTxt = null;
  String? _fnameErrorTxt = null;
  String? _usernameErrorTxt = null;
  String? _emailErrorTxt = null;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.width * 0.35),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                        child: Text(
                      "Register",
                      style: TextStyle(fontSize: 30),
                    )),
                    Text("Create Your Account"),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        isDense: true,
                        errorText: _usernameErrorTxt,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                        hintText: 'Username',
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * space),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail),
                        errorText: _emailErrorTxt,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                        hintText: 'Email',
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * space),
                    TextField(
                      controller: fnameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.contacts),
                        errorText: _fnameErrorTxt,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                        hintText: 'First Name',
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * space),
                    TextField(
                      controller: lnameController,
                      decoration: InputDecoration(
                        errorText: _lnameErrorTxt,
                        prefixIcon: const Icon(Icons.contacts),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                        hintText: 'Last Name',
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * space),
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
                    SizedBox(height: MediaQuery.of(context).size.width * space),
                    TextField(
                      controller: password2Controller,
                      decoration: InputDecoration(
                        errorText: _passErrorTxt,
                        prefixIcon: const Icon(Icons.password),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                        hintText: 'Confirm Password',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.035),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            String? passValidation = validatePassword(
                                passwordController.text,
                                password2Controller.text);
                            String? lnameValidation =
                                validateLName(lnameController.text);
                            String? emailValidation =
                                validateEmail(emailController.text);
                            String? fnameValidation =
                                validateFName(fnameController.text);
                            setState(() {
                              _passErrorTxt = passValidation;
                              _lnameErrorTxt = lnameValidation;
                              _fnameErrorTxt = fnameValidation;
                              _emailErrorTxt = emailValidation;
                            });
                            if (passValidation == null &&
                                lnameValidation == null &&
                                fnameValidation == null) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  });
                              Response res = await signup(
                                  usernameController.text,
                                  passwordController.text,
                                  fnameController.text,
                                  lnameController.text,
                                  emailController.text);
                              Navigator.of(context).pop();
                              if (res.statusCode >= 200 &&
                                  res.statusCode < 300) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                    'token', json.decode(res.body)["token"]);
                                Navigator.of(context).pushNamed("home");
                              } else if (res.statusCode == 406){
                                  setState(() => _usernameErrorTxt = "Username already exists");
                              }
                            }
                          },
                          child: const Text("Register")),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed("login");
                            },
                            child: const Text("Login"))
                      ],
                    ),
                  ],
                ),
              ],
            )));
  }

  String? validatePassword(String pass1, String pass2) {
    RegExp regExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    if (pass1 != pass2) return "Passwords must match";
    if (pass1.isEmpty && pass2.isEmpty) return null;
    if (!regExp.hasMatch(pass1))
      return "Must contain a lowercase, uppercase, and number";
    return null;
  }

  String? validateEmail(String email) {
    return EmailValidator.validate(email) ? null : "Invalid email address";
  }

  String? validateLName(String lname) {
    if (lname.isEmpty) return "Please add a last name";
    RegExp regExp = RegExp(r'.*[0-9!@#\$%^&*()_+{}\[\]:;<>,.?\/\\~-].*');
    if (regExp.hasMatch(lname)) return "Please add a proper last name";
    return null;
  }

  String? validateFName(String fname) {
    if (fname.isEmpty) return "Please add a first name";
    RegExp regExp = RegExp(r'.*[0-9!@#\$%^&*()_+{}\[\]:;<>,.?\/\\~-].*');
    if (regExp.hasMatch(fname)) return "Please add a proper last name";
    return null;
  }
}
