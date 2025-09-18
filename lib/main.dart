import 'dart:io';
import 'package:flutter/material.dart';

Future<void> runServo(List<String> args, BuildContext ctx) async {
  final p = await Process.run('servoctl', args);
  final out = (p.stdout is String ? p.stdout as String : '') +
              (p.stderr is String ? p.stderr as String : '');
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(out.trim().isEmpty ? 'OK' : out)),
  );
}

void main() => runApp(const ServoApp());

class ServoApp extends StatelessWidget {
  const ServoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servo Control',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
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

  Future<void> _showSetLimitDialog(BuildContext ctx) async {
    final lowController = TextEditingController();
    final highController = TextEditingController();

    await showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Set Servo Limits'),
        backgroundColor: Colors.black87,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lowController,
              decoration: const InputDecoration(
                labelText: 'Lower Limit (µs)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: highController,
              decoration: const InputDecoration(
                labelText: 'Upper Limit (µs)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final low = lowController.text;
              final high = highController.text;
              if (low.isNotEmpty && high.isNotEmpty) {
                runServo(['set-limits', low, high], ctx);
              }
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['Set limits', () => _showSetLimitDialog(context)],
      ['0°', () => runServo(['to0'], context)],
      ['90°', () => runServo(['to90'], context)],
      ['180°', () => runServo(['to180'], context)],
      ['→0° @60', () => runServo(['--speed', '60', 'to0'], context)],
      ['→180° @60', () => runServo(['--speed', '60', 'to180'], context)],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Servo Control')),
      body: Center(
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.all(16),
          children: buttons.map((b) {
            return ElevatedButton(
              onPressed: b[1] as void Function(),
              child: Text(b[0] as String),
            );
          }).toList(),
        ),
      ),
    );
  }
}
