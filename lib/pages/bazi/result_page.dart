import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/bazi/bazi_result.dart';
import '../../widgets/disclaimer_text.dart';
import '../../services/llm_service.dart';
import '../../app/theme.dart';
import '../../data/save_helper.dart';

class BaziResultPage extends StatefulWidget {
  final BaziResult result;

  const BaziResultPage({super.key, required this.result});

  @override
  State<BaziResultPage> createState() => _BaziResultPageState();
}

class _BaziResultPageState extends State<BaziResultPage> {
  late Future<String> _reading;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _reading = LlmService.instance.getBaziReading(widget.result).then((v) {
      _autoSave(v);
      return v;
    });
  }

  void _autoSave(String reading) {
    if (_saved) return;
    _saved = true;
    SaveHelper.saveBazi(SaveHelper.encodeBazi(widget.result), reading: reading);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Scaffold(
      appBar: AppBar(title: const Text('排盘结果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPillarTable(r),
            const SizedBox(height: 16),
            _buildDerivationProcess(),
            const SizedBox(height: 16),
            _buildTiYongCard(r),
            const SizedBox(height: 16),
            _buildDaYunSection(r),
            const SizedBox(height: 16),
            _buildCurrentYearCard(r),
            const SizedBox(height: 16),
            _buildReadingCard(),
            const SizedBox(height: 8),
            const DisclaimerText(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  //  四柱排盘表格
  // ==========================================================

  Widget _buildPillarTable(BaziResult r) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                '四柱排盘',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // ── 表头 ──
                _tableRow(
                  cells: ['', '年', '月', '日', '时'],
                  isHeader: true,
                ),
                // ── 干支 ──
                _tableRow(
                  cells: ['干支', '', '', '', ''],
                  isHeader: true,
                  customCells: [
                    null,
                    _pillarLabelCell(
                      '${r.yearPillar.heavenlyStem}${r.yearPillar.earthlyBranch}',
                    ),
                    _pillarLabelCell(
                      '${r.monthPillar.heavenlyStem}${r.monthPillar.earthlyBranch}',
                    ),
                    _pillarDayCell(
                      '${r.dayPillar.heavenlyStem}${r.dayPillar.earthlyBranch}',
                      cs,
                    ),
                    _pillarLabelCell(
                      '${r.hourPillar.heavenlyStem}${r.hourPillar.earthlyBranch}',
                    ),
                  ],
                ),
                // ── 藏干 ──
                _tableRow(
                  cells: [
                    '藏干',
                    _joinList(r.yearPillar.hiddenStems),
                    _joinList(r.monthPillar.hiddenStems),
                    _joinList(r.dayPillar.hiddenStems),
                    _joinList(r.hourPillar.hiddenStems),
                  ],
                ),
                // ── 十神 ──
                _tableRow(
                  cells: [
                    '十神',
                    _joinList(r.yearPillar.tenGods),
                    _joinList(r.monthPillar.tenGods),
                    _joinList(r.dayPillar.tenGods),
                    _joinList(r.hourPillar.tenGods),
                  ],
                ),
                // ── 五行 ──
                _tableRow(
                  cells: [
                    '五行',
                    _joinList(r.yearPillar.fiveElements),
                    _joinList(r.monthPillar.fiveElements),
                    _joinList(r.dayPillar.fiveElements),
                    _joinList(r.hourPillar.fiveElements),
                  ],
                ),
                // ── 纳音 ──
                _tableRow(
                  cells: [
                    '纳音',
                    r.yearPillar.nayin,
                    r.monthPillar.nayin,
                    r.dayPillar.nayin,
                    r.hourPillar.nayin,
                  ],
                ),
              ],
            ),
            // 空亡
            if (r.kongWang.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('空亡：', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
                  ...r.kongWang.map((kw) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(kw, style: TextStyle(fontSize: 12, color: cs.error)),
                    ),
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  TableRow _tableRow({
    required List<String> cells,
    bool isHeader = false,
    List<Widget?>? customCells,
  }) {
    final cs = Theme.of(context).colorScheme;

    return TableRow(
      children: List.generate(5, (i) {
        if (customCells != null && customCells[i] != null) {
          return customCells[i]!;
        }
        final text = i < cells.length ? cells[i] : '';
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          alignment: Alignment.center,
          decoration: i == 0
              ? BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.4))
              : (isHeader
                  ? BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.25))
                  : null),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isHeader || i == 0 ? 13 : 12,
              fontWeight: isHeader || i == 0 ? FontWeight.bold : null,
              color: i == 0 ? cs.onSurface.withValues(alpha: 0.7) : null,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }

  Widget _pillarLabelCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _pillarDayCell(String text, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '日主',
              style: TextStyle(fontSize: 9, color: cs.onPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _joinList(List<String> list) {
    if (list.isEmpty) return '--';
    return list.join(' ');
  }

  // ==========================================================
  //  推导过程
  // ==========================================================

  Widget _buildDerivationProcess() {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ExpansionTile(
        title: Text(
          '推导过程',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
        ),
        subtitle: Text(
          '查看八字排盘计算步骤',
          style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _derivationItem(
                  title: '年柱推算',
                  content:
                      '年柱以立春为分界。出生日在立春（约2月4日前后）之前，年柱按上一年干支计算；'
                      '在立春之后，按当年干支计算。天干每10年一循环，地支每12年一循环。',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _derivationItem(
                  title: '月柱推算',
                  content:
                      '月柱地支根据节气分界确定，立春为寅月起点，惊蛰为卯月起点，依此类推。'
                      '月柱天干通过"五虎遁"规则由年干推算：甲己之年丙作首，乙庚之岁戊为头，'
                      '丙辛必定寻庚起，丁壬壬位顺行流，戊癸何方发，甲寅之上好追求。',
                  icon: Icons.rotate_left,
                ),
                const SizedBox(height: 12),
                _derivationItem(
                  title: '日柱推算',
                  content:
                      '日柱以2000年1月1日（戊午日，天干索引4、地支索引6）为基准日期，'
                      '通过出生日期与基准日期的偏移天数计算干支索引。'
                      '晚子时（23:00-23:59）日柱按次日计算。',
                  icon: Icons.date_range,
                ),
                const SizedBox(height: 12),
                _derivationItem(
                  title: '时柱推算',
                  content:
                      '时柱地支根据出生时辰确定（子时23:00-00:59，丑时01:00-02:59，依此类推）。'
                      '时柱天干通过"五鼠遁"规则由日干推算：甲己还加甲，乙庚丙作初，'
                      '丙辛从戊起，丁壬庚子居，戊癸何方发，壬子是真途。'
                      '若填写了出生地点，将根据当地经度进行真太阳时校正。',
                  icon: Icons.access_time,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _derivationItem({
    required String title,
    required String content,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 10),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  //  体用量化卡片
  // ==========================================================

  Widget _buildTiYongCard(BaziResult r) {
    final cs = Theme.of(context).colorScheme;
    final elementColor = AppTheme.colors.forElement(r.dayMasterElement);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '体用量化',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // 日主大字
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: elementColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: elementColor.withValues(alpha: 0.4)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    r.dayMaster,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: elementColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '日主：${r.dayMaster}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: elementColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              r.dayMasterElement,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: elementColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '五行属性',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  //  大运列表
  // ==========================================================

  Widget _buildDaYunSection(BaziResult r) {
    final cs = Theme.of(context).colorScheme;

    if (r.daYunList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            '大运',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: cs.primary,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: r.daYunList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final dy = r.daYunList[index];
              final isCurrent = dy.isCurrent;
              final elementColor = AppTheme.colors.forElement(dy.element);

              return Container(
                width: 88,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrent ? cs.primaryContainer : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: isCurrent
                      ? Border.all(color: cs.primary, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${dy.startAge}-${dy.endAge}岁',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.bold : null,
                        color: isCurrent ? cs.primary : cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${dy.heavenlyStem}${dy.earthlyBranch}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? cs.primary : elementColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: elementColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dy.element,
                        style: TextStyle(fontSize: 10, color: elementColor),
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '当前',
                          style: TextStyle(fontSize: 9, color: cs.onPrimary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================
  //  当前流年卡片
  // ==========================================================

  Widget _buildCurrentYearCard(BaziResult r) {
    final cs = Theme.of(context).colorScheme;
    final cy = r.currentYear;
    final elementColor = AppTheme.colors.forElement(cy.element);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${cy.heavenlyStem}${cy.earthlyBranch}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: elementColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cy.year}年 流年',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '干支：${cy.heavenlyStem}${cy.earthlyBranch} · 纳音：${cy.nayin} · 五行：${cy.element}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                cy.nayin,
                style: TextStyle(fontSize: 12, color: elementColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  //  LLM 解读区
  // ==========================================================

  Widget _buildReadingCard() {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  '命理解读',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: _reading,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    '解读生成失败：${snapshot.error}',
                    style: TextStyle(color: cs.error, fontSize: 13),
                  );
                }
                return MarkdownBody(
                  data: snapshot.data ?? '暂无解读',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
