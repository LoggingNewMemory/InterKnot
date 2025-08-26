import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the icon package
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        fontFamily: 'Gilmer',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
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
      body: Row(
        children: [
          _SideNavBar(),
          VerticalDivider(width: 1, color: Colors.grey[850]),
          const Expanded(
            child: _MainContent(),
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
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          _buildNavIcon(icon: Icons.account_circle, onPressed: () {}),
          const SizedBox(height: 20),
          // --- UPDATED ICONS ---
          _buildNavIcon(
              icon: FontAwesomeIcons.whatsapp,
              onPressed: () {}), // WhatsApp Business
          _buildNavIcon(icon: Icons.telegram, onPressed: () {}),
          _buildNavIcon(
              icon: FontAwesomeIcons.whatsapp, onPressed: () {}), // WhatsApp
          // --- END OF UPDATE ---
          _buildNavIcon(icon: Icons.music_note, onPressed: () {}),
          const Spacer(),
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
          // Using FaIcon for FontAwesome icons works seamlessly here
          // as it's a widget, but Icon(icon) is more generic.
          icon: Icon(icon, size: 22),
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
    final String formattedDate =
        DateFormat('dd / MMM / yyyy').format(DateTime.now());
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            'The Day is $formattedDate',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
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
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
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
