import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// The Task model now includes a boolean to track completion status.
class Task {
  final String name;
  final DateTime dueDate;
  final String priority;
  bool isCompleted; // This field tracks if the task is done.

  Task({
    required this.name,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false, // Defaults to false for new tasks.
  });

  // NEW: Converts a Task instance into a Map (JSON format).
  // This is essential for saving the task data.
  Map<String, dynamic> toJson() => {
        'name': name,
        'dueDate': dueDate.toIso8601String(), // DateTime is saved as a string
        'priority': priority,
        'isCompleted': isCompleted,
      };

  // NEW: Creates a Task instance from a Map (JSON format).
  // This is used to reconstruct the task object when loading data.
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        name: json['name'],
        dueDate: DateTime.parse(
            json['dueDate']), // The string is parsed back to DateTime
        priority: json['priority'],
        isCompleted: json['isCompleted'],
      );
}

// The page for adding a new task
class TaskerPage extends StatefulWidget {
  const TaskerPage({super.key});

  @override
  State<TaskerPage> createState() => _TaskerPageState();
}

class _TaskerPageState extends State<TaskerPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  // Changed to hold both date and time information.
  DateTime? _selectedDateTime;
  String _selectedPriority = 'Medium';
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  // This function now picks both a date and a time.
  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    // Exit if the user cancels the date picker.
    if (pickedDate == null) return;

    // ignore: use_build_context_synchronously
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    // Exit if the user cancels the time picker.
    if (pickedTime == null) return;

    // Combine the picked date and time and update the state.
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // Function to save the task
  void _saveTask() {
    // Validate the form before saving
    if (_formKey.currentState!.validate()) {
      if (_selectedDateTime == null) {
        // Show an error if no date and time are selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a due date and time.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create a new task object
      final newTask = Task(
        name: _taskNameController.text,
        dueDate: _selectedDateTime!,
        priority: _selectedPriority,
      );

      // Return the new task to the previous screen
      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add a New Task'),
        backgroundColor: Colors.grey[900],
      ),
      // MODIFIED: Wrapped the body in a SingleChildScrollView
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task Name', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _taskNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter task name',
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Due Date & Time', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedDateTime == null
                          ? 'Select date and time'
                          : DateFormat('dd / MMM / yyyy HH:mm')
                              .format(_selectedDateTime!),
                      style:
                          textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Priority', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  items: _priorities.map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                // MODIFIED: Replaced Spacer with a SizedBox for consistent spacing
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        const Text('Save Task', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
