import 'dart:async';
import 'dart:core';

import 'package:chat/utils/AppColors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:record/record.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({required this.onStop});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = Record();

  // ignore: unused_field
  Amplitude? _amplitude;
  double width = 50;
  double height = 50;
  double recorderTimerWidth = 0.0;

  @override
  void initState() {
    _isRecording = false;
    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (Timer t) async {
        _amplitude = await _audioRecorder.getAmplitude();
        setState(() {});
      },
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _audioRecorder.stop();

    widget.onStop(path!);
    setState(() {
      _isRecording = false;
      _audioRecorder.stop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;

    if (_isRecording || _isPaused) {
      icon = const Icon(Icons.send, color: Colors.white, size: 22);
    } else {
      icon = Icon(Icons.mic, color: Colors.white, size: 25);
    }

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
      child: GestureDetector(
        child: icon,
        onTap: () {
          if (_isRecording || _isPaused) {
            _resume();
            recorderTimerWidth = 0;
            _stop();
          } else {
            recorderTimerWidth = context.width() - 78;
            _start();
          }
        },
      ),
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: secondaryTextStyle(size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Row(
          children: [
            AnimatedContainer(
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(24),
                backgroundColor: context.cardColor,
              ),
              duration: Duration(milliseconds: 1500),
              width: recorderTimerWidth,
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  16.width,
                  GestureDetector(
                    onTap: () async {
                      await _audioRecorder.dispose();
                      setState(() {
                        recorderTimerWidth = 0;
                        _isRecording = false;
                      });
                    },
                    child: Icon(Icons.close, color: Colors.grey),
                  ),
                  16.width,
                  Icon(Icons.mic_none, color: Colors.red.shade400, size: 20),
                  8.width,
                  _buildTimer(),
                  16.width.expand(),
                  GestureDetector(
                    onTap: () {
                      _isPaused ? _resume() : _pause();
                      setState(() {});
                    },
                    child: Icon(!_isPaused ? Icons.pause : Icons.play_arrow, color: Colors.grey),
                  ),
                  16.width,
                ],
              ),
            ).visible(_isRecording),
            8.width,
            if (recorderTimerWidth != 0) 50.width,
          ],
        ),
        _buildRecordStopControl(),
      ],
    );
  }
}
