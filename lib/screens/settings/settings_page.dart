import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 80,
              color: Colors.cyan,
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.1, 1.1),
                  duration: 1.seconds,
                  curve: Curves.easeInOut,
                )
                .fadeIn(duration: 800.ms),
            const SizedBox(height: 24),
            const Text(
              "Don't push the horses 🐎\nPage in progress...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ).animate().fadeIn(duration: 1200.ms, delay: 400.ms).slideY(begin: 0.4, end: 1),
          ],
        ),
      ),
    );
  }
}
