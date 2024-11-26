import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PythonCompilerScreen extends StatefulWidget {
  const PythonCompilerScreen({super.key});

  @override
  State<PythonCompilerScreen> createState() => _PythonCompilerScreenState();
}

class _PythonCompilerScreenState extends State<PythonCompilerScreen> {
  final TextEditingController _codeController = TextEditingController();
  final List<String> _outputHistory = [];
  bool _isLoading = false;

  Future<void> _executeCode() async {
    // Validate code input
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some Python code')),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Send code to backend for execution
      final response = await http.post(
        Uri.parse('http://localhost:5001/execute'), // Updated port to 5001
        body: json.encode({'code': _codeController.text}),
        headers: {'Content-Type': 'application/json'},
      );

      // Parse response
      final responseBody = json.decode(response.body);

      setState(() {
        // Add input to history
        _outputHistory.add('> ${_codeController.text}');

        if (responseBody['output'] != null) {
          _outputHistory.add(responseBody['output']);
        }

        // Handle errors
        if (responseBody['error'] != null) {
          _outputHistory.add('Error: ${responseBody['error']}');
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _outputHistory.add('Network Error: ${e.toString()}');
        _isLoading = false;
      });
    }
  }

  void _clearOutput() {
    setState(() {
      _outputHistory.clear();
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Python Compiler'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Code Input Area
            TextField(
              controller: _codeController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Enter your Python code here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _executeCode,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Run Code'),
                ),
                ElevatedButton(
                  onPressed: _clearOutput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Output Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _outputHistory.isEmpty
                    ? const Center(child: Text('Output will appear here'))
                    : ListView.builder(
                        itemCount: _outputHistory.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Text(
                              _outputHistory[index],
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  color:
                                      _outputHistory[index].startsWith('Error')
                                          ? Colors.red
                                          : Colors.black),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
