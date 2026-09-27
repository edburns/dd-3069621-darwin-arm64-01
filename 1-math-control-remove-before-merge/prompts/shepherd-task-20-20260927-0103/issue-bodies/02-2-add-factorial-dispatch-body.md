## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Before implementation, read the entire plan. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

Apply these resolved decisions:

- The sole canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing pull-request workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner; do not replace or bypass either contract.
- Direct CLI execution writes exactly one result line: `Fibonacci(N) = value` for Fibonacci or `Factorial(N) = value` for factorial.
- Both calculation functions return only their numeric values, with no incidental output.
- Inputs are non-negative integers.
- This task extends repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.
- Task 2 depends on task 1 being merged, and all existing Fibonacci behavior must remain intact.

There are no separate spike findings or spike-derived implementation patterns for this task. Implement from the plan's resolved behavior and the repository's production dependencies; do not copy research code.

## Branch and execution order

Use `experiment/shepherd-control` as the base branch. This is serial task 2 of 2. Tasks are assigned, completed, and merged in the order listed in the plan. Do not begin until this issue is assigned and task 1 has been completed and merged to the base branch.

## Implement

Extend the task-1 implementation in repository-root `math-tool.ps1`:

- Add a pure `Get-Factorial` function for non-negative integer input.
- Add an `Operation` parameter that dispatches between `fibonacci` and `factorial` while retaining the `N` parameter.
- Preserve the existing Fibonacci invocation and output behavior. An invocation that previously selected Fibonacci implicitly must continue to work, so Fibonacci remains the default operation.
- For `fibonacci`, direct execution must emit exactly `Fibonacci(N) = value`.
- For `factorial`, direct execution must emit exactly `Factorial(N) = value`.
- Each function must return only its numeric result, without incidental output.

Extend repository-root `math-tool.Tests.ps1` with objective, small coverage:

- Dot-sourced unit coverage for `Get-Factorial` at `N=0`, `N=1`, and at least one small representative value.
- Isolated child-`pwsh` coverage for explicit factorial dispatch and its exact one-line stdout contract.
- Regression coverage proving the existing Fibonacci function, default CLI invocation, and exact Fibonacci output remain unchanged.
- Dispatch coverage proving each supported operation selects the correct calculation and label without cross-operation output.

Use the production script and production dependencies in tests. Do not recreate or import research-only helpers.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite.
- Factorial edge cases satisfy `0! = 1` and `1! = 1`, and a representative nontrivial factorial value is correct.
- Dot-sourced function tests prove numeric-only return values with no extra pipeline output.
- Isolated child-process tests compare complete stdout and successful exit status for both operations.
- Existing task-1 Fibonacci unit and CLI tests continue to pass unchanged in meaning, including the default Fibonacci invocation.
- The pinned pull-request CI passes without changing its Pester version or bypassing the repository-owned runner.
- Changes remain limited to the math tool, its tests, and directly necessary repository metadata.

## Out of scope

- Operations other than Fibonacci and factorial.
- Replacing or weakening `eng/test-math-tool.ps1` or `.github/workflows/shepherd-task-math-tool.yml`.
- Changing the pinned Pester 5.7.1 environment.
- Adding unrelated user interfaces, dependencies, broad refactors, or speculative behavior for negative/non-integer input.
- Reading, adapting, or copying spike source code.
