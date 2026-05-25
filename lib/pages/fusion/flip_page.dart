import 'package:flutter/material.dart';
import '../../models/fusion_result.dart';
import '../../models/tarot/tarot_spread.dart';
import '../../widgets/card_flip.dart';
import '../../app/theme.dart';

class FusionFlipPage extends StatefulWidget {
  final FusionResult fusionResult;
  const FusionFlipPage({super.key, required this.fusionResult});

  @override
  State<FusionFlipPage> createState() => _FusionFlipPageState();
}

class _FusionFlipPageState extends State<FusionFlipPage> {
  late List<bool> _flipped;
  int _flippedCount = 0;

  @override
  void initState() {
    super.initState();
    _flipped = [false, false, false];
  }

  @override
  Widget build(BuildContext context) {
    final spread = widget.fusionResult.tarot;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final colors = AppTheme.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('翻牌占卜')),
      body: Column(
        children: [
          // 映射提示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colors.forTiYong(widget.fusionResult.meihua.tiYong.relation).withValues(alpha: 0.1),
            child: Text(
              '体用${widget.fusionResult.meihua.tiYong.relation} · 点击逐张翻牌',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.forTiYong(widget.fusionResult.meihua.tiYong.relation),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 三张牌
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) {
                  final pos = spread.positions[i];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pos.name, style: tt.labelMedium),
                      const SizedBox(height: 8),
                      CardFlipWidget(
                        front: _buildFace(pos, cs, colors),
                        back: _buildBack(cs),
                        flipped: _flipped[i],
                        onFlip: () => setState(() => _flippedCount++),
                        width: 100,
                        height: 160,
                      ),
                      if (_flipped[i]) ...[
                        const SizedBox(height: 4),
                        Text(pos.card.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: pos.isReversed ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pos.isReversed ? '逆位' : '正位',
                            style: TextStyle(fontSize: 11, color: pos.isReversed ? Colors.orange : Colors.green),
                          ),
                        ),
                        if (pos.focusWeight > 1)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('★ 聚焦', style: TextStyle(fontSize: 10, color: Colors.amber)),
                          ),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ),
          // 底部按钮
          if (_flippedCount >= 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/fusion/reading', arguments: widget.fusionResult);
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('查看完整解读'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFace(TarotPosition pos, ColorScheme cs, dynamic colors) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: pos.isReversed ? Colors.orange : Colors.green.shade300,
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _suitIcon(pos.card.suit),
                size: 28,
                color: cs.primary,
              ),
              const SizedBox(height: 6),
              Text(
                pos.card.keyword,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: const Center(
        child: Icon(Icons.auto_awesome, color: Colors.white54, size: 36),
      ),
    );
  }

  IconData _suitIcon(String suit) {
    switch (suit) {
      case 'wands': return Icons.local_fire_department;
      case 'cups': return Icons.water_drop;
      case 'swords': return Icons.content_cut;
      case 'pentacles': return Icons.circle;
      default: return Icons.star;
    }
  }
}
