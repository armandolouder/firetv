import 'package:flutter/material.dart';
import '../models/channel.dart';

class FeaturedBanner extends StatelessWidget {
  final Channel channel;
  final VoidCallback onPlay;

  const FeaturedBanner({super.key, required this.channel, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image/logo
          channel.logo.isNotEmpty
              ? Image.network(
                  channel.logo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackBg(),
                )
              : _fallbackBg(),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Colors.transparent, Color(0xCC0A0A0A), Color(0xF00A0A0A)],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xDD0A0A0A)],
              ),
            ),
          ),

          // Content
          Positioned(
            left: 48,
            bottom: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    channel.group.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  channel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    _buildPlayButton(onPlay),
                    const SizedBox(width: 12),
                    _buildInfoButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(VoidCallback onPlay) {
    return Focus(
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: onPlay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: focused ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: focused
                    ? [const BoxShadow(color: Colors.white30, blurRadius: 16)]
                    : [],
              ),
              child: const Row(
                children: [
                  Icon(Icons.play_arrow, color: Colors.black, size: 24),
                  SizedBox(width: 8),
                  Text('Reproduzir',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Mais info',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _fallbackBg() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: Icon(Icons.live_tv, color: Colors.white12, size: 120),
      ),
    );
  }
}
