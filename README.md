# assistant-layer

**The operating structure of an executive-assistant agent seat** — the layer that sits directly
beneath a human principal, interprets intent, holds delegated authority, and hands execution to an
orchestrator.

This is the **structure and the method**, published as reference. It is one half of a pair; the other
is [`head-orchestrator`](../head-orchestrator), which documents the seat this layer delegates to.
The two repositories share the same skeleton on purpose — same protocol, same authority model, same
laws — because both seats have to agree about those things to work at all.

---

## What this is

A multi-agent system, run by one person, where independent agent sessions on several machines
coordinate through a git repository and operate under explicit written authority boundaries.

These documents describe **how it is organised and what it has learned**. Everything here was written
after running it, not before.

## What this is not

- **Not a framework or a library.** There is nothing to install.
- **Not the operation itself.** No people, clients, accounts, handles, campaign data, figures, machine
  names, or credentials appear here, and none ever will. This repository was built by allowlist —
  written fresh rather than copied and cleaned — so that nothing unvetted exists in its history to be
  scrubbed later.
- **Not the knowledge vaults.** `brains/` describes how they are *structured and maintained*. Their
  contents are a model of a specific person's judgement and a specific operation's private state, and
  are not published.

---

## Read in this order

| File | What it answers |
|---|---|
| **[CHARTER.md](CHARTER.md)** | What this seat is for, what it decides, and what it refuses |
| **[AUTHORITY.md](AUTHORITY.md)** | The six levels, the hard gates, how a delegation is recorded, and why identity never moves |
| **[BUS-PROTOCOL.md](BUS-PROTOCOL.md)** | How independent sessions coordinate through a git repository |
| **[LAWS.md](LAWS.md)** | **Start here if you only read one.** Twenty-one failure modes, each written after something broke |
| **[CONTINUITY.md](CONTINUITY.md)** | What survives a restart, and what only looks like it does |
| **[RESTART.md](RESTART.md)** | The pattern for a document that brings everything back |
| **[brains/](brains/)** | Two knowledge vaults — why two, and how they are kept honest |
| **[tools/](tools/)** | The supporting machinery, as transferable patterns |

---

## The four ideas worth taking away

**1. A declared cadence is a claim until it is measured.**
An agent is active when a round-trip has been observed *and* its heartbeat is fresh — never because
it says so. Self-reports and authorship metadata are labels, not credentials.

**2. Guards fail in the reassuring direction, and those are the ones that survive.**
A check that can report healthy while its subject is dead eventually will, and nobody files a bug
about good news. The mirror image is just as expensive: a guard that fails *loudly* into a channel
with no reader is worth exactly the same. **An alarm needs an actuator.**

**3. Authority is delegable. Verification is not.**
When a principal delegates decision-making, the right to decide moves and the requirement for
evidence does not. Taking someone's word on authority is not taking their word on facts.

**4. On a machine a human uses, an agent's polling loop is not free.**
It costs the human. Poll a file, not a process.

---

## Why it is public

The operating structure is the transferable part. The failure modes in `LAWS.md` were expensive to
find and are not specific to this operation — most of them are shapes that any system of independent
agents writing to shared state will eventually produce.

Corrections are welcome. Claims that turn out to be wrong get marked wrong and kept, with the
correction, rather than deleted — that is the same rule the vaults run on.
