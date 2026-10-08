# Confirmed model-routing and reasoning policy

- **Date:** 2026-10-08
- **Source:** Matthew, direct instruction in ChatGPT
- **Status:** confirmed

## Matthew's exact words

> "I have a free reset don’t throttle when we get back please but I do want to optimize for Claude token usage since it’s the head orchestrator I want it to be orchestrating other model agents utilizing all of our usages as best possible together. The higher in the hierarchy the stronger the reasoning needs to be"

## Binding interpretation

1. When Claude capacity returns after the available reset, end the temporary emergency throttle.
2. Continue optimizing Claude usage: Claude serves as the Head Orchestrator and spends its capacity on orchestration, judgment, exception handling, and acceptance rather than routine production.
3. Route production through division orchestrators to task-fit worker agents and balance work across all available subscription-included, free-cloud, and local-model allowances.
4. Required reasoning strength increases with hierarchy level. A lower layer may be upgraded for a difficult or high-risk task, but a higher layer must not be silently downgraded below the reasoning needed for its judgment.
5. Do not enable or use paid API consumption. Subscription access does not imply API entitlement.
