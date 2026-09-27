## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Before implementation, read the entire plan. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

Apply these resolved decisions:

- The sole canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing pull-request workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner; do not replace or bypass either contract.
- Direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`.
- `Get-Fibonacci` returns only the numeric value, with no incidental output.
- Inputs are non-negative integers.
- The production and test files are repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.

There are no separate spike findings or spike-derived implementation patterns for this task. Implement from the plan's resolved behavior and the repository's production dependencies; do not copy research code.

## Branch and execution order

Use `experiment/shepherd-control` as the base branch. This is serial task 1 of 2. Tasks are assigned, completed, and merged in the order listed in the plan. Do not begin until this issue is assigned. Task 2 must not begin until this task is complete and merged to the base branch.

## Implement

Create repository-root `math-tool.ps1` with:

- A script parameter named `N` for a non-negative integer.
- A pure `Get-Fibonacci` function that computes and returns the Fibonacci value without writing progress, diagnostics, formatting, or other incidental output.
- Direct-script behavior that invokes the function and writes exactly `Fibonacci(N) = value` followed only by the normal line terminator.

Create repository-root `math-tool.Tests.ps1` with:

- Dot-sourced unit coverage for `Get-Fibonacci`.
- Unit cases for `N=0`, `N=1`, and at least one small representative value beyond the base cases.
- Isolated direct-CLI coverage that starts a child `pwsh` process rather than treating a dot-sourced invocation as CLI coverage.
- Assertions for exact stdout content and successful process exit for `N=0`, `N=1`, and a small representative value.
- A check that direct execution produces exactly one result line and no incidental stdout.

Keep the implementation objective and small. Follow existing repository PowerShell and Pester conventions.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero.
- The dot-sourced function tests prove the return value is numeric and is not accompanied by extra pipeline output.
- The isolated child-process tests distinguish direct execution from dot-sourced use and compare the complete stdout contract, not a substring.
- Fibonacci base cases `0` and `1` and a representative nontrivial value pass through both the appropriate unit and CLI layers.
- The pinned pull-request CI passes without changing its Pester version or bypassing the repository-owned runner.
- Only `math-tool.ps1`, `math-tool.Tests.ps1`, and directly necessary repository metadata are changed.

## Out of scope

- Factorial, operation dispatch, or any task-2 behavior.
- Replacing or weakening `eng/test-math-tool.ps1` or `.github/workflows/shepherd-task-math-tool.yml`.
- Changing the pinned Pester 5.7.1 environment.
- Adding unrelated operations, user interfaces, dependencies, broad refactors, or speculative behavior for negative/non-integer input.
- Reading, adapting, or copying spike source code.
