# Workflow

Use this workflow when analyzing a frontend requirement that depends on a vague PRD and a reference app such as `追齐APP`.

## Stage 0: Establish the business vocabulary

Goal: align business language before code search and mapping.

Collect or infer:
- business terms
- aliases and abbreviations
- slot names
- page names
- event names
- field semantics

Preferred sources, in order:
1. a user-provided glossary
2. prior requirement docs
3. PRD wording
4. code identifiers and comments

Output a small table if the terms are likely to affect searching:
- term
- alias
- likely code keywords
- meaning
- confidence

If a term is still ambiguous after light inspection, choose one of two paths:
- continue with a marked assumption if it does not affect core conclusions
- ask the user only if it blocks page selection, slot mapping, or field equivalence

## Stage 1: Clarify the PRD

Goal: turn the PRD into a structured problem statement before searching code.

Extract:
- business goal
- target users
- entry pages
- user actions
- slots or placement positions
- expected display states
- fields mentioned in PRD
- interfaces mentioned in PRD
- unclear points

Deliverable for this stage:
- `已明确`
- `待确认`
- `潜在风险`

Do not search the codebase with raw PRD text only. Normalize the requirement into keywords first.

## Stage 2: Normalize into a spec

Goal: turn the PRD into a development-facing spec that is precise enough for code analysis.

Use:
- `assets/spec-template.md`
- `references/spec-gap-checklist.md`

At this stage, force the requirement into:
- scope and non-scope
- pages/modules/slots
- display and interaction rules
- field definitions
- edge cases
- acceptance criteria

If the PRD does not contain enough detail, do not hide that. Mark the missing parts as:
- `待确认`
- `缺失定义`
- `推测`

## Stage 3: Build the search vocabulary

Before opening many files, write down the search vocabulary in three groups:

1. Business words
- module names
- page names
- slot names
- card names
- activity or campaign names

2. Technical words
- route keys
- component names
- api namespaces
- field names
- enum names

3. Alternative words
- old naming
- abbreviations
- synonyms
- backend naming vs frontend naming

Example:
- business word: `banner`
- alternative words: `slot`, `pit`, `module`, `card`, `floor`

## Stage 4: Reverse the reference app

Goal: identify what the reference app actually does, not what the PRD suggests it does.

Trace in this order:
1. route or page entry
2. page container
3. child components for each slot
4. data source
5. fields that drive visibility, content, jump, style, and tracking
6. special states and guard conditions

For each function point, capture:
- what the user sees
- where it renders
- which fields it consumes
- which condition gates it
- which event is reported
- which files prove the behavior

If one slot behaves differently under different states, split it into separate rows.

## Stage 4.5: Cross-repo structural diff

Goal: build a **diff map** between the reference repo and the target repo before touching any target code.

This stage exists because a PRD describes intent, not structural reality. Without a diff pass, the agent finds what the PRD told it to look for — and misses everything else.

**Always run this stage when:**
- The change involves UI layout or component structure
- The change involves both UI and logic
- The requirement touches more than 3 modules
- The PRD is vague or high-level about implementation scope
- The two repos call different backend services

**For small, pure-logic, explicitly scoped changes**, a light spot-diff (Pre-flight + Step 3 + Step 4 only) is sufficient.

Follow the steps in `references/repo-diff-playbook.md`. **Start with the Quick decision tree at the top** — it tells you exactly which sections to read based on change type, tech stack compatibility, service alignment, and scale. Do not read the full playbook for every task.

**Pre-flight (required before any diff step):**
0. Tech stack snapshot — framework, routing, state, API layer, styling, build
0. Directory convention map — where pages / components / API / state live in each repo
0. Module anchor table — declare `functional module → ref path + target path` for every in-scope module; search target repo by business keywords if location is unknown

**Diff steps (operate on module anchor pairs, not on whole-repo trees):**
1. Directory structure diff
2. Route diff
3. Component structure diff (per page/module in scope)
4. API diff
5. State and data flow diff
6. Style/CSS diff (for UI-type changes only)
7. Produce the diff map table

The diff map table becomes the **primary input** to Stage 5. Do not start Stage 5 without it.

**Change type classification** (assign to each diff row):
- `UI-only` — visual layout, style, props
- `Logic-only` — data flow, business rules, API calls
- `UI+Logic` — both layers coupled; investigate both paths independently

**Preliminary classification** (assign to each diff row):
- `直接复用` — identical behavior confirmed
- `小改` — minor delta found
- `需新增` — exists in reference, missing from target
- `字段缺失` — API or data field absent in target
- `待确认` — structural presence unclear

## Stage 5: Map to the target project

Goal: compare `reference app truth` with `target project reality`, using the diff map from Stage 4.5 as the starting point.

For each row in the diff map from Stage 4.5:
1. locate the target page
2. locate the target slot or analogous module
3. inspect data source and field names
4. refine the preliminary classification from the diff map
5. note downstream impact

Work through diff map rows by risk order, not PRD mention order.

Suggested classifications (refine from diff map):
- `直接复用`
- `小改`
- `需新增`
- `字段缺失`
- `待确认`

## Stage 6: Prepare the report

Write the report as an engineering artifact, not a chat reply.

The report should help the team answer:
- what exactly changes
- where to change it
- which fields matter
- what is still unclear
- what is easy to miss
- how to split the implementation work

Use the template in `assets/requirement-analysis-template.md`.

## Stage 7: Anti-omission review

Before finishing:
- walk the checklist in `references/checklist.md`
- confirm that each important conclusion has evidence
- convert weak conclusions into `待确认`
- point out the highest-risk missing pieces

## Stage 8: QA static verification (post-development closure)

Use this stage after development is done and test cases are available.

Goal: verify each test case against the actual implementation without running the code.

This stage covers two types of verification:

**Logic verification** (fully static):
1. Locate the validation function(s) and the call site
2. Confirm which type system value is passed in at the call site
3. Extract the regex or logic rule from the implementation
4. For each test case, verify: happy path, boundary values, disallowed characters, case sensitivity, empty/blank inputs, leading/trailing whitespace
5. Check the UI constraint layer independently (`maxlength`, `input type`, keyboard type)
6. Record all results using `assets/qa-record-template.md`

**UI structural verification** (static, per slot in diff map contract):
1. Slot existence — verify every slot from the contract exists in target code
2. Field binding — verify each field is correctly bound, including field name mapping
3. Conditional render — verify visibility conditions match the spec
4. Event handlers — verify interactive slots have handlers attached
5. State variations — verify empty / loading / error states are handled

**UI visual verification** (cannot be done statically — flag for human or tooling):
- Layout, spacing, color — requires running app + screenshot vs design spec
- Cross-stack visual parity — requires running both platforms and comparing
- When handing off, specify exactly which slots need visual confirmation and why; do not give a blanket "all UI needs visual review"

See `references/qa-playbook.md` for detailed search patterns, common traps, and the UI verification checklist.
