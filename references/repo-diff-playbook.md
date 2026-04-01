# Repo Diff Playbook

Use this playbook **after** understanding the PRD and reversing the reference app (Stage 3), and **before** mapping to the target project (Stage 5).

Goal: build a **diff map** between the reference repo and the target repo so that the mapping in Stage 5 is grounded in structural reality, not just PRD text.

## Pre-flight: Diff Preparation

**Do not start Step 1–7 without completing these three pre-flight items.**

Two repos almost never share the same tech stack or directory conventions. A raw directory diff between a React Native app and a Vue miniapp produces noise, not insight. You must first establish the conceptual translation layer that makes the diff meaningful.

### Pre-flight 1: Tech stack snapshot

Capture the tech stack for each repo in a two-column table before touching any diff.

| Dimension | Reference repo | Target repo |
|-----------|---------------|-------------|
| Framework | e.g. React Native | e.g. Vue 3 + miniapp |
| Routing | e.g. React Navigation (stack-based) | e.g. `pages.json` (file-based) |
| State management | e.g. Zustand | e.g. Pinia |
| API layer | e.g. `src/services/` axios wrappers | e.g. `src/api/` wx.request |
| Styling | e.g. StyleSheet + design tokens | e.g. SCSS modules + rpx |
| Component library | e.g. custom DS | e.g. uview-plus |
| Build / platform | e.g. Metro + iOS/Android | e.g. uni-app + WeChat |

Fill this table from `package.json`, `app.json` / `pages.json`, and a quick directory scan. Mark any dimension as `待确认` if unclear.

**Why this matters**: the same concept (e.g. "a page component") lives in structurally different places depending on framework. Comparing file paths without this map is comparing apples to oranges.

### Pre-flight 2: Directory convention map

Each repo has its own "language" for organizing code. Document it before diffing.

For each repo, answer:
- Where do page-level components live? (`src/pages/`, `src/screens/`, `src/views/`?)
- Where do shared/reusable components live?
- Where do API calls or service wrappers live?
- Where does state (store, hooks) live?
- Where does routing config live?
- Where do types/interfaces live?
- Where do static assets and style tokens live?

Produce a side-by-side summary:

| Layer | Reference repo path | Target repo path |
|-------|--------------------|--------------------|
| Pages | `src/screens/` | `src/pages/` |
| Shared components | `src/components/` | `src/components/` |
| API layer | `src/services/` | `src/api/` |
| State | `src/store/` (Zustand) | `src/stores/` (Pinia) |
| Routing | `src/navigation/` | `src/pages.json` |
| Types | `src/types/` | `src/typings/` |

This table becomes the translation key for all subsequent diff steps. When Step 1 says "compare directories", compare the semantically equivalent paths, not the literal paths.

### Pre-flight 3: Module anchor table

Before diffing anything, declare the **functional module locations** in both repos.

This is the most important pre-flight item. Without module anchors, a diff is just a list of file differences with no meaning.

**How to build the anchor table:**

1. Start from the PRD — what pages or modules are in scope?
2. Use Stage 3 reference app analysis — you already know where things live in the reference repo
3. For each module, search the target repo using business keywords (not file paths):

```bash
# Search target repo for the functional module — use business terms, not assumed paths
rg -rn "商品详情|productDetail|goodsDetail|ItemDetail" src --type=ts -l
rg -rn "购物车|cart|shoppingCart" src --type=ts -l
```

4. If not found in target → preliminary classification is `需新增`, mark target path as `待确认`

Produce the anchor table:

| Functional module | Reference repo path | Target repo path | Found? |
|-------------------|--------------------|--------------------|--------|
| 商品详情页 | `src/screens/Product/Detail/` | `src/pages/goods/detail/` | ✅ |
| 购物车 | `src/screens/Cart/` | `src/pages/cart/` | ✅ |
| 运营活动 Banner | `src/screens/Home/components/Banner/` | `src/pages/index/components/` | ⚠️ 位置未确认 |
| 新模块 XYZ | `src/screens/Xyz/` | — | ❌ 目标不存在 |

**If you cannot locate a module in the target repo:**
- Do a broader keyword search before concluding it is missing
- Ask the user if the module location is known — this is one case where interrupting is worth it
- If still not found, mark target path as `待确认（可能需新增）` and continue

**Once the anchor table is complete, Steps 1–7 operate on module-by-module pairs from this table, not on the repos as a whole.**

---

## Why diff before mapping

A PRD describes intent. It does not describe everything that is structurally different between the two repos.

Without a diff pass:
- UI changes that the PRD assumes are "obvious" get missed
- Large-scale alignment work lacks a scope baseline
- The agent finds what it looks for, but misses what it does not know to look for

With a diff pass:
- The agent knows *all* the divergence points, not just PRD-mentioned ones
- Changes are pre-classified by type, so the right investigation strategy is applied
- Large-scale work is scoped before diving into any single module

## Three change types

| Type | What differs | Typical risk | Investigation depth |
|------|--------------|--------------|---------------------|
| **UI-only** | Layout, visual style, component props, display logic | Lower — usually self-contained within view layer | Check component tree, style files, conditional render |
| **Logic-only** | Business rules, API calls, state management, data transforms | Medium — may have hidden dependencies | Trace data source → transform → output |
| **UI + Logic** | Both layers are coupled | High — changing one layer affects the other | Must trace both paths independently, then check where they intersect |

Classify every diff finding into one of these three types. Do not assume UI changes are logic-safe or vice versa.

## Scale guide

| Scale | Criterion | Approach |
|-------|-----------|----------|
| **Small** | ≤ 3 modules, PRD is explicit | PRD-driven spot diff — check targeted files only |
| **Medium** | 4–10 modules, or any UI overhaul | Build a diff map (route + component + API) before diving in |
| **Large** | > 10 modules, structural reorganization, or PRD vague | Full structural diff first; do not start mapping until the diff map exists |

## Step 1: Directory structure diff

**Prerequisite: Pre-flight 3 anchor table must exist.**

Compare module-level directories **within each anchor pair**, not across the whole repo root.

```bash
# For a specific module anchor pair — list files in each
find <ref-module-path> -type f | sort
find <target-module-path> -type f | sort
```

Look for:
- Files in reference module that are entirely missing from target module (`需新增` candidate)
- Files in target with no reference counterpart (may be out-of-scope legacy, or `待确认`)
- Naming divergence that maps to the same concept (note as aliases for Step 3)

## Step 2: Route diff

Use the routing convention from Pre-flight 2 — do not assume both repos use the same routing pattern.

| Routing pattern | Where to look |
|----------------|---------------|
| Config-based (React Navigation, Vue Router) | Route config files |
| File-based (Next.js, Nuxt, uni-app) | `pages.json`, `pages/` directory structure |
| Mixed | Both |

```bash
# Reference repo — config-based routing
rg -n "path:|routes|createBrowserRouter|useRoutes|RouteRecordRaw|addRoute" src --type=ts

# Target repo — file-based routing example (miniapp)
cat src/pages.json | grep -A2 '"path"'
```

For each in-scope module anchor, confirm:
- Route exists in both → check path, params, guards
- Route exists only in reference → `需新增` or `待确认`
- Route guards differ → `Logic-only` or `UI+Logic` change

## Step 3: Component structure diff

For each module anchor pair, compare the component tree **within that module** using the directory convention map from Pre-flight 2.

```bash
# List component files in each anchor module
find <ref-module-path> -name "*.tsx" -o -name "*.vue" -o -name "*.jsx" | sort
find <target-module-path> -name "*.tsx" -o -name "*.vue" -o -name "*.jsx" | sort
```

Do not compare file names literally across different tech stacks. Map by **component responsibility**, not file name:
- A `.vue` SFC in target may correspond to a `.tsx` file + a `styles.ts` file in reference
- A container component in reference may be split into page + layout in target

Diff heuristics:
- Same responsibility, both exist → inspect props, slots, conditional render → classify as `小改` or `直接复用`
- Responsibility exists in reference only → `需新增`
- File exists in target with no reference counterpart → out-of-scope or legacy, mark `待确认`

> **When tech stacks differ (e.g. React vs WXML miniapp):** do not compare syntax. Skip to [Cross-stack UI semantic diff](#cross-stack-ui-semantic-diff) below, then return to Step 4.

## Cross-stack UI semantic diff

Use this section when the reference and target use incompatible UI syntaxes — for example React/RN JSX vs WeChat miniapp WXML, or Vue SFC vs React Native StyleSheet. A line-by-line code diff produces noise, not insight.

**The principle**: do not diff code. Extract the **UI contract** from each side independently, then diff the contracts.

A UI contract describes:
- what slots/elements exist
- which server field drives each element
- what condition controls visibility
- what interaction is attached

### Step A: Extract the reference UI contract

For each component in scope, read the reference code and fill this table:

| Slot / Element | Renders when | Driven by field(s) | Interaction | Notes |
|----------------|-------------|-------------------|-------------|-------|
| 商品主图 | always | `imageUrl` | tap → 图片预览 | — |
| 促销角标 | `promotionTag != null` | `promotionTag.text`, `promotionTag.color` | none | 可能多个 |
| 加购按钮 | `canAddCart === true` | `skuId`, `stock` | tap → 加购 API | 登录态门控 |
| 推荐列表 | `recommendList.length > 0` | `recommendList[].id`, `.title`, `.price` | tap → 详情页 | 横滑 |

Search patterns for React/RN:
```bash
# Find conditional renders
rg -n "&&\s*<|? <|\bif\b.*return|\.map\(" <ref-component-file>

# Find field references in JSX
rg -n "\{[a-zA-Z_]+\.[a-zA-Z_]+\}" <ref-component-file>

# Find event handlers
rg -n "onPress|onClick|onTap|onTouch" <ref-component-file>
```

### Step B: Extract the target UI contract

Repeat for the target component. WXML/miniapp search patterns:

```bash
# Find conditional renders in WXML
rg -n "wx:if|wx:elif|wx:else|hidden=" <target-component.wxml>

# Find data bindings
rg -n "\{\{[^}]+\}\}" <target-component.wxml>

# Find event handlers
rg -n "bind:tap|bindtap|catch:tap|bind:" <target-component.wxml>

# Find field usage in JS/TS logic file
rg -n "this\.setData|this\.data\." <target-component.js>
# or for uni-app / Vue style:
rg -n "v-if=|v-show=|:class=|@tap=|@click=" <target-component.vue>
```

### Step C: Diff the two contracts

Place them side by side:

| Slot / Element | Ref field | Target field | Match? | Gap type |
|----------------|-----------|-------------|--------|----------|
| 商品主图 | `imageUrl` | `mainPic` | ✅ 语义相同，字段名不同 | 字段名映射 |
| 促销角标 | `promotionTag.text` | `tagName` (扁平) | ⚠️ 结构不同 | 字段结构差异 |
| 加购按钮 | `canAddCart` | ❌ 无此字段 | ❌ | `字段缺失` |
| 推荐列表 | `recommendList[]` | `recList[]` | ✅ 语义相同 | 字段名映射 |

Gap types:
- **字段名映射** — same semantics, different name; need explicit alias in target
- **字段结构差异** — same data, different shape (nested vs flat, array vs string); need transform
- **字段缺失** — reference has it, target API does not return it; escalate to backend
- **行为缺失** — interaction exists in reference but not in target; scope item

### Step D: Server field diff

If the reference and target call different backend APIs (common in cross-stack alignment), the response schemas may differ even when the UI intent is the same.

```bash
# Find the API response type definition in reference
rg -n "interface.*Response|type.*Response|ApiResponse" <ref-api-file> -A 20

# Find the API response type definition in target
rg -n "interface.*Response|type.*Res\b" <target-api-file> -A 20
# or for miniapp with no TypeScript:
# read the actual response field names from the service file or mock data
rg -n "res\.data\.|result\." <target-page-js>
```

Produce a **field name mapping table** for every field that differs:

| Semantic meaning | Ref field name | Target field name | Match type |
|-----------------|---------------|------------------|------------|
| 商品主图 | `imageUrl` | `mainPic` | 改名 |
| 促销角标 | `promotionTag` (object) | `tagName` + `tagColor` (flat) | 结构拆分 |
| 是否可加购 | `canAddCart` (boolean) | ❌ 无 | `字段缺失` |
| 推荐商品列表 | `recommendList` | `recList` | 改名 |

This table feeds directly into Stage 5 field mapping. Every `字段缺失` row must be confirmed with the backend team before implementation starts.

### When to stop the semantic diff

Move on when:
- All visible slots in the reference have a corresponding row in the contract diff table
- Every `字段缺失` and `字段结构差异` row has been flagged
- The contract diff table is complete enough to write the field mapping section of the Stage 5 report

Do not try to compare CSS or style tokens across incompatible stacks (StyleSheet px vs WXML rpx). Instead, note style differences as: "layout intent is X; target must achieve the same intent using its own style system."

## Step 4: API diff

Use the API layer path from Pre-flight 2 for each repo. Note that the API call mechanism differs by tech stack — use the platform-appropriate search pattern.

```bash
# Reference API layer (axios / fetch)
find <ref-api-layer-path> -type f | sort
rg -rn "fetch|axios|request" <ref-module-path> -l

# Target API layer — use correct platform pattern
# miniapp / uni-app:
rg -rn "wx\.request|uni\.request|uni\.get|uni\.post" <target-module-path> -l
# h5 / RN:
rg -rn "fetch|axios|request" <target-module-path> -l
```

For each API used in the reference for this requirement:
- Does target have an equivalent API call?
- Is the request/response shape compatible?
- Is there a field that exists in reference response but not in target? → `字段缺失`

## Step 5: State and data flow diff

Use the state layer path from Pre-flight 2. State management patterns differ by tech stack — adapt the search.

```bash
# Zustand (RN / React)
rg -n "create\(|useStore|createStore" <ref-module-path> --type=ts

# Pinia (Vue / uni-app)
rg -n "defineStore|useStore|storeToRefs" <target-module-path> --type=ts

# Redux / RTK
rg -n "createSlice|useSelector|useDispatch" src --type=ts

# Local state only
rg -n "useState|useReducer|ref\(|reactive\(" <module-path> --type=ts
```

Compare:
- Which state is managed centrally vs locally in each repo
- Whether reference uses a store that target has not created
- Whether the data transformation between API response and UI state differs

## Step 6: Style and CSS diff

Relevant only for UI-only or UI+Logic change types.

**If tech stacks are incompatible** (e.g. RN StyleSheet vs WXML/WXSS): do not compare style code. Instead record the **layout intent** — "reference renders a 2-column grid with 8px gap" — and let the target implement it with its own style system. Flag only structural layout differences (number of columns, scroll direction, element order) as diff items, not pixel values or class names.

For same-stack style diff, use platform-appropriate patterns:

```bash
# React Native — StyleSheet
rg -n "StyleSheet\.create|style=\{\{" <ref-module-path> --type=tsx

# Vue SFC — scoped styles
find <target-module-path> -name "*.vue" | xargs grep -l "<style"

# SCSS / LESS modules
find <target-module-path> -name "*.scss" -o -name "*.less" | sort

# CSS-in-JS (styled-components, emotion)
rg -n "styled\.|css`|makeStyles" <ref-module-path>

# Design tokens / variables
rg -n "colors\.|spacing\.|theme\.|var(--" src -l
```

For each module anchor pair in UI-type changes:
- Does the reference use a layout component or grid system the target does not have?
- Are spacing/color/typography tokens semantically compatible, or do they need a mapping?
- Does the target use a unit system (px, rpx, rem) that differs from reference?

Note: do not list every style difference. Focus on structural differences that affect layout or component composition.

## Step 7: Produce the diff map

After steps 1–6, produce a **diff map table** before entering Stage 5 mapping.

The table extends the module anchor table from Pre-flight 3 with diff findings.

| Functional module | Ref path | Target path | Ref ✓ | Target ✓ | Change type | Preliminary classification | Notes |
|-------------------|----------|-------------|--------|----------|-------------|---------------------------|-------|
| 商品详情/Banner坑位 | `screens/Product/Detail/Banner` | `pages/goods/detail/Banner.vue` | ✅ | ✅ | UI-only | `小改` | 布局结构不同 |
| 商品详情/推荐列表 | `screens/Product/Detail/RecommendList` | `pages/goods/detail/Recommend.vue` | ✅ | ✅ | UI+Logic | `小改` | API 字段待确认 |
| 新运营模块 XYZ | `screens/Xyz/` | — | ✅ | ❌ | UI+Logic | `需新增` | 整块缺失 |
| 公共卡片组件 | `components/Card/` | `components/GoodsCard.vue` | ✅ | ✅ | Logic-only | `小改` | 字段映射需验证 |

This table becomes the **primary input** to Stage 5 target project mapping. Do not skip directly to file-level investigation before this table exists.

## Signals that the diff is incomplete

Do not move to Stage 5 if any of these are true:
- You only diffed files the PRD mentioned (PRD-driven, not diff-driven)
- You found no differences — this is suspicious for any real alignment task
- More than 30% of rows in the diff map are `待确认` on both "Ref has it" and "Target has it"

## What to do with the diff map in Stage 5

For each row in the diff map:
- `直接复用` rows: confirm props/API are truly identical, then skip deep investigation
- `小改` rows: focus on exactly what differs, avoid over-investigating stable parts
- `需新增` rows: trace the full reference implementation before writing target code
- `字段缺失` rows: escalate immediately — these may block delivery

Large-scale alignment tip: work through the diff map top-down by risk, not by PRD mention order.
