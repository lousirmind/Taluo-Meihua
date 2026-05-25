import 'package:flutter/material.dart';
import '../../engines/bazi_engine.dart';
import '../../models/bazi/bazi_result.dart';
import '../../widgets/disclaimer_text.dart';
import '../../data/constants/earthly_branches.dart';

class BaziInputPage extends StatefulWidget {
  const BaziInputPage({super.key});

  @override
  State<BaziInputPage> createState() => _BaziInputPageState();
}

class _BaziInputPageState extends State<BaziInputPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLunar = false;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  int _day = 1;
  int? _hour;
  String _gender = 'male';
  final _birthPlaceCtrl = TextEditingController();
  bool _isLoading = false;

  /// 12 时辰对应的代表小时数（0-23）
  /// 子(0)、丑(2)、寅(4)、卯(6)、辰(8)、巳(10)、
  /// 午(12)、未(14)、申(16)、酉(18)、戌(20)、亥(22)
  static const _shiChenHours = [
    0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22,
  ];

  @override
  void initState() {
    super.initState();
    _day = DateTime.now().day.clamp(1, _daysInMonth(_year, _month));
  }

  @override
  void dispose() {
    _birthPlaceCtrl.dispose();
    super.dispose();
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
      return isLeap ? 29 : 28;
    }
    return [4, 6, 9, 11].contains(month) ? 30 : 31;
  }

  List<int> _getDayOptions() {
    return List.generate(_daysInMonth(_year, _month), (i) => i + 1);
  }

  void _onMonthYearChanged() {
    final maxDay = _daysInMonth(_year, _month);
    if (_day > maxDay) {
      _day = maxDay;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final input = BaziInput(
        year: _year,
        month: _month,
        day: _day,
        hour: _hour ?? 12, // fallback 午时
        gender: _gender,
        isLunar: false,
        birthPlace: _birthPlaceCtrl.text.isEmpty ? null : _birthPlaceCtrl.text,
      );
      final result = await BaziEngine.calculate(input);
      if (!mounted) return;
      Navigator.pushNamed(context, '/bazi/result', arguments: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('排盘失败：$e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('八字命理')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 公历/农历切换 ──
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('公历')),
                  ButtonSegment(value: true, label: Text('农历')),
                ],
                selected: {_isLunar},
                onSelectionChanged: (v) {
                  if (v.first) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('农历支持将在后续版本中提供，请使用公历')),
                    );
                    return;
                  }
                  setState(() => _isLunar = false);
                },
              ),
              const SizedBox(height: 20),

              // ── 出生日期 ──
              Text('出生日期', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _year,
                      decoration: const InputDecoration(labelText: '年'),
                      isExpanded: true,
                      items: List.generate(201, (i) => 1900 + i).map((y) =>
                        DropdownMenuItem(value: y, child: Text('$y年')),
                      ).toList(),
                      onChanged: (v) => setState(() {
                        _year = v!;
                        _onMonthYearChanged();
                      }),
                      validator: (v) => v == null ? '请选择年份' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _month,
                      decoration: const InputDecoration(labelText: '月'),
                      isExpanded: true,
                      items: List.generate(12, (i) => i + 1).map((m) =>
                        DropdownMenuItem(value: m, child: Text('$m月')),
                      ).toList(),
                      onChanged: (v) => setState(() {
                        _month = v!;
                        _onMonthYearChanged();
                      }),
                      validator: (v) => v == null ? '请选择月份' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _day,
                      decoration: const InputDecoration(labelText: '日'),
                      isExpanded: true,
                      items: _getDayOptions().map((d) =>
                        DropdownMenuItem(value: d, child: Text('$d日')),
                      ).toList(),
                      onChanged: (v) => setState(() => _day = v!),
                      validator: (v) => v == null ? '请选择日期' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── 出生时辰 ──
              Text('出生时辰', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _hour,
                decoration: const InputDecoration(labelText: '时辰'),
                isExpanded: true,
                hint: const Text('请选择时辰'),
                items: List.generate(EarthlyBranch.list.length, (i) {
                  final branch = EarthlyBranch.list[i];
                  return DropdownMenuItem(
                    value: _shiChenHours[i],
                    child: Text('${branch.name}时（${branch.hours}）'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _hour = v),
                validator: (v) {
                  if (v == null) return '请选择时辰';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── 性别 ──
              Text('性别', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'male',
                    label: Text('男'),
                    icon: Icon(Icons.male),
                  ),
                  ButtonSegment(
                    value: 'female',
                    label: Text('女'),
                    icon: Icon(Icons.female),
                  ),
                ],
                selected: {_gender},
                onSelectionChanged: (v) => setState(() => _gender = v.first),
              ),
              const SizedBox(height: 16),

              // ── 出生地点（选填）──
              Text('出生地点（选填）', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _birthPlaceCtrl,
                decoration: const InputDecoration(
                  hintText: '如：北京',
                  helperText: '用于真太阳时校正，不填默认北京时间',
                ),
              ),
              const SizedBox(height: 24),

              // ── 开始排盘 ──
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isLoading ? '排盘中...' : '开始排盘'),
                ),
              ),
              const SizedBox(height: 16),
              const DisclaimerText(),
            ],
          ),
        ),
      ),
    );
  }
}
