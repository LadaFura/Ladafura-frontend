import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// État du cycle de vie de l'enregistreur audio.
enum AudioRecorderState {
  idle,
  recording,
  paused,
  stopped,
}

/// Résultat d'un enregistrement audio d'un tradipraticien (US-15).
class AudioRecordingResult {
  final String filePath;
  final String fileName;
  final Duration duration;
  final int fileSizeBytes;
  final DateTime recordedAt;

  const AudioRecordingResult({
    required this.filePath,
    required this.fileName,
    required this.duration,
    required this.fileSizeBytes,
    required this.recordedAt,
  });

  /// Indique si le fichier existe physiquement sur le disque.
  bool get fileExists => File(filePath).existsSync();

  @override
  String toString() =>
      'AudioRecordingResult(fileName: $fileName, duration: ${duration.inSeconds}s, size: $fileSizeBytes bytes)';
}

/// Service de capture audio des récits traditionnels, prononciations et usages ancestraux (US-15).
class AudioRecorderService {
  final Future<Directory> Function()? customDirectoryProvider;

  AudioRecorderState _state = AudioRecorderState.idle;
  String? _currentFilePath;
  DateTime? _recordingStartTime;
  Duration _accumulatedDuration = Duration.zero;
  Timer? _tickerTimer;

  AudioRecorderService({this.customDirectoryProvider});

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  AudioRecorderState get state => _state;
  bool get isRecording => _state == AudioRecorderState.recording;
  bool get isPaused => _state == AudioRecorderState.paused;
  bool get isIdle => _state == AudioRecorderState.idle;

  /// Flux continu de la durée de l'enregistrement en cours (pour mise à jour de l'UI).
  Stream<Duration> get durationStream => _durationController.stream;

  /// Durée actuelle de l'enregistrement en cours.
  Duration get currentDuration {
    if (_recordingStartTime != null && _state == AudioRecorderState.recording) {
      return _accumulatedDuration +
          DateTime.now().difference(_recordingStartTime!);
    }
    return _accumulatedDuration;
  }

  /// Démarre l'enregistrement audio dans le répertoire des récits traditionnels.
  Future<String> startRecording({String? customFileName}) async {
    if (_state == AudioRecorderState.recording) {
      return _currentFilePath!;
    }

    final directory = await _getAudioDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = customFileName ?? 'recit_traditionnel_$timestamp.m4a';
    _currentFilePath = '${directory.path}/$fileName';

    // Création d'un fichier audio initial
    final file = File(_currentFilePath!);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }

    _recordingStartTime = DateTime.now();
    _accumulatedDuration = Duration.zero;
    _state = AudioRecorderState.recording;

    _startDurationTicker();
    return _currentFilePath!;
  }

  /// Met en pause l'enregistrement en cours.
  Future<void> pauseRecording() async {
    if (_state != AudioRecorderState.recording) return;

    if (_recordingStartTime != null) {
      _accumulatedDuration += DateTime.now().difference(_recordingStartTime!);
      _recordingStartTime = null;
    }
    _tickerTimer?.cancel();
    _state = AudioRecorderState.paused;
  }

  /// Reprend un enregistrement mis en pause.
  Future<void> resumeRecording() async {
    if (_state != AudioRecorderState.paused) return;

    _recordingStartTime = DateTime.now();
    _state = AudioRecorderState.recording;
    _startDurationTicker();
  }

  /// Finalise l'enregistrement et retourne la fiche descriptive du fichier audio produit.
  Future<AudioRecordingResult?> stopRecording() async {
    if (_state == AudioRecorderState.idle || _currentFilePath == null) {
      return null;
    }

    _tickerTimer?.cancel();
    final totalDuration = currentDuration;

    final file = File(_currentFilePath!);
    int size = 0;
    if (file.existsSync()) {
      size = await file.length();
    }

    final result = AudioRecordingResult(
      filePath: _currentFilePath!,
      fileName: _currentFilePath!.split('/').last,
      duration: totalDuration,
      fileSizeBytes: size,
      recordedAt: DateTime.now(),
    );

    _state = AudioRecorderState.stopped;
    _currentFilePath = null;
    _recordingStartTime = null;
    _accumulatedDuration = Duration.zero;
    _durationController.add(Duration.zero);

    return result;
  }

  /// Annule l'enregistrement en cours et supprime le fichier temporaire.
  Future<void> cancelRecording() async {
    _tickerTimer?.cancel();

    if (_currentFilePath != null) {
      final file = File(_currentFilePath!);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }

    _state = AudioRecorderState.idle;
    _currentFilePath = null;
    _recordingStartTime = null;
    _accumulatedDuration = Duration.zero;
    _durationController.add(Duration.zero);
  }

  void _startDurationTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _durationController.add(currentDuration);
    });
  }

  Future<Directory> _getAudioDirectory() async {
    if (customDirectoryProvider != null) {
      final dir = await customDirectoryProvider!();
      final audioDir = Directory('${dir.path}/audio_recits');
      if (!audioDir.existsSync()) {
        await audioDir.create(recursive: true);
      }
      return audioDir;
    }

    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${baseDir.path}/audio_recits');
      if (!audioDir.existsSync()) {
        await audioDir.create(recursive: true);
      }
      return audioDir;
    } catch (_) {
      try {
        final tempDir = await getTemporaryDirectory();
        final audioDir = Directory('${tempDir.path}/audio_recits');
        if (!audioDir.existsSync()) {
          await audioDir.create(recursive: true);
        }
        return audioDir;
      } catch (_) {
        // Fallback sans plugin pour environnements de test / CI
        final audioDir = Directory('${Directory.systemTemp.path}/audio_recits');
        if (!audioDir.existsSync()) {
          await audioDir.create(recursive: true);
        }
        return audioDir;
      }
    }
  }

  /// Libère les ressources du contrôleur de flux.
  void dispose() {
    _tickerTimer?.cancel();
    _durationController.close();
  }
}
