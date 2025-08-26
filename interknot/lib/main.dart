import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for system UI services
import 'package:intl/intl.dart';

// The main function is now async to allow for system UI settings
Future<void> main() async {
  // Ensure that widget binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Set the app to run in immersive sticky fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inter-Knot',
      theme: ThemeData(
        // Set the default font family to Gilmer
        fontFamily: 'Gilmer',
        // Define a dark theme to match the design
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        // Customize text themes for different weights
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 34.0, fontWeight: FontWeight.w700, color: Colors.white),
          bodyMedium: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: Colors.white70),
          labelMedium: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        // Style for the Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: CircleBorder(),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The main layout is a Row: SideNav on the left, MainContent on the right
      body: Row(
        children: [
          _SideNavBar(), // Left-side navigation bar
          // A thin vertical line to separate the sections
          VerticalDivider(width: 1, color: Colors.grey[850]),
          const Expanded(
            child: _MainContent(), // Main content area
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement action to add a new task
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

/// A widget for the left-side navigation bar
class _SideNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, // Set a fixed width for the nav bar
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          // Top icon (Custom Image)
          _buildNavIcon(icon: Icons.account_circle, onPressed: () {}),
          const SizedBox(height: 20),
          // Middle icons for apps
          _buildNavIcon(
              icon: Icons.business_center,
              onPressed: () {}), // WhatsApp Business
          _buildNavIcon(icon: Icons.telegram, onPressed: () {}), // Telegram
          _buildNavIcon(icon: Icons.chat_bubble, onPressed: () {}), // WhatsApp
          _buildNavIcon(icon: Icons.music_note, onPressed: () {}), // Music
          const Spacer(), // Pushes the settings icon to the bottom
          // Bottom icon (Settings)
          _buildNavIcon(icon: Icons.settings, onPressed: () {}),
        ],
      ),
    );
  }

  /// Helper method to create a styled circular icon button
  Widget _buildNavIcon(
      {required IconData icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[900],
        child: IconButton(
          icon: Icon(icon),
          color: Colors.white70,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// A widget for the main content on the right
class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    // Get the current date and format it as shown in the UI
    final String formattedDate =
        DateFormat('dd / MMM / yyyy').format(DateTime.now());
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          Text(
            'Welcome to',
            style:
                textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w400),
          ),
          Text(
            'Inter-Knot, Proxy',
            style: textTheme.headlineLarge,
          ),
          const Divider(
              color: Colors.white, thickness: 1.5, endIndent: 50, height: 20),

          // Date Text
          Text(
            'The Day is $formattedDate',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),

          // Task Card
          _TaskCard(),
        ],
      ),
    );
  }
}

/// A widget representing the task card from the UI
class _TaskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // A subtle border to define the card area
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left side with task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Task Name:', style: textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Text('Due Date:', style: textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Text('Time Left:', style: textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Text('Priority:', style: textTheme.labelMedium),
                ],
              ),
            ),
            VerticalDivider(color: Colors.grey[800]!, thickness: 1),
            // Right side with action icons
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.check, color: Colors.green[400]),
                  Icon(Icons.close, color: Colors.red[400]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
