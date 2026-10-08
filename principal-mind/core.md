# CORE — how {{PRINCIPAL_NAME}} decides

**One page. Loads every session.** Everything else is reached from `MAP.md`.

> **Honesty check:** if `confirmed/` is empty, everything below is **inference** and must be read
> that way. Mark each line with its source: `[confirmed YYYY-MM-DD]` or `[inferred]`.

## Objectives — in {{PRINCIPAL_NAME}}'s own words

- Use the strongest reasoning at the highest layers while delegating execution across other model agents and available usage pools. `[confirmed 2026-10-08]`

## Priority rule

- Preserve high-reasoning capacity for direction, difficult judgment, exception handling and acceptance; route bounded production to the lowest layer that can meet the required quality. `[confirmed 2026-10-08]`

## Hard lines

- Money, identity (logins, passwords, accounts), sending to clients or the public, deleting — always
  {{PRINCIPAL_NAME}}'s call. See `CLAUDE.md` §6.
- Use subscription-included access, free cloud allowances, or local models only; never assume a subscription includes API entitlement and never enable paid API use. `[confirmed 2026-10-08]`

## Heuristics — when X happens, do Y

- Claude allowance returns after the available reset → end the temporary emergency throttle and resume adaptive routing. `[confirmed 2026-10-08]`
- A task can be completed reliably below the Head → delegate through division orchestrators to a task-fit worker model. `[confirmed 2026-10-08]`
- Work rises in hierarchy or consequence → raise the minimum reasoning strength; do not silently downgrade judgment work. `[confirmed 2026-10-08]`
- One allowance approaches its limit → rebalance across subscription, free-cloud and local pools before slowing the whole fleet. `[confirmed 2026-10-08]`

## Defaults by decision type

- **Blocked, reversible** → take the default, write it down, continue.
- **Blocked, irreversible** → wait; add to the blocked register.
- **A risk {{PRINCIPAL_NAME}} has accepted** → record who and when; do not raise it again.

## How {{PRINCIPAL_NAME}} likes to be spoken to

- Lead with the outcome or decision, then give concise reasons and evidence. `[inferred]`

## Ownership and consumption
Assistant edits this canonical vault. Head reads it via PRINCIPAL_MIND_DIR and proposes operational
learning updates through its own bus log. Follow `docs/HEAD-LEARNING.md`; confirmed preferences never
expand authority. Keep the core to one page and move detailed evidence to indexed notes.
