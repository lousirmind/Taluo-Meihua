import 'package:flutter/material.dart';
import '../../engines/tarot_engine.dart';
import '../../widgets/disclaimer_text.dart';

class TarotPreparePage extends StatefulWidget {
  const TarotPreparePage({super.key});

  @override
  State<TarotPreparePage> createState() => _TarotPreparePageState();
}

class _TarotPreparePageState extends State<TarotPreparePage> {
  final _questionCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _startDraw() async {
    setState(() => _isLoading = true);
    try {
      final spread = await TarotEngine.drawRandom();
      if (!mounted) return;
      Navigator.pushNamed(context, '/tarot/flip', arguments: {
        'spread': spread,
        'question': _questionCtrl.text.trim(),
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('塔罗占卜')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Icon(Icons.auto_awesome, size: 64, color: cs.primary.withValues(alpha: 0.6)),
            const SizedBox(height: 24),
            Text(
              '请在心中默念你的问题，\n然后点击下方按钮开始抽牌。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.7), height: 1.5),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _questionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '心中所问（选填）',
                hintText: '输入你心中的问题，将开启解惑指引...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              width: 200,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _startDraw,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.style),
                label: Text(_isLoading ? '抽牌中...' : '开始抽牌'),
              ),
            ),
            const SizedBox(height: 24),
            const DisclaimerText(),
          ],
        ),
      ),
    );
  }
}
