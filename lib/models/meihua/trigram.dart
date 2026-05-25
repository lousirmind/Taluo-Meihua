class Trigram {
  final String name;
  final String element;
  final String symbol;
  final String nature;
  final int number;

  const Trigram({
    required this.name,
    required this.element,
    required this.symbol,
    required this.nature,
    required this.number,
  });

  static const trigrams = [
    Trigram(name: '乾', element: '金', symbol: '☰', nature: '天', number: 1),
    Trigram(name: '兑', element: '金', symbol: '☱', nature: '泽', number: 2),
    Trigram(name: '离', element: '火', symbol: '☲', nature: '火', number: 3),
    Trigram(name: '震', element: '木', symbol: '☳', nature: '雷', number: 4),
    Trigram(name: '巽', element: '木', symbol: '☴', nature: '风', number: 5),
    Trigram(name: '坎', element: '水', symbol: '☵', nature: '水', number: 6),
    Trigram(name: '艮', element: '土', symbol: '☶', nature: '山', number: 7),
    Trigram(name: '坤', element: '土', symbol: '☷', nature: '地', number: 8),
  ];

  static final _byNumber = {for (final t in trigrams) t.number: t};

  static Trigram fromNumber(int n) {
    final key = n == 0 ? 8 : n;
    return _byNumber[key]!;
  }

  static const elementCycleSheng = [4, 0, 1, 2, 3];
  static const elementCycleKe = [2, 3, 4, 0, 1];

  static List<String> elementNames = ['木', '火', '土', '金', '水'];

  static int elementIndex(String e) => elementNames.indexOf(e);
}
