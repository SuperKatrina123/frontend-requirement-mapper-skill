# Spec Gap Checklist

Use this checklist before treating a PRD as implementation-ready.

## Scope

- Is the changed page or module explicitly named?
- Is it clear what is in scope?
- Is it clear what is out of scope?
- Is the terminal or platform clear?

## Flow

- Is the entry point defined?
- Is the user flow complete?
- Is the end state defined?

## UI and slots

- Are all slots or placement positions identified?
- Are display conditions defined?
- Are different UI states separated clearly?
- Are fallback or downgrade behaviors defined?

## Fields

- Are required fields listed?
- Are field semantics defined?
- Are field sources clear?
- Are any enums or mappings missing?
- Is it clear which fields are must-have vs optional?

## Interaction and state

- Are click actions defined?
- Are jump targets defined?
- Are loading, empty, error, and retry states defined?
- Are permission, login, or region restrictions defined?

## Engineering dependencies

- Are backend interfaces or schema changes mentioned?
- Are tracking requirements mentioned?
- Are shared component or shared repo impacts mentioned?
- Are config, experiment, or feature-flag dependencies mentioned?

## Acceptance

- Is the acceptance standard testable?
- Could a frontend engineer implement this without guessing?
- Could QA derive test points from the PRD/spec?

## Output rule

Any unchecked item should be surfaced as one of:
- `待确认`
- `缺失定义`
- `推测`
