class HexagramEntry {
  final String name;
  final String upper;
  final String lower;
  final String guaCi;
  final String translation;
  final int linesMask;

  const HexagramEntry(this.name, this.upper, this.lower, this.guaCi, this.translation, this.linesMask);
}

class HexagramsData {
  // sequence -> entry
  static const _list = [
    null, // index 0 unused
    HexagramEntry('乾为天', '乾', '乾', '元亨利贞', '大通顺，利于坚守正道', 63),
    HexagramEntry('坤为地', '坤', '坤', '元亨，利牝马之贞', '大通顺，利于柔顺坚守', 0),
    HexagramEntry('水雷屯', '坎', '震', '元亨利贞，勿用有攸往，利建侯', '万事初创艰难，宜积蓄力量', 34),
    HexagramEntry('山水蒙', '艮', '坎', '亨。匪我求童蒙，童蒙求我', '启蒙求学，虚心求教', 19),
    HexagramEntry('水天需', '坎', '乾', '有孚，光亨，贞吉，利涉大川', '等待时机，诚信待人', 58),
    HexagramEntry('天水讼', '乾', '坎', '有孚窒惕，中吉终凶', '口舌是非，宜和解', 23),
    HexagramEntry('地水师', '坤', '坎', '贞，丈人吉，无咎', '统御众人，需有德长者带领', 16),
    HexagramEntry('水地比', '坎', '坤', '吉。原筮元永贞，无咎', '亲和团结，择善而从', 2),
    HexagramEntry('风天小畜', '巽', '乾', '亨。密云不雨，自我西郊', '小有积蓄，力量不足', 59),
    HexagramEntry('天泽履', '乾', '兑', '履虎尾，不咥人，亨', '如履虎尾，言行谨慎', 55),
    HexagramEntry('地天泰', '坤', '乾', '小往大来，吉亨', '天地交泰，万事亨通', 56),
    HexagramEntry('天地否', '乾', '坤', '否之匪人，不利君子贞', '天地不交，闭塞不通', 7),
    HexagramEntry('天火同人', '乾', '离', '同人于野，亨。利涉大川', '与人合作，公平公正', 47),
    HexagramEntry('火天大有', '离', '乾', '元亨', '大丰收，富足丰盛', 61),
    HexagramEntry('地山谦', '坤', '艮', '亨，君子有终', '谦逊为美德，终究有成', 8),
    HexagramEntry('雷地豫', '震', '坤', '利建侯行师', '喜悦安乐，顺势而动', 4),
    HexagramEntry('泽雷随', '兑', '震', '元亨利贞，无咎', '跟随大势，随机应变', 38),
    HexagramEntry('山风蛊', '艮', '巽', '元亨，利涉大川', '积弊需整顿，拨乱反正', 25),
    HexagramEntry('地泽临', '坤', '兑', '元亨利贞。至于八月有凶', '居高临下，事态逼近', 48),
    HexagramEntry('风地观', '巽', '坤', '盥而不荐，有孚颙若', '观察等待，不宜轻举妄动', 3),
    HexagramEntry('火雷噬嗑', '离', '震', '亨，利用狱', '咬合决断，适合处理纠纷', 37),
    HexagramEntry('山火贲', '艮', '离', '亨，小利有攸往', '装饰美化，文饰之事', 41),
    HexagramEntry('山地剥', '艮', '坤', '不利有攸往', '剥落衰败，小人当道', 1),
    HexagramEntry('地雷复', '坤', '震', '亨。出入无疾，朋来无咎', '一阳复始，万象更新', 32),
    HexagramEntry('天雷无妄', '乾', '震', '元亨利贞。其匪正有眚', '不妄为，诚实无欺', 39),
    HexagramEntry('山天大畜', '艮', '乾', '利贞，不家食吉，利涉大川', '大积蓄，厚积薄发', 57),
    HexagramEntry('山雷颐', '艮', '震', '贞吉。观颐，自求口实', '养生颐养，注意健康', 33),
    HexagramEntry('泽风大过', '兑', '巽', '栋桡，利有攸往，亨', '过度非常，需非常手段', 30),
    HexagramEntry('坎为水', '坎', '坎', '习坎，有孚，维心亨', '坎险重重，保持诚信', 18),
    HexagramEntry('离为火', '离', '离', '利贞，亨。畜牝牛吉', '依附光明，柔顺中正', 45),
    HexagramEntry('泽山咸', '兑', '艮', '亨，利贞，取女吉', '感应沟通，心灵相通', 14),
    HexagramEntry('雷风恒', '震', '巽', '亨，无咎，利贞', '恒久不变，守常之道', 28),
    HexagramEntry('天山遁', '乾', '艮', '亨，小利贞', '退避隐遁，适时退让', 15),
    HexagramEntry('雷天大壮', '震', '乾', '利贞', '强盛壮大，以正行事', 60),
    HexagramEntry('火地晋', '离', '坤', '康侯用锡马蕃庶', '进取晋升，步步高升', 5),
    HexagramEntry('地火明夷', '坤', '离', '利艰贞', '光明受伤，韬光养晦', 40),
    HexagramEntry('风火家人', '巽', '离', '利女贞', '家庭和睦，各守其位', 43),
    HexagramEntry('火泽睽', '离', '兑', '小事吉', '乖离矛盾，求同存异', 53),
    HexagramEntry('水山蹇', '坎', '艮', '利西南，不利东北', '艰难跛行，宜止不宜进', 10),
    HexagramEntry('雷水解', '震', '坎', '利西南，无所往', '困难解除，豁然开朗', 20),
    HexagramEntry('山泽损', '艮', '兑', '有孚，元吉，无咎', '损下益上，减损才能得', 49),
    HexagramEntry('风雷益', '巽', '震', '利有攸往，利涉大川', '增益有利，时运大好', 35),
    HexagramEntry('泽天夬', '兑', '乾', '扬于王庭，孚号有厉', '决断决裂，当断则断', 62),
    HexagramEntry('天风姤', '乾', '巽', '女壮，勿用取女', '不期而遇，邂逅之象', 31),
    HexagramEntry('泽地萃', '兑', '坤', '亨。王假有庙，利见大人', '荟萃聚集，众人相聚', 6),
    HexagramEntry('地风升', '坤', '巽', '元亨，用见大人', '上升提升，适合向上发展', 24),
    HexagramEntry('泽水困', '兑', '坎', '亨，贞，大人吉', '困顿之象，坚守等待', 22),
    HexagramEntry('水风井', '坎', '巽', '改邑不改井，无丧无得', '井养不穷，滋养众人', 26),
    HexagramEntry('泽火革', '兑', '离', '己日乃孚，元亨利贞', '变革改革，破旧立新', 46),
    HexagramEntry('火风鼎', '离', '巽', '元吉，亨', '鼎新革故，建立新秩序', 29),
    HexagramEntry('震为雷', '震', '震', '亨。震来虩虩，笑言哑哑', '震动惊雷，处变不惊', 36),
    HexagramEntry('艮为山', '艮', '艮', '艮其背，不获其身', '停止静止，当止则止', 9),
    HexagramEntry('风山渐', '巽', '艮', '女归吉，利贞', '循序渐进，缓慢进展', 11),
    HexagramEntry('雷泽归妹', '震', '兑', '征凶，无攸利', '非正配，事情有不当之处', 52),
    HexagramEntry('雷火丰', '震', '离', '亨，王假之，勿忧', '丰盛盛大，如日中天', 44),
    HexagramEntry('火山旅', '离', '艮', '小亨，旅贞吉', '旅行在外，客居之象', 13),
    HexagramEntry('巽为风', '巽', '巽', '小亨，利有攸往', '巽顺谦逊，以柔顺处之', 27),
    HexagramEntry('兑为泽', '兑', '兑', '亨，利贞', '喜悦和悦，沟通交流', 54),
    HexagramEntry('风水涣', '巽', '坎', '亨。王假有庙，利涉大川', '涣散分离，重新聚合', 19),
    HexagramEntry('水泽节', '坎', '兑', '亨。苦节不可贞', '节制约束，适可而止', 50),
    HexagramEntry('风泽中孚', '巽', '兑', '豚鱼吉，利涉大川', '诚信守中，大事可成', 51),
    HexagramEntry('雷山小过', '震', '艮', '亨，利贞。可小事不可大事', '稍有过度，小事可行', 12),
    HexagramEntry('水火既济', '坎', '离', '亨小，利贞。初吉终乱', '事已成功，防松懈', 42),
    HexagramEntry('火水未济', '离', '坎', '亨。小狐汔济，濡其尾', '事未完成，仍需努力', 21),
  ];

  static const seqNames = [
    '', '乾', '坤', '屯', '蒙', '需', '讼', '师', '比',
    '小畜', '履', '泰', '否', '同人', '大有', '谦', '豫',
    '随', '蛊', '临', '观', '噬嗑', '贲', '剥', '复',
    '无妄', '大畜', '颐', '大过', '坎', '离', '咸', '恒',
    '遁', '大壮', '晋', '明夷', '家人', '睽', '蹇', '解',
    '损', '益', '夬', '姤', '萃', '升', '困', '井',
    '革', '鼎', '震', '艮', '渐', '归妹', '丰', '旅',
    '巽', '兑', '涣', '节', '中孚', '小过', '既济', '未济',
  ];

  static HexagramEntry getHexagram(int seq) => _list[seq]!;

  static Iterable<HexagramEntry> get all => _list.skip(1).cast<HexagramEntry>();

  static int? findSequence(String upper, String lower) {
    for (int i = 1; i < _list.length; i++) {
      final e = _list[i]!;
      if (e.upper == upper && e.lower == lower) return i;
    }
    return null;
  }
}
