class Pillar {
  final String heavenlyStem;
  final String earthlyBranch;
  final List<String> hiddenStems;
  final List<String> tenGods;
  final List<String> fiveElements;
  final String nayin;

  const Pillar({
    required this.heavenlyStem,
    required this.earthlyBranch,
    this.hiddenStems = const [],
    this.tenGods = const [],
    this.fiveElements = const [],
    this.nayin = '',
  });

  Map<String, dynamic> toJson() => {
    'heavenlyStem': heavenlyStem,
    'earthlyBranch': earthlyBranch,
    'hiddenStems': hiddenStems,
    'tenGods': tenGods,
    'fiveElements': fiveElements,
    'nayin': nayin,
  };
}
