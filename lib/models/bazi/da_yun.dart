class DaYun {
  final int startAge;
  final int endAge;
  final String heavenlyStem;
  final String earthlyBranch;
  final String element;
  final bool isCurrent;

  const DaYun({
    required this.startAge,
    required this.endAge,
    required this.heavenlyStem,
    required this.earthlyBranch,
    required this.element,
    this.isCurrent = false,
  });

  Map<String, dynamic> toJson() => {
    'startAge': startAge,
    'endAge': endAge,
    'heavenlyStem': heavenlyStem,
    'earthlyBranch': earthlyBranch,
    'element': element,
    'isCurrent': isCurrent,
  };
}

class LiuNian {
  final int year;
  final String heavenlyStem;
  final String earthlyBranch;
  final String element;
  final String nayin;

  const LiuNian({
    required this.year,
    required this.heavenlyStem,
    required this.earthlyBranch,
    required this.element,
    required this.nayin,
  });

  Map<String, dynamic> toJson() => {
    'year': year,
    'heavenlyStem': heavenlyStem,
    'earthlyBranch': earthlyBranch,
    'element': element,
    'nayin': nayin,
  };
}
