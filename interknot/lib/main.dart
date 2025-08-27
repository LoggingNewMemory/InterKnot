import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'settings.dart';
import 'tasker.dart';

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
  final List<Task> _tasks = []; // List to hold the tasks

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadTasks(); // Load saved tasks when the app starts.
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

  // NEW: Saves the current list of tasks to device storage.
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the list of Task objects into a list of JSON strings.
    final List<String> tasksAsString =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksAsString);
  }

  // NEW: Loads tasks from device storage when the app starts.
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksAsString = prefs.getStringList('tasks');
    if (tasksAsString != null) {
      if (mounted) {
        setState(() {
          // Decode the JSON strings back into Task objects.
          _tasks.clear();
          _tasks.addAll(tasksAsString
              .map((taskString) => Task.fromJson(jsonDecode(taskString)))
              .toList());
        });
      }
    }
  }

  // --- Navigation and State Update Logic ---

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

  void _navigateToTasker() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => const TaskerPage()),
    );

    if (newTask != null && mounted) {
      setState(() {
        _tasks.add(newTask);
      });
      _saveTasks(); // Save the list after adding a new task.
    }
  }

  void _updateTaskStatus(int index, bool isCompleted) {
    setState(() {
      _tasks[index].isCompleted = isCompleted;
    });
    _saveTasks(); // Save the list after updating a task.
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
                child: _MainContent(
                  username: _username,
                  tasks: _tasks,
                  onTaskStatusChanged: _updateTaskStatus,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTasker,
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
  final List<Task> tasks;
  // Callback function to handle status changes.
  final Function(int, bool) onTaskStatusChanged;

  const _MainContent({
    required this.username,
    required this.tasks,
    required this.onTaskStatusChanged,
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
            const SizedBox(height: 40),
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
            const SizedBox(height: 40),
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
                          // Pass the callback to the TaskCard.
                          onStatusChanged: (isCompleted) {
                            onTaskStatusChanged(index, isCompleted);
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
  // Callback to notify the parent widget of a status change.
  final Function(bool) onStatusChanged;

  const _TaskCard({required this.task, required this.onStatusChanged});

  // Helper now considers the completion status.
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
                  // This is now an IconButton to mark the task as complete.
                  IconButton(
                    icon: Icon(Icons.check,
                        color:
                            task.isCompleted ? Colors.green[400] : Colors.grey),
                    onPressed: () => onStatusChanged(true),
                  ),
                  // This IconButton marks the task as incomplete.
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
    // Apply a strikethrough style if the task is complete.
    final valueStyle = textTheme.bodyMedium?.copyWith(
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
            child: Text(label, style: textTheme.labelMedium),
          ),
          Expanded(
            child: Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
