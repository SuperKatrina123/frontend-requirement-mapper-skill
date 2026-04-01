# QA Static Verification Playbook

Use this playbook when the development phase is complete and test cases need to be verified against the implementation — without running the code.

## When to use static verification

Static verification is appropriate when:
- Test cases are provided as a list of inputs and expected outputs
- The logic under test is pure (validation functions, regex, type mapping)
- You have access to the source code but not a running environment

Static verification is **not sufficient** for:
- Integration flows (e.g., submit → API → redirect)
- Dynamic rendering conditions
- A/B flags or remote config

---

## Step 1: Locate the validation implementation

Find the function(s) that handle the field(s) being tested.

```bash
# Find by function name
rg -n "getCardErrMsg|validateField|isValid" src

# Find by call site (trace backwards from UI)
rg -n "errMsg|onBlur|onChange" src -A 2
```

Confirm:
- Which file defines the function?
- Is the function shared or per-platform?
- Is there a separate validation library (`validateidcard.js`) and a caller (`index.js`)?

---

## Step 2: Understand the type system at the call site

Before verifying cases, confirm what value is actually passed into the function.

```bash
# Find where the function is called and what is passed in
rg -n "getCardErrMsg\|isValidCard" src -A 2
```

Ask:
- Does the call site pass the server-facing type (API response value)?
- Or the internal enum?
- Or the component callback value?

These three may differ even when the variable name looks the same. Confirm the mapping before running cases.

---

## Step 3: Extract the validation rules

Read the implementation and extract:

| Field type | Regex or rule | Notes |
|------------|--------------|-------|
| 护照 | `/^[A-Za-z0-9]{6,20}$/` | 大小写均允许 |
| 台胞证 | `/^\d{8}$/` | 纯数字，严格8位 |
| 回乡证 | length=9 + `/^(?:(HA\|MA)\d{7}\|[HM]\d{8})$/` | 字母必须大写 |

---

## Step 4: Verify each test case against the rule

For each test case, evaluate:

1. **Happy path**: does the valid input satisfy the regex/rule?
2. **Boundary**: does the min/max length boundary work correctly?
3. **Character type**: are disallowed characters (Chinese, space, special char, newline, tab) rejected?
4. **Case sensitivity**: are lowercase variants correctly rejected when the rule requires uppercase?
5. **Empty / blank**: is an empty string or all-spaces input caught?
   - Note: `!value` check in the caller catches empty string; all-spaces may pass that check — verify the regex also rejects it.
6. **Leading/trailing whitespace**: a valid value padded with spaces — does length or regex reject it?

---

## Step 5: Check the UI constraint layer

Even when the validation function is correct, a conflicting UI constraint can silently prevent users from reaching the validation boundary.

```bash
# WXML (WeChat miniapp)
rg -n 'maxlength=|type="number"|type="idcard"|type="digit"' src --type=xml

# JSX / React Native
rg -n "maxLength|keyboardType|inputMode" src

# HTML / Vue / h5
rg -n 'maxlength=|type="number"|inputmode=' src
```

Check:
- Is `maxlength` set to at least the maximum allowed by the validation rule?
  - If validation allows 20 chars but `maxlength="18"`, the user can never enter chars 19–20.
- Is the `input type` restricting what the user can type (e.g., `type="number"` blocks letters)?
- If multiple field types share a single input template, is `maxlength` set to the **widest** value?

---

## Step 6: Record and document

Organize results into a table. For each case record:

| CaseID | Input | Expected | Result |
|--------|-------|----------|--------|
| 2092042 | 6位字母数字 | 通过校验 | ✅ 通过 |
| 2092077 | 5位 | 拦截提示 | ✅ 拦截 |

Use the template in `assets/qa-record-template.md`.

---

## Common traps

| Trap | Description |
|------|-------------|
| `!value` vs all-spaces | `!value` only catches empty string. `"   "` is truthy — verify the regex also rejects it. |
| Silent truncation | `maxlength` silently stops input before the user reaches the validation boundary. |
| Case sensitivity | Regex `[HM]` rejects `h`/`m`. Confirm lowercase variants are tested. |
| Duplicate implementations | If the validation function is copied into multiple files (e.g., per-platform), all copies must be verified independently. |
| Type system mismatch | The test case may use the internal enum value, but the function receives the server-facing type. Confirm the mapping before checking. |
| Regex anchoring | A regex without `^` and `$` anchors may pass inputs with extra characters. Confirm anchors are present. |

---

## UI Change Verification

Use this section when the requirement includes UI layout or display changes, not just logic changes.

**The fundamental limit**: visual correctness cannot be verified by reading code. Static analysis can verify structural correctness (right elements, right fields, right conditions). Visual appearance requires a running app and human eyes or screenshot tooling.

**Preferred approach when the app can be run**: use the runtime-assisted diff workflow in `references/repo-diff-playbook.md` (Cross-stack UI semantic diff → Runtime-assisted mode). Screenshot diff identifies what is different; browser inspection (React/Vue DevTools + Playwright) locates the exact component and file. The static checks below are a fallback when the app cannot be run, or a verification pass after runtime-assisted diff.

### What the agent can verify (structural)

For each slot in the diff map contract (from Stage 4 / `repo-diff-playbook.md` Step C), verify the following by reading code:

#### 1. Slot existence

Verify that every slot listed in the contract exists in the target implementation.

```bash
# Search for the element by its data field or label keyword
rg -n "promotionTag|tagName|mainPic|recList" <target-component-file>

# WXML: look for the element by its wx:if or bind condition
rg -n "wx:if|wx:for|bindtap" <target-component.wxml>

# JSX: look for conditional renders
rg -n "&&\s*<|? <|\.map(" <target-component-file>
```

For each slot in contract: ✅ present / ❌ missing / ⚠️ present but condition differs

#### 2. Field binding

Verify each field in the contract is correctly bound in the template, including field name differences identified during diff.

```bash
# WXML binding
rg -n "\{\{[a-zA-Z_.]+\}\}" <target-component.wxml>

# JSX binding
rg -n "\{[a-zA-Z_.]+\}" <target-component-file>
```

Check against the field name mapping table from the diff (e.g. `imageUrl → mainPic`). A wrong field name silently renders empty.

#### 3. Conditional render rules

Verify that visibility conditions in the target match the spec.

| Slot | Spec condition | Ref implementation | Target implementation | Match? |
|------|---------------|-------------------|----------------------|--------|
| 促销角标 | `promotionTag != null` | `{item.promotionTag && <Tag>}` | `wx:if="{{item.tagName}}"` | ✅ / ❌ |

Common discrepancy: reference checks for object existence, target checks for string non-empty — semantically equivalent but falsy edge cases may differ.

#### 4. Event handlers

Verify interactive slots have the correct handler attached and the handler targets the right action.

```bash
# WXML
rg -n "bindtap|bind:tap|catchtap" <target-component.wxml> -A 1

# JSX / React
rg -n "onPress|onClick|onTap" <target-component-file> -A 1
```

#### 5. State variations

Verify that empty, loading, and error states are handled. These are the most commonly missed UI states in cross-stack alignment.

```bash
rg -n "empty|loading|error|skeleton|placeholder|noData|list\.length" <target-component-file>
```

For each state in the reference: does the target have a corresponding branch?

---

### What the agent cannot verify (visual) — requires human or tooling

| Verification type | Why agent cannot do it | Suggested approach |
|-------------------|----------------------|-------------------|
| Layout correctness | Pixel positions, margins, and flex behavior only appear at runtime | Screenshot vs design spec side-by-side |
| Cross-stack visual parity | `rpx` vs `px` vs `rem` spacing, font rendering differs by platform | Run both apps, compare screenshots |
| Style token accuracy | Color values and typography from design tokens only resolve at render time | Check token names match design system; visual confirm after deploy |
| Animation and transition | Not inspectable from static code alone | Manual review |
| Responsive / device variation | Layout at different screen sizes requires a running environment | Device testing or simulator |

**When handing off to human review, specify exactly which slots need visual confirmation** — do not give a blanket "all UI needs visual review." Output a targeted list:

```
以下坑位结构验证通过，需人工视觉确认：
- 商品主图：字段绑定正确，但 rpx 尺寸需对照设计稿确认
- 促销角标：条件逻辑正确，但角标颜色由 tagColor 字段驱动，需运行后截图确认
以下坑位存在结构问题，应先修复再做视觉验证：
- 推荐列表：target 未找到 recList 字段绑定 → 字段缺失，待后端确认
```
