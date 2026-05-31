import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';

import '../widgets/profile/profile_avatar.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  final TextEditingController _passwordAtualController =
      TextEditingController();
  final TextEditingController _novaPasswordController = TextEditingController();
  final TextEditingController _confirmarPasswordController =
      TextEditingController();

  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _photoUrl = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordAtualController.dispose();
    _novaPasswordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (picked == null) return;

    // GUARDAR LOCALMENTE
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${widget.user.id}.jpg';
    final savedFile = await File(
      picked.path,
    ).copy(p.join(appDir.path, fileName));

    setState(() => _photoUrl = savedFile.path);
  }

  Future<void> _guardar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final passwordAtual = _passwordAtualController.text;
    final novaPassword = _novaPasswordController.text;
    final confirmarPassword = _confirmarPasswordController.text;

    if (nome.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e email são obrigatórios.')),
      );
      return;
    }

    final alterarEmail = email != widget.user.email;
    final alterarPassword = novaPassword.isNotEmpty;

    // PASSWORD ATUAL obrigatória para alterar email ou password
    if ((alterarEmail || alterarPassword) && passwordAtual.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Introduz a password atual para guardar alterações sensíveis.',
          ),
        ),
      );
      return;
    }

    // VALIDAÇÃO DE NOVA PASSWORD (só se preenchida)
    if (alterarPassword) {
      if (novaPassword != confirmarPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As passwords não coincidem.')),
        );
        return;
      }

      if (novaPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A nova password deve ter pelo menos 6 caracteres.'),
          ),
        );
        return;
      }
    }

    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) return;

      // ATUALIZAR NOME NO FIREBASE
      if (nome != firebaseUser.displayName) {
        await firebaseUser.updateDisplayName(nome);
      }

      // ALTERAR EMAIL E/OU PASSWORD — requer reautenticação
      if (alterarEmail || alterarPassword) {
        // REAUTENTICAR com a password atual (sempre obrigatória aqui,
        // a validação acima garante que passwordAtual está preenchida)
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: firebaseUser.email!,
          password: passwordAtual,
        );

        await firebaseUser.reauthenticateWithCredential(credential);

        if (alterarEmail) {
          await firebaseUser.verifyBeforeUpdateEmail(email);
        }

        if (alterarPassword) {
          await firebaseUser.updatePassword(novaPassword);
        }
      }

      // ATUALIZAR NA DB LOCAL
      await appDatabase.usersDao.updateProfile(
        userId: widget.user.id,
        name: nome,
        email: email,
        photoUrl: _photoUrl,
      );

      if (!mounted) return;

      if (alterarEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enviámos um email de confirmação para o novo endereço. '
              'O email só será atualizado após confirmares.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }

      Navigator.pop(context);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;

      final mensagem = switch (e.code) {
        'wrong-password' => 'Password atual incorreta.',
        'email-already-in-use' => 'Este email já está em uso.',
        'invalid-email' => 'Email inválido.',
        'requires-recent-login' =>
          'Por segurança, faz login novamente antes de alterar o email.',
        _ => 'Erro: ${e.message}',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil'), centerTitle: false),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // AVATAR
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      photoUrl: _photoUrl,
                      radius: 52,
                      onTap: _selecionarFoto,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clique no ícone para alterar a foto',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // NOME
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // EMAIL
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SECÇÃO PASSWORD
              const Text(
                'Alterar Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                'Deixe em branco se não quiser alterar a password',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 14),

              // PASSWORD ATUAL
              TextField(
                controller: _passwordAtualController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Atual',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // NOVA PASSWORD
              TextField(
                controller: _novaPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nova Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // CONFIRMAR PASSWORD
              TextField(
                controller: _confirmarPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar Nova Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // BOTÕES
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
