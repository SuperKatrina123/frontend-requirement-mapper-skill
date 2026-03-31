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
