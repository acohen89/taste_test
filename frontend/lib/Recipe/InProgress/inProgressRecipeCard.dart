import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  final double horizontalCardPadding; 
  const MyWidget({super.key, required this.horizontalCardPadding});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width - (widget.horizontalCardPadding * 2),
      child: const Column(
        children: [
          Text(
            "Really long string such that it overflows and I can see what happens",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23),
          ),
        ],
      ),
    );
  }
}