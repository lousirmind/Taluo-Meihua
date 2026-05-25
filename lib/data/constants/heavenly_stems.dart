class HeavenlyStem {
  final String name;
  final String pinyin;
  final bool isYang;
  final String element;
  final String direction;

  const HeavenlyStem({
    required this.name,
    required this.pinyin,
    required this.isYang,
    required this.element,
    required this.direction,
  });

  static const list = [
    HeavenlyStem(name: '甲', pinyin: 'jia', isYang: true, element: '木', direction: '东'),
    HeavenlyStem(name: '乙', pinyin: 'yi', isYang: false, element: '木', direction: '东'),
    HeavenlyStem(name: '丙', pinyin: 'bing', isYang: true, element: '火', direction: '南'),
    HeavenlyStem(name: '丁', pinyin: 'ding', isYang: false, element: '火', direction: '南'),
    HeavenlyStem(name: '戊', pinyin: 'wu', isYang: true, element: '土', direction: '中'),
    HeavenlyStem(name: '己', pinyin: 'ji', isYang: false, element: '土', direction: '中'),
    HeavenlyStem(name: '庚', pinyin: 'geng', isYang: true, element: '金', direction: '西'),
    HeavenlyStem(name: '辛', pinyin: 'xin', isYang: false, element: '金', direction: '西'),
    HeavenlyStem(name: '壬', pinyin: 'ren', isYang: true, element: '水', direction: '北'),
    HeavenlyStem(name: '癸', pinyin: 'gui', isYang: false, element: '水', direction: '北'),
  ];

  static final _byName = {for (final s in list) s.name: s};
  static HeavenlyStem fromName(String name) => _byName[name]!;
  static String nameByIndex(int i) => list[i % 10].name;
  static int indexOf(String name) => list.indexWhere((s) => s.name == name);
}
