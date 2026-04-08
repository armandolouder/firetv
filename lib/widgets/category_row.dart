import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/channel.dart';
import 'channel_card.dart';

class CategoryRow extends StatefulWidget {
  final String title;
  final List<Channel> channels;
  final Function(Channel) onChannelSelected;

  const CategoryRow({
    super.key,
    required this.title,
    required this.channels,
    required this.onChannelSelected,
  });

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  final ScrollController _scrollController = ScrollController();
  int _focusedIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 12),
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Horizontal scroll
          SizedBox(
            height: 175,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              itemCount: widget.channels.length,
              itemBuilder: (context, index) {
                return ChannelCard(
                  channel: widget.channels[index],
                  isFocused: _focusedIndex == index,
                  onFocus: () {
                    setState(() => _focusedIndex = index);
                    _scrollToIndex(index);
                  },
                  onSelect: () => widget.onChannelSelected(widget.channels[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToIndex(int index) {
    final cardWidth = 150.0 + 10.0; // card width + margin
    final offset = (index * cardWidth) - 48;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
