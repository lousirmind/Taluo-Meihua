import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/database/history_dao.dart';
import '../../models/history_record.dart';

class HistoryListPage extends StatefulWidget {
  const HistoryListPage({super.key});

  @override
  State<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage> {
  List<HistoryRecord> _records = [];
  DivinationType? _filter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await HistoryDao.getAll(type: _filter);
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await HistoryDao.delete(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: Column(
        children: [
          _buildFilter(cs),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? _buildEmpty(cs)
                    : _buildList(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(ColorScheme cs) {
    const types = <DivinationType?>[null, DivinationType.fusion, DivinationType.meihua, DivinationType.tarot, DivinationType.bazi];
    const labels = ['全部', '融合', '梅花', '塔罗', '八字'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(types.length, (i) {
          final selected = _filter == types[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(labels[i]),
              selected: selected,
              onSelected: (_) {
                setState(() => _filter = types[i]);
                _load();
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('暂无记录', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _buildList(ColorScheme cs) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final r = _records[index];
          return Dismissible(
            key: Key(r.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _delete(r.id),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(_typeIcon(r.type), color: _typeColor(r.type)),
                title: Text('占卜方式：${r.typeLabel}', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatTime(r.createTime),
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                    if (_extractQuestion(r) case final q?) ...[
                      const SizedBox(height: 2),
                      Text('占卜问题：$q',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: cs.primary.withValues(alpha: 0.8))),
                    ],
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/history/detail', arguments: r),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _typeIcon(DivinationType t) {
    switch (t) {
      case DivinationType.fusion: return Icons.auto_awesome;
      case DivinationType.meihua: return Icons.hexagon_outlined;
      case DivinationType.tarot: return Icons.style;
      case DivinationType.bazi: return Icons.calendar_month;
    }
  }

  Color _typeColor(DivinationType t) {
    switch (t) {
      case DivinationType.fusion: return Colors.purple;
      case DivinationType.meihua: return Colors.teal;
      case DivinationType.tarot: return Colors.indigo;
      case DivinationType.bazi: return Colors.brown;
    }
  }

  String? _extractQuestion(HistoryRecord r) {
    if (r.jsonData == null || r.jsonData!.isEmpty) return null;
    try {
      final data = jsonDecode(r.jsonData!) as Map<String, dynamic>;
      final q = data['question'] as String?;
      return (q != null && q.isNotEmpty) ? q : null;
    } catch (_) {
      return null;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}
