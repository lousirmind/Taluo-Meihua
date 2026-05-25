import 'package:flutter/material.dart';

class DisclaimerText extends StatelessWidget {
  final String text;
  final double fontSize;

  const DisclaimerText({
    super.key,
    this.text = '',
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
