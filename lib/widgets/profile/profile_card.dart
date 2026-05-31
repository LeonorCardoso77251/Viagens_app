import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import 'profile_avatar.dart';

/// Card superior da página de perfil com avatar, nome, email e estatísticas.
class ProfileCard extends StatelessWidget {
  final User user;
  final int tripCount;
  final int activeTaskCount;

  const ProfileCard({
    super.key,
    required this.user,
    required this.tripCount,
    required this.activeTaskCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // AVATAR + NOME + EMAIL
            Row(
              children: [
                ProfileAvatar(photoUrl: user.photoUrl, radius: 36),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.email,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            // ESTATÍSTICAS
            Row(
              children: [
                Expanded(
                  child: _StatItem(count: tripCount, label: 'Viagens'),
                ),
                Expanded(
                  child: _StatItem(
                    count: activeTaskCount,
                    label: 'Tarefas pendentes',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
