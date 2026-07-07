import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import 'fullscreen_video_player.dart';

class VideoDemoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final String? videoSource;
  final String? title;

  const VideoDemoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.videoSource,
    this.title,
  });

  @override
  State<VideoDemoPlayer> createState() => _VideoDemoPlayerState();
}

class _VideoDemoPlayerState extends State<VideoDemoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showThumbnail = true;
  bool _showControls = true;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (_isInitialized || widget.videoUrl.isEmpty) return;

    setState(() {
      _showThumbnail = false;
    });

    try {
      String videoUrl = widget.videoUrl;
      
      // Add base URL if needed
      if (!videoUrl.startsWith('http')) {
        videoUrl = 'https://edufirma.com$videoUrl';
      }
      
      debugPrint('Initializing video: $videoUrl');

      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _controller!.initialize();
      
      _controller!.addListener(_videoListener);
      
      _duration = _controller!.value.duration;

      setState(() {
        _isInitialized = true;
      });

      await _controller!.play();
      setState(() {
        _isPlaying = true;
      });

      // Hide controls after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });

    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() {
        _errorMessage = 'Impossible de charger la vidéo';
        _showThumbnail = true;
      });
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final position = _controller!.value.position;
      final isPlaying = _controller!.value.isPlaying;
      
      if (position != _position || isPlaying != _isPlaying) {
        setState(() {
          _position = position;
          _isPlaying = isPlaying;
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
    }
    
    setState(() {
      _showControls = true;
    });

    // Hide controls after 3 seconds if playing
    if (!_isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls && _isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _openFullscreen() async {
    // Pause current video
    _controller?.pause();
    
    // Navigate to fullscreen player
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          videoUrl: widget.videoUrl,
          title: widget.title ?? 'Vidéo démo',
          thumbnailUrl: widget.thumbnailUrl,
          startPosition: _position,
        ),
      ),
    );
    
    // Resume video after returning
    if (mounted && _controller != null) {
      _controller!.play();
      setState(() {
        _isPlaying = true;
      });
    }
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(color: Colors.black),

            // Thumbnail or Video
            if (_showThumbnail) ...[
              _buildThumbnail(),
            ] else if (_isInitialized && _controller != null) ...[
              _buildVideoPlayer(),
            ] else ...[
              _buildLoading(),
            ],

            // Error message
            if (_errorMessage != null) _buildError(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail image
        if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
          Image.network(
            widget.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.secondary,
              child: const Icon(Iconsax.video_play, size: 50, color: Colors.white54),
            ),
          )
        else
          Container(
            color: AppColors.secondary,
            child: const Icon(Iconsax.video_play, size: 50, color: Colors.white54),
          ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // Play button
        Center(
          child: GestureDetector(
            onTap: _initializeVideo,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.play5,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ),

        // Demo label
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.video_play, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Vidéo démo',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Controls overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top bar (empty for now, could add title)
                  const SizedBox(height: 10),

                  // Center play/pause button
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),

                  // Bottom controls
                  _buildBottomControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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
                  fontSize: 12,
                ),
              ),

              // Additional controls
              Row(
                children: [
                  // Volume toggle
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
                      _controller!.value.volume == 0
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Fullscreen button
                  GestureDetector(
                    onTap: _openFullscreen,
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 26,
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

  Widget _buildLoading() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.video_slash, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _showThumbnail = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
