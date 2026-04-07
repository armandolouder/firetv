import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ChannelProvider extends ChangeNotifier {
  static const String m3uUrl =
      'http://elitedns.sbs/get.php?username=3919680&password=9940229&type=m3u_plus&output=mpegts';

  List<Channel> _channels = [];
  Map<String, List<Channel>> _groups = {};
  bool _loading = false;
  String? _error;
  String _selectedGroup = 'Todos';

  List<Channel> get channels => _channels;
  Map<String, List<Channel>> get groups => _groups;
  bool get loading => _loading;
  String? get error => _error;
  String get selectedGroup => _selectedGroup;

  List<String> get groupNames => ['Todos', ..._groups.keys.toList()];

  List<Channel> get filteredChannels {
    if (_selectedGroup == 'Todos') return _channels;
    return _groups[_selectedGroup] ?? [];
  }

  ChannelProvider() {
    fetchChannels();
  }

  void selectGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }

  Future<void> fetchChannels() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(m3uUrl)).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        _channels = _parseM3U(response.body);
        _buildGroups();
      } else {
        _error = 'Erro ao carregar lista: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    }

    _loading = false;
    notifyListeners();
  }

  List<Channel> _parseM3U(String content) {
    final channels = <Channel>[];
    final lines = content.split('\n');

    String name = '';
    String logo = '';
    String group = 'Geral';
    String epgId = '';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF')) {
        name = _extractAttr(line, 'tvg-name') ?? _extractTitle(line);
        logo = _extractAttr(line, 'tvg-logo') ?? '';
        group = _extractAttr(line, 'group-title') ?? 'Geral';
        epgId = _extractAttr(line, 'tvg-id') ?? '';
      } else if (line.isNotEmpty && !line.startsWith('#') && name.isNotEmpty) {
        channels.add(Channel(
          name: name,
          url: line,
          logo: logo,
          group: group,
          epgId: epgId.isNotEmpty ? epgId : null,
        ));
        name = '';
        logo = '';
        group = 'Geral';
        epgId = '';
      }
    }

    return channels;
  }

  void _buildGroups() {
    _groups = {};
    for (final channel in _channels) {
      _groups.putIfAbsent(channel.group, () => []).add(channel);
    }
  }

  String? _extractAttr(String line, String attr) {
    final regex = RegExp('$attr="([^"]*)"');
    final match = regex.firstMatch(line);
    return match?.group(1);
  }

  String _extractTitle(String line) {
    final idx = line.lastIndexOf(',');
    if (idx != -1 && idx < line.length - 1) {
      return line.substring(idx + 1).trim();
    }
    return 'Sem nome';
  }
}
