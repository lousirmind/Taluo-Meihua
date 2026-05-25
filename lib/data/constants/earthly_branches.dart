class EarthlyBranch {
  final String name;
  final String pinyin;
  final bool isYang;
  final String element;
  final String animal;
  final String hours;

  const EarthlyBranch({
    required this.name,
    required this.pinyin,
    required this.isYang,
    required this.element,
    required this.animal,
    required this.hours,
  });

  static const list = [
    EarthlyBranch(name: '子', pinyin: 'zi', isYang: true, element: '水', animal: '鼠', hours: '23:00-01:00'),
    EarthlyBranch(name: '丑', pinyin: 'chou', isYang: false, element: '土', animal: '牛', hours: '01:00-03:00'),
    EarthlyBranch(name: '寅', pinyin: 'yin', isYang: true, element: '木', animal: '虎', hours: '03:00-05:00'),
    EarthlyBranch(name: '卯', pinyin: 'mao', isYang: false, element: '木', animal: '兔', hours: '05:00-07:00'),
    EarthlyBranch(name: '辰', pinyin: 'chen', isYang: true, element: '土', animal: '龙', hours: '07:00-09:00'),
    EarthlyBranch(name: '巳', pinyin: 'si', isYang: false, element: '火', animal: '蛇', hours: '09:00-11:00'),
    EarthlyBranch(name: '午', pinyin: 'wu', isYang: true, element: '火', animal: '马', hours: '11:00-13:00'),
    EarthlyBranch(name: '未', pinyin: 'wei', isYang: false, element: '土', animal: '羊', hours: '13:00-15:00'),
    EarthlyBranch(name: '申', pinyin: 'shen', isYang: true, element: '金', animal: '猴', hours: '15:00-17:00'),
    EarthlyBranch(name: '酉', pinyin: 'you', isYang: false, element: '金', animal: '鸡', hours: '17:00-19:00'),
    EarthlyBranch(name: '戌', pinyin: 'xu', isYang: true, element: '土', animal: '狗', hours: '19:00-21:00'),
    EarthlyBranch(name: '亥', pinyin: 'hai', isYang: false, element: '水', animal: '猪', hours: '21:00-23:00'),
  ];

  static final _byName = {for (final b in list) b.name: b};
  static EarthlyBranch fromName(String name) => _byName[name]!;
  static String nameByIndex(int i) => list[i % 12].name;
  static int indexOf(String name) => list.indexWhere((b) => b.name == name);

  static const hiddenStems = {
    '子': ['癸'],
    '丑': ['己', '癸', '辛'],
    '寅': ['甲', '丙', '戊'],
    '卯': ['乙'],
    '辰': ['戊', '乙', '癸'],
    '巳': ['丙', '庚', '戊'],
    '午': ['丁', '己'],
    '未': ['己', '丁', '乙'],
    '申': ['庚', '壬', '戊'],
    '酉': ['辛'],
    '戌': ['戊', '辛', '丁'],
    '亥': ['壬', '甲'],
  };
}
