import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engines/meihua_engine.dart';
import '../../widgets/disclaimer_text.dart';

class FusionInputPage extends StatefulWidget {
  const FusionInputPage({super.key});

  @override
  State<FusionInputPage> createState() => _FusionInputPageState();
}

class _FusionInputPageState extends State<FusionInputPage> {
  final _n1Ctrl = TextEditingController();
  final _n2Ctrl = TextEditingController();
  final _n3Ctrl = TextEditingController();
  final _questionCtrl = TextEditingController();

  @override
  void dispose() {
    _n1Ctrl.dispose();
    _n2Ctrl.dispose();
    _n3Ctrl.dispose();
    _questionCtrl.dispose();
    super.dispose();
  }

  void _randomFill() {
    final nums = MeihuaEngine.randomNumbers(max: 9999);
    _n1Ctrl.text = nums[0].toString();
    _n2Ctrl.text = nums[1].toString();
    _n3Ctrl.text = nums[2].toString();
  }

  void _submit() {
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
    Navigator.pushNamed(context, '/fusion/hexagram', arguments: {
      'result': result,
      'question': _questionCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('融合占卜')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('输入数字起卦', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('请输入三个数字，系统将以梅花易数起卦，再映射塔罗牌阵进行融合解读。',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('三个数字（1-9999）', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(
                  controller: _n1Ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '数字一', hintText: '上卦'),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
                Expanded(child: TextField(
                  controller: _n2Ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '数字二', hintText: '下卦'),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
                Expanded(child: TextField(
                  controller: _n3Ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '数字三', hintText: '动爻'),
                )),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _randomFill,
                icon: const Icon(Icons.shuffle),
                label: const Text('随机生成'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '心中所问（选填）',
                hintText: '输入你心中所想的问题，帮助解读更聚焦...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('开始占卜'),
              ),
            ),
            const SizedBox(height: 12),
            const DisclaimerText(),
          ],
        ),
      ),
    );
  }
}
