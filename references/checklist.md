# Anti-Omission Checklist

Use this checklist before finalizing the analysis.

## Requirement understanding

- Is the change an addition, replacement, downgrade, or partial reuse?
- Is the entry point clear?
- Is the scope global or conditional?
- Are there user type, permission, login, region, or channel constraints?
- Does the PRD hide any default assumptions?
- Does the reference app show behavior that the PRD does not mention?

## Reference app reverse analysis

- Did you find the route or page entry?
- Did you trace from UI to the real data source?
- Did you identify the fields for every slot?
- Did you split different slot states into separate cases?
- Did you find fallback fields or downgrade logic?
- Did you inspect tracking, exposure, and click reporting?
- Did you inspect feature flags or experiment logic?
- Did you inspect loading, empty, error, and retry states?

## Target project mapping

- Did you find the target page and analogous module?
- Did you inspect route config, page container, child components, hooks/store, and API layer?
- Did you check whether a shared component change will affect other pages?
- Did you check old features or similar historical requirements for reuse?
- Did you inspect local cache, URL params, and page return-flow logic?
- Did you inspect style coupling, slot order, and layout dependencies?

## Field verification

- Which fields drive content?
- Which fields drive visibility?
- Which fields drive jumps?
- Which fields drive style or badge state?
- Are any fields frontend-computed rather than server-returned?
- Are any fields enums that need mapping tables?
- Are there empty-value fallbacks?
- Are there missing fields, or just not-yet-found fields?

## Form input validation (easy to miss)

When the requirement touches input fields or validation rules, check both layers independently:

**Validation logic layer** (functions, regex):
- Did you find the validation function for each field type?
- Does the regex or rule match the PRD exactly, including edge values (min/max length, allowed charset, case restriction)?
- Are there separate functions for different cert/field types, or does one generic fallback cover them all?
- Is the function reused across platforms, or does each platform have its own copy?

**UI constraint layer** (markup, component props):
- Does the input have a hardcoded `maxlength` / `maxLength` that contradicts the validation rule?
  - Example: validation allows 20 chars but `maxlength="18"` silently prevents the user from typing characters 19–20.
- Is the `input type` (e.g., `type="number"`, `type="idcard"`) restricting what the user can enter?
- Is the keyboard type appropriate for the field (e.g., numeric keyboard for digit-only fields)?
- If `maxlength` is shared across multiple field types by a single template, set it to the widest allowed value and let the validation function enforce the exact rule — avoid per-type conditionals like `type === X ? 20 : 18` that become stale when new types are added.

**Cross-platform consistency**:
- If the requirement covers multiple platforms (app / miniapp / h5), does each platform have the correct validation logic?
- Did you verify all platforms, not just the first one you found?
- Is the validation function duplicated across files (e.g. copied into multiple components)? If so, are all copies consistent with each other?
- At the call site, confirm which type system's value is passed into the validation function — the internal enum, the API response value, or the external component callback value. These may differ even when the variable name looks the same.

## Engineering risk

- Does the change affect tracking semantics?
- Does it affect permissions or login state?
- Does it affect cache behavior or prefetch behavior?
- Does it affect internationalization, themes, or device/container differences?
- Does it require backend field additions or schema changes?
- Does it require QA regression across linked modules?

## Output quality

- Does every key conclusion have evidence?
- Are unsupported claims labeled `推测` or `待确认`?
- Is the final report specific enough for review and implementation planning?
