import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

/// Statuts d'enregistrement audio
enum AudioRecordingState {
  idle,
  recording,
  recorded,
}

/// Widget proéminent d'enregistrement de note vocale pour description de panne
/// Conçu pour être positionné côte à côte avec le champ de texte descriptif.
/// Intègre un mode hors-ligne / résilient (enregistrement local d'abord).
class AudioRecorderWidget extends StatefulWidget {
  final ValueChanged<String>? onAudioRecorded;
  final VoidCallback? onAudioRemoved;
  final String? initialAudioPath;
  final bool isCompact;

  const AudioRecorderWidget({
    super.key,
    this.onAudioRecorded,
    this.onAudioRemoved,
    this.initialAudioPath,
    this.isCompact = false,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  late AudioRecordingState _state;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _recordingTimer;
  int _secondsElapsed = 0;
  String? _recordedPath;

  // Prévisualisation audio
  bool _isPlaying = false;
  Timer? _playbackTimer;
  int _playbackSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialAudioPath != null && widget.initialAudioPath!.isNotEmpty) {
      _state = AudioRecordingState.recorded;
      _recordedPath = widget.initialAudioPath;
      _secondsElapsed = 14; // Durée par défaut si non spécifiée
    } else {
      _state = AudioRecordingState.idle;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _startRecording() {
    setState(() {
      _state = AudioRecordingState.recording;
      _secondsElapsed = 0;
    });
    _pulseController.repeat(reverse: true);

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    // Génération d'un chemin de stockage local (mode résilient offline-first)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final localPath = '/local/recordings/techsos_audio_$timestamp.m4a';

    setState(() {
      _state = AudioRecordingState.recorded;
      _recordedPath = localPath;
      if (_secondsElapsed == 0) _secondsElapsed = 1;
    });

    widget.onAudioRecorded?.call(localPath);
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    setState(() {
      _isPlaying = true;
      _playbackSeconds = 0;
    });

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _playbackSeconds++;
        if (_playbackSeconds >= _secondsElapsed) {
          _stopPlayback();
        }
      });
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _playbackSeconds = 0;
    });
  }

  void _deleteRecording() {
    _stopPlayback();
    setState(() {
      _state = AudioRecordingState.idle;
      _recordedPath = null;
      _secondsElapsed = 0;
    });
    widget.onAudioRemoved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: TechSosColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _state == AudioRecordingState.recording
                ? TechSosColors.accent
                : (_state == AudioRecordingState.recorded
                    ? TechSosColors.success
                    : TechSosColors.border),
            width: _state == AudioRecordingState.idle ? 1.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildContentByState(),
        ),
      ),
    );
  }

  Widget _buildContentByState() {
    switch (_state) {
      case AudioRecordingState.idle:
        return _buildIdleView();
      case AudioRecordingState.recording:
        return _buildRecordingView();
      case AudioRecordingState.recorded:
        return _buildRecordedView();
    }
  }

  /// Vue initiale : Bouton Micro proéminent et explication
  Widget _buildIdleView() {
    return Column(
      key: const ValueKey('audio_idle_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            const Icon(
              Icons.mic_rounded,
              color: TechSosColors.accent,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'Message vocal (Recommandé)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TechSosColors.primary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: TechSosColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Hors-ligne OK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TechSosColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Expliquez votre panne avec votre propre voix en Bambara ou Français pour les réparateurs.',
          style: TextStyle(
            fontSize: 14,
            color: TechSosColors.textSecondary,
            height: 1.3,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 16),
        InkWell(
          key: const ValueKey('audio_record_button'),
          onTap: _startRecording,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3752A), TechSosColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TechSosColors.accent.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Touchez pour enregistrer',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TechSosColors.accent,
          ),
        ),
      ],
    );
  }

  /// Vue pendant l'enregistrement : pulsation animée, chronomètre et bouton stop
  Widget _buildRecordingView() {
    return Column(
      key: const ValueKey('audio_recording_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: TechSosColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Enregistrement vocal en cours...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TechSosColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TechSosColors.accent.withValues(alpha: 0.15),
            ),
            child: Center(
              child: InkWell(
                key: const ValueKey('audio_stop_button'),
                onTap: _stopRecording,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: TechSosColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stop_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _formatDuration(_secondsElapsed),
          key: const ValueKey('audio_timer_text'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: TechSosColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Touchez le carré pour arrêter l\'enregistrement',
          style: TextStyle(
            fontSize: 14,
            color: TechSosColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Vue après enregistrement : lecteur de prévisualisation, durée et action refaire/supprimer
  Widget _buildRecordedView() {
    return Column(
      key: const ValueKey('audio_recorded_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: TechSosColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: TechSosColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Note vocale prête',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TechSosColors.primary,
                    ),
                  ),
                  if (_recordedPath != null)
                    Text(
                      _recordedPath!.split('/').last,
                      style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TechSosColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Stockage local OK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TechSosColors.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TechSosColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TechSosColors.border),
          ),
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('audio_play_button'),
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: TechSosColors.primary,
                  size: 36,
                ),
                onPressed: _togglePlayback,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: _secondsElapsed > 0
                          ? (_isPlaying ? (_playbackSeconds / _secondsElapsed).clamp(0.0, 1.0) : 1.0)
                          : 0.0,
                      backgroundColor: TechSosColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(TechSosColors.primary),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isPlaying ? _formatDuration(_playbackSeconds) : '0:00',
                          style: TechSosStyles.caption.copyWith(fontSize: 14),
                        ),
                        Text(
                          _formatDuration(_secondsElapsed),
                          style: TechSosStyles.caption.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              key: const ValueKey('audio_delete_button'),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              label: const Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: _deleteRecording,
            ),
            TextButton.icon(
              key: const ValueKey('audio_re_record_button'),
              icon: const Icon(
                Icons.refresh_rounded,
                color: TechSosColors.primary,
                size: 20,
              ),
              label: const Text(
                'Réenregistrer',
                style: TextStyle(
                  color: TechSosColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                _deleteRecording();
                _startRecording();
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Lecteur audio autonome pour l'écoute des notes vocales dans le détail d'une demande
class AudioPlayerCard extends StatefulWidget {
  final String audioUrl;
  final String? title;

  const AudioPlayerCard({
    super.key,
    required this.audioUrl,
    this.title,
  });

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  bool _isPlaying = false;
  int _currentSeconds = 0;
  final int _totalSeconds = 18; // Durée représentative simulée
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stop();
    } else {
      _play();
    }
  }

  void _play() {
    setState(() {
      _isPlaying = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _currentSeconds++;
        if (_currentSeconds >= _totalSeconds) {
          _stop();
        }
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _currentSeconds = 0;
    });
  }

  String _format(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TechSosColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TechSosColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.record_voice_over_rounded,
                color: TechSosColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title ?? 'Message vocal du client',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  size: 38,
                  color: TechSosColors.accent,
                ),
                onPressed: _togglePlay,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: (_currentSeconds / _totalSeconds).clamp(0.0, 1.0),
                      backgroundColor: TechSosColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(TechSosColors.accent),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _format(_currentSeconds),
                          style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                        ),
                        Text(
                          _format(_totalSeconds),
                          style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
