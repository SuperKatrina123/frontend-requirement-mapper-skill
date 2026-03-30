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
