# TOOLS — the supporting machinery, as patterns

Descriptions of what each piece of tooling does and the design rule it encodes. Implementations are
omitted where they are specific to one operation; the patterns are the transferable part.

---

## Watch loop — urgent-only alerting

A short-interval job that pushes a notification **only** for things that need a human now: an item on
the blocked-on-human register, a direct message addressed to the operator, a machine silent past its
declared cadence, activity on a channel that is normally quiet.

**The design rule is the filter.** An alerting system that reports healthy cycles trains its reader to
skim, and the alert that matters then arrives into a habit of skimming.

> **⚠ Its most instructive failure: the loop kept exiting zero while the step that refreshed its data
> failed on nearly half of all cycles.** It alerted correctly — off data it had not refreshed —
> and reported quiet cycles through a real outage. The step was labelled "non-fatal" by the script's
> own author, and that label was never tested. **Confident quiet is the worst output an alerting
> system can produce.** Check that a monitor's *inputs* refreshed, not just that it ran.

---

## Periodic report — the digest

A low-frequency summary of the whole operation to the operator, leading with **anything blocked on
them, and its age.**

Leading with the blocked register is deliberate: those items are the only ones nobody else can clear,
and they are the ones that sit for hours because nothing carries them as a list.

---

## Documentation-currency sweep

Measures drift between what documents assert and what state files measure, and publishes the result as
a state file of its own.

**Two rules learned the hard way:**

- **Never measure an agent's freshness by a file a scheduled job writes on its behalf** — that seat
  becomes unflaggable forever (`LAWS.md` §3). Measure against the newest **agent-authored** field.
- **Prefer adding a step to an existing scheduled job over registering a new one.** A second entry is
  a second thing that can silently never fire — which this job itself did, sitting with a placeholder
  date, having never run, while its output was quietly produced by hand (`LAWS.md` §9).

---

## Physical control surface and local dashboard

A hardware key panel and a loopback web page showing the same information.

**The design rule that matters:** the page **imports the panel's own renderer functions** rather than
querying sources independently. Two surfaces that compute the same number two ways will eventually
disagree, and then both are quotable (`LAWS.md` §6).

**Its failure mode is the dangerous direction and it has fired:** the panel froze for four hours with
its process alive, reporting responsive, its log simply stopping mid-stream — no error, no exit.
**A frozen tile and a current tile are the same photograph.** Confirm by watching the log tick and
the rendered output files change, never by looking at the panel.

**And it is where `LAWS.md` §11 came from.** Every renderer shelled out to a console program on every
refresh, and each invocation opened a window that took foreground focus on the machine its owner was
sitting at — **nine windows in 8.6 minutes**, stealing his keyboard mid-sentence. Fixed by suppressing
the console at every call site, *not* by widening a staleness threshold, which would have removed the
symptom by making the displayed number staler.

---

## Hidden launcher

A tiny shim that runs a console program with no window, preserving the user context, the standard
output handles, and **the exit code**.

It exists because the two obvious fixes are both worse:

- **A windowless interpreter variant** typically provides no standard output, so any `print()` in the
  target begins raising — silencing a real alarm to cure a cosmetic flicker.
- **Changing a scheduled job to run non-interactively** removes the window, but also changes the logon
  type, and jobs that authenticate to remote services may lose access to the credential store —
  risking a quiet delivery failure.

**Preserving the exit code is not optional:** for a scheduled job it is the only health signal
anything reads. Test both a zero and a non-zero case explicitly.

---

## Messaging bridge

A long-poll process that relays messages between the operator's chat client and a headless agent
session.

**One ownership rule prevents the whole class of bug:** exactly **one** process owns receiving. Every
other session may only send. Two readers on one message stream silently split the messages between
them, and each looks like it is working.

---

## Launchers

Starting an agent seat requires entering the correct directory *first*, because identity is
hostname + working directory (`BUS-PROTOCOL.md`). A launcher that invokes the agent without changing
directory produces a seat that cannot match its own identity row — and the correct behaviour then is
to **stop**, which reads as a broken launcher rather than a working safety check.
