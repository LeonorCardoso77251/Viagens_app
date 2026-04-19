import 'package:flutter/material.dart';
import 'views/welcome_page.dart';
import 'data/database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await appDatabase.usersDao.ensureDemoUser();

  runApp(const ViagensApp());
}

class ViagensApp extends StatelessWidget {
  const ViagensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Viagens Universitárias',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomePage(),
    );
  }
}
