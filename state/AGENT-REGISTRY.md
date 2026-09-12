# AGENT REGISTRY — who is actually alive

> **A declared cadence is a claim until measured. A seat is ACTIVE only when a round-trip has been
> observed (a question asked and answered) AND its latest write is fresh.**

**Write the time of measurement beside every status.** A status without a time goes stale silently.

## Measured {{SETUP_DATE}}

| Seat | Last log write | Round-trip seen | Status | Measured at |
|---|---|---|---|---|
| assistant | — | no | `UNVERIFIED` | — |
| head | — | no | `UNVERIFIED` | — |

**Both start UNVERIFIED.** They move to `VERIFIED-ACTIVE` only after the setup round-trip test in
`SETUP.md`, step 8.

## Status values

| Status | Requires |
|---|---|
| `VERIFIED-ACTIVE` | a round-trip **and** a write fresher than the seat's declared cadence |
| `ATTENDED` | round-trip proven; runs only when someone opens it — don't expect unprompted replies |
| `UNVERIFIED` | anything not yet proven. **No document may call this "active."** |
| `STALE` | was verified, has gone quiet past its cadence — treat as down |
| `DORMANT` | deliberately not running — a decision, not a failure |

## Rules

- **Read a seat's log and state file together.** If they disagree, report it; don't pick the fresher.
- **Don't nudge a seat just because its log is quiet** — check for a second sign of work first.
- **Never let a scheduled job write a seat's heartbeat for it.**
