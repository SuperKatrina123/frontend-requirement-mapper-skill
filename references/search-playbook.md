# Search Playbook

Use `rg` first. Search small, then expand.

Before searching, translate business words into code words when possible.

Example:
- business word: `金刚区`
- possible code words: `grid`, `kingkong`, `shortcut`, `serviceEntry`

Search both the original business term and likely code aliases.

## Route and page entry

```bash
rg -n "path:|routes|router|createBrowserRouter|useRoutes|RouteRecordRaw|router.addRoute" src
```

## Page or module names

```bash
rg -n "banner|slot|pit|floor|module|card|tab|panel" src
rg -n "活动|运营位|坑位|入口|楼层|组件" src
```

## Data source and API calls

```bash
rg -n "fetch|request|axios|get.*List|query|api" src
rg -n "banner|slot|module|position|floor|config|material" src
```

## Tracking and analytics

```bash
rg -n "track|report|exposure|click|logEvent|埋点|曝光|点击" src
```

## Visibility and conditional rendering

```bash
rg -n "if \\(|\\? .*:|&& .*<|visible|show|hidden|disabled|canShow|permission" src
```

## Fields and enums

```bash
rg -n "jumpUrl|schema|link|title|subTitle|image|icon|tag|corner|bizType|status" src
rg -n "enum|type .* =|interface .* {|const .*Map" src
```

## State and hooks

```bash
rg -n "use[A-Z].*\\(|create\\(|defineStore|zustand|redux|mobx|pinia|selector" src
```

## Config and feature flags

```bash
rg -n "feature|flag|switch|toggle|experiment|abTest|gray|whitelist" src
```

## Validation functions and input constraints

When the requirement involves field validation rules, search both the logic layer and the UI layer.

**Find validation functions:**

```bash
# Search for validation/check functions by field type keyword
rg -n "isValid|validate|check|verify" src

# Find regex patterns
rg -n "RegExp|new RegExp|\.test\(|\/\^" src
```

**Find UI input constraints (easy to miss):**

```bash
# React Native / React
rg -n "maxLength|keyboardType|inputMode" src

# WeChat miniapp WXML
rg -n 'maxlength=|type="number"|type="idcard"|type="digit"' src --type=xml

# HTML / Vue / h5
rg -n 'maxlength=|type="number"|inputmode=' src
```

**Common trap — silent truncation**: A validation function may correctly accept a wider range (e.g. up to 20 chars) while a hardcoded `maxlength` on the input silently blocks users from entering values at the upper bound. Always check both layers.

## Dual type mapping systems

In some projects, the same concept (e.g. a select-option type, a card type, a status code) exists in two separate numbering systems that are not the same:

| System | Typical source | Typical use |
|--------|---------------|-------------|
| Server-facing type (e.g. `apiResponse.type`) | API response, UI display | Value used in validation `switch/if` |
| Internal enum (e.g. `FieldTypeEnum`) | Codebase constant | Value stored in data model |

These two systems may assign different numbers to the same concept. A value of `6` in one system may mean something different in the other.

**Search pattern to detect this:**

```bash
# Find the mapping bridge function between the two systems
rg -n "typeMap|mapType|toType|TypeToCode|CodeToType" src

# Find enum definitions
rg -n "^export.*enum|const.*= {" src

# Find where the type value is actually passed into the validation call
rg -n "switch.*type|if.*type ===|getErrMsg|isValid" src
```

When you find both systems, document the mapping table explicitly. Do not assume a value in one system equals the same value in the other.

## What to capture while searching

When a candidate file looks relevant, capture:
- absolute file path
- module or component name
- matched keyword
- why it matters

Do not stop after finding a render component. Keep tracing until you find:
- the true data source
- the field transformation
- the conditional logic
- the tracking/report logic

## Slot-by-slot mapping hints

When the task involves comparing slots or placement positions across apps, create one row per slot and search for:
- slot id
- slot code
- module code
- floor id
- position id
- card type
- material type
- jump schema
- exposure event

Treat the following as potential aliases of the same concept:
- `坑位`, `slot`, `position`, `module`, `floor`, `card`, `block`
