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

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentName = prefs.getString('username') ?? 'Proxy';
        _nameController.text = _currentName;
      });
    }
  }

  // This method now runs when the user tries to go back
  Future<void> _saveUsernameOnExit() async {
    final newUsername = _nameController.text;
    if (newUsername.isNotEmpty && newUsername != _currentName) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', newUsername);
    }
  }

  @override
  void dispose() {
    // The save logic is no longer needed here.
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // **CHANGE**: Wrapped the Scaffold in a WillPopScope
    return WillPopScope(
      onWillPop: () async {
        // This code now runs when the user presses the back button.
        // It awaits the save operation to ensure it completes.
        await _saveUsernameOnExit();
        // Return true to allow the screen to be popped.
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings',
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
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
            ],
          ),
        ),
      ),
    );
  }
}
