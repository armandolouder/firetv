import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/channel.dart';

class ChannelCard extends StatefulWidget {
  final Channel channel;
  final bool isFocused;
  final VoidCallback onFocus;
  final VoidCallback onSelect;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.isFocused,
    required this.onFocus,
    required this.onSelect,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(ChannelCard old) {
    super.didUpdateWidget(old);
    if (widget.isFocused && !old.isFocused) {
      _controller.forward();
    } else if (!widget.isFocused && old.isFocused) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        if (focused) widget.onFocus();
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.select) {
          widget.onSelect();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onSelect,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: widget.isFocused
                        ? Border.all(color: Colors.white, width: 2.5)
                        : Border.all(color: Colors.transparent, width: 2.5),
                    boxShadow: widget.isFocused
                        ? [
                            const BoxShadow(
                              color: Colors.white24,
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.channel.logo.isNotEmpty
                            ? Image.network(
                                widget.channel.logo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _fallback(),
                              )
                            : _fallback(),
                        // Gradient overlay
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0x880A0A0A)],
                            ),
                          ),
                        ),
                        // Play icon on focus
                        if (widget.isFocused)
                          const Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Name
                Text(
                  widget.channel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.isFocused ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: widget.isFocused
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF1E1E2E),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.live_tv, color: Colors.white24, size: 32),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.channel.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
