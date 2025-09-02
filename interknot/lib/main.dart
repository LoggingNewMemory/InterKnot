import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'settings.dart';
import 'tasker.dart';
import 'webclient.dart'; // Import the refactored webclient file

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

// Helper class to store web client arguments
class WebClientArgs {
  final String title;
  final String url;
  WebClientArgs({required this.title, required this.url});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _username = 'Proxy';
  String? _avatarPath;
  late AnimationController _animationController;
  final double _sidebarWidth = 71.0;
  final List<Task> _tasks = [];

  // --- State for managing the main content view ---
  WebClientArgs? _activeWebClient;
  InAppWebViewController? _webViewController;

  // --- State for sidebar position ---
  bool _isSidebarOnLeft = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
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

  // --- Task Persistence Logic ---

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksAsString =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksAsString);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksAsString = prefs.getStringList('tasks');
    if (tasksAsString != null) {
      if (mounted) {
        setState(() {
          _tasks.clear();
          _tasks.addAll(tasksAsString
              .map((taskString) => Task.fromJson(jsonDecode(taskString)))
              .toList());
        });
      }
    }
  }

  // --- View and Navigation Logic ---

  void _showDashboard() {
    setState(() {
      _activeWebClient = null;
    });
    _animationController.reverse();
  }

  void _showWebClient(String title, String url) {
    setState(() {
      _activeWebClient = WebClientArgs(title: title, url: url);
    });
    _animationController.reverse();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString('username') ?? 'Proxy';
        _avatarPath = prefs.getString('user_avatar_path');
      });
    }
  }

  void _navigateToSettings() async {
    _animationController.reverse();
    // Return to dashboard view before navigating away
    _showDashboard();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    _loadUserData();
  }

  void _navigateToTasker() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => const TaskerPage()),
    );

    if (newTask != null && mounted) {
      setState(() {
        _tasks.add(newTask);
      });
      _saveTasks();
    }
  }

  void _updateTaskStatus(int index, bool isCompleted) {
    setState(() {
      _tasks[index].isCompleted = isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
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
    void handleDragEnd(DragEndDetails details) {
      if (_animationController.status != AnimationStatus.dismissed &&
          _animationController.status != AnimationStatus.completed) {
        if (_animationController.value < 0.5) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment:
                _isSidebarOnLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isSidebarOnLeft)
                  VerticalDivider(width: 1, color: Colors.grey[850]),
                _SideNavBar(
                  onSettingsTap: _navigateToSettings,
                  avatarPath: _avatarPath,
                  onHomeTap: _showDashboard,
                  onWebClientTap: _showWebClient,
                ),
                if (_isSidebarOnLeft)
                  VerticalDivider(width: 1, color: Colors.grey[850]),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final slideAmount = _animationController.value * _sidebarWidth;
              final angle = _animationController.value * math.pi / 12;

              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..translate(_isSidebarOnLeft ? slideAmount : -slideAmount)
                ..rotateY(_isSidebarOnLeft ? -angle : angle);

              return Transform(
                transform: transform,
                alignment: _isSidebarOnLeft
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Material(
                  elevation: 8.0,
                  color: Colors.black,
                  // REMOVED: borderRadius and clipBehavior properties
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                // This logic is for closing the sidebar by dragging the main content
                if (_animationController.status != AnimationStatus.dismissed) {
                  if (_isSidebarOnLeft) {
                    _animationController.value +=
                        (details.primaryDelta ?? 0) / _sidebarWidth;
                  } else {
                    _animationController.value -=
                        (details.primaryDelta ?? 0) / _sidebarWidth;
                  }
                }
              },
              onHorizontalDragEnd: handleDragEnd,
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: _activeWebClient == null
                    ? null
                    : AppBar(
                        title: Text(_activeWebClient!.title),
                        backgroundColor: Colors.black,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: _toggleSidebar,
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _webViewController?.reload(),
                          ),
                        ],
                      ),
                body: _activeWebClient == null
                    ? _MainContent(
                        username: _username,
                        tasks: _tasks,
                        onTaskStatusChanged: _updateTaskStatus,
                        onDelete: _deleteTask,
                      )
                    : WebClientView(
                        key: ValueKey(_activeWebClient!.url),
                        url: _activeWebClient!.url,
                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                        },
                      ),
              ),
            ),
          ),
          // Left edge detector for opening the sidebar
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if ((details.primaryDelta ?? 0) > 0) {
                  if (_animationController.status ==
                      AnimationStatus.dismissed) {
                    setState(() {
                      _isSidebarOnLeft = true;
                    });
                  }
                  if (_isSidebarOnLeft) {
                    _animationController.value +=
                        (details.primaryDelta ?? 0) / _sidebarWidth;
                  }
                }
              },
              onHorizontalDragEnd: handleDragEnd,
              child: Container(
                width: 20.0,
                color: Colors.transparent,
              ),
            ),
          ),
          // Right edge detector for opening the sidebar
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if ((details.primaryDelta ?? 0) < 0) {
                  if (_animationController.status ==
                      AnimationStatus.dismissed) {
                    setState(() {
                      _isSidebarOnLeft = false;
                    });
                  }
                  if (!_isSidebarOnLeft) {
                    _animationController.value -=
                        (details.primaryDelta ?? 0) / _sidebarWidth;
                  }
                }
              },
              onHorizontalDragEnd: handleDragEnd,
              child: Container(
                width: 20.0,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - _animationController.value,
            child: child,
          );
        },
        child: FloatingActionButton(
          onPressed: _navigateToTasker,
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }
}

class _SideNavBar extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final String? avatarPath;
  final VoidCallback onHomeTap;
  final Function(String, String) onWebClientTap;

  const _SideNavBar({
    required this.onSettingsTap,
    this.avatarPath,
    required this.onHomeTap,
    required this.onWebClientTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = avatarPath != null && File(avatarPath!).existsSync()
        ? FileImage(File(avatarPath!)) as ImageProvider
        : null;

    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[900],
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.account_circle,
                      size: 22, color: Colors.white70)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          _buildNavIcon(
            icon: Icons.space_dashboard_outlined,
            onPressed: onHomeTap,
          ),
          _buildNavIcon(
            icon: FontAwesomeIcons.whatsapp,
            onPressed: () => onWebClientTap(
              'WhatsApp Web',
              'https://web.whatsapp.com/',
            ),
          ),
          _buildNavIcon(
            icon: Icons.telegram,
            onPressed: () => onWebClientTap(
              'Telegram Web',
              'https://web.telegram.org/',
            ),
          ),
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
  final List<Task> tasks;
  final Function(int, bool) onTaskStatusChanged;
  final Function(int) onDelete;

  const _MainContent({
    required this.username,
    required this.tasks,
    required this.onTaskStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String formattedDate = DateFormat('dd / MMM / yyyy').format(now);
    final String formattedTime = DateFormat('HH:mm').format(now);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Welcome to',
                style: textTheme.headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w400, fontSize: 28.0)),
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Inter-Knot, $username',
                      style: textTheme.headlineLarge?.copyWith(fontSize: 28.0)),
                  const Divider(
                      color: Colors.white, thickness: 1.5, height: 20),
                ],
              ),
            ),
            Text('The Day is $formattedDate', style: textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('The Time is $formattedTime', style: textTheme.bodyMedium),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No task available, enjoy your day $username',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _TaskCard(
                          task: tasks[index],
                          onStatusChanged: (isCompleted) {
                            onTaskStatusChanged(index, isCompleted);
                          },
                          onDelete: () {
                            onDelete(index);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool) onStatusChanged;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onStatusChanged,
    required this.onDelete,
  });

  String _getTimeLeft(DateTime dueDate) {
    if (task.isCompleted) return 'Completed';

    final difference = dueDate.difference(DateTime.now());
    if (difference.isNegative) return 'Overdue';
    if (difference.inDays > 0) return '${difference.inDays}d left';
    if (difference.inHours > 0) return '${difference.inHours}h left';
    return '${difference.inMinutes}m left';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Colors.grey.withOpacity(0.1)
            : Colors.transparent,
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
                  _buildTaskDetailRow('Task Name:', task.name, textTheme),
                  _buildTaskDetailRow(
                      'Due Date:',
                      DateFormat('dd/MM/yyyy HH:mm').format(task.dueDate),
                      textTheme),
                  _buildTaskDetailRow(
                      'Time Left:', _getTimeLeft(task.dueDate), textTheme),
                  _buildTaskDetailRow('Priority:', task.priority, textTheme),
                ],
              ),
            ),
            VerticalDivider(color: Colors.grey[800]!, thickness: 1),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.check,
                        color:
                            task.isCompleted ? Colors.green[400] : Colors.grey),
                    onPressed: () => onStatusChanged(true),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                    onPressed: onDelete,
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color:
                            !task.isCompleted ? Colors.red[400] : Colors.grey),
                    onPressed: () => onStatusChanged(false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailRow(String label, String value, TextTheme textTheme) {
    const double cardFontSize = 14.0;

    final valueStyle = textTheme.bodyMedium?.copyWith(
      fontSize: cardFontSize,
      decoration: (label == 'Task Name:' && task.isCompleted)
          ? TextDecoration.lineThrough
          : TextDecoration.none,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: textTheme.labelMedium?.copyWith(fontSize: cardFontSize)),
          ),
          Expanded(
            child: Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
