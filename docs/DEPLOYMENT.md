# DEPLOYMENT — one remote bus, independent working copies

Choose one authoritative coordination remote before launch. For an existing fleet, retain its
established remote (for example, a separate coord repository) rather than starting a second bus.
For a new installation, the private Head repository may serve as that remote.

- ASSISTANT_BUS_DIR is the Assistant's exclusive checkout of the chosen remote.
- HEAD_BUS_DIR is the Head's exclusive checkout of the same remote. It may equal HEAD_DIR when the
  private Head repository is the chosen bus and no other session writes that working copy.
- Neither seat writes the other's checkout. The remote and relative bus paths are shared; working
  directories and staging areas are not.
- The authoritative identity table lives in the chosen bus. The IDENTITY.md in this template is a
  bootstrap seed only when creating a new bus. Never overwrite an existing fleet identity table.
- Register each real division and worker with a unique seat ID, role, parent, host, launch path,
  owned bus paths and authority ceiling. Template rows are not deployed agents.

## Synchronization and delivery

Before a cycle, fetch and integrate the remote in the seat's own checkout. Preserve local changes;
never discard another commit or force-push. Stage explicit owned paths, inspect the diff, commit,
push and confirm the commit is reachable on the remote. On a rejected push, fetch, reconcile and
retry; never overwrite an append-only entry or silently drop a task.

The Assistant writes msg/assistant.md and state/assistant.json; the Head writes msg/head.md,
state/head.json and the blocked register. Other seats own their own msg/state paths and send blocked
items upward; the Head maintains the central blocked register. Add ownership to the identity table.

Briefs stay in the Assistant workspace. A bus handoff must include a brief ID and an accessible
repository/file path plus commit revision (or an approved full brief payload). A local filename alone
is insufficient across machines. Head acknowledges the exact revision and checks access before dispatch.

## Existing deployments

Back up current instructions and record current revisions. Fill new path settings using measured
paths; review the actual fleet registry, resource budgets and authority grants. Preserve existing
logs, tasks, authority records and private memory. Do not run a placeholder replacement over live
history. Apply template changes to the deployed charters deliberately, then launch fresh sessions.

Validate one harmless brief through Assistant → Head → division → worker → verifier/result → Head
acceptance → Assistant report. Prove that top seats did not execute production work. Test a blocked
worker, duplicate task delivery and a stale memory snapshot. Report ATTENDED for manually launched
seats; VERIFIED-ACTIVE requires a measured autonomous cadence as well as a round trip.

These templates supply instructions and launchers; they do not install division agents, schedulers,
RAM monitors or an automatic learning service. Treat those capabilities as UNVERIFIED until deployed.
