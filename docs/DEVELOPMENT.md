# 灵犀天机 — 开发文档

## 一、项目概览

| 属性 | 值 |
|------|-----|
| 项目名称 | 灵犀天机（Tarot_meihua） |
| 产品形态 | Android App |
| 开发框架 | Flutter |
| 编程语言 | Dart |
| 算法参考 | 微信小程序版「灵犀天机」（BaZi-weapp） |
| 仓库路径 | `/Users/chenyidongting/Documents/5-Python/Taluo_meihua` |

## 二、核心设计决策

| 决策项 | 结论 |
|--------|------|
| 四大模块 | 融合占卜 / 梅花易数 / 塔罗占卜 / 八字命理 |
| 融合策略 | 梅花定势 → 级联映射塔罗（方案B） |
| LLM 解读 | DeepSeek API（代码完成后配置，接口先保留） |
| 离线策略 | 无网提示"需联网"，不降级 |
| 塔罗牌义 | 标准韦特塔罗 78 张结构化 JSON |
| 塔罗牌阵 | 3 张牌（过去/现在/未来），逐张翻牌动画 |
| 八字排盘 | 完整推导过程展示，地点选填 |
| 真太阳时 | 支持，出生城市选填，不填默认北京时间 |
| UI 风格 | Material Design 原生安卓风格 |
| 历史记录 | SQLite 本地保存，可回溯 |
| 数据来源 | `docs（参考）/reference-data.md` 中的命理数据 |

## 三、项目结构

```
Taluo_meihua/
├── docs/                                    # 📚 项目文档
│   ├── PRD.md                               #   产品需求文档
│   ├── DEVELOPMENT.md                       #   开发文档（本文件）
│   └── PROJECT.md                           #   项目进度文档
│
├── docs（参考）/                             # 📚 参考文档（微信小程序版）
│   ├── PRD.md                               #   小程序版 PRD
│   ├── DEVELOPMENT.md                       #   小程序版开发文档
│   ├── PROJECT.md                           #   小程序版项目进度
│   └── reference-data.md                    #   完整命理算法资料库
│
├── lib/                                     # 🚀 Flutter 主源码
│   ├── main.dart                            #   入口
│   ├── app/                                 #   App 配置
│   │   ├── app.dart                         #   MaterialApp 定义
│   │   └── theme.dart                       #   Material Design 主题
│   │
│   ├── models/                              # 🔧 数据模型
│   │   ├── meihua/                          #   梅花易数模型
│   │   │   ├── hexagram.dart                #     卦象
│   │   │   ├── trigram.dart                 #     八卦
│   │   │   └── meihua_result.dart           #     梅花结果
│   │   ├── tarot/                           #   塔罗模型
│   │   │   ├── tarot_card.dart              #     塔罗牌
│   │   │   └── tarot_spread.dart            #     牌阵
│   │   ├── bazi/                            #   八字模型
│   │   │   ├── pillar.dart                  #     四柱
│   │   │   ├── da_yun.dart                  #     大运
│   │   │   └── bazi_result.dart             #     八字结果
│   │   ├── fusion_result.dart               #   融合占卜结果
│   │   └── history_record.dart              #   历史记录
│   │
│   ├── data/                                # 📊 数据层
│   │   ├── constants/                       #   常量数据
│   │   │   ├── heavenly_stems.dart          #     十天干
│   │   │   ├── earthly_branches.dart        #     十二地支
│   │   │   ├── 64_hexagrams.dart            #     六十四卦
│   │   │   ├── five_elements.dart           #     五行
│   │   │   └── ten_gods.dart                #     十神
│   │   ├── tarot_cards.json                 #   塔罗牌义库（78张）
│   │   ├── database/                        #   数据库
│   │   │   ├── database_helper.dart         #     SQLite 连接
│   │   │   └── history_dao.dart             #     历史记录 DAO
│   │   └── secure_storage.dart              #   API Key 加密存储
│   │
│   ├── engines/                             # ⚙️ 算法引擎
│   │   ├── meihua_engine.dart               #   梅花起卦（本卦/互卦/变卦/体用）
│   │   ├── tarot_engine.dart                #   塔罗抽牌
│   │   ├── bazi_engine.dart                 #   八字排盘（四柱/十神/大运）
│   │   └── fusion_mapper.dart               #   梅花→塔罗映射逻辑
│   │
│   ├── services/                            # 🌐 服务层
│   │   ├── deepseek_service.dart            #   DeepSeek API 调用
│   │   └── llm_service.dart                 #   LLM 接口抽象
│   │
│   ├── pages/                               # 📄 页面
│   │   ├── home/                            #   主界面
│   │   ├── fusion/                          #   融合占卜
│   │   │   ├── input_page.dart              #     起数页
│   │   │   ├── hexagram_page.dart           #     卦象生成页
│   │   │   ├── flip_page.dart               #     翻牌页
│   │   │   └── reading_page.dart            #     解读页
│   │   ├── meihua/                          #   梅花易数
│   │   │   ├── input_page.dart              #     起卦页
│   │   │   └── result_page.dart             #     结果页
│   │   ├── tarot/                           #   塔罗占卜
│   │   │   ├── prepare_page.dart            #     准备页
│   │   │   ├── flip_page.dart               #     翻牌页
│   │   │   └── reading_page.dart            #     解读页
│   │   ├── bazi/                            #   八字命理
│   │   │   ├── input_page.dart              #     输入页
│   │   │   └── result_page.dart             #     结果页
│   │   ├── history/                         #   历史记录
│   │   │   ├── list_page.dart               #     列表页
│   │   │   └── detail_page.dart             #     详情页
│   │   └── settings/                        #   设置
│   │       └── settings_page.dart           #     设置页
│   │
│   └── widgets/                             # 🧩 通用组件
│       ├── card_flip.dart                   #   翻牌动画组件
│       ├── hexagram_view.dart               #   卦象可视化组件
│       ├── trigram_symbol.dart              #   八卦符号组件
│       ├── loading_overlay.dart             #   加载动画
│       └── disclaimer_text.dart             #   免责声明组件
│
├── assets/                                  # 🎨 资源
│   ├── images/                              #   图片
│   └── fonts/                               #   字体
│
├── test/                                    # 🧪 测试
│   ├── engines/                             #   算法引擎测试
│   │   ├── meihua_engine_test.dart
│   │   ├── tarot_engine_test.dart
│   │   ├── bazi_engine_test.dart
│   │   └── fusion_mapper_test.dart
│   ├── models/                              #   模型测试
│   └── widgets/                             #   组件测试
│
├── pubspec.yaml                             # Flutter 项目配置
├── analysis_options.yaml                    # Lint 配置
└── README.md                                # 项目说明
```

## 四、架构设计

### 4.1 分层架构

```
┌──────────────────────────────────────┐
│  UI 层 (Pages + Widgets)             │  ← Flutter Widget
├──────────────────────────────────────┤
│  服务层 (Services)                    │  ← DeepSeek API / LLM 抽象
├──────────────────────────────────────┤
│  业务层 (Engines)                     │  ← 算法引擎 + 映射逻辑
├──────────────────────────────────────┤
│  模型层 (Models)                      │  ← 数据模型 / DTO
├──────────────────────────────────────┤
│  数据层 (Data)                        │  ← 常量 / 数据库 / 存储
└──────────────────────────────────────┘
```

### 4.2 融合占卜数据流

```
用户输入（3个数字/随机生成）
        │
        ▼
  meihua_engine.dart  ──→  MeihuaResult
        │                    (本卦/互卦/变卦/动爻/体用)
        ▼
  fusion_mapper.dart  ──→  五行 → 塔罗牌组
                             体用生克 → 正逆位 & 大小阿卡纳
                             动爻位置 → 聚焦权重
        │
        ▼
  tarot_engine.dart   ──→  随机抽牌（受映射规则约束）
        │                    (3张：过去/现在/未来)
        ▼
  FusionResult
    (梅花结果 + 塔罗牌阵 + 结构化数据)
        │
        ▼
  deepseek_service.dart ──→  DeepSeek API → 自然语言解读
        │
        ▼
  reading_page.dart 展示
```

### 4.3 八字排盘数据流

```
BaziInput (出生日期 + 时辰 + 性别 + 地点[选填])
        │
        ▼
  bazi_engine.dart
    ├── 月柱推算（节气判定 + 五虎遁）
    ├── 时柱推算（真太阳时校正 + 五鼠遁）
    ├── 日柱推算（基准日期偏移公式）
    ├── 年柱推算（立春分界）
    ├── 十神判定（五行生克 × 阴阳同异）
    ├── 大运排列（顺逆判定 + 起运年龄）
    ├── 空亡、纳音
    └── 流年分析
        │
        ▼
  BaziResult → 结果页展示（推导过程可展开）
        │
        ▼
  deepseek_service.dart → LLM 解读
```

## 五、核心算法覆盖

### 5.1 梅花易数引擎

| 算法项 | 实现方式 | 正确性关键 |
|--------|---------|-----------|
| 起卦 | 数字 mod 8/6（余0=8坤/6爻） | 余0边界 |
| 时间起卦 | 年支序+月+日 / 年支序+月+日+时辰 | 农历转换 |
| 互卦 | 本卦2-3-4爻为下互，3-4-5爻为上互 | 爻位选取 |
| 变卦 | 动爻阴阳反转，其余不变 | 单爻变化 |
| 体用 | 1-3爻动→用为下卦，4-6爻动→用为上卦 | 位置判断 |
| 64卦数据 | 完整卦名/卦辞/爻辞 | 数据完整性 |

### 5.2 塔罗引擎

| 算法项 | 实现方式 |
|--------|---------|
| 随机抽牌 | 78张中不重复抽取3张 |
| 正逆位 | 50%概率随机（融合模式受体用生克影响） |
| 牌组筛选 | 融合模式：按映射规则筛选牌组 |
| 翻牌动画 | 3D Transform 翻转效果 |

### 5.3 八字排盘引擎

| 算法项 | 实现方式 | 参考来源 |
|--------|---------|---------|
| 年柱 | 立春分界，非正月初一 | reference-data.md §1.2.1 |
| 月柱 | 节气分界 + 五虎遁 | reference-data.md §1.2.2 |
| 日柱 | 1900-01-01（甲戌日）基准偏移 | reference-data.md §1.2.3 |
| 时柱 | 五鼠遁 + 真太阳时校正 | reference-data.md §1.2.4 |
| 十神 | 五行生克 × 阴阳同异查表 | reference-data.md §1.3 |
| 大运 | 阳男阴女顺排 / 阴男阳女逆排 | reference-data.md §1.5 |
| 纳音 | 六十甲子查表 | reference-data.md §1.1.4 |
| 空亡 | 日柱所在旬 → 两个空亡地支 | reference-data.md §1.2 |

### 5.4 融合映射逻辑

| 映射项 | 规则来源 |
|--------|---------|
| 八卦五行→塔罗牌组 | PRD §3.2 |
| 体用生克→牌组基调 | PRD §3.3 |
| 动爻位置→聚焦权重 | PRD §3.4 |

## 六、依赖库

| 库名 | 用途 | 备注 |
|------|------|------|
| sqflite / drift | SQLite 本地数据库 | 历史记录存储 |
| flutter_secure_storage | API Key 加密存储 | 安全存储 |
| http | DeepSeek API 请求 | HTTP 客户端 |
| provider / riverpod | 状态管理 | 全局状态管理 |
| json_annotation | JSON 序列化 | 数据模型 |
| intl | 日期/国际化 | 农历支持 |
| flutter_animate | 翻牌动画 | 翻牌效果 |

## 七、开发阶段

### Phase 1 — 数据层 + 算法引擎
- 搭建 Flutter 项目骨架
- 塔罗牌义库 JSON（78 张牌结构化数据）
- 64 卦数据 + 八卦五行字典
- 梅花易数算法引擎
- 八字排盘算法引擎
- SQLite 数据库搭建

### Phase 2 — 梅花 + 塔罗独立模块
- 梅花易数 UI + 算法串联
- 塔罗占卜 UI + 随机抽牌
- 翻牌动画组件

### Phase 3 — 融合占卜
- 梅花 → 塔罗映射逻辑
- 融合占卜 UI 串联
- DeepSeek API 集成

### Phase 4 — 八字命理
- 八字输入 UI
- 排盘结果展示 + 推导过程
- 大运时间线组件

### Phase 5 — 收尾
- 历史记录模块
- 设置页（API Key 配置）
- 免责声明 + 联网提示
- 整体联调测试
