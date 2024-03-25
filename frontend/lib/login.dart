import 'package:flutter/material.dart';
import 'package:taste_test/api_calls.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
              child: Text(
            "Welcome back",
            style: TextStyle(fontSize: 30),
          )),
          Text("Login to your account"),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
              hintText: 'Username',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.password),
              border: OutlineInputBorder(),
              hintText: 'Password',
            ),
          ),
          ElevatedButton(onPressed: () 
          async {
            print((await login('ere', 'fdsfds')).body);

          },
                        
          child: Text("login"))
        ],
      ),
    ));
  }
}

