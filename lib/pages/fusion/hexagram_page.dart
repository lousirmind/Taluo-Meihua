import 'package:flutter/material.dart';
import '../../models/meihua/meihua_result.dart';
import '../../models/fusion_result.dart';
import '../../models/tarot/tarot_spread.dart';
import '../../widgets/hexagram_view.dart';
import '../../widgets/disclaimer_text.dart';
import '../../engines/fusion_mapper.dart';
import '../../engines/tarot_engine.dart';
import '../../app/theme.dart';

class FusionHexagramPage extends StatefulWidget {
  final MeihuaResult meihuaResult;
  final String? question;
  const FusionHexagramPage({super.key, required this.meihuaResult, this.question});

  @override
  State<FusionHexagramPage> createState() => _FusionHexagramPageState();
}

class _FusionHexagramPageState extends State<FusionHexagramPage> {
  Future<TarotSpread>? _tarotFuture;

  @override
  void initState() {
    super.initState();
    _tarotFuture = _calculateFusion();
  }

  Future<TarotSpread> _calculateFusion() async {
    final m = widget.meihuaResult;
    final strategy = FusionMapper.getTarotStrategy(m.tiYong.relation);
    final focusPos = FusionMapper.movingYaoToFocusPosition(m.movingYao.position);
    return TarotEngine.drawFiltered(
      suitFilter: FusionMapper.getSuitFilter(m, strategy),
      preferMajor: strategy['preferMajor'] as bool,
      focusPosition: focusPos,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.meihuaResult;
    final colors = AppTheme.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('卦象推演')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTiYongCard(r, colors),
            const SizedBox(height: 16),
            HexagramComparison(
              benGua: r.benGua,
              huGua: r.huGua,
              bianGua: r.bianGua,
              movingYaoPos: r.movingYao.position,
            ),
            const SizedBox(height: 16),
            _buildGuaCiCard(r),
            const SizedBox(height: 16),
            _buildMappingHint(),
            const SizedBox(height: 24),
            FutureBuilder<TarotSpread>(
              future: _tarotFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('计算塔罗映射失败: ${snapshot.error}'));
                }
                final spread = snapshot.data!;
                return SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      final fusion = FusionResult(
                        meihua: r,
                        tarot: spread,
                        createTime: DateTime.now(),
                        question: widget.question,
                      );
                      Navigator.pushNamed(context, '/fusion/flip', arguments: fusion);
                    },
                    icon: const Icon(Icons.style),
                    label: Text('查看塔罗映射（${spread.positions.map((p) => p.card.name).join("·")}）'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const DisclaimerText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTiYongCard(MeihuaResult r, dynamic colors) {
    final t = r.tiYong;
    return Card(
      color: colors.forTiYong(t.relation).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Text('${r.benGua.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text('体卦：${t.tiGua.name}（${t.tiElement}） | 用卦：${t.yongGua.name}（${t.yongElement}）'),
            const SizedBox(height: 4),
            Text('动爻：第${r.movingYao.position}爻动', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaCiCard(MeihuaResult r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('【${r.benGua.name}】${r.benGua.guaCi}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(r.benGua.guaCiTranslation, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingHint() {
    final r = widget.meihuaResult;
    final strategy = FusionMapper.getTarotStrategy(r.tiYong.relation);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.compare_arrows, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '体用${r.tiYong.relation} → ${strategy['desc']}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
