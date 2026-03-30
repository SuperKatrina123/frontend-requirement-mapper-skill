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

## Stage 2: Build the search vocabulary

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

## Stage 3: Reverse the reference app

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

## Stage 4: Map to the target project

Goal: compare `reference app truth` with `target project reality`.

For each function point:
1. locate the target page
2. locate the target slot or analogous module
3. inspect data source and field names
4. classify the gap
5. note downstream impact

Suggested classifications:
- `直接复用`
- `小改`
- `需新增`
- `字段缺失`
- `待确认`

## Stage 5: Prepare the report

Write the report as an engineering artifact, not a chat reply.

The report should help the team answer:
- what exactly changes
- where to change it
- which fields matter
- what is still unclear
- what is easy to miss
- how to split the implementation work

Use the template in `assets/requirement-analysis-template.md`.

## Stage 6: Anti-omission review

Before finishing:
- walk the checklist in `references/checklist.md`
- confirm that each important conclusion has evidence
- convert weak conclusions into `待确认`
- point out the highest-risk missing pieces
