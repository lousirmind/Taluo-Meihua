import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/history_record.dart';
import '../../data/database/history_dao.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryRecord record;
  const HistoryDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(record.typeLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('删除记录'),
                  content: const Text('确定删除此条记录？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                    TextButton(onPressed: () {
                      Navigator.pop(ctx);
                      HistoryDao.delete(record.id);
                      Navigator.pop(context);
                    }, child: const Text('删除', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(cs),
            const SizedBox(height: 16),
            if (record.jsonData != null && record.jsonData!.isNotEmpty)
              _buildJsonCard(cs)
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('无详细数据', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_typeIcon(record.type), color: _typeColor(record.type), size: 28),
                const SizedBox(width: 8),
                Text(record.typeLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _row('时间', _formatTime(record.createTime), cs),
            if (record.summary.isNotEmpty) ...[
              const SizedBox(height: 6),
              _row('摘要', record.summary, cs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJsonCard(ColorScheme cs) {
    try {
      final data = jsonDecode(record.jsonData!) as Map<String, dynamic>;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('详细数据', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
              const SizedBox(height: 8),
              _buildJsonTree(data, cs, 0),
            ],
          ),
        ),
      );
    } catch (_) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(record.jsonData!, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
        ),
      );
    }
  }

  Widget _buildJsonTree(dynamic value, ColorScheme cs, int depth) {
    if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(left: depth * 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.key}: ', style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary, fontSize: 13)),
                    if (e.value is! Map && e.value is! List)
                      Expanded(
                        child: Text(
                          '${e.value}',
                          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ),
                  ],
                ),
                if (e.value is Map || e.value is List)
                  _buildJsonTree(e.value, cs, depth + 1),
              ],
            ),
          );
        }).toList(),
      );
    } else if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(left: depth * 12.0),
            child: e.value is Map || e.value is List
                ? _buildJsonTree(e.value, cs, depth + 1)
                : Text('• ${e.value}', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7))),
          );
        }).toList(),
      );
    }
    return Text('$value', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7)));
  }

  Widget _row(String label, String value, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
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

  String _formatTime(DateTime dt) {
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}:${_p(dt.second)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}
