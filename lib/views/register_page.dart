import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../data/database/database_provider.dart';

import 'main_navigation_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final nameController = TextEditingController();

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> register() async {

    final name =
    nameController.text.trim();

    final email =
    emailController.text.trim();

    final password =
    passwordController.text.trim();

    // VALIDAÇÃO
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Preenche todos os campos.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      // REGISTO FIREBASE
      await authService.register(
        email: email,
        password: password,
      );

      // UTILIZADOR FIREBASE
      final firebaseUser =
          FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {

        // GUARDAR NOME FIREBASE
        await firebaseUser.updateDisplayName(
          name,
        );

        // GUARDAR SQLITE
        await appDatabase.usersDao
            .saveFirebaseUser(
          firebaseUid: firebaseUser.uid,
          name: name,
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
        );
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (context) =>
          const MainNavigationPage(),
        ),

            (route) => false,
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro no registo: $e',
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
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
                  Icons.person_add_alt_1,
                  size: 90,
                  color: Colors.blue,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Criar Conta',

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Regista-te para começares a organizar viagens.',

                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // NOME
                TextField(
                  controller: nameController,

                  decoration:
                  const InputDecoration(
                    labelText: 'Nome',
                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // EMAIL
                TextField(
                  controller: emailController,

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

                // BOTÃO REGISTAR
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed:
                    isLoading
                        ? null
                        : register,

                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                      'Registar',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // BOTÃO VOLTAR
                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child:
                    const Text('Voltar'),
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