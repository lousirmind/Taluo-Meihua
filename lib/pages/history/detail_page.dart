import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/history_record.dart';
import '../../data/database/history_dao.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryRecord record;
  const HistoryDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = _parseData();
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
            _buildInfoCard(cs, data),
            const SizedBox(height: 16),
            if (data != null) _buildReadingCard(cs, data),
            const SizedBox(height: 16),
            if (data != null && data.reading.isNotEmpty) _buildGuidanceCard(cs, data.reading),
          ],
        ),
      ),
    );
  }

  _DetailData? _parseData() {
    if (record.jsonData == null || record.jsonData!.isEmpty) return null;
    try {
      return _DetailData.fromJson(record.type, jsonDecode(record.jsonData!) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Widget _buildInfoCard(ColorScheme cs, _DetailData? data) {
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
            if (data != null && data.question.isNotEmpty) ...[
              const SizedBox(height: 6),
              _row('占卜问题', data.question, cs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(ColorScheme cs, _DetailData data) {
    final title = switch (record.type) {
      DivinationType.fusion => '融合解读',
      DivinationType.meihua => '卦象解读',
      DivinationType.tarot => '牌面解读',
      DivinationType.bazi => '命理解读',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_sectionIcon(record.type), size: 20, color: cs.primary),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ...data.widgets(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard(ColorScheme cs, String reading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 20),
                const SizedBox(width: 6),
                Text('解惑指引', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownBody(data: reading),
          ],
        ),
      ),
    );
  }

  IconData _sectionIcon(DivinationType t) {
    switch (t) {
      case DivinationType.fusion: return Icons.auto_awesome;
      case DivinationType.meihua: return Icons.hexagon_outlined;
      case DivinationType.tarot: return Icons.style;
      case DivinationType.bazi: return Icons.calendar_month;
    }
  }

  Widget _row(String label, String value, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
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

// ---- 数据结构化解析 ----
class _DetailData {
  final String question;
  final String reading;
  final List<Widget> Function(ColorScheme) _buildWidgets;

  _DetailData({required this.question, required this.reading, required List<Widget> Function(ColorScheme) widgets})
      : _buildWidgets = widgets;

  List<Widget> widgets(ColorScheme cs) => _buildWidgets(cs);

  static _DetailData? fromJson(DivinationType type, Map<String, dynamic> data) {
    final question = data['question'] as String? ?? '';
    final reading = data['reading'] as String? ?? '';

    switch (type) {
      case DivinationType.fusion:
        return _DetailData(question: question, reading: reading, widgets: (cs) => _fusionWidgets(data, cs));
      case DivinationType.meihua:
        return _DetailData(question: question, reading: reading, widgets: (cs) => _meihuaWidgets(data, cs));
      case DivinationType.tarot:
        return _DetailData(question: question, reading: reading, widgets: (cs) => _tarotWidgets(data, cs));
      case DivinationType.bazi:
        return _DetailData(question: question, reading: reading, widgets: (cs) => _baziWidgets(data, cs));
    }
  }

  static List<Widget> _kv(String label, String value, ColorScheme cs) {
    if (value.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13)),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      ),
    ];
  }

  static Widget _tarotCard(Map<String, dynamic> card, ColorScheme cs) {
    final isReversed = card['isReversed'] as bool? ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isReversed ? Colors.orange.withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('【${card['position']}】', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 13)),
              const SizedBox(width: 4),
              Text(card['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: (isReversed ? Colors.orange : Colors.green).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(isReversed ? '逆位' : '正位',
                  style: TextStyle(fontSize: 11, color: isReversed ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (card['keyword'] != null && (card['keyword'] as String).isNotEmpty) ...[
            const SizedBox(height: 2),
            Text('关键词：${card['keyword']}', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
          ],
        ],
      ),
    );
  }

  // ---- 融合占卜 ----
  static List<Widget> _fusionWidgets(Map<String, dynamic> data, ColorScheme cs) {
    final list = <Widget>[];
    final h = data['hexagram'] as Map<String, dynamic>?;
    if (h != null) {
      list.addAll(_kv('本卦', '${h['name']}（${h['guaCi']}）', cs));
      list.addAll(_kv('互卦', h['huGua'] as String? ?? '', cs));
      list.addAll(_kv('变卦', h['bianGua'] as String? ?? '', cs));
      list.addAll(_kv('动爻', '第${h['movingYao']}爻', cs));
      final ty = h['tiYong'] as Map<String, dynamic>?;
      if (ty != null) {
        list.addAll(_kv('体用', ty['relation'] as String? ?? '', cs));
        list.addAll(_kv('体卦', '${ty['tiGua']}（${ty['tiElement']}）', cs));
        list.addAll(_kv('用卦', '${ty['yongGua']}（${ty['yongElement']}）', cs));
      }
    }
    final cards = data['tarotCards'] as List<dynamic>?;
    if (cards != null && cards.isNotEmpty) {
      list.add(const SizedBox(height: 6));
      list.add(Text('塔罗牌面', style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary, fontSize: 14)));
      list.add(const SizedBox(height: 4));
      for (final c in cards) {
        list.add(_tarotCard(c as Map<String, dynamic>, cs));
      }
    }
    return list;
  }

  // ---- 梅花易数 ----
  static List<Widget> _meihuaWidgets(Map<String, dynamic> data, ColorScheme cs) {
    final list = <Widget>[];
    list.addAll(_kv('本卦', '${data['name']}（${data['guaCi']}）', cs));
    list.addAll(_kv('互卦', data['huGua'] as String? ?? '', cs));
    list.addAll(_kv('变卦', data['bianGua'] as String? ?? '', cs));
    list.addAll(_kv('动爻', '第${data['movingYao']}爻', cs));
    if (data['tiYong'] != null) {
      final ty = data['tiYong'] as Map<String, dynamic>;
      list.add(const SizedBox(height: 4));
      list.addAll(_kv('体用', ty['relation'] as String? ?? '', cs));
      list.addAll(_kv('体卦', '${ty['tiGua']}（${ty['tiElement']}）', cs));
      list.addAll(_kv('用卦', '${ty['yongGua']}（${ty['yongElement']}）', cs));
    }
    return list;
  }

  // ---- 塔罗占卜 ----
  static List<Widget> _tarotWidgets(Map<String, dynamic> data, ColorScheme cs) {
    final cards = data['cards'] as List<dynamic>?;
    if (cards == null || cards.isEmpty) {
      return [Text('无牌面数据', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))];
    }
    return [for (final c in cards) _tarotCard(c as Map<String, dynamic>, cs)];
  }

  // ---- 八字命理 ----
  static List<Widget> _baziWidgets(Map<String, dynamic> data, ColorScheme cs) {
    final list = <Widget>[];
    list.addAll(_kv('日主', '${data['dayMaster']}（${data['dayMasterElement']}）', cs));
    list.add(const SizedBox(height: 4));
    for (final label in ['年柱', '月柱', '日柱', '时柱']) {
      final key = switch (label) {
        '年柱' => 'yearPillar', '月柱' => 'monthPillar', '日柱' => 'dayPillar', _ => 'hourPillar',
      };
      final p = data[key] as Map<String, dynamic>?;
      if (p != null) {
        list.addAll(_kv(label, '${p['heavenlyStem']}${p['earthlyBranch']}', cs));
        list.addAll(_kv('藏干', (p['hiddenStems'] as List?)?.join('、') ?? '', cs));
        list.addAll(_kv('十神', (p['tenGods'] as List?)?.join('、') ?? '', cs));
        list.addAll(_kv('纳音', p['nayin'] as String? ?? '', cs));
      }
    }
    final kw = data['kongWang'];
    if (kw != null) {
      list.add(const SizedBox(height: 4));
      list.addAll(_kv('空亡', (kw as List).join('、'), cs));
    }
    return list;
  }
}
