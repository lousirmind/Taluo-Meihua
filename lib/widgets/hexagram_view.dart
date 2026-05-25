import 'package:flutter/material.dart';
import '../models/meihua/hexagram.dart';

/// 卦象可视化组件 — 垂直展示6条阴阳爻
class HexagramView extends StatelessWidget {
  final Hexagram hexagram;
  final double lineWidth;
  final int? highlightYao; // 高亮的爻位置（动爻）
  final bool showLabel;

  const HexagramView({
    super.key,
    required this.hexagram,
    this.lineWidth = 40,
    this.highlightYao,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(hexagram.name, style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
          const SizedBox(height: 4),
        ],
        ...List.generate(6, (i) {
          final yao = hexagram.lines[5 - i]; // 从上到下显示
          final isHighlight = highlightYao == yao.position;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 1.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: lineWidth,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isHighlight ? Colors.amber : cs.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                if (!yao.isYang)
                  Container(
                    width: 4,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// 三卦并排对比视图（本卦/互卦/变卦）
class HexagramComparison extends StatelessWidget {
  final Hexagram benGua;
  final Hexagram huGua;
  final Hexagram bianGua;
  final int? movingYaoPos;

  const HexagramComparison({
    super.key,
    required this.benGua,
    required this.huGua,
    required this.bianGua,
    this.movingYaoPos,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _column(context, '本卦', benGua, movingYaoPos),
        _column(context, '互卦', huGua, null),
        _column(context, '变卦', bianGua, movingYaoPos),
      ],
    );
  }

  Widget _column(BuildContext context, String label, Hexagram h, int? highlight) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        HexagramView(hexagram: h, lineWidth: 28, highlightYao: highlight, showLabel: true),
      ],
    );
  }
}
