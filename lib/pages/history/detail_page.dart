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
              _buildDataCard(cs)
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

  Widget _buildDataCard(ColorScheme cs) {
    try {
      final data = jsonDecode(record.jsonData!) as Map<String, dynamic>;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('详细数据', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 16)),
              const SizedBox(height: 12),
              ..._buildTypeSpecific(data, cs),
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

  List<Widget> _buildTypeSpecific(Map<String, dynamic> data, ColorScheme cs) {
    switch (record.type) {
      case DivinationType.fusion:
        return _buildFusionData(data, cs);
      case DivinationType.meihua:
        return _buildMeihuaData(data, cs);
      case DivinationType.tarot:
        return _buildTarotData(data, cs);
      case DivinationType.bazi:
        return _buildBaziData(data, cs);
    }
  }

  // ---- 融合占卜 ----
  List<Widget> _buildFusionData(Map<String, dynamic> data, ColorScheme cs) {
    final widgets = <Widget>[];

    // 问题
    final q = data['question'] as String?;
    if (q != null && q.isNotEmpty) {
      widgets.add(_kv('你的问题', q, cs));
      widgets.add(const SizedBox(height: 8));
    }

    // 卦象
    final h = data['hexagram'] as Map<String, dynamic>?;
    if (h != null) {
      widgets.add(_sectionHeader('梅花卦象', Icons.hexagon_outlined, cs));
      widgets.add(_kv('本卦', '${h['name']}（${h['guaCi']}）', cs));
      widgets.add(_kv('互卦', h['huGua'] as String? ?? '', cs));
      widgets.add(_kv('变卦', h['bianGua'] as String? ?? '', cs));
      widgets.add(_kv('动爻', '第${h['movingYao']}爻', cs));

      final ty = h['tiYong'] as Map<String, dynamic>?;
      if (ty != null) {
        widgets.add(_kv('体用', ty['relation'] as String? ?? '', cs));
        widgets.add(_kv('体卦', '${ty['tiGua']}（${ty['tiElement']}）', cs));
        widgets.add(_kv('用卦', '${ty['yongGua']}（${ty['yongElement']}）', cs));
      }
      widgets.add(const SizedBox(height: 12));
    }

    // 塔罗牌
    final cards = data['tarotCards'] as List<dynamic>?;
    if (cards != null && cards.isNotEmpty) {
      widgets.add(_sectionHeader('塔罗牌面', Icons.style, cs));
      for (final c in cards) {
        final card = c as Map<String, dynamic>;
        widgets.add(_tarotCardBrief(card, cs));
      }
    }

    return widgets;
  }

  // ---- 梅花易数 ----
  List<Widget> _buildMeihuaData(Map<String, dynamic> data, ColorScheme cs) {
    return [
      _kv('本卦', '${data['name']}（${data['guaCi']}）', cs),
      _kv('互卦', data['huGua'] as String? ?? '', cs),
      _kv('变卦', data['bianGua'] as String? ?? '', cs),
      _kv('动爻', '第${data['movingYao']}爻', cs),
      if (data['tiYong'] != null) ...[
        const SizedBox(height: 6),
        _sectionHeader('体用分析', Icons.compare_arrows, cs),
        _kv('关系', (data['tiYong'] as Map)['relation'] as String? ?? '', cs),
        _kv('体卦', '${(data['tiYong'] as Map)['tiGua']}（${(data['tiYong'] as Map)['tiElement']}）', cs),
        _kv('用卦', '${(data['tiYong'] as Map)['yongGua']}（${(data['tiYong'] as Map)['yongElement']}）', cs),
      ],
    ];
  }

  // ---- 塔罗占卜 ----
  List<Widget> _buildTarotData(Map<String, dynamic> data, ColorScheme cs) {
    final cards = data['cards'] as List<dynamic>?;
    if (cards == null || cards.isEmpty) {
      return [Text('无牌面数据', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))];
    }
    return [
      _sectionHeader('抽取牌面', Icons.style, cs),
      for (final c in cards) _tarotCardBrief(c as Map<String, dynamic>, cs),
    ];
  }

  // ---- 八字命理 ----
  List<Widget> _buildBaziData(Map<String, dynamic> data, ColorScheme cs) {
    final widgets = <Widget>[
      _kv('日主', '${data['dayMaster']}（${data['dayMasterElement']}）', cs),
      const SizedBox(height: 8),
      _sectionHeader('四柱', Icons.calendar_month, cs),
    ];
    for (final label in ['年柱', '月柱', '日柱', '时柱']) {
      final key = switch (label) {
        '年柱' => 'yearPillar',
        '月柱' => 'monthPillar',
        '日柱' => 'dayPillar',
        _ => 'hourPillar',
      };
      final p = data[key] as Map<String, dynamic>?;
      if (p != null) {
        widgets.add(_kv(label, '${p['heavenlyStem']}${p['earthlyBranch']}', cs));
        widgets.add(_kv('  └ 藏干', (p['hiddenStems'] as List?)?.join('、') ?? '', cs));
        widgets.add(_kv('  └ 十神', (p['tenGods'] as List?)?.join('、') ?? '', cs));
        widgets.add(_kv('  └ 纳音', p['nayin'] as String? ?? '', cs));
      }
    }
    final kw = data['kongWang'];
    if (kw != null) {
      widgets.add(const SizedBox(height: 6));
      widgets.add(_kv('空亡', (kw as List).join('、'), cs));
    }
    return widgets;
  }

  // ---- 通用组件 ----
  Widget _sectionHeader(String text, IconData icon, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _tarotCardBrief(Map<String, dynamic> card, ColorScheme cs) {
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

  Widget _kv(String label, String value, ColorScheme cs) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
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
    );
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
