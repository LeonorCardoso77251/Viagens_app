import 'package:flutter/material.dart';
import 'main_navigation_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void entrarNaApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.card_travel,
                size: 90,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'App de Viagens',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Organiza as tuas viagens universitárias de forma simples e rápida.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // BOTÃO LOGIN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => entrarNaApp(context),
                  child: const Text('Iniciar Sessão'),
                ),
              ),

              const SizedBox(height: 16),

              // BOTÃO REGISTO
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => entrarNaApp(context),
                  child: const Text('Registar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}