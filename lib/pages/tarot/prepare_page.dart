import 'package:flutter/material.dart';
import '../../engines/tarot_engine.dart';
import '../../widgets/disclaimer_text.dart';

class TarotPreparePage extends StatefulWidget {
  const TarotPreparePage({super.key});

  @override
  State<TarotPreparePage> createState() => _TarotPreparePageState();
}

class _TarotPreparePageState extends State<TarotPreparePage> {
  bool _isLoading = false;

  Future<void> _startDraw() async {
    setState(() => _isLoading = true);
    try {
      final spread = await TarotEngine.drawRandom();
      if (!mounted) return;
      Navigator.pushNamed(context, '/tarot/flip', arguments: spread);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('塔罗占卜')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 64, color: cs.primary.withValues(alpha: 0.6)),
              const SizedBox(height: 24),
              Text(
                '请在心中默念你的问题，\n然后点击下方按钮开始抽牌。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                height: 56,
                width: 200,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _startDraw,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.style),
                  label: Text(
                    _isLoading ? '抽牌中...' : '开始抽牌',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const DisclaimerText(),
            ],
          ),
        ),
      ),
    );
  }
}
