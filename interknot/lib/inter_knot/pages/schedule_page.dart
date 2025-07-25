// schedule_page.dart
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _selectedTime;

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _scheduleTask() {
    if (_selectedTime != null) {
      final DateTime now = DateTime.now();
      final DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      AndroidAlarmManager.oneShotAt(
        scheduledTime,
        _taskController.text.hashCode,
        () => print("Reminder: ${_taskController.text}"),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scheduled: ${_taskController.text}")),
      );
      _taskController.clear();
      setState(() => _selectedTime = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Task Scheduler'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Task',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: _pickTime, child: Text('Pick Time')),
                Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'No Time Chosen',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleTask,
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
