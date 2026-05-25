import 'package:flutter/material.dart';
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
  late Future<String> _reading;
  bool _initialized = false;
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _spread = ModalRoute.of(context)!.settings.arguments as TarotSpread;
      _reading = LlmService.instance.getTarotReading(_spread!).then((v) {
        _autoSave();
        return v;
      });
      _initialized = true;
    }
  }

  void _autoSave() {
    if (_saved || _spread == null) return;
    _saved = true;
    SaveHelper.saveTarot(SaveHelper.encodeTarot(_spread!));
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
            const SizedBox(height: 24),
            _buildReadingCard(cs),
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
              Text(
                position.card.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: position.isReversed
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  position.isReversed ? '逆位' : '正位',
                  style: TextStyle(
                    fontSize: 10,
                    color: position.isReversed ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          position.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '占卜解读',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: _reading,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    '解读生成失败：${snapshot.error}',
                    style: TextStyle(color: cs.error),
                  );
                }
                return Text(
                  snapshot.data ?? '暂无解读内容',
                  style: const TextStyle(height: 1.6, fontSize: 14),
                );
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
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/tarot',
              (route) => route.isFirst,
            ),
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
