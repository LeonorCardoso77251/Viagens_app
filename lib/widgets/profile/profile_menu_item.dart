import 'package:flutter/material.dart';

/// Linha de menu reutilizável na página de perfil.
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: effectiveColor),
        title: Text(label, style: TextStyle(color: effectiveColor)),
        trailing: color == null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }
}
