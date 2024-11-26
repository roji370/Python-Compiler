import 'package:flutter/material.dart';
import 'screens/python_compiler_screen.dart';

void main() {
  runApp(const PythonCompilerApp());
}

class PythonCompilerApp extends StatelessWidget {
  const PythonCompilerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Compiler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PythonCompilerScreen(),
    );
  }
}
