import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  String _currentName = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadCurrentUser();
  }

  // Load the current name from shared preferences
  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentName = prefs.getString('username') ?? 'Proxy';
      _nameController.text = _currentName;
    });
  }

  // Save the new name to shared preferences
  Future<void> _saveUsername() async {
    if (_nameController.text.isEmpty) {
      // Optional: show a message if the name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty!')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _nameController.text);

    // Show confirmation and pop back to home page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username saved!')),
    );
    Navigator.of(context)
        .pop(true); // Pop with a 'true' result to indicate a change
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Username',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Gilmer',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
