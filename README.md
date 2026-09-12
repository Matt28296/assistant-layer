# assistant-layer

**A deployable template for an executive-assistant agent seat** — the seat that works directly with a
person, works out what they actually want, keeps track of everything in motion, and hands real work
to a head orchestrator as written briefs.

It is one half of a pair. The other half is
**the companion `head-orchestrator` template**, which is also the shared bus.

**→ Start with [SETUP.md](SETUP.md).**

---

## ⚠ Do not fork this repository

**A GitHub fork of a public repository stays public.** A deployed copy will hold a real person's
priorities and a real business's state. Use **Use this template → Private** under the account of the
person the system works for.

---

## What is in here

```
CLAUDE.md                     the assistant seat's charter      (placeholders: double-braced NAMES)
SETUP.md                      step-by-step install, with the steps only the principal may do marked
HANDOFF.md                    where things stand, for the next session
CONTINUITY.md / RESTART.md    what survives a restart, and how to bring each part back
state/WORLD-MODEL.md          priorities, projects, blockers
state/AGENT-REGISTRY.md       who is actually alive — measured, not claimed
principal-mind/               how the principal decides: confirmed/ vs inferred/, review queue
system-brain/                 how the system works
briefs/                       Execution Brief template
reports/                      outcome summaries
tools/                        launcher + placeholder filler that refuses to say OK early
values.example.json           the values to fill in
docs/                         how and why it works: charter, authority, bus protocol, 21 laws
```

**Nothing here is specific to any person or business.** Every personal value is a double-braced placeholder,
filled on the target machine.

## Read first

- **[docs/LAWS.md](docs/LAWS.md)** — the failure modes this structure exists to prevent
- **[docs/AUTHORITY.md](docs/AUTHORITY.md)** — levels, hard lines, and why identity is never delegated
- **[docs/CHARTER.md](docs/CHARTER.md)** — the full reasoning behind the assistant role
