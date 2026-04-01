# Repo Diff Playbook

Use this playbook **after** understanding the PRD and reversing the reference app (Stage 3), and **before** mapping to the target project (Stage 5).

Goal: build a **diff map** between the reference repo and the target repo so that the mapping in Stage 5 is grounded in structural reality, not just PRD text.

## Quick decision tree — read this first

Answer these questions in order. Stop at the first match and follow only the sections listed.

```
Q1. 改动是否涉及 UI 结构或视觉变化？
    ├─ 否（纯逻辑 / 纯字段）→ 跳到 Q3
    └─ 是 → Q2

Q2. 两端技术栈是否兼容（同为 React、同为 Vue 等）？
    ├─ 是（同栈）→ 走 Pre-flight + Step 1–7，跳过 Cross-stack UI semantic diff
    └─ 否（跨栈，如 React vs WXML）→ 走 Pre-flight + Step 1–3 + Cross-stack UI semantic diff（含 Runtime-assisted / Static）

Q3. 两端调用的是否为同一服务 / 同一 BFF？
    ├─ 是（Case 1）→ 走 Pre-flight + Step 1–3（结构 diff）+ Step 4（API 确认），跳过 Step D 和 Response payload diff
    └─ 否 → Q4

Q4. 上游集成服务是否相同？
    ├─ 是（Case 2，不同 BFF 但上游一致）→ Pre-flight + Step 1–7 + Response payload diff（重点 BFF 字段透传分析）
    └─ 否 / 不确定（Case 3）→ 全量走，Pre-flight + Step 1–7 + Cross-stack UI semantic diff（如适用）+ Response payload diff

Q5. 改动规模？
    ├─ 小（≤3 模块，PRD 明确）→ 所有步骤只做涉及模块，不全仓库扫
    ├─ 中（4–10 模块）→ 先产出 Diff Map 表再深挖
    └─ 大（>10 模块 / PRD 模糊）→ 严格按顺序走完再进入 Stage 5，不提前开始映射
```

**Minimum viable diff（纯逻辑 + Case 1 + 小规模）：**
只需要：Pre-flight 3（模块锚点）→ Step 3（组件结构）→ Step 4（API 确认）→ Diff Map。预计阅读量：本文约 20%。

**Full diff（UI+Logic + Case 3 + 中大规模）：**
全量走。预计阅读量：本文全部。

---

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
| **BFF** | e.g. Node.js BFF at `api.ref-app.com` | e.g. Node.js BFF at `api.target-app.com` |
| **Upstream service** | e.g. `product-service` gRPC | e.g. same `product-service`? or different? |
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

Template: use `assets/module-anchor-template.md` to record anchor pairs in a consistent format.

**Preferred: developer provides locations directly**

If the developer has already told you where the relevant code is (e.g. in the initial prompt or during PRD clarification), record it directly into the anchor table and skip the search steps below. Developer knowledge is faster and more accurate than any keyword search.

Example of what a developer might provide:
```
业务代码位置：
- 参考端：src/screens/Product/Detail/，src/components/Card/
- 目标端：src/pages/goods/detail/，src/components/goods-card.vue
```

Just record these as anchor pairs and proceed.

**Fallback: agent-driven search**

If locations are not provided, build the anchor table through search:

1. Start from the PRD — what pages or modules are in scope?
2. Use Stage 3 reference app analysis — you already know where things live in the reference repo
3. For each module, search the target repo using business keywords (not file paths):

```bash
rg -rn "商品详情|productDetail|goodsDetail|ItemDetail" src --type=ts -l
rg -rn "购物车|cart|shoppingCart" src --type=ts -l
```

4. If not found → ask the user before concluding it is missing. This is one case where interrupting is worth it.
5. If still not found → mark as `待确认（可能需新增）` and continue

Produce the anchor table:

| Functional module | Reference repo path | Target repo path | Found? |
|-------------------|--------------------|--------------------|--------|
| 商品详情页 | `src/screens/Product/Detail/` | `src/pages/goods/detail/` | ✅ |
| 购物车 | `src/screens/Cart/` | `src/pages/cart/` | ✅ |
| 运营活动 Banner | `src/screens/Home/components/Banner/` | `src/pages/index/components/` | ⚠️ 位置未确认 |
| 新模块 XYZ | `src/screens/Xyz/` | — | ❌ 目标不存在 |

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

## Service and field alignment classification

Before starting the structural diff steps, classify the service layer relationship. This determines how deep the field diff needs to go and whether BFF changes are in scope.

| Case | Service layer | Field alignment | Frontend diff scope | BFF scope |
|------|-------------|----------------|--------------------|-----------| 
| **Case 1** | Same service, same BFF | Fields basically consistent | Frontend structure only | None |
| **Case 2** | Different BFF, upstream service same | Fields mostly consistent | Frontend + BFF field rename/reshape | BFF light change |
| **Case 3** | Different BFF, upstream service different (or unknown) | Fields significantly different | Frontend + BFF + field full remapping | BFF substantial change |

**How to determine the case:**

1. Check the API endpoint called by each frontend — same domain/path = likely Case 1
2. If different endpoints, check whether the BFF repos share an upstream service:
   - Look for the same gRPC proto, REST service name, or data source identifier in both BFF codebases
   - If upstream is shared → Case 2; if not → Case 3

```bash
# Find upstream service calls in BFF code
rg -rn "product-service|order-service|grpc|upstream|integration" <bff-src-path> -l

# Find API endpoint the frontend calls
rg -rn "baseURL|API_HOST|endpoint|/api/v" src --type=ts
```

3. If BFF code is not accessible, infer from response payload structure (see next section).

**Implications per case:**

- **Case 1**: skip Step D (server field diff); field names are identical. Focus diff effort on frontend structure.
- **Case 2**: run Step D with moderate scope. Most fields will map 1:1; focus on renamed/restructured fields. BFF changes are likely small.
- **Case 3**: Step D is critical. Treat every field as potentially different. BFF changes may be substantial — scope them explicitly before starting frontend work.

---

## Response payload diff (optional but preferred input)

When the developer can provide **actual API response JSON** for the same page/module from both apps, prefer direct payload diff over inferring field structure from code.

Template: use `assets/payload-diff-template.md` to record the diff and ownership decisions.

**Why this is more reliable than code inference:**
- TypeScript interfaces may be outdated or incomplete
- BFF may transform fields in ways that are hard to trace statically
- Actual JSON shows exactly what the frontend receives at runtime

**How to request response payloads:**

Ask the developer to capture the response for the same API call on both sides:

```
请提供以下两端的接口返回报文（JSON）：
- 参考端：[页面名] 的 [接口路径] 返回的完整 response.data
- 目标端：[页面名] 的 [接口路径] 返回的完整 response.data
```

**How to diff two JSON payloads:**

Once provided, do a structural diff:

1. List all top-level keys in each payload
2. For keys present in both: compare value types and structure (object vs array vs primitive)
3. For keys only in reference: → candidate `字段缺失` in target
4. For keys only in target: → may be irrelevant or may indicate target has extra fields
5. For nested objects: recurse one level deep and repeat

Output a **payload field diff table**:

| 字段路径 | 参考端类型/值示例 | 目标端类型/值示例 | 差异 |
|---------|----------------|----------------|------|
| `imageUrl` | `string` `"https://..."` | ❌ 不存在 | 目标端字段缺失 |
| `mainPic` | ❌ 不存在 | `string` `"https://..."` | 参考端字段缺失（可能是 imageUrl 的改名） |
| `promotionTag` | `object {text, color}` | ❌ 不存在 | 目标端字段缺失 |
| `tagName` | ❌ 不存在 | `string` `"限时特价"` | 参考端字段缺失（可能是 promotionTag.text 的改名/拆分） |
| `price` | `number` `1200`（分） | `string` `"¥12.00"` | **类型不同**，值语义不同，不可直接替换 |
| `recList` | ❌ 不存在 | `array` | 参考端字段缺失（可能是 recommendList 的改名） |

**BFF inference from payload diff:**

When Case 2 is suspected (same upstream, different BFF), the payload diff reveals what the BFF is doing:
- Field renamed: BFF is aliasing a field from the upstream response
- Field missing in target: BFF is not forwarding it — check whether upstream has it; if yes, BFF needs to add the field
- Field structure different (nested vs flat): BFF is transforming the upstream response

```bash
# Trace a field from target BFF response back to upstream
rg -rn "imageUrl|mainPic|promotionTag" <bff-src-path> -A 3
```

If the upstream service has the field but the BFF does not forward it, the fix is a BFF change (not a backend service change) — this is lower risk and faster to deliver.

**When payload is not available**: fall back to Step D (server field diff from code) in the Cross-stack UI semantic diff section.

---

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

There are two modes depending on whether the apps can be run:

| Mode | When to use | Starting point |
|------|------------|---------------|
| **Runtime-assisted** | Both apps can be opened (preferred) | Screenshot diff → browser/tool inspection → code location |
| **Static** | Apps cannot be run, or platform does not support browser inspection | Read code directly to extract UI contract |

---

### Runtime-assisted mode (preferred)

#### Phase 1: Screenshot diff — identify WHAT differs

Take a screenshot of the same page/state in both apps, then compare side by side.

What to capture per screenshot:
- Same page, same scroll position, same data state (logged-in, same product, etc.)
- All significant states: default, empty, loading, error, edge case

How to diff:
- Side-by-side visual comparison (manual, or tools like `pixelmatch`, `resemblejs`)
- Annotate directly on the screenshots: circle differences, label with visual semantic path
- Output a **visual diff annotation list** — what is visually different, expressed in business language

Example output:
```
1. 商品详情页 > 商品卡片 > 主图：参考端有圆角，目标端无
2. 商品详情页 > 商品卡片 > 促销角标：参考端有，目标端缺失
3. 商品详情页 > 底部操作栏：参考端有加购按钮，目标端只有购买按钮
4. 商品详情页 > 推荐区：滚动方向不同（参考端横滑，目标端竖列）
```

This list becomes the **primary input** to Phase 2. Only investigate elements that appear in this list — do not investigate stable parts.

#### Phase 2: Browser inspection — locate WHERE in the code

**For web apps (React / Vue):**

If the agent can operate a browser (e.g. via Playwright MCP or similar browser automation):

```
1. Open the target app in browser
2. Navigate to the page
3. Right-click the differing element → Inspect
4. In React DevTools (Components tab):
   - Select the element
   - Read the component name and props
   - Click the source icon (⚛ → go to source) → jumps to the exact file and line
5. Record: component name, file path, line number, props in use
```

If the agent cannot operate a browser but React DevTools source maps are available, the developer can do this step manually and paste the component name + file path for the agent to continue.

**React component name → source file** (without browser, fallback):
```bash
# Search by component name found in DevTools
rg -rn "export.*function BannerSlot|export.*const BannerSlot|export default.*BannerSlot" src

# Search by props found in DevTools
rg -rn "promotionTag|canAddCart|imageUrl" src --type=tsx -l
```

**For Vue apps:**
Vue DevTools (Components tab) similarly shows component name, file, and props. Same workflow applies.

**Platform support matrix:**

| Platform | Browser inspection | Agent-operable? | Fallback |
|----------|--------------------|----------------|---------|
| Web (React/Vue) | ✅ Chrome DevTools + React/Vue DevTools | ✅ via Playwright MCP | grep by component/prop name |
| WeChat miniapp | ⚠️ 微信开发者工具 WXML debugger | ❌ limited | static code reading |
| uni-app (H5 build) | ✅ Chrome DevTools | ✅ | same as web |
| React Native | ⚠️ Flipper / React DevTools over USB | ❌ | static code reading |

#### Phase 3: Map visual diff → code evidence

After Phase 1 and 2, for each item in the visual diff annotation list, fill in the code evidence:

| 视觉语义路径 | 视觉差异 | 参考端代码位置 | 目标端代码位置 | 初步分类 |
|-------------|---------|--------------|--------------|---------|
| 商品卡片 > 促销角标 | 参考端有，目标端缺失 | `Badge.tsx:18`，字段 `promotionTag` | ❌ 未找到 | `需新增` |
| 底部操作栏 > 加购按钮 | 参考端有，目标端无 | `ActionBar.tsx:67`，字段 `canAddCart` | ❌ 未找到 | `需新增` |
| 推荐区 > 滚动方向 | 横滑 vs 竖列 | `Recommend.tsx:9`，`horizontal={true}` | `recommend.vue:5`，无 horizontal 属性 | UI-only `小改` |

This table feeds directly into Step C (contract diff) and Step D (server field diff) below.

---

### Static mode (fallback)

Use this when the app cannot be run. Read code directly to extract the UI contract.

### Element addressing across stacks

When two repos call different backend services, field names are not a stable cross-stack anchor — the same visual element may be driven by `imageUrl` on one side and `mainPic` on the other, from two completely different API schemas.

**The only stable cross-stack anchor is the visual semantic identity of the element**: what the user sees, where it appears in the UI, and what it does.

Use a **visual semantic path** to identify every element:

```
页面名 > 区块名 > 元素名
```

Examples:
- `商品详情页 > 商品卡片 > 主图`
- `商品详情页 > 商品卡片 > 右上角促销角标`
- `商品详情页 > 底部操作栏 > 加购按钮`

Rules:
- Use business language, not code identifiers
- Be specific enough to be unambiguous — "按钮" alone is not enough; "底部操作栏 > 加购按钮" is
- Each side then records its own implementation evidence (file, field, condition) independently
- **Never assume the two sides use the same field name** — they must be discovered separately per side
- If two elements are visually equivalent but driven by structurally different data (e.g., object vs flat fields), that difference is a gap to be documented, not hidden by a shared label

A UI contract then describes, for each element:
- visual semantic path (shared identifier)
- which file renders it (per side)
- which field(s) drive it (per side, independently discovered)
- what condition controls visibility (per side)
- what interaction is attached

### Step A: Extract the reference UI contract

For each component in scope, read the reference code and fill this table. Use the visual semantic path as the row identifier — not field names.

| 视觉语义路径 | 渲染条件 | 驱动字段（参考端） | 参考端代码证据 | 交互 |
|-------------|---------|------------------|--------------|------|
| 商品详情页 > 商品卡片 > 主图 | always | `imageUrl` | `screens/Product/Detail/index.tsx:42` | tap → 图片预览 |
| 商品详情页 > 商品卡片 > 促销角标 | `promotionTag != null` | `promotionTag.text`, `.color` | `screens/Product/Detail/Badge.tsx:18` | none |
| 商品详情页 > 底部操作栏 > 加购按钮 | `canAddCart === true` | `skuId`, `stock` | `screens/Product/Detail/ActionBar.tsx:67` | tap → 加购 API |
| 商品详情页 > 推荐区 > 商品列表 | `recommendList.length > 0` | `recommendList[].id/title/price` | `screens/Product/Detail/Recommend.tsx:9` | tap → 详情页 |

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

Repeat independently for the target — do not copy field names from Step A. Discover each field from the target codebase directly.

| 视觉语义路径 | 渲染条件 | 驱动字段（目标端） | 目标端代码证据 | 交互 |
|-------------|---------|------------------|--------------|------|
| 商品详情页 > 商品卡片 > 主图 | always | `mainPic` | `pages/goods/detail/index.wxml:8` | tap → 预览 |
| 商品详情页 > 商品卡片 > 促销角标 | `tagName` 非空 | `tagName`, `tagColor` | `pages/goods/detail/index.wxml:23` | none |
| 商品详情页 > 底部操作栏 > 加购按钮 | ❌ 未找到 | ❌ 字段未知 | — | — |
| 商品详情页 > 推荐区 > 商品列表 | `recList.length > 0` | `recList[].id/name/price` | `pages/goods/detail/recommend.vue:5` | tap → 详情页 |

**If you cannot locate an element in the target**: do a broader keyword search before concluding it is absent. If still not found, mark as `❌ 未找到` — do not fill in field names by analogy with the reference side.

Search patterns for WXML / miniapp / uni-app:

```bash
# Conditional renders
rg -n "wx:if|wx:elif|wx:else|hidden=" <target-component.wxml>

# Data bindings
rg -n "\{\{[^}]+\}\}" <target-component.wxml>

# Event handlers
rg -n "bind:tap|bindtap|catch:tap|bind:" <target-component.wxml>

# Logic layer field usage (native miniapp)
rg -n "this\.setData|this\.data\." <target-component.js>

# uni-app / Vue SFC
rg -n "v-if=|v-show=|:class=|@tap=|@click=" <target-component.vue>
```

### Step C: Diff the two contracts

Align rows by **visual semantic path**. For each row, compare the two sides' findings independently — do not assume field names correspond just because they describe the same visual element.

Template: use `assets/ui-contract-template.md` (A/B/C tables) to keep the contract extraction and diff consistent.

| 视觉语义路径 | 参考端字段 | 目标端字段 | 元素存在？ | 字段关系 | Gap 类型 |
|-------------|-----------|-----------|-----------|---------|---------|
| 商品详情页 > 商品卡片 > 主图 | `imageUrl` | `mainPic` | 两端均有 | 改名（需显式映射） | 字段名映射 |
| 商品详情页 > 商品卡片 > 促销角标 | `promotionTag` (object) | `tagName`+`tagColor` (flat) | 两端均有 | 结构不同 | 字段结构差异 |
| 商品详情页 > 底部操作栏 > 加购按钮 | `canAddCart` | ❌ 未找到 | 目标缺失 | — | `需新增` / `字段缺失` |
| 商品详情页 > 推荐区 > 商品列表 | `recommendList[].price` | `recList[].price` | 两端均有 | 改名 | 字段名映射 |

**Gap types:**
- **字段名映射** — 语义相同，字段名不同；目标端需要显式 alias 或适配层
- **字段结构差异** — 同一数据，形状不同（nested vs flat, array vs string）；需要 transform
- **字段缺失** — 参考端有，目标端 API 未返回；上升到后端确认
- **需新增** — 整个元素在目标端不存在；属于实现工作范围
- **行为缺失** — 交互在参考端有，目标端未实现；属于实现工作范围

**Important**: "字段名映射" does not mean the fields are equivalent — it only means the visual elements serve the same purpose. The actual field semantics (nullability, value range, data type) must be verified separately before assuming they can be directly substituted.

### Step D: Server field diff

When the reference and target call **different backend services**, their response schemas are independent. Do not assume any field equivalence — discover each side's schema separately, then produce a semantic mapping.

```bash
# Reference: find response type definition
rg -n "interface.*Response|type.*Response|ApiResponse" <ref-api-file> -A 20

# Target: find response type definition
rg -n "interface.*Response|type.*Res\b" <target-api-file> -A 20

# Target miniapp (no TypeScript): read field names from actual usage
rg -n "res\.data\.|result\." <target-page-js>
rg -n "this\.setData\(\{" <target-page-js> -A 10
```

Produce a **semantic field mapping table** — aligned by visual semantic path, not by field name:

| 视觉语义路径 | 语义含义 | 参考端字段 & 类型 | 目标端字段 & 类型 | 差异 |
|-------------|---------|-----------------|-----------------|-----|
| 商品卡片 > 主图 | 商品主图 URL | `imageUrl: string` | `mainPic: string` | 改名，类型一致 |
| 商品卡片 > 促销角标 | 角标文案 + 颜色 | `promotionTag: {text, color}` | `tagName: string`, `tagColor: string` | 结构拆分 |
| 底部操作栏 > 加购按钮 | 是否可加购 | `canAddCart: boolean` | ❌ 不存在 | `字段缺失`，需后端提供 |
| 推荐区 > 商品列表 | 推荐商品数组 | `recommendList[]` | `recList[]` | 改名；子字段需逐一核对 |

Every `字段缺失` row must be confirmed with the backend team before implementation starts.

**Do not mark a field as "equivalent" based on name similarity alone.** For example, `price` in one API may be a formatted string `"¥12.00"` while in another it is a number `1200` (in fen). Always verify value semantics, not just field names.

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
