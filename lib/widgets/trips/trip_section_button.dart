import 'package:flutter/material.dart';

class TripSectionButton extends StatelessWidget {
  final String label;
  final Widget destination;

  const TripSectionButton({
    super.key,
    required this.label,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },

        child: Text(label),
      ),
    );
  }
}
