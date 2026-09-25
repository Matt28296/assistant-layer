# examples/ — a fictional filled install

Everything on this page is invented: the person, the business, the machine and the paths. It shows
what `SETUP.md` step 5 produces, so you can see the shape before filling a real install.

## The values file

`C:\Users\jordan\Agents\values.json`, shared by both repositories:

```json
{
  "PRINCIPAL_NAME": "Jordan Example",
  "BUSINESS_NAME": "Example Garden Studio",
  "BUSINESS_DESCRIPTION": "a two-person garden design studio",
  "OPERATOR_NAME": "Casey Operator",
  "HOSTNAME": "EXAMPLE-LAPTOP",
  "AGENTS_ROOT": "C:\\Users\\jordan\\Agents",
  "ASSISTANT_DIR": "C:\\Users\\jordan\\Agents\\assistant",
  "HEAD_DIR": "C:\\Users\\jordan\\Agents\\head",
  "TIMEZONE": "Europe/London",
  "SETUP_DATE": "2026-01-15"
}
```

`HOSTNAME` is exactly what `hostname` printed on that machine, and `assistant` and `head` are sibling
folders inside `AGENTS_ROOT`. The filler checks both before it writes anything.

## What the filler prints

In `C:\Users\jordan\Agents\assistant`:

```
filled 14 file(s) under C:\Users\jordan\Agents\assistant
OK - no placeholders left in this repository, and every JSON file parses.
```

In `C:\Users\jordan\Agents\head`:

```
filled 7 file(s) under C:\Users\jordan\Agents\head
OK - no placeholders left in this repository, and every JSON file parses.
```

## What the filled files look like

The identity table in `head\IDENTITY.md`:

| Seat | Host | Exact working directory | May write | Must never |
|---|---|---|---|---|
| **assistant** | `EXAMPLE-LAPTOP` | `C:\Users\jordan\Agents\assistant` | its own workspace; here only `msg/assistant.md`, `state/assistant.json` | write `msg/head.md` or `state/head.json`; cross a hard line |
| **head** | `EXAMPLE-LAPTOP` | `C:\Users\jordan\Agents\head` | `msg/head.md`, `state/head.json`, its rows in `state/blocked_on_principal.json` | write the assistant's files; cross a hard line |

The top of `assistant\CLAUDE.md`:

```
# CLAUDE.md — ASSISTANT seat · Example Garden Studio

> ## SCOPE — THIS FILE BINDS EXACTLY ONE SEAT
> A session whose working directory is **exactly** `C:\Users\jordan\Agents\assistant` on host `EXAMPLE-LAPTOP`.
> If your working directory is anything else, **this is not your charter. Stop and say so.**

You are **Jordan Example's assistant** for Example Garden Studio — a two-person garden design studio.
```

`head\state\head.json`. In JSON files the filler escapes each backslash, so the file still parses:

```json
{
  "seat": "head",
  "hostname": "EXAMPLE-LAPTOP",
  "cwd": "C:\\Users\\jordan\\Agents\\head",
  "status": "NOT_STARTED",
  "last_seen": null,
  "valid_until": null,
  "_valid_until_rule": "Always write valid_until beside last_seen. A heartbeat with no expiry keeps looking healthy after the writer dies.",
  "current_work": null,
  "last_shipped": null,
  "last_cycle": null
}
```
