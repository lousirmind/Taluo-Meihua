import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/fusion_result.dart';
import '../../services/llm_service.dart';
import '../../widgets/disclaimer_text.dart';
import '../../app/theme.dart';
import '../../data/save_helper.dart';

class FusionReadingPage extends StatefulWidget {
  final FusionResult fusionResult;
  const FusionReadingPage({super.key, required this.fusionResult});

  @override
  State<FusionReadingPage> createState() => _FusionReadingPageState();
}

class _FusionReadingPageState extends State<FusionReadingPage> {
  late Future<String> _reading;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _reading = LlmService.instance.getFusionReading(widget.fusionResult, question: widget.fusionResult.question).then((v) {
      _autoSave(v);
      return v;
    });
  }

  void _autoSave(String reading) {
    if (_saved) return;
    _saved = true;
    final r = widget.fusionResult;
    SaveHelper.saveFusion(
      hexagramData: SaveHelper.encodeMeihua(r.meihua),
      tarotCards: SaveHelper.encodeTarot(r.tarot),
      question: r.question,
      reading: reading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.fusionResult;
    final m = r.meihua;
    final t = r.tarot;
    final colors = AppTheme.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('融合解读')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 卦象总览
            _buildOverviewCard(m, colors),
            const SizedBox(height: 16),
            // 塔罗牌面
            Text('塔罗牌面', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildTarotCards(t, colors),
            const SizedBox(height: 16),
            // LLM解读
            if (r.question != null && r.question!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('你的问题：${r.question}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
              ),
            ],
            const SizedBox(height: 8),
            _buildReadingCard(),
            const SizedBox(height: 8),
            const DisclaimerText(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(dynamic m, dynamic colors) {
    return Card(
      color: colors.forTiYong(m.tiYong.relation).withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Column(
              children: [
                Text(m.benGua.upperSymbol, style: const TextStyle(fontSize: 24)),
                Text(m.benGua.lowerSymbol, style: const TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(m.benGua.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.forTiYong(m.tiYong.relation),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(m.tiYong.relation, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(m.benGua.guaCi, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('体${m.tiYong.tiGua.name}${m.tiYong.tiElement} · 用${m.tiYong.yongGua.name}${m.tiYong.yongElement}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarotCards(dynamic t, dynamic colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(t.positions.length, (i) {
          final pos = t.positions[i];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(pos.name, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 4),
                    Icon(
                      pos.isReversed ? Icons.flip_to_back : Icons.flip_to_front,
                      color: pos.isReversed ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(pos.card.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: pos.isReversed ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(pos.isReversed ? '逆位' : '正位', style: TextStyle(fontSize: 10, color: pos.isReversed ? Colors.orange : Colors.green)),
                    ),
                    const SizedBox(height: 2),
                    Text(pos.card.keyword, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                    if (pos.focusWeight > 1)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: const Text('★ 动爻聚焦', style: TextStyle(fontSize: 9, color: Colors.amber)),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReadingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('融合解读', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _reading,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('正在生成解读...', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ));
                }
                if (snapshot.hasError) {
                  return Text('解读生成失败: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                }
                return MarkdownBody(data: snapshot.data ?? '');
              },
            ),
          ],
        ),
      ),
    );
  }
}
