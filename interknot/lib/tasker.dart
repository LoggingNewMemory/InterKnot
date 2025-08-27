import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// A simple model class to represent a task
class Task {
  final String name;
  final DateTime dueDate;
  final String priority;

  Task({required this.name, required this.dueDate, required this.priority});
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
  DateTime? _selectedDate;
  String _selectedPriority = 'Medium';
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to save the task
  void _saveTask() {
    // Validate the form before saving
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        // Show an error if no date is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a due date.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create a new task object
      final newTask = Task(
        name: _taskNameController.text,
        dueDate: _selectedDate!,
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
      body: Padding(
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
              Text('Due Date', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select a date'
                        : DateFormat('dd / MMM / yyyy').format(_selectedDate!),
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
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
              const Spacer(),
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
    );
  }
}
