import 'package:flutter/material.dart';
import '../../models/tarot/tarot_spread.dart';
import '../../widgets/card_flip.dart';

class TarotFlipPage extends StatefulWidget {
  const TarotFlipPage({super.key});

  @override
  State<TarotFlipPage> createState() => _TarotFlipPageState();
}

class _TarotFlipPageState extends State<TarotFlipPage> {
  TarotSpread? _spread;
  String? _question;
  late List<bool> _flippedStates;
  bool _initialized = false;

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
      _flippedStates = List.filled(3, false);
      _initialized = true;
    }
  }

  bool get _allFlipped => _flippedStates.every((f) => f);

  @override
  Widget build(BuildContext context) {
    final spread = _spread;
    if (spread == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('翻牌占卜')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('翻牌占卜')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              '点击牌面进行翻牌',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (i) => _buildCardColumn(i, spread, cs)),
              ),
            ),
            const SizedBox(height: 8),
            _buildMeanings(spread, cs),
            _buildBottomButton(cs),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMeanings(TarotSpread spread, ColorScheme cs) {
    final anyFlipped = _flippedStates.any((f) => f);
    if (!anyFlipped) return const SizedBox.shrink();
    final cards = List.generate(3, (i) {
      if (!_flippedStates[i]) return const SizedBox.shrink();
      final pos = spread.positions[i];
      final meaning = pos.isReversed ? pos.card.meaningDown : pos.card.meaningUp;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('【${pos.name}】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.primary)),
                    const SizedBox(width: 6),
                    Text(pos.card.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: pos.isReversed ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(pos.isReversed ? '逆位' : '正位', style: TextStyle(fontSize: 10, color: pos.isReversed ? Colors.orange : Colors.green)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(meaning, style: TextStyle(fontSize: 12, height: 1.4, color: cs.onSurface.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      );
    });
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: cards,
    );
  }

  Widget _buildBottomButton(ColorScheme cs) {
    if (!_allFlipped) {
      return const SizedBox(height: 100);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, '/tarot/reading', arguments: {
                'spread': _spread,
                'question': _question,
              }),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('查看完整解读'),
        ),
      ),
    );
  }

  Widget _buildCardColumn(int index, TarotSpread spread, ColorScheme cs) {
    final position = spread.positions[index];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          position.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 8),
        CardFlipWidget(
          front: _buildCardFace(position, cs),
          back: _buildCardBack(cs),
          flipped: _flippedStates[index],
          onFlip: () => setState(() => _flippedStates[index] = true),
          width: 100,
          height: 160,
        ),
        const SizedBox(height: 8),
        if (_flippedStates[index]) _buildCardInfo(position),
      ],
    );
  }

  Widget _buildCardInfo(TarotPosition position) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          position.card.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        _buildOrientationBadge(position.isReversed),
        const SizedBox(height: 2),
        Text(
          position.card.keyword,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOrientationBadge(bool isReversed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isReversed
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isReversed ? '逆位' : '正位',
        style: TextStyle(
          fontSize: 11,
          color: isReversed ? Colors.orange : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardBack(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A4A6A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Color(0xFF6A6A8A),
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace(TarotPosition position, ColorScheme cs) {
    // 牌框留空，后续放图片
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
    );
  }
}
