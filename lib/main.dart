import 'package:flutter/material.dart';
import 'menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chess Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const Menu(),
    );
  }
}
