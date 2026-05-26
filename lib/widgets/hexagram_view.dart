import 'package:flutter/material.dart';
import '../models/meihua/hexagram.dart';

/// 卦象可视化组件 — 显示上下卦 Unicode 符号
class HexagramView extends StatelessWidget {
  final Hexagram hexagram;
  final double symbolSize;
  final int? highlightYao;
  final bool showLabel;

  const HexagramView({
    super.key,
    required this.hexagram,
    this.symbolSize = 32,
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
          Text(hexagram.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.primary)),
          const SizedBox(height: 4),
        ],
        Text(hexagram.upperSymbol, style: TextStyle(fontSize: symbolSize)),
        Text(hexagram.lowerSymbol, style: TextStyle(fontSize: symbolSize)),
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
        HexagramView(hexagram: h, symbolSize: 28, highlightYao: highlight, showLabel: true),
      ],
    );
  }
}
