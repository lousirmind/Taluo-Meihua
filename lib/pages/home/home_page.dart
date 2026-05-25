import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _modules = [
    _ModuleEntry('融合占卜', '梅花定势·塔罗映象', Icons.auto_awesome, '/fusion'),
    _ModuleEntry('梅花易数', '数字起卦·卦象推演', Icons.hexagon_outlined, '/meihua'),
    _ModuleEntry('塔罗占卜', '三牌阵·逐张翻牌', Icons.style, '/tarot'),
    _ModuleEntry('八字命理', '四柱排盘·大运流年', Icons.calendar_month, '/bazi'),
    _ModuleEntry('历史记录', '占卜回溯·结果对比', Icons.history, '/history'),
    _ModuleEntry('设置', 'API配置·关于', Icons.settings, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('灵犀天机'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(cs, tt),
            const SizedBox(height: 24),
            Expanded(child: _buildGrid(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, TextTheme tt) {
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: cs.onPrimaryContainer, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('灵犀天机', style: tt.titleLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 2),
                  Text('梅花·塔罗·八字·融合', style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _modules.length,
      itemBuilder: (context, index) => _buildCard(context, _modules[index]),
    );
  }

  Widget _buildCard(BuildContext context, _ModuleEntry m) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, m.route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(m.icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(m.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(m.subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  const _ModuleEntry(this.title, this.subtitle, this.icon, this.route);
}
