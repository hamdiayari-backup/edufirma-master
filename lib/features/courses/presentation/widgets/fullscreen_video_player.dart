import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/localization/app_translations.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String? thumbnailUrl;
  final Duration? startPosition;

  const FullscreenVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
    this.thumbnailUrl,
    this.startPosition,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isBuffering = false;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      String videoUrl = widget.videoUrl;

      if (!videoUrl.startsWith('http')) {
        videoUrl = 'https://edufirma.com$videoUrl';
      }

      debugPrint('Initializing fullscreen video: $videoUrl');

      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _controller!.initialize();

      _controller!.addListener(_videoListener);

      _duration = _controller!.value.duration;

      // Seek to start position if provided
      if (widget.startPosition != null) {
        await _controller!.seekTo(widget.startPosition!);
      }

      setState(() {
        _isInitialized = true;
      });

      await _controller!.play();
      setState(() {
        _isPlaying = true;
      });

      _hideControlsAfterDelay();
    } catch (e) {
      debugPrint('Error initializing video: $e');
      final msg = e.toString().toLowerCase();
      final isFormatOrSourceError =
          msg.contains('unrecognizedinputformatexception') ||
              msg.contains('source error') ||
              msg.contains('could not read the stream') ||
              msg.contains('exoplaybackexception');
      setState(() {
        _errorMessage = isFormatOrSourceError
            ? 'video_format_or_unavailable'
            : 'video_load_error';
      });
    }
  }

  Future<void> _openVideoInBrowser() async {
    String url = widget.videoUrl;
    if (!url.startsWith('http')) url = 'https://edufirma.com$url';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final value = _controller!.value;

      if (value.position != _position ||
          value.isPlaying != _isPlaying ||
          value.isBuffering != _isBuffering) {
        setState(() {
          _position = value.position;
          _isPlaying = value.isPlaying;
          _isBuffering = value.isBuffering;
        });
      }
    }
  }

  void _togglePlay() {
    if (_controller == null) return;

    if (_isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      _hideControlsAfterDelay();
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls && _isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  void _seek(Duration delta) {
    if (_controller == null) return;
    final newPosition = _position + delta;
    _controller!.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
    setState(() {
      _showControls = true;
    });
    _hideControlsAfterDelay();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 3) {
            _seek(const Duration(seconds: -10));
          } else if (details.localPosition.dx > screenWidth * 2 / 3) {
            _seek(const Duration(seconds: 10));
          } else {
            _togglePlay();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else if (_errorMessage != null)
              _buildError(locale)
            else
              _buildLoading(locale),

            // Buffering indicator
            if (_isBuffering && _isInitialized)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            // Controls overlay (hide when error)
            if (_errorMessage == null)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _buildControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top bar
            _buildTopBar(),

            // Center controls
            _buildCenterControls(),

            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              widget.title ?? '',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10s
        GestureDetector(
          onTap: () => _seek(const Duration(seconds: -10)),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.replay_10_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),

        const SizedBox(width: 40),

        // Play/Pause
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),

        const SizedBox(width: 40),

        // Forward 10s
        GestureDetector(
          onTap: () => _seek(const Duration(seconds: 10)),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forward_10_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _position.inMilliseconds.toDouble().clamp(
                    0,
                    _duration.inMilliseconds.toDouble(),
                  ),
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                _controller?.seekTo(Duration(milliseconds: value.toInt()));
              },
            ),
          ),

          // Time and controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current time / Duration
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),

              // Right controls
              Row(
                children: [
                  // Volume
                  GestureDetector(
                    onTap: () {
                      if (_controller!.value.volume == 0) {
                        _controller!.setVolume(1.0);
                      } else {
                        _controller!.setVolume(0);
                      }
                      setState(() {});
                    },
                    child: Icon(
                      _controller?.value.volume == 0
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Fullscreen toggle
                  GestureDetector(
                    onTap: _toggleFullscreen,
                    child: Icon(
                      _isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'loading'.tr(locale),
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String locale) {
    final message = _errorMessage != null && _errorMessage!.startsWith('video_')
        ? _errorMessage!.tr(locale)
        : (_errorMessage ?? 'video_load_error'.tr(locale));
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.video_slash, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeVideo();
              },
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr(locale)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openVideoInBrowser,
              icon: const Icon(Icons.open_in_browser, size: 20),
              label: Text('video_open_in_browser'.tr(locale)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'back'.tr(locale),
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
