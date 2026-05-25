class TarotCard {
  final int id;
  final String name;
  final String nameEn;
  final String suit; // "major" | "wands" | "cups" | "swords" | "pentacles"
  final int rank; // 1-14 (1=Ace, 11=Page, 12=Knight, 13=Queen, 14=King)
  final String meaningUp;
  final String meaningDown;
  final String keyword;

  const TarotCard({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.suit,
    required this.rank,
    required this.meaningUp,
    required this.meaningDown,
    required this.keyword,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      suit: json['suit'] as String,
      rank: json['rank'] as int,
      meaningUp: json['meaningUp'] as String,
      meaningDown: json['meaningDown'] as String,
      keyword: json['keyword'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameEn': nameEn,
    'suit': suit,
    'rank': rank,
    'meaningUp': meaningUp,
    'meaningDown': meaningDown,
    'keyword': keyword,
  };
}
