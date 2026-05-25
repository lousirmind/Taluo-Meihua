import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/meihua/meihua_result.dart';
import '../../widgets/hexagram_view.dart';
import '../../widgets/disclaimer_text.dart';
import '../../services/llm_service.dart';
import '../../app/theme.dart';
import '../../data/save_helper.dart';
import '../../data/constants/hexagrams.dart';

class MeihuaResultPage extends StatefulWidget {
  final MeihuaResult result;
  final String? question;
  const MeihuaResultPage({super.key, required this.result, this.question});

  @override
  State<MeihuaResultPage> createState() => _MeihuaResultPageState();
}

class _MeihuaResultPageState extends State<MeihuaResultPage> {
  Future<String>? _reading;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    if (q != null && q.isNotEmpty) {
      _reading = LlmService.instance.getMeihuaReading(widget.result, question: q).then((v) {
        _autoSave();
        return v;
      });
    }
  }

  void _autoSave() {
    if (_saved) return;
    _saved = true;
    SaveHelper.saveMeihua(SaveHelper.encodeMeihua(widget.result));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final colors = AppTheme.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('卦象结果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTiYongBadge(r.tiYong, colors),
            const SizedBox(height: 16),
            HexagramComparison(
              benGua: r.benGua,
              huGua: r.huGua,
              bianGua: r.bianGua,
              movingYaoPos: r.movingYao.position,
            ),
            const SizedBox(height: 16),
            _buildYaoCard(r),
            const SizedBox(height: 16),
            _buildInfoCard(r),
            if (_reading != null) ...[
              const SizedBox(height: 16),
              _buildReadingCard(),
            ],
            const SizedBox(height: 8),
            const DisclaimerText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTiYongBadge(TiYongAnalysis t, dynamic colors) {
    return Card(
      color: colors.forTiYong(t.relation).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.forTiYong(t.relation),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(t.relation, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '体卦${t.tiElement}（${t.tiGua.name}）· 用卦${t.yongElement}（${t.yongGua.name}）',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYaoCard(MeihuaResult r) {
    final cs = Theme.of(context).colorScheme;
    final entry = HexagramsData.getHexagram(r.benGua.sequence);
    final moving = r.movingYao.position;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('爻辞详解', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 15)),
            const SizedBox(height: 8),
            ...List.generate(6, (i) {
              final pos = i + 1;
              final isMoving = pos == moving;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isMoving ? Colors.amber.withValues(alpha: 0.15) : null,
                  borderRadius: BorderRadius.circular(4),
                  border: isMoving ? Border.all(color: Colors.amber, width: 1) : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text('第${pos}爻${isMoving ? " ⚡" : ""}',
                        style: TextStyle(fontSize: 12, fontWeight: isMoving ? FontWeight.bold : FontWeight.normal,
                          color: isMoving ? Colors.amber.shade800 : cs.onSurface.withValues(alpha: 0.6))),
                    ),
                    Expanded(
                      child: Text(
                        pos <= entry.yaoTexts.length ? entry.yaoTexts[pos - 1] : '',
                        style: TextStyle(fontSize: 13, height: 1.4, color: cs.onSurface),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(MeihuaResult r) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('【${r.benGua.name}】${r.benGua.guaCi}', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
            const SizedBox(height: 4),
            Text(r.benGua.guaCiTranslation, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
            const SizedBox(height: 8),
            Text('动爻：第${r.movingYao.position}爻 ${r.movingYao.originalIsYang ? "阳" : "阴"}变${r.movingYao.changedIsYang ? "阳" : "阴"}',
              style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard() {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            if (widget.question != null && widget.question!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('你的问题：${widget.question}', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7))),
              ),
            ],
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _reading,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ));
                }
                return MarkdownBody(data: snapshot.data ?? '解读生成失败');
              },
            ),
          ],
        ),
      ),
    );
  }
}
