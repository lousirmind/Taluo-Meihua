import 'package:flutter/material.dart';

class DisclaimerText extends StatelessWidget {
  final String text;
  final double fontSize;

  const DisclaimerText({
    super.key,
    this.text = '以上内容仅供娱乐参考，请理性看待。',
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
