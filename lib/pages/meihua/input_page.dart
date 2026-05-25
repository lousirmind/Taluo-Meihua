import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engines/meihua_engine.dart';
import '../../widgets/disclaimer_text.dart';

class MeihuaInputPage extends StatefulWidget {
  const MeihuaInputPage({super.key});

  @override
  State<MeihuaInputPage> createState() => _MeihuaInputPageState();
}

class _MeihuaInputPageState extends State<MeihuaInputPage> {
  final _n1Ctrl = TextEditingController();
  final _n2Ctrl = TextEditingController();
  final _n3Ctrl = TextEditingController();
  bool _isNumberMode = true;

  @override
  void dispose() {
    _n1Ctrl.dispose();
    _n2Ctrl.dispose();
    _n3Ctrl.dispose();
    super.dispose();
  }

  void _randomFill() {
    final nums = MeihuaEngine.randomNumbers(max: 9999);
    _n1Ctrl.text = nums[0].toString();
    _n2Ctrl.text = nums[1].toString();
    _n3Ctrl.text = nums[2].toString();
  }

  void _submit() {
    if (_isNumberMode) {
      final n1 = int.tryParse(_n1Ctrl.text);
      final n2 = int.tryParse(_n2Ctrl.text);
      final n3 = int.tryParse(_n3Ctrl.text);
      if (n1 == null || n2 == null || n3 == null || n1 <= 0 || n2 <= 0 || n3 <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入三个正整数')),
        );
        return;
      }
      final result = MeihuaEngine.calculate(n1, n2, n3);
      Navigator.pushNamed(context, '/meihua/result', arguments: result);
    } else {
      final result = MeihuaEngine.timeBasedCalculate(DateTime.now());
      Navigator.pushNamed(context, '/meihua/result', arguments: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('梅花易数')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('数字起卦'), icon: Icon(Icons.numbers)),
                ButtonSegment(value: false, label: Text('时间起卦'), icon: Icon(Icons.access_time)),
              ],
              selected: {_isNumberMode},
              onSelectionChanged: (v) => setState(() => _isNumberMode = v.first),
            ),
            const SizedBox(height: 24),
            if (_isNumberMode) _buildNumberMode(),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isNumberMode ? '开始起卦' : '以当前时间起卦'),
              ),
            ),
            const SizedBox(height: 16),
            const DisclaimerText(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('请输入三个正整数（1-9999）', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextField(
              controller: _n1Ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: '数字一', hintText: '上卦'),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
            Expanded(child: TextField(
              controller: _n2Ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: '数字二', hintText: '下卦'),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
            Expanded(child: TextField(
              controller: _n3Ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: '数字三', hintText: '动爻'),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _randomFill,
            icon: const Icon(Icons.shuffle),
            label: const Text('随机生成'),
          ),
        ),
      ],
    );
  }
}
