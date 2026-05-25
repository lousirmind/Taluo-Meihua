import 'tarot_card.dart';

class TarotPosition {
  final String name;
  final TarotCard card;
  final bool isReversed;
  final int focusWeight;

  const TarotPosition({
    required this.name,
    required this.card,
    required this.isReversed,
    this.focusWeight = 1,
  });
}

class TarotSpread {
  final List<TarotPosition> positions;
  final String spreadType; // "past_present_future"

  const TarotSpread({
    required this.positions,
    this.spreadType = 'past_present_future',
  });

  TarotPosition? get past =>
      positions.isNotEmpty ? positions[0] : null;
  TarotPosition? get present =>
      positions.length > 1 ? positions[1] : null;
  TarotPosition? get future =>
      positions.length > 2 ? positions[2] : null;
}
