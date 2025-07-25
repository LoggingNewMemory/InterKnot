// music_player_page.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  List<File> _musicFiles = [];
  File? _currentFile;

  void _pickMusicFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      final folder = Directory(path);
      final files = folder
          .listSync()
          .where((f) => f.path.endsWith('.mp3') || f.path.endsWith('.wav'))
          .map((f) => File(f.path))
          .toList();

      setState(() => _musicFiles = files);
    }
  }

  void _playMusic(File file) async {
    await _player.setFilePath(file.path);
    _player.play();
    setState(() => _currentFile = file);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Music Player'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _pickMusicFolder,
          ),
        ],
      ),
      body: _musicFiles.isEmpty
          ? Center(
              child: Text(
                'No music files found.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _musicFiles.length,
              itemBuilder: (context, index) {
                final file = _musicFiles[index];
                return ListTile(
                  title: Text(
                    file.path.split('/').last,
                    style: TextStyle(color: Colors.white),
                  ),
                  selected: file == _currentFile,
                  onTap: () => _playMusic(file),
                );
              },
            ),
    );
  }
}
