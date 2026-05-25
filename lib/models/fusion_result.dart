import 'meihua/meihua_result.dart';
import 'tarot/tarot_spread.dart';

class FusionResult {
  final MeihuaResult meihua;
  final TarotSpread tarot;
  final String llmInterpretation;
  final DateTime createTime;

  const FusionResult({
    required this.meihua,
    required this.tarot,
    this.llmInterpretation = '',
    required this.createTime,
  });
}
