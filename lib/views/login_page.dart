import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../data/database/database_provider.dart';

import 'main_navigation_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> login() async {

    setState(() {
      isLoading = true;
    });

    try {

      // LOGIN FIREBASE
      await authService.login(
        email:
        emailController.text.trim(),

        password:
        passwordController.text.trim(),
      );

      // UTILIZADOR FIREBASE
      final firebaseUser =
          FirebaseAuth.instance.currentUser;

      // GUARDAR SQLITE
      if (firebaseUser != null) {

        await appDatabase.usersDao
            .saveFirebaseUser(
          firebaseUid:
          firebaseUser.uid,

          name:
          firebaseUser.displayName ??
              firebaseUser.email ??
              'Utilizador',

          email:
          firebaseUser.email ?? '',

          photoUrl:
          firebaseUser.photoURL,
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (context) =>
          const MainNavigationPage(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro no login: $e',
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void abrirRegisto() {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
        const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Center(

          child: SingleChildScrollView(

            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                const Icon(
                  Icons.lock_outline,
                  size: 90,
                  color: Colors.blue,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Iniciar Sessão',

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Entra na tua conta para continuar.',

                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // EMAIL
                TextField(
                  controller:
                  emailController,

                  decoration:
                  const InputDecoration(
                    labelText: 'Email',
                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD
                TextField(
                  controller:
                  passwordController,

                  obscureText: true,

                  decoration:
                  const InputDecoration(
                    labelText: 'Password',
                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // BOTÃO LOGIN
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed:
                    isLoading
                        ? null
                        : login,

                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                      'Entrar',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // BOTÃO REGISTO
                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton(
                    onPressed:
                    abrirRegisto,

                    child: const Text(
                      'Criar Conta',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}