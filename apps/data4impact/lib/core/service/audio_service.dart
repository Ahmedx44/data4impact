import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecordingService {
  static const int maxRecordingDuration = 180; // 3 minutes

  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  int _recordingDuration = 0;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  int get recordingDuration => _recordingDuration;

  Future<bool> _checkPermissions() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return true;
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recordings';
      await Directory(path).create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$path/recording_$timestamp.m4a';

      await _record.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), // Use AAC format for better compatibility
        path: filePath,
      );

      _isRecording = true;
      _currentRecordingPath = filePath;
      _recordingDuration = 0;

      // Start timer to update duration
      _startTimer();
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _record.stop();
      _isRecording = false;
      _stopTimer();
      return path;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  void _startTimer() {
    _recordingDuration = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      _recordingDuration++;
      if (_recordingDuration >= maxRecordingDuration) {
        stopRecording();
        timer.cancel();
      }
    });
  }

  void _stopTimer() {
    // Timer is automatically cancelled when _isRecording becomes false
  }

  Future<void> dispose() async {
    await _record.dispose();
  }

  Future<void> deleteRecording() async {
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _currentRecordingPath = null;
    _recordingDuration = 0;
  }
}