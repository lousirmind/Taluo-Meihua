class Yao {
  final int position;
  final bool isYang;

  const Yao({required this.position, required this.isYang});

  String get display => isYang ? '▅▅▅▅▅' : '▅▅  ▅▅';
}

class Hexagram {
  final String name;
  final int sequence;
  final String upperName;
  final String lowerName;
  final List<Yao> lines;
  final String guaCi;
  final String guaCiTranslation;

  const Hexagram({
    required this.name,
    required this.sequence,
    required this.upperName,
    required this.lowerName,
    required this.lines,
    required this.guaCi,
    this.guaCiTranslation = '',
  });

  String get upperSymbol {
    return _symbolFor(upperName);
  }

  String get lowerSymbol {
    return _symbolFor(lowerName);
  }

  static String _symbolFor(String name) {
    const map = {'乾': '☰', '兑': '☱', '离': '☲', '震': '☳', '巽': '☴', '坎': '☵', '艮': '☶', '坤': '☷'};
    return map[name] ?? '';
  }
}
