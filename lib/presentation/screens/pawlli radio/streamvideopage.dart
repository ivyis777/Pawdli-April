import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:pawlli/data/api service.dart';

class StreamVideoPage extends StatefulWidget {
  final String streamUrl;
  final bool isRecorded;

  // Backend values
  final int playbackOffset;
  final int remainingSeconds;
  final bool isPlayable;

  const StreamVideoPage({
    Key? key,
    required this.streamUrl,
    this.isRecorded = false,
    this.playbackOffset = 0,
    this.remainingSeconds = 0,
    this.isPlayable = true,
  }) : super(key: key);

  @override
  State<StreamVideoPage> createState() => _StreamVideoPageState();
}

class _StreamVideoPageState extends State<StreamVideoPage> {
  late VideoPlayerController _controller;
  bool _loading = true;
  bool _error = false;

  Timer? _pollTimer;
  Timer? _recordedStopTimer;

  String currentUrl = "";

  bool _recordedStopping = false;

  @override
    void initState() {
      super.initState();

      currentUrl = widget.streamUrl;

      _startPlayer();

      // Start polling ONLY for live streams
      if (!widget.isRecorded) {
        _startPolling();
      }
    }

  // ----------------------- POLLING BACKEND -----------------------
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final result = await ApiService.validateSlotAndGetToken();
      if (result == null) return;

      bool live = result["live"] ?? false;
      String newUrl = result["stream_url"] ?? "";

      debugPrint("🔄 Poll: live=$live | url=$newUrl");

      if (!live) {
        debugPrint("⚠️ Stream offline");
        setState(() => _error = true);
        return;
      }

      if (newUrl.isNotEmpty && newUrl != currentUrl) {
        debugPrint("🔁 Stream URL changed — reconnecting...");
        currentUrl = newUrl;
        _startPlayer();
      }
    });
  }

  // ----------------------- START PLAYER -----------------------
  Future<void> _startPlayer() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      String finalUrl = currentUrl.startsWith("http")
          ? currentUrl
          : "https://pawlli-podcasts.s3.ap-south-1.amazonaws.com$currentUrl";

      debugPrint("🎬 FINAL PLAY URL: $finalUrl");

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(finalUrl),
      );

      await _controller.initialize();

      debugPrint(
        "🎬 Media duration: ${_controller.value.duration.inSeconds} sec",
      );

      // ==========================================================
      // RECORDED PROGRAM ONLY
      // ==========================================================
      if (widget.isRecorded) {
        if (!widget.isPlayable || widget.remainingSeconds <= 0) {
          debugPrint("⛔ Recorded slot is not currently playable");

          setState(() {
            _loading = false;
            _error = true;
          });

          return;
        }

        final int mediaDuration =
            _controller.value.duration.inMilliseconds;

        if (mediaDuration > 0) {
          final int elapsedMs = widget.playbackOffset * 1000;

          final int startPositionMs =
              elapsedMs % mediaDuration;

          debugPrint("📻 RECORDED PROGRAM");
          debugPrint("Elapsed: ${widget.playbackOffset} sec");
          debugPrint(
            "Media Duration: ${_controller.value.duration.inSeconds} sec",
          );
          debugPrint(
            "Start Position: ${(startPositionMs / 1000).toStringAsFixed(1)} sec",
          );
          debugPrint(
            "Slot Remaining: ${widget.remainingSeconds} sec",
          );

          await _controller.seekTo(
            Duration(milliseconds: startPositionMs),
          );

          _recordedStopping = false;

          _controller.addListener(
            _recordedPlaybackListener,
          );

          _recordedStopTimer?.cancel();

          _recordedStopTimer = Timer(
            Duration(
              seconds: widget.remainingSeconds,
            ),
            () async {
              if (!mounted) return;

              debugPrint(
                "⏰ SLOT ENDED - stopping recorded playback",
              );

              _recordedStopping = true;

              await _controller.pause();
              await _controller.seekTo(
                Duration.zero,
              );

              if (mounted) {
                setState(() {});
              }
            },
          );
        }
      }

      await _controller.play();

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

      _controller.addListener(() {
        if (_controller.value.hasError) {
          debugPrint(
            "🔥 Player Error: ${_controller.value.errorDescription}",
          );

          if (mounted) {
            setState(() {
              _error = true;
            });
          }
        }
      });
    } catch (e) {
      debugPrint("🔥 Init Error: $e");

      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  void _recordedPlaybackListener() async {
    if (!widget.isRecorded) return;
    if (_recordedStopping) return;
    if (!_controller.value.isInitialized) return;

    final duration = _controller.value.duration;
    final position = _controller.value.position;

    if (duration.inMilliseconds <= 0) return;

    if (position >= duration) {
      if (_recordedStopping) return;

      debugPrint("🔁 Recording finished - restarting from 0:00");

      await _controller.seekTo(Duration.zero);

      if (mounted &&
          !_recordedStopping &&
          widget.remainingSeconds > 0) {
        await _controller.play();
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _recordedStopTimer?.cancel();

    if (_controller.value.isInitialized &&
        widget.isRecorded) {
      _controller.removeListener(
        _recordedPlaybackListener,
      );
    }

    _controller.dispose();

    super.dispose();
  }

  // ----------------------- UI -----------------------
  @override
  Widget build(BuildContext context) {
    bool isAudioOnly =
        _controller.value.isInitialized &&
        (_controller.value.size.width == 0 ||
            _controller.value.aspectRatio.isNaN);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Live Stream".tr),
        backgroundColor: Colors.black,
        foregroundColor: Colours.secondarycolour,
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)

            : _error
                ?  Text(
                    "Stream Offline",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )

                : _controller.value.isInitialized
                    ? isAudioOnly
                        ? const AudioVisualizer()
                        : AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )

                    :  Text(
                        "Stream not available",
                        style: TextStyle(color: Colors.white),
                      ),
      ),
    );
  }
}

// ----------------------- AUDIO VISUALIZER -----------------------

class AudioVisualizer extends StatefulWidget {
    const AudioVisualizer({super.key});

    @override
    State<AudioVisualizer> createState() => _AudioVisualizerState();
  }

  class _AudioVisualizerState extends State<AudioVisualizer>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;

    @override
    void initState() {
      super.initState();

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      )..repeat(reverse: true);
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    Widget _bar(double height) {
      return Container(
        width: 25,
        height: height * (_controller.value + 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Stack(
        children: [

          /// Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/Audio player.png",
              fit: BoxFit.contain,
            ),
          ),

          /// Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // /// Visualizer
          // Center(
          //   child: AnimatedBuilder(
          //     animation: _controller,
          //     builder: (context, child) {
          //       return Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           _bar(25),
          //           const SizedBox(width: 9),
          //           _bar(70),
          //           const SizedBox(width: 9),
          //           _bar(110),
          //           const SizedBox(width: 9),
          //           _bar(70),
          //           const SizedBox(width: 9),
          //           _bar(25),
          //         ],
          //       );
          //     },
          //   ),
          // ),
        ],
      );
    }


  // Widget _bar(double height) {
  //   return Container(
  //     width: 25,
  //     height: height * (_controller.value + 3),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(25),
  //     ),
  //   );
  // }
}
