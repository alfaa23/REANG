// lib/widgets/menu_item_widget.dart

import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor:
              Colors.grey[850], // Warna disesuaikan dengan dark theme
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8), // Sedikit menambah jarak
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
