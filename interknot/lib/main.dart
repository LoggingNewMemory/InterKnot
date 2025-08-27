import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

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
          headlineSmall: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
          titleLarge: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = 'Proxy'; // Default username
  bool _isSidebarVisible = true; // NEW: State to control sidebar visibility

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // NEW: Method to toggle the sidebar's visibility
  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  // Method to load the username from shared preferences
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString('username') ?? 'Proxy';
      });
    }
  }

  // Method to navigate to the settings page and wait for a result
  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    _loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // UPDATED: Conditionally build the sidebar and divider
          if (_isSidebarVisible)
            _SideNavBar(onSettingsTap: _navigateToSettings),
          if (_isSidebarVisible)
            VerticalDivider(width: 1, color: Colors.grey[850]),
          Expanded(
            // UPDATED: Pass the username AND the toggle callback
            child: _MainContent(
              username: _username,
              onToggleSidebar: _toggleSidebar, // Pass the callback
            ),
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

class _SideNavBar extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _SideNavBar({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          _buildNavIcon(icon: Icons.account_circle, onPressed: () {}),
          const SizedBox(height: 20),
          _buildNavIcon(icon: FontAwesomeIcons.whatsapp, onPressed: () {}),
          _buildNavIcon(icon: Icons.telegram, onPressed: () {}),
          _buildNavIcon(icon: FontAwesomeIcons.whatsapp, onPressed: () {}),
          _buildNavIcon(icon: Icons.music_note, onPressed: () {}),
          const Spacer(),
          _buildNavIcon(icon: Icons.settings, onPressed: onSettingsTap),
        ],
      ),
    );
  }

  Widget _buildNavIcon(
      {required IconData icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[900],
        child: IconButton(
          icon: Icon(icon, size: 22),
          color: Colors.white70,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

// UPDATED: _MainContent now includes a toggle button
class _MainContent extends StatelessWidget {
  final String username;
  final VoidCallback onToggleSidebar; // NEW: Accept the callback

  const _MainContent({
    required this.username,
    required this.onToggleSidebar, // NEW: Add to constructor
  });

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
          // NEW: Added the toggle button
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onToggleSidebar, // Call the callback when pressed
            color: Colors.white70,
            tooltip: 'Toggle Sidebar',
          ),
          const SizedBox(height: 8), // Space after the button
          Text(
            'Welcome to',
            style:
                textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w400),
          ),
          Text(
            'Inter-Knot, $username',
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
