import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/tarot/tarot_spread.dart';
import '../../services/llm_service.dart';
import '../../widgets/disclaimer_text.dart';
import '../../data/save_helper.dart';

class TarotReadingPage extends StatefulWidget {
  const TarotReadingPage({super.key});

  @override
  State<TarotReadingPage> createState() => _TarotReadingPageState();
}

class _TarotReadingPageState extends State<TarotReadingPage> {
  TarotSpread? _spread;
  String? _question;
  Future<String>? _reading;
  bool _initialized = false;
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is TarotSpread) {
        _spread = args;
      } else {
        final map = args as Map<String, dynamic>;
        _spread = map['spread'] as TarotSpread;
        _question = map['question'] as String?;
      }
      final q = _question;
      if (q != null && q.isNotEmpty) {
        _reading = LlmService.instance.getTarotReading(_spread!, question: q).then((v) {
          _autoSave(v);
          return v;
        });
      }
      _initialized = true;
    }
  }

  void _autoSave(String reading) {
    if (_saved || _spread == null) return;
    _saved = true;
    SaveHelper.saveTarot(SaveHelper.encodeTarot(_spread!), question: _question, reading: reading);
  }

  @override
  Widget build(BuildContext context) {
    final spread = _spread;
    if (spread == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('解读结果')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('解读结果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCardSummaryRow(spread, cs),
            const SizedBox(height: 16),
            _buildCardMeanings(spread, cs),
            if (_reading != null) ...[
              const SizedBox(height: 16),
              _buildReadingCard(cs),
            ],
            const SizedBox(height: 8),
            const DisclaimerText(),
            const SizedBox(height: 16),
            _buildActionButtons(cs),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSummaryRow(TarotSpread spread, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: spread.positions.map((p) => _buildMiniCard(p, cs)).toList(),
    );
  }

  Widget _buildMiniCard(TarotPosition position, ColorScheme cs) {
    final borderColor = position.isReversed ? Colors.orange : Colors.green;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            children: [
              Text(position.card.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: position.isReversed ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(position.isReversed ? '逆位' : '正位',
                  style: TextStyle(fontSize: 10, color: position.isReversed ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(position.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.primary)),
      ],
    );
  }

  Widget _buildCardMeanings(TarotSpread spread, ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: spread.positions.map((p) {
            final meaning = p.isReversed ? p.card.meaningDown : p.card.meaningUp;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('【${p.name}】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.primary)),
                      const SizedBox(width: 6),
                      Text(p.card.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.isReversed ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(p.isReversed ? '逆位' : '正位',
                          style: TextStyle(fontSize: 11, color: p.isReversed ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(meaning, style: TextStyle(fontSize: 13, height: 1.5, color: cs.onSurface.withValues(alpha: 0.8))),
                  if (p != spread.positions.last) const Divider(height: 12),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReadingCard(ColorScheme cs) {
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
            if (_question != null && _question!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('你的问题：$_question', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7))),
              ),
            ],
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: _reading,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (snapshot.hasError) {
                  return Text('解读生成失败：${snapshot.error}', style: TextStyle(color: cs.error));
                }
                return MarkdownBody(data: snapshot.data ?? '暂无解读内容');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/tarot', (route) => route.isFirst),
            icon: const Icon(Icons.refresh),
            label: const Text('重新占卜'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('结果已自动保存到历史记录')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('已保存'),
          ),
        ),
      ],
    );
  }
}
