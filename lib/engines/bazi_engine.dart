import '../data/constants/earthly_branches.dart';
import '../data/constants/ten_gods.dart';
import '../models/bazi/pillar.dart';
import '../models/bazi/da_yun.dart';
import '../models/bazi/bazi_result.dart';

/// 八字排盘算法引擎
///
/// 实现了完整的八字四柱推算，包括：
///   - 年柱（立春分界）
///   - 月柱（节气分界 + 五虎遁）
///   - 日柱（戊午日基准 + 晚子时处理）
///   - 时柱（五鼠遁 + 真太阳时校正）
///   - 十神判定、藏干、纳音、空亡、大运、流年
class BaziEngine {
  // ==================== 常量 ====================

  static const List<String> _tianGan = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸',
  ];

  static const List<String> _diZhi = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥',
  ];

  /// 节气边界（month*100+day），立春→惊蛰→...→大雪
  static const List<int> _solarTermBounds = [
    204, 306, 405, 506, 606, 707, 808, 908, 1008, 1108, 1207,
  ];

  /// 五虎遁基干索引：年干 % 5 → 寅月天干索引
  /// 甲己→丙(2), 乙庚→戊(4), 丙辛→庚(6), 丁壬→壬(8), 戊癸→甲(0)
  static const List<int> _wuHuDunBase = [2, 4, 6, 8, 0];

  /// 五鼠遁基干索引：日干 % 5 → 子时天干索引
  /// 甲己→甲(0), 乙庚→丙(2), 丙辛→戊(4), 丁壬→庚(6), 戊癸→壬(8)
  static const List<int> _wuShuDunBase = [0, 2, 4, 6, 8];

  /// 六十甲子纳音（两柱一组，共 30 组）
  static const List<String> _nayinList = [
    '海中金', '炉中火', '大林木', '路旁土', '剑锋金', '山头火',
    '涧下水', '城头土', '白蜡金', '杨柳木', '泉中水', '屋上土',
    '霹雳火', '松柏木', '长流水', '沙中金', '山下火', '平地木',
    '壁上土', '金箔金', '覆灯火', '天河水', '大驿土', '钗钏金',
    '桑柘木', '大溪水', '沙中土', '天上火', '石榴木', '大海水',
  ];

  /// 天干对应五行
  static const List<String> _stemElements = [
    '木', '木', '火', '火', '土', '土', '金', '金', '水', '水',
  ];

  /// 中国主要城市经度表（用于真太阳时校正）
  static const Map<String, double> cityLongitudes = {
    '北京': 116.4, '上海': 121.5, '广州': 113.3, '深圳': 114.1,
    '成都': 104.1, '重庆': 106.5, '武汉': 114.3, '西安': 108.9,
    '南京': 118.8, '杭州': 120.2, '长沙': 113.0, '昆明': 102.7,
    '哈尔滨': 126.6, '乌鲁木齐': 87.6, '拉萨': 91.1, '郑州': 113.7,
    '济南': 117.0, '天津': 117.2, '沈阳': 123.4, '福州': 119.3,
    '合肥': 117.3, '南昌': 115.9, '石家庄': 114.5, '太原': 112.5,
    '南宁': 108.3, '海口': 110.3, '贵阳': 106.7, '兰州': 103.7,
    '银川': 106.3, '西宁': 101.8, '呼和浩特': 111.7,
    '台北': 121.5, '香港': 114.2,
  };

  // ==================== 主入口 ====================

  /// 计算完整的八字排盘结果。
  ///
  /// [input] 包含出生年月日时、性别、出生地等信息。
  /// 日期使用公历（Gregorian），如为农历需在传入前转换。
  static Future<BaziResult> calculate(BaziInput input) async {
    final year = input.year;
    final month = input.month;
    final day = input.day;
    final rawHour = input.hour;
    const minute = 0;
    final gender = input.gender;

    // ---- 解析出生地经度 ----
    double? longitude;
    if (input.longitude != null) {
      longitude = input.longitude;
    } else if (input.birthPlace != null) {
      longitude = cityLongitudes[input.birthPlace];
    }

    // =============================================
    // 1. 真太阳时校正
    // =============================================
    final solarHour = _getSolarHour(rawHour, minute, longitude);

    // =============================================
    // 2. 年柱（以立春为界）
    // =============================================
    final isBeforeLiChun = month < 2 || (month == 2 && day < 4);
    final yearForPillar = isBeforeLiChun ? year - 1 : year;
    final yearGanIndex = (yearForPillar - 4) % 10;
    final yearZhiIndex = (yearForPillar - 4) % 12;

    // =============================================
    // 3. 月柱（节气分界 + 五虎遁）
    // =============================================
    final termIndex = _getSolarTermIndex(year, month, day);
    final monthZhiIndex = (termIndex + 2) % 12; // 寅=2
    final monthGanIndex = _calcMonthGanIndex(yearGanIndex, monthZhiIndex);

    // =============================================
    // 4. 日柱
    //    晚子时（23:00-23:59）日柱按次日计算
    // =============================================
    final isLateZiShi = solarHour >= 23;
    final effectiveDate = DateTime.utc(year, month, day + (isLateZiShi ? 1 : 0));
    final (dayGanIndex, dayZhiIndex) = _calcDayPillar(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
    );

    // =============================================
    // 5. 时柱（五鼠遁）
    // =============================================
    final hourZhiIndex = _getHourBranchIndex(solarHour);
    final hourGanIndex = _calcHourGanIndex(dayGanIndex, hourZhiIndex);

    // =============================================
    // 6. 日主
    // =============================================
    final dayMaster = _tianGan[dayGanIndex];
    final dayMasterElement = _stemElements[dayGanIndex];

    // =============================================
    // 7. 构建四柱
    // =============================================
    final yearPillar = _buildPillar(yearGanIndex, yearZhiIndex, dayMaster);
    final monthPillar = _buildPillar(monthGanIndex, monthZhiIndex, dayMaster);
    final dayPillar = _buildPillar(dayGanIndex, dayZhiIndex, dayMaster);
    final hourPillar = _buildPillar(hourGanIndex, hourZhiIndex, dayMaster);

    // =============================================
    // 8. 空亡
    // =============================================
    final kongWang = _getKongWang(dayGanIndex, dayZhiIndex);

    // =============================================
    // 9. 大运
    // =============================================
    final isMale = gender == 'male';
    final isYearYang = yearGanIndex % 2 == 0;
    final isShunPai = (isMale && isYearYang) || (!isMale && !isYearYang);
    final startAge = _calcStartAge(year, month, day, isShunPai);
    final daYunList = _calcDaYun(
      _tianGan[monthGanIndex],
      _diZhi[monthZhiIndex],
      yearGanIndex,
      startAge,
      year,
      gender,
    );

    // =============================================
    // 10. 流年
    // =============================================
    final now = DateTime.now();
    final currentYearPillar = _buildLiuNian(now.year);

    return BaziResult(
      yearPillar: yearPillar,
      monthPillar: monthPillar,
      dayPillar: dayPillar,
      hourPillar: hourPillar,
      dayMaster: dayMaster,
      dayMasterElement: dayMasterElement,
      kongWang: kongWang,
      startAge: startAge,
      daYunList: daYunList,
      currentYear: currentYearPillar,
    );
  }

  // ==================== 构建辅助 ====================

  /// 构建单柱 [Pillar]，包含天干、地支、藏干、十神、五行、纳音。
  static Pillar _buildPillar(int ganIdx, int zhiIdx, String dayMaster) {
    final stem = _tianGan[ganIdx];
    final branch = _diZhi[zhiIdx];
    final hidden = List<String>.from(EarthlyBranch.hiddenStems[branch] ?? []);

    // 十神列表：[天干十神, 藏干1十神, 藏干2十神, ...]
    final tenGods = <String>[TenGods.getTenGod(dayMaster, stem)];
    // 五行列表：[天干五行, 藏干1五行, 藏干2五行, ...]
    final elements = <String>[_stemElements[ganIdx]];

    for (final hStem in hidden) {
      tenGods.add(TenGods.getTenGod(dayMaster, hStem));
      elements.add(TenGods.heavenlyStemElements[hStem] ?? '');
    }

    return Pillar(
      heavenlyStem: stem,
      earthlyBranch: branch,
      hiddenStems: hidden,
      tenGods: tenGods,
      fiveElements: elements,
      nayin: _getNayin(ganIdx, zhiIdx),
    );
  }

  /// 构建流年 [LiuNian]。
  static LiuNian _buildLiuNian(int year) {
    final ganIdx = (year - 4) % 10;
    final zhiIdx = (year - 4) % 12;
    return LiuNian(
      year: year,
      heavenlyStem: _tianGan[ganIdx],
      earthlyBranch: _diZhi[zhiIdx],
      element: _stemElements[ganIdx],
      nayin: _getNayin(ganIdx, zhiIdx),
    );
  }

  // ==================== 排盘算法 ====================

  /// 获取真太阳时校正后的小时（0-23）。
  ///
  /// [longitude] 为出生地经度，中国使用东八区（E120°）标准时间，
  /// 每度经度差 4 分钟。经度为空时直接返回原小时。
  static int _getSolarHour(int hour, int minute, double? longitude) {
    if (longitude == null) return hour;
    final offsetMinutes = ((longitude - 120) * 4).round();
    final totalMinutes = hour * 60 + minute + offsetMinutes;
    return ((totalMinutes % 1440) + 1440) % 1440 ~/ 60;
  }

  /// 获取节气索引（0=立春, 1=惊蛰, ..., 11=小寒）。
  ///
  /// 根据公历月日判断出生日期落在哪个节气段内，
  /// 用于确定月柱地支。
  static int _getSolarTermIndex(int year, int month, int day) {
    final dateVal = month * 100 + day;

    // 1 月：小寒（1/6）为界
    if (month == 1) {
      return day < 6 ? 10 : 11;
    }

    // 立春（2/4）前 → 丑月（小寒→立春）
    if (dateVal < 204) return 11;

    // 依次比较节气边界
    for (int i = 0; i < _solarTermBounds.length; i++) {
      if (dateVal < _solarTermBounds[i]) return i;
    }

    // 大雪（12/7）后 → 子月（大雪→小寒）
    return 10;
  }

  /// 计算日柱干支索引。
  ///
  /// 基准日：2000-01-01 = 戊午日（天干索引 4，地支索引 6）。
  /// 使用 UTC 避免夏令时影响天数差计算。
  static (int, int) _calcDayPillar(int year, int month, int day) {
    final target = DateTime.utc(year, month, day);
    final base = DateTime.utc(2000, 1, 1);
    final diff = target.difference(base).inDays;
    final ganIndex = ((4 + diff) % 10 + 10) % 10;
    final zhiIndex = ((6 + diff) % 12 + 12) % 12;
    return (ganIndex, zhiIndex);
  }

  /// 获取时辰地支索引（0=子, 1=丑, ..., 11=亥）。
  ///
  /// 子时：23:00-00:59，丑时：01:00-02:59，依此类推。
  static int _getHourBranchIndex(int hour) {
    if (hour == 23 || hour == 0) return 0; // 子时
    return ((hour + 1) ~/ 2) % 12;
  }

  /// 五虎遁计算月干索引。
  ///
  /// [yearGanIndex] 年柱天干索引，[monthZhiIndex] 月柱地支索引。
  static int _calcMonthGanIndex(int yearGanIndex, int monthZhiIndex) {
    final baseIdx = _wuHuDunBase[yearGanIndex % 5];
    final offset = (monthZhiIndex - 2 + 12) % 12; // 寅=2 为起点
    return (baseIdx + offset) % 10;
  }

  /// 五鼠遁计算时干索引。
  ///
  /// [dayGanIndex] 日柱天干索引，[hourZhiIndex] 时柱地支索引。
  static int _calcHourGanIndex(int dayGanIndex, int hourZhiIndex) {
    final baseIdx = _wuShuDunBase[dayGanIndex % 5];
    return (baseIdx + hourZhiIndex) % 10;
  }

  /// 查六十甲子纳音。
  static String _getNayin(int ganIndex, int zhiIndex) {
    return _nayinList[_getJiaziIndex(ganIndex, zhiIndex) ~/ 2];
  }

  /// 计算六十甲子序号（0-59）。
  ///
  /// 天干和地支在六十甲子中各推进一位，此函数从
  /// 给定干支组合反向计算出它在六十甲子中的序号。
  static int _getJiaziIndex(int ganIndex, int zhiIndex) {
    for (int k = 0; k < 6; k++) {
      final idx = ganIndex + k * 10;
      if (idx % 12 == zhiIndex) return idx;
    }
    return 0;
  }

  /// 查日柱所属旬的两个空亡地支。
  ///
  /// 六甲旬空亡规则：
  ///   甲子旬 → 戌亥, 甲戌旬 → 申酉, 甲申旬 → 午未,
  ///   甲午旬 → 辰巳, 甲辰旬 → 寅卯, 甲寅旬 → 子丑
  static List<String> _getKongWang(int dayGanIndex, int dayZhiIndex) {
    // 旬首地支 = (日支 - 日干) mod 12（结果必为 0,2,4,6,8,10 之一）
    final xunBranch = ((dayZhiIndex - dayGanIndex) % 12 + 12) % 12;
    // 空亡 = 旬首后推 10、11 位（即旬末之后第一个和第二地支）
    return [
      _diZhi[(xunBranch + 10) % 12],
      _diZhi[(xunBranch + 11) % 12],
    ];
  }

  // ==================== 大运与起运年龄 ====================

  /// 生成目标年前后各一年的全部 12 节气日期（用于起运计算）。
  ///
  /// 三个年份共 36 个日期，覆盖所有边界情况。
  static List<DateTime> _generateTermDates(int year) {
    final terms = <DateTime>[];
    for (int y = year - 1; y <= year + 1; y++) {
      terms.add(DateTime.utc(y, 2, 4));   // 立春
      terms.add(DateTime.utc(y, 3, 6));   // 惊蛰
      terms.add(DateTime.utc(y, 4, 5));   // 清明
      terms.add(DateTime.utc(y, 5, 6));   // 立夏
      terms.add(DateTime.utc(y, 6, 6));   // 芒种
      terms.add(DateTime.utc(y, 7, 7));   // 小暑
      terms.add(DateTime.utc(y, 8, 8));   // 立秋
      terms.add(DateTime.utc(y, 9, 8));   // 白露
      terms.add(DateTime.utc(y, 10, 8));  // 寒露
      terms.add(DateTime.utc(y, 11, 8));  // 立冬
      terms.add(DateTime.utc(y, 12, 7));  // 大雪
      terms.add(DateTime.utc(y + 1, 1, 6)); // 小寒（跨年）
    }
    return terms;
  }

  /// 计算起运年龄。
  ///
  /// 阳男阴女顺排（找生日后第一个节气），阴男阳女逆排（找生日前最后一个节气）。
  /// 公历 3 天 = 1 年，结果以年为单位（double）。
  static double _calcStartAge(int year, int month, int day, bool isShunPai) {
    final birthday = DateTime.utc(year, month, day);
    final allTerms = _generateTermDates(year);
    allTerms.sort((a, b) => a.compareTo(b));

    if (isShunPai) {
      // 顺排：生日之后的第一个节气
      for (final t in allTerms) {
        if (t.isAfter(birthday)) {
          return t.difference(birthday).inDays / 3.0;
        }
      }
    } else {
      // 逆排：生日之前（含当日）的最后一个节气
      DateTime? prevTerm;
      for (final t in allTerms) {
        if (!t.isAfter(birthday)) {
          prevTerm = t;
        } else {
          break;
        }
      }
      if (prevTerm != null) {
        return birthday.difference(prevTerm).inDays / 3.0;
      }
    }
    return 0;
  }

  /// 计算大运列表（10 步，每步 10 年）。
  ///
  /// 从月柱开始顺推（阳男阴女）或逆推（阴男阳女），
  /// 每一步生成一柱干支及其五行和起止年龄。
  static List<DaYun> _calcDaYun(
    String monthGan,
    String monthZhi,
    int yearGanIndex,
    double startAge,
    int birthYear,
    String gender,
  ) {
    const int stepCount = 10;
    final monthGanIdx = _tianGan.indexOf(monthGan);
    final monthZhiIdx = _diZhi.indexOf(monthZhi);
    final isMale = gender == 'male';
    final isYearYang = yearGanIndex % 2 == 0;
    final isShunPai = (isMale && isYearYang) || (!isMale && !isYearYang);

    final currentYear = DateTime.now().year;
    final currentAge = currentYear - birthYear;
    final List<DaYun> result = [];

    for (int i = 0; i < stepCount; i++) {
      final step = i + 1; // 第一步从月柱的下/上一步开始
      int ganIdx, zhiIdx;
      if (isShunPai) {
        ganIdx = (monthGanIdx + step) % 10;
        zhiIdx = (monthZhiIdx + step) % 12;
      } else {
        ganIdx = (monthGanIdx - step + 10) % 10;
        zhiIdx = (monthZhiIdx - step + 12) % 12;
      }

      final yStart = startAge.floor() + i * 10;
      final yEnd = yStart + 9;
      final stem = _tianGan[ganIdx];
      final branch = _diZhi[zhiIdx];

      result.add(DaYun(
        startAge: yStart,
        endAge: yEnd,
        heavenlyStem: stem,
        earthlyBranch: branch,
        element: _stemElements[ganIdx],
        isCurrent: currentAge >= yStart && currentAge <= yEnd,
      ));
    }

    return result;
  }
}
