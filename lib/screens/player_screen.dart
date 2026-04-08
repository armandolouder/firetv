import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/channel.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isBuffering = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _hideControlsAfterDelay();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.channel.url),
    );

    try {
      await _controller.initialize();
      await _controller.play();
      setState(() {});
    } catch (e) {
      setState(() => _hasError = true);
    }

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isBuffering = _controller.value.isBuffering;
        });
      }
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: _handleKey,
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video
              _controller.value.isInitialized
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : const SizedBox(),

              // Error state
              if (_hasError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFE50914), size: 64),
                      const SizedBox(height: 16),
                      const Text('Erro ao reproduzir canal',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(widget.channel.url,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                        ),
                        child: const Text('Voltar'),
                      ),
                    ],
                  ),
                ),

              // Loading spinner
              if (!_controller.value.isInitialized && !_hasError)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE50914)),
                ),

              // Buffering
              if (_isBuffering)
                const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white54, strokeWidth: 2),
                ),

              // Controls overlay
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _buildControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        // Top gradient + info
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.channel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.channel.group,
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                // Live badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 8),
                      SizedBox(width: 4),
                      Text('AO VIVO',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(
                  icon: Icons.replay_10,
                  onTap: () => _controller.seekTo(
                    (_controller.value.position - const Duration(seconds: 10)),
                  ),
                ),
                const SizedBox(width: 24),
                _controlButton(
                  icon: _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 56,
                  onTap: () {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                    setState(() {});
                  },
                ),
                const SizedBox(width: 24),
                _controlButton(
                  icon: Icons.forward_10,
                  onTap: () => _controller.seekTo(
                    (_controller.value.position + const Duration(seconds: 10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 36,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.goBack:
        case LogicalKeyboardKey.escape:
          Navigator.pop(context);
          break;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.mediaPlayPause:
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
          _toggleControls();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _controller.seekTo(
              _controller.value.position - const Duration(seconds: 10));
          break;
        case LogicalKeyboardKey.arrowRight:
          _controller.seekTo(
              _controller.value.position + const Duration(seconds: 10));
          break;
        default:
          _toggleControls();
      }
    }
  }
}
