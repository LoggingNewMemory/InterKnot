// main.dart
import 'package:flutter/material.dart';
import 'inter_knot/pages/schedule_page.dart';
import 'inter_knot/pages/chat_webview_page.dart';
import 'inter_knot/pages/music_player_page.dart';
import 'inter_knot/pages/guide_page.dart';

void main() => runApp(InterKnotApp());

class InterKnotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inter-Knot',
      theme: ThemeData.dark(useMaterial3: true),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> menu = [
    {'title': 'Schedule', 'icon': Icons.schedule, 'page': SchedulePage()},
    {'title': 'Web Chat', 'icon': Icons.chat, 'page': ChatWebviewPage()},
    {
      'title': 'Music Player',
      'icon': Icons.music_note,
      'page': MusicPlayerPage(),
    },
    {'title': 'Guide', 'icon': Icons.language, 'page': GuidePage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Inter-Knot'),
        backgroundColor: Colors.grey[900],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        children: menu.map((item) => _buildMenuItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return Card(
      color: Colors.grey[850],
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item['page']),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item['icon'], size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(item['title'], style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
