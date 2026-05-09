import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },

                  child: const Text('Iniciar Sessão'),
                ),
              ),

              const SizedBox(height: 16),

              // BOTÃO REGISTO
              SizedBox(
                width: double.infinity,

                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },

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