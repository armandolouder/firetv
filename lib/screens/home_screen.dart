import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/channel_provider.dart';
import '../models/channel.dart';
import '../widgets/channel_card.dart';
import '../widgets/featured_banner.dart';
import '../widgets/category_row.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Consumer<ChannelProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE50914)),
                  SizedBox(height: 20),
                  Text('A carregar conteúdos...',
                      style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE50914), size: 64),
                  const SizedBox(height: 16),
                  Text(provider.error!,
                      style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: provider.fetchChannels,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Tentar novamente', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          }

          final groups = provider.groups;
          final featured = provider.channels.isNotEmpty ? provider.channels[0] : null;

          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A0A0A), Color(0xFF111111)],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top navbar
                  _buildNavBar(provider),

                  // Content
                  Expanded(
                    child: ListView(
                      children: [
                        // Featured banner
                        if (featured != null)
                          FeaturedBanner(
                            channel: featured,
                            onPlay: () => _openPlayer(context, featured),
                          ),

                        const SizedBox(height: 8),

                        // Category rows
                        ...groups.entries.take(15).map((entry) {
                          return CategoryRow(
                            title: entry.key,
                            channels: entry.value,
                            onChannelSelected: (ch) => _openPlayer(context, ch),
                          );
                        }),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavBar(ChannelProvider provider) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC0A0A0A), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Logo
          const Text(
            'STREAMTV',
            style: TextStyle(
              color: Color(0xFFE50914),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 48),

          // Nav items
          ..._buildNavItems(provider),

          const Spacer(),

          // Search icon
          const Icon(Icons.search, color: Colors.white, size: 26),
          const SizedBox(width: 24),
          const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems(ChannelProvider provider) {
    final items = ['Início', 'Ao Vivo', 'Filmes', 'Séries', 'Desporto'];
    return items.asMap().entries.map((e) {
      final selected = _selectedCategoryIndex == e.key;
      return GestureDetector(
        onTap: () => setState(() => _selectedCategoryIndex = e.key),
        child: Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: selected
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE50914), width: 2),
                  ),
                )
              : null,
          child: Text(
            e.value,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white60,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _openPlayer(BuildContext context, Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel)),
    );
  }
}
