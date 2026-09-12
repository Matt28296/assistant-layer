# CONTINUITY — failure and recovery

This file exists because the system is a collection of processes on machines that restart without
asking. It answers one question: **when something stops, what brings it back, and who has to be
there?**

---

## The finding that shapes everything else

Across three unplanned restarts:

> **Every registered scheduled job came back unaided. Not one attended working session did.**

Durability is exactly the fraction of the system that is a scheduled job. In most systems that
fraction is the *monitoring* — and the production work, which is what anyone actually cares about,
runs in attended sessions with no autostart at all.

That is not automatically wrong. It is only wrong when it is **unknown**. So this file lists, per
component, whether it returns on its own.

---

## Classify every component by what it survives

| Class | Survives a restart? | Needs |
|---|---|---|
| **Scheduled job** | Yes, unaided | Nothing |
| **At-logon service** | Yes, on next logon | Nothing |
| **Attended session** | **No** | A human, or a launcher |
| **Interactive dependency** (a signed-in browser, a debugging port, a desktop app) | **No** | A human |

**The trap is class 4.** A component can be "running" and still be missing the interactive context it
needs. A browser process being up says nothing about whether the right identity is signed in on the
right surface — and the check that reads one identity per browser will confidently confirm the wrong
one. See `LAWS.md` §6 and §19.

---

## Per-failure playbooks

Write one per failure mode, not one per component. Each answers:

1. **How do I know this happened?** (the signal, and *which instrument* produces it)
2. **What is lost while it is down?** (in units someone cares about, not "the service is degraded")
3. **What brings it back?** (exact commands, with paths)
4. **Who has to be present?** (nobody / any agent / the human specifically)
5. **How do I confirm it actually came back?** — and *never* by re-reading the thing that lied.

Point 5 is the one people skip. Confirm a frozen display by watching its **log tick** and its output
files change mtime, never by looking at the display: **a frozen panel and a current panel are the
same photograph.**

---

## The failure mode this file originally had no playbook for

A machine came back **different**.

An operating-system update installed itself, the machine rebooted, every service returned — and a
media-decode capability was quietly broken afterwards. Encoding worked. Probing worked. Decoding did
not. Two seats were blocked for hours.

**"The machine came back" and "the machine came back the same" are different assertions**, and only
the first is covered by a normal recovery plan. Add a playbook for post-update regression, and note
that rolling back an OS update is a human action.

---

## Single points of failure — the ones that hide

List them explicitly, because the dangerous ones are invisible:

- **A repository with no remote.** Two working repositories were excluded from the backup under a
  heading that read *"separate repos — these have their own remotes."* **Neither had a remote.** The
  exclusion was copied forward; the premise was never checked. Recovery for those was *none*, and it
  read as covered.
- **A component embedded in a parent repository as a bare reference.** A nested repository recorded
  as a link rather than as files means **the backup restores an empty directory**. This was reported
  fixed three times and measured back each time, because the fix was run and the check was not re-run.
  Its actual cause was an ignore rule written with a trailing separator (directory-only) against an
  index entry without one — **and an ignore rule never applies to an already-tracked path at all.**
  *The rule protected nothing and looked like it did.*
- **A component that exists on exactly one disk.** An entire working subsystem was built, run, and
  left untracked against a repository last committed months earlier. It was found only because
  someone asked an unrelated question. **A new component with no continuity entry is a bug.**
- **A monitor bound to a session.** When the session ends the monitor ends, and nothing records that
  it ever existed. **A quiet system and an unwatched system produce the identical observation.**

---

## Keep this file current, or it becomes a liability

Update it whenever a component is added, moved, or retired — **in the same change**, not afterwards.

**And cross-read the neighbouring documents before writing "no entry exists."** Twice in two days a
fact was held by three documents and missing from the fourth, where the fourth was the recovery
document — the one whose entire job is answering "how do I bring this back." Those files are written
in the same pass by the same author, which is exactly why the gap is invisible from inside any one of
them. See `LAWS.md` §14.
