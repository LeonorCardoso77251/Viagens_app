import 'dart:io';

import 'package:flutter/material.dart';

/// Avatar do utilizador com ícone de câmara opcional (modo de edição).
/// Mostra a foto local se existir, ou um ícone genérico.
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final VoidCallback? onTap; // se null, não mostra ícone de câmara

  const ProfileAvatar({super.key, this.photoUrl, this.radius = 48, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: color.withOpacity(0.15),
            backgroundImage: photoUrl != null && File(photoUrl!).existsSync()
                ? FileImage(File(photoUrl!))
                : null,
            child: photoUrl == null || !File(photoUrl!).existsSync()
                ? Icon(Icons.person, size: radius, color: color)
                : null,
          ),

          // ÍCONE CÂMARA (apenas em modo de edição)
          if (onTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: radius * 0.28,
                backgroundColor: color,
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.28,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
