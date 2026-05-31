import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';

import 'edit_profile_page.dart';
import 'welcome_page.dart';
import '../widgets/profile/profile_card.dart';
import '../widgets/profile/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  int _tripCount = 0;
  int _activeTaskCount = 0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return;

    final user = await appDatabase.usersDao.getUserByFirebaseUid(
      firebaseUser.uid,
    );

    if (user == null) return;

    final tripCount = await appDatabase.usersDao.getTripCountForUser(user.id);

    final activeTaskCount = await appDatabase.usersDao
        .getActiveTaskCountForUser(user.id);

    setState(() {
      _user = user;
      _tripCount = tripCount;
      _activeTaskCount = activeTaskCount;
    });
  }

  Future<void> _terminarSessao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminar sessão'),
        content: const Text('Tens a certeza que queres terminar sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Terminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await firebase_auth.FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDados,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // CARD DE PERFIL
                  ProfileCard(
                    user: _user!,
                    tripCount: _tripCount,
                    activeTaskCount: _activeTaskCount,
                  ),

                  const SizedBox(height: 12),

                  // EDITAR PERFIL
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    label: 'Editar Perfil',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: _user!),
                        ),
                      );
                      // RECARREGAR após voltar da edição
                      _carregarDados();
                    },
                  ),

                  const SizedBox(height: 12),

                  // TERMINAR SESSÃO
                  ProfileMenuItem(
                    icon: Icons.logout,
                    label: 'Terminar Sessão',
                    onTap: _terminarSessao,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
    );
  }
}
