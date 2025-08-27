import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _username = 'Proxy';
  late AnimationController _animationController;
  final double _sidebarWidth = 71.0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString('username') ?? 'Proxy';
      });
    }
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    _loadUsername();
  }

  void _toggleSidebar() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _animationController.value +=
              (details.primaryDelta ?? 0) / _sidebarWidth;
        },
        onHorizontalDragEnd: (details) {
          if (_animationController.value < 0.5) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                _SideNavBar(onSettingsTap: _navigateToSettings),
                VerticalDivider(width: 1, color: Colors.grey[850]),
              ],
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..translate(_animationController.value * _sidebarWidth)
                    ..rotateY(_animationController.value * -math.pi / 12),
                  alignment: Alignment.centerLeft,
                  child: child,
                );
              },
              child: Material(
                elevation: 8.0,
                color: Colors.black,
                child: _MainContent(username: _username),
              ),
            ),
          ],
        ),
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

class _MainContent extends StatelessWidget {
  final String username;

  const _MainContent({required this.username});

  @override
  Widget build(BuildContext context) {
    // Get current date and time
    final now = DateTime.now();
    final String formattedDate = DateFormat('dd / MMM / yyyy').format(now);
    // Format the current time in 24-hour format
    final String formattedTime = DateFormat('HH:mm').format(now);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Welcome to',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 28.0,
              ),
            ),
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Inter-Knot, $username',
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 28.0,
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    thickness: 1.5,
                    height: 20,
                  ),
                ],
              ),
            ),
            Text(
              'The Day is $formattedDate',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'The Time is $formattedTime',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            _TaskCard(),
          ],
        ),
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
