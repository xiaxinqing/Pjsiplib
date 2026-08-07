# VPhone 多语言维护教程

VPhone 使用 Flutter 官方的 `gen-l10n` 方案管理多语言。翻译内容保存在
ARB 文件中，执行生成命令后，Flutter 会生成类型安全的 Dart API。

当前支持：

- 简体中文
- 繁體中文（香港）
- English
- 跟随系统（系统语言不受支持时回退到英文）

## 1. 文件说明

需要手动维护的文件：

| 文件 | 用途 |
| --- | --- |
| `lib/l10n/app_zh.arb` | 简体中文基础资源，也是字段和参数模板 |
| `lib/l10n/app_zh_Hant.arb` | 香港繁体中文翻译 |
| `lib/l10n/app_en.arb` | 英文翻译 |
| `l10n.yaml` | Flutter 国际化生成配置，一般不需要修改 |
| `lib/src/localization/locale_controller.dart` | 语言选择、持久化和系统语言匹配规则 |

以下文件由 Flutter 自动生成，**不要手动修改**：

```text
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_zh.dart
```

重新执行 `flutter gen-l10n` 时，自动生成文件会被覆盖。

项目使用基础 `zh` 资源表示简体中文，使用 `zh_Hant` 表示香港繁体中文。这是
Flutter `gen-l10n` 支持繁体回退时要求的三文件结构。项目不按地区继续拆分
`zh_CN`、`zh_TW`、`zh_HK` 等资源；系统地区只用于判断应该选择简体还是繁体。

繁体文案统一采用香港书面表达；由于项目只维护一份繁体资源，其他繁体中文
系统也会使用这套香港繁体文案。

## 2. 修改已有文案

例如把“设置”改成“系统设置”。

先在三个 ARB 文件中搜索同一个字段名：

```json
"settings": "设置"
```

分别修改对应翻译：

`app_zh.arb`：

```json
"settings": "系统设置"
```

`app_zh_Hant.arb`：

```json
"settings": "系統設定"
```

`app_en.arb`：

```json
"settings": "System settings"
```

修改完成后执行：

```bash
flutter gen-l10n
```

如果应用正在运行，生成后执行热重载；新增了字段时，必要时执行热重启。

## 3. 新增普通文案

例如新增“自动接听”。字段名使用有业务含义的英文小驼峰命名：

```text
automaticAnswer
```

不要使用 `text1`、`label2` 或中文拼音等难以维护的名称。

先在模板 `app_zh.arb` 中添加简体中文字段和可选说明：

```json
"automaticAnswer": "自动接听",
"@automaticAnswer": {
  "description": "自动接听设置名称"
}
```

在 `app_zh_Hant.arb` 中添加：

```json
"automaticAnswer": "自動接聽"
```

在 `app_en.arb` 中添加：

```json
"automaticAnswer": "Automatic answer"
```

生成代码：

```bash
flutter gen-l10n
```

在 Widget 中使用：

```dart
import 'package:veserve_vphone/src/localization/build_context_l10n.dart';

Text(context.l10n.automaticAnswer)
```

## 4. 新增带参数的文案

不要在 UI 中手动拼接句子，例如：

```dart
// 不推荐：英文和其他语言的语序可能不同。
Text('已连接 $count 条线路');
```

应该把完整句子交给多语言资源管理。

参数结构必须定义在模板 `app_zh.arb` 中：

```json
"connectedLineCount": "已连接 {count} 条线路",
"@connectedLineCount": {
  "description": "当前已连接线路数量",
  "placeholders": {
    "count": {
      "type": "int"
    }
  }
}
```

`app_zh_Hant.arb`：

```json
"connectedLineCount": "已連線 {count} 條線路"
```

`app_en.arb`：

```json
"connectedLineCount": "{count} lines connected"
```

生成后调用：

```dart
Text(context.l10n.connectedLineCount(count))
```

常用参数类型包括 `String`、`int`、`double` 和 `DateTime`。参数名称在所有
语言文件中必须保持一致。

## 5. 单复数文案

英文等语言需要区分单复数时，使用 ICU plural 语法，不要在 Dart 中分别判断。

模板 `app_zh.arb`：

```json
"missedCallCount": "{count, plural, =0{没有未接来电} other{# 个未接来电}}",
"@missedCallCount": {
  "description": "未接来电数量",
  "placeholders": {
    "count": {
      "type": "int"
    }
  }
}
```

`app_en.arb`：

```json
"missedCallCount": "{count, plural, =0{No missed calls} =1{1 missed call} other{# missed calls}}"
```

调用方式仍然是：

```dart
Text(context.l10n.missedCallCount(count))
```

## 6. 在页面中替换硬编码文字

原代码：

```dart
const Text('通话记录')
```

修改后：

```dart
Text(context.l10n.navCallHistory)
```

因为国际化文本依赖 `BuildContext`，通常不能再使用 `const Text(...)`。

查找尚未国际化的中文文案可以使用：

```bash
rg -n "[一-龥]" lib --glob '*.dart'
```

日志、开发注释、协议状态和数据库原始值不一定需要国际化。优先处理用户能在
界面上看到的标题、按钮、提示、空状态、弹窗和错误说明。

## 7. 标准生成与检查流程

每次修改 ARB 后，建议依次执行：

```bash
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
```

仅修改已有翻译时，主要变化通常只在 ARB 和生成文件中；新增字段后，生成的
`AppLocalizations` 会出现新的 getter 或方法。

## 8. 常见问题

### 新字段在 Dart 中找不到

确认已经执行：

```bash
flutter gen-l10n
```

如果 IDE 仍然报错，执行一次热重启或重新打开项目。

### 生成命令提示 ARB 格式错误

ARB 使用 JSON 格式，重点检查：

- 上一项末尾是否缺少逗号。
- 字符串中的双引号是否转义为 `\"`。
- 是否出现重复字段名。
- `{count}` 等参数名是否在各语言中保持一致。
- `@字段名` 是否与对应字段完全一致。

### 某个语言显示了模板文字

检查该语言 ARB 是否缺少对应字段。新增字段时，应同时更新全部三个 ARB 文件。

### 系统语言不受支持时显示什么

当前规则位于 `locale_controller.dart`：

- 简体中文书写体系，以及未明确标记为繁体的中文系统，使用基础 `zh` 资源。
- `zh-Hant`、台湾、香港、澳门地区使用 `zh_Hant`。
- 英文系统使用英文。
- 其他不支持的语言回退到英文。

旧版本保存的 `zh_Hans`、`zh_CN` 和 `zh_TW` 偏好仍可读取，并分别迁移为
简体和繁体选择。

### 是否可以直接修改生成的 Dart 文件

不可以。生成文件的修改会在下一次运行 `flutter gen-l10n` 时丢失，所有文案都应
从 ARB 文件维护。

## 9. 新增一种语言

例如以后增加日语，需要完成以下步骤：

1. 新建 `lib/l10n/app_ja.arb`。
2. 设置 `"@@locale": "ja"`，并补齐模板中的全部字段。
3. 执行 `flutter gen-l10n`。
4. 在 `AppLocalePreference` 中增加日语选项和存储值。
5. 在 `resolveAppLocale` 中增加日语系统匹配规则。
6. 在通用设置的语言选择菜单中增加日语。
7. 补充语言解析测试并运行完整检查。

不要只新增 ARB 文件而遗漏语言选择和持久化逻辑，否则生成代码虽然支持该语言，
用户仍可能无法在设置中选择。

## 10. 提交前检查清单

- [ ] 三个 ARB 文件使用相同字段名。
- [ ] 简体、繁体和英文翻译均已填写。
- [ ] 参数名称和类型在各语言中一致。
- [ ] 页面不再使用对应的硬编码文字。
- [ ] 已执行 `flutter gen-l10n`。
- [ ] `flutter analyze` 通过。
- [ ] 相关测试通过。
- [ ] 手动切换三种语言检查布局，没有文字溢出或按钮变形。
