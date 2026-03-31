import 'package:flutter/material.dart';
import 'views/welcome_page.dart';

void main() {
  runApp(const ViagensApp());
}

class ViagensApp extends StatelessWidget {
  const ViagensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Viagens Universitárias',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(),
    );
  }
}