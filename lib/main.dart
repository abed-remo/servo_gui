import 'dart:io';
import 'package:flutter/material.dart';

Future<void> runServo(List<String> args, BuildContext ctx) async {
  final p = await Process.run('servoctl', args);
  final out = (p.stdout is String ? p.stdout as String : '') +
              (p.stderr is String ? p.stderr as String : '');
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(out.trim().isEmpty ? 'OK' : out)));
}

void main() => runApp(const ServoApp());

class ServoApp extends StatelessWidget {
  const ServoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servo Control',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
          background: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 40),   // kleinere Buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6), // leicht eckig
            ),
          ),
        ),
      ),
      home: const ServoHome(),
    );
  }
}

class ServoHome extends StatelessWidget {
  const ServoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['Set limits', ['set-limits', '500', '2500']],
      ['0°', ['to0']],
      ['90°', ['to90']],
      ['180°', ['to180']],
      ['→0° @60', ['--speed', '60', 'to0']],
      ['→180° @60', ['--speed', '60', 'to180']],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Servo Control')),
      body: Center(
        child: GridView.count(
          crossAxisCount: 3,     // 3 Spalten → passt alles auf einen Screen
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.all(16),
          children: buttons.map((b) {
            return ElevatedButton(
              onPressed: () => runServo(b[1] as List<String>, context),
              child: Text(b[0] as String),
            );
          }).toList(),
        ),
      ),
    );
  }
}
