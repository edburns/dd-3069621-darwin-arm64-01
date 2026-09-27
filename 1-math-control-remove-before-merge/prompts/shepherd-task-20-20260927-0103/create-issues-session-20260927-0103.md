# Copilot CLI Session

> [!NOTE]
> - **Session ID:** `6645082f-2630-4075-b68e-ffc0f53b317f`  
> - **Started:** 9/27/2026, 1:03:48 AM  
> - **Duration:** 1m 31s  
> - **Exported:** 9/27/2026, 1:05:20 AM  

---

<sub>2s</sub>

### User

Invoke skill `shepherd-task-20-create-issues-from-plan` with these inputs:

- CAMPAIGN_ID: fd5e9050-6c32-41c7-9c93-5a92731ee993
- LESSON_PROPAGATION: off
- REPO: edburns/dd-3069621-darwin-arm64-01
- BASE_BRANCH: experiment/shepherd-control
- PARENT_ISSUE: 1
- PLAN_DIRECTORY: 1-math-control-remove-before-merge
- PLAN_FILE_NAME: math-tool-ignorance-reduction-plan.md
- QUESTIONS_SECTION: ## Ignorance reduction
- IMPLEMENTATION_SECTION: ## Implementation
- EXPECTED_TASK_COUNT: 2
- BASE_REMOTE: origin
- LOG_DIRECTORY: /Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103
- DRAFT_VALIDATOR: /Users/edburns/.copilot/plugins/shepherd-task/scripts/validate-stage20-drafts.sh
- ISSUE_BODY_VERIFIER: /Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-github-issue-body.sh
- CHILD_LINK_VERIFIER: /Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-stage20-child-links.sh

Fixture pagination response contract (mandatory):

- `gh api ... --paginate --slurp` returns a JSON array of page payloads, so a
  one-page response has the shape `[[{...}]]`, not `[{...}]`.
- Before indexing child issue fields such as `.id`, normalize the response to
  one flat issue array exactly once.
- In Bash, use:
  `jq 'if length == 0 then [] elif all(.[]; type == "array") then add else . end'`.
- In PowerShell, capture the `gh` output and `$LASTEXITCODE` first, then pass
  the complete JSON through the same `jq` normalization before
  `ConvertFrom-Json`.
- Use the normalized flat array for the pre-creation baseline, final child
  count/order checks, and failure reconciliation. Do not apply `add` a second
  time to an already-flat array.

---

<sub>4s</sub>

### `skill`

**shepherd-task-20-create-issues-from-plan**

<details>
<summary>Arguments</summary>

```json
{
  "skill": "shepherd-task-20-create-issues-from-plan"
}
```

</details>

```
Skill "shepherd-task-20-create-issues-from-plan" loaded successfully. Follow the instructions in the skill context.
```


---

<sub>7s</sub>

### Copilot

I’m validating the campaign inputs, repository state, plan structure, and issue-drafting conventions before any GitHub mutation.

---

<sub>13s</sub>

### `bash`

**Validate repository inputs and read plan**

$ set -euo pipefail
printf '%s\n' '--- git/remotes ---'
git status --short
git remote -v
printf '%s\n' '--- branch/default/log/scripts ---'
git show-ref --verify --quiet refs/heads/experiment/shepherd-control && echo 'base-branch=local' || git ls-remote --exit-code --heads origin experiment/shepherd-control
git remote get-url origin
[ -d '/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103' ] && [ -w '/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103' ] && echo 'log-directory=ok'
for f in '/Users/edburns/.copilot/plugins/shepherd-task/scripts/validate-stage20-drafts.sh' '/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-github-issue-body.sh' '/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-stage20-child-links.sh'; do [ -x "$f" ] && echo "executable=$f" || { echo "not-executable=$f"; exit 1; }; done
printf '%s\n' '--- plan ---'
git show 'experiment/shepherd-control:1-math-control-remove-before-merge/math-tool-ignorance-reduction-plan.md'
printf '%s\n' '--- campaign ---'
git show 'experiment/shepherd-control:1-math-control-remove-before-merge/shepherd-campaign.json'
printf '%s\n' '--- campaign lessons exists ---'
git cat-file -e 'experiment/shepherd-control:1-math-control-remove-before-merge/campaign-lessons.md' && echo yes

<details>
<summary>70 lines</summary>

```
--- git/remotes ---
?? 1-math-control-remove-before-merge/prompts/
origin	git@github.com:edburns/dd-3069621-darwin-arm64-01.git (fetch)
origin	git@github.com:edburns/dd-3069621-darwin-arm64-01.git (push)
--- branch/default/log/scripts ---
base-branch=local
git@github.com:edburns/dd-3069621-darwin-arm64-01.git
log-directory=ok
executable=/Users/edburns/.copilot/plugins/shepherd-task/scripts/validate-stage20-drafts.sh
executable=/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-github-issue-body.sh
executable=/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-stage20-child-links.sh
--- plan ---
# PowerShell math-tool control campaign

Build the fixture in two cheap, serial tasks. The repository already contains
deterministic CI pinned to Pester 5.7.1. The acceptance command for every task
is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. Task 2 starts only after task 1 is merged.

## Ignorance reduction

### Repository-owned validation

**Question:** What command and environment define acceptance?

**Resolution:** The committed canonical command is
`pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The baseline workflow
`.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester
5.7.1 and invokes that repository-owned runner. Do not replace or bypass it.

### Output and ordering contracts

**Question:** What externally observable behavior and dependency order are required?

**Resolution:** Direct CLI execution writes exactly one result line to stdout:
`Fibonacci(N) = value` or `Factorial(N) = value`. Functions return the
numeric value without incidental output. Inputs are non-negative integers.
Implementation is serial: task 2 depends on merged task 1. The implementation
and test files are repository-root `math-tool.ps1` and
`math-tool.Tests.ps1`.

## Implementation

### 1. Implement Fibonacci with unit and isolated CLI coverage

Create `math-tool.ps1` with parameter `N` and a pure `Get-Fibonacci`
function. Direct execution must print exactly `Fibonacci(N) = value`.
Create `math-tool.Tests.ps1` containing dot-sourced unit tests for the
function and isolated child-`pwsh` process tests for direct CLI behavior.
Cover N=0, N=1, and a small representative value. Keep changes limited to the
math tool and its tests.

Acceptance: `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero and the pinned pull-request CI
passes.

### 2. Add factorial and operation dispatch

After task 1 is merged, extend the same script with a pure `Get-Factorial`
function and an `Operation` parameter that dispatches between `fibonacci`
and `factorial` while retaining `N`. Preserve Fibonacci behavior. Cover
factorial edge cases 0 and 1 plus a small representative value. Keep the
interface and tests objective and small; the issue does not prescribe how to
extend the tests.

Acceptance: `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite
and the pinned pull-request CI passes.
--- campaign ---
{
  "schemaVersion": 1,
  "campaignId": "fd5e9050-6c32-41c7-9c93-5a92731ee993",
  "campaignIssueNumber": 1,
  "campaignShortname": "math-control",
  "repository": "edburns/dd-3069621-darwin-arm64-01",
  "baseBranch": "experiment/shepherd-control",
  "lessonPropagation": "off",
  "campaignMetadataDirectory": "1-math-control-remove-before-merge",
  "lessonsFile": "campaign-lessons.md",
  "createdBy": {
    "shepherdTaskVersion": "1.0.5",
    "stageOutcomeProtocolVersion": 1
  },
  "createdAt": "2026-09-27T05:03:42Z"
}
--- campaign lessons exists ---
yes
<shellId: 0 completed with exit code 0>
```

</details>


---

<sub>13s</sub>

### `view`

**view the file at /Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/01-1682-java-tool-ergonomics.md.**

/Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/01-1682-java-tool-ergonomics.md

<details>
<summary>15 lines</summary>

```
# Example 01: 1682-java-tool-ergonomics-prompts-remove-before-merge

Read `copilot-sdk/1682-java-tool-ergonomics-prompts-remove-before-merge/dd-3018003-ignorance-reduction-for-implementation-plan.md` (the plan) to get the context.

✅✅Pay very close attention to each **Resolution:** to the questions in `Phase 3 — Ignorance reduction: questions to answer before writing code`.

In this session, we are creating issues of type **Task** as children of Epic https://github.com/github/copilot-sdk/issues/1682 . These issues correspond to the sub-sections in `## Phase 4 — Implementation (the build order)`.

I want you to use `gh` to create issues as sub-issues of 1682.

- I will dispatch these issues by assigning them to an agent. Leave them unassigned for now.

- The description you put in the issues you create is the specification for the work the agent assigned to the issue must do. Therefore, you need to be very specific and targeted when writing the description.

- Set the type to **Task**.

- Each issue will be worked on and resolved in serial. You can assume:
  - All issues will operate in this topic branch of `upstream`: `edburns/1682-java-tool-ergonomics`.

  - The assignee agent has access to the topic branch and, most importantly, to the prompts in the directory `1682-java-tool-ergonomics-prompts-remove-before-merge`, which includes the plan. Therefore, you can instruct the agent to access the plan by reference, you don't need to reference it by value directly in the issue.

- The sub-sections of `## Phase 4 — Implementation (the build order)` have essential details for each corresponding **Task**.

- Instruct the agent to read the entire plan before working.

- Instruct the agent to carefully re-read the relevant sections of the plan. ❌❌You can't just say, "read the relevant sections of the plan". ✅✅In the description of the issue, list exactly what sections of the plan apply to this particular issue.
- Though the sub-sections of `## Phase 4 — Implementation (the build order)` have essential details for each corresponding **Task**, I want you to carefully consider if there are additional gating tests you can add so that as the agent proceeds from one task to the next, the likelihood of rework is reduced.
```

</details>


---

<sub>13s</sub>

### `view`

**view the file at /Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/02-1810-java-tool-as-lambda.md.**

/Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/02-1810-java-tool-as-lambda.md

<details>
<summary>12 lines</summary>

```
# Example 02: 1810-java-tool-ergonomics-tool-as-lambda-remove-before-merge

Carefully read the plan `copilot-sdk/1810-java-tool-ergonomics-tool-as-lambda-remove-before-merge/1810-ignorance-reduction-for-implementation-plan.md`.

We have completed Phases 1 - 3. We are now on Phase 4.

For each sub item in Phase 4, file a child issue of Feature #1810.

Use `gh` to look at Epic #1682 and its child issues for the standard of verbosity and concreteness for issue descriptions.

The issue should be assignable to a coding agent and there must be sufficient detail in the description for the agent to proceed to completion.

Pull out the specific relevant content from Phase 3 as it applies to this current issue in Phase 4.

Tell the agent to take `edburns/1810-java-tool-ergonomics-tool-as-lambda` as the base branch. When I assign the issue to the coding agent, I will set this as the base branch.

Tell the agent to read `1810-java-tool-ergonomics-tool-as-lambda-remove-before-merge/1810-ignorance-reduction-for-implementation-plan.md`, which is present on the branch, for context.

Tell the agent which sub-item within Phase 4 they are solving.

Tell the agent that each issue will be assigned, resolved and merged to the base branch in the order in which they appear in the plan.

No work is to start until I assign each issue to the coding agent, in turn.
```

</details>


---

<sub>13s</sub>

### `view`

**view the file at /Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/03-dd-3017826-java-real-estate-demo.md.**

/Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/03-dd-3017826-java-real-estate-demo.md

<details>
<summary>14 lines</summary>

```
# Example 03: dd-3017826-java-real-estate-demo-remove-before-merge

Read `dd-3017826-java-real-estate-demo-remove-before-merge\dd-3017826-java-real-estate-demo-ignorance-reduction-plan.md` (the plan) to get the context.

✅✅Pay very close attention to each **Resolution:** to the questions in `Phase 2 — Ignorance reduction: questions to answer before writing code`.

In this session, we are creating sub-issues as children of https://github.com/edburns/Build26-BRK206-your-agent-anywhere-multiclient-multidevice-with-github-copilot-sdk/issues/2 . These issues correspond to the sub-sections in `## Phase 3 — Implementation (build order)`.

I want you to use `gh` to create issues as sub-issues of #2.

- I will dispatch these issues by assigning them to an agent. Leave them unassigned for now.

- The description you put in the issues you create is the specification for the work the agent assigned to the issue must do. Therefore, you need to be very specific and targeted when writing the description.

- Each issue will be worked on and resolved in serial. You can assume:
  - All issues will operate in this topic branch of `origin`: `edburns/2-build-out-demo`.

  - The assignee agent has access to the topic branch and, most importantly, to the prompts in the directory `dd-3017826-java-real-estate-demo-remove-before-merge`, which includes the plan. Therefore, you can instruct the agent to access the plan by reference, you don't need to reference it by value directly in the issue.

- The sub-sections of `## Phase 3 — Implementation (build order)` have essential details for each corresponding sub-issue.

- Instruct the agent to read the entire plan before working.

- Instruct the agent to carefully re-read the relevant sections of the plan. ❌❌You can't just say, "read the relevant sections of the plan". ✅✅In the description of the issue, list exactly what sections of the plan apply to this particular issue.
- Though the sub-sections of `## Phase 3 — Implementation (build order)` have essential details for each corresponding sub-issue, I want you to carefully consider if there are additional gating tests you can add so that as the agent proceeds from one task to the next, the likelihood of rework is reduced.
```

</details>


---

<sub>13s</sub>

### `view`

**view the file at /Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/04-28-python-agent-demo.md.**

/Users/edburns/.copilot/skills/shepherd-task-20-create-issues-from-plan/examples/04-28-python-agent-demo.md

<details>
<summary>16 lines</summary>

```
# Example 04: 28-python-agent-demo-remove-before-merge

Read `28-python-agent-demo-remove-before-merge/28-python-agent-demo-ignorance-reduction-plan.md` (the plan) to get the context.

✅✅Pay very close attention to each **Resolution:** to the questions in `Phase 2 — Ignorance reduction: questions to answer before writing code`. These pertain to the implementation tasks in Phase 3. ✅✅✅ Include relevant spike findings as self-contained prose in the issue description; do not direct the agent to spike directories or source files.

In this session, we are creating sub-issues as children of https://github.com/edburns/Build26-BRK206-your-agent-anywhere-multiclient-multidevice-with-github-copilot-sdk/issues/28 . These issues correspond to the sub-sections in `## Phase 3 — Implementation (build order)`.

I want you to use `gh` to create issues as sub-issues of #28

- I will dispatch these issues by assigning them to an agent. Leave them unassigned for now.

- The description you put in the issues you create is the specification for the work the agent assigned to the issue must do. Therefore, you need to be very specific and targeted when writing the description.

- Again, ✅✅For each **Resolution:** to the questions in `Phase 2 — Ignorance reduction: questions to answer before writing code`, include the relevant Resolution values in the issue description. These pertain to the implementation tasks in Phase 3. ✅✅✅ State relevant spike findings directly in the issue body with enough detail to implement them without reading spike code.

- For tasks dealing with the UI, make sure to refer to the relevant screengrabs, but only ones within `28-python-agent-demo-remove-before-merge/`.

- Each issue will be worked on and resolved in serial. You can assume:
  - All issues will operate in this topic branch of `origin`: `edburns/28-python-agent-demo`.

  - The assignee agent has access to the topic branch and, most importantly, to the prompts in the directory `28-python-agent-demo-remove-before-merge/`, which includes the plan. Therefore, you can instruct the agent to access the plan by reference, you don't need to reference it by value directly in the issue.

- The sub-sections of `## Phase 3 — Implementation (build order)` have essential details for each corresponding sub-issue.

- Instruct the agent to read the entire plan before working.

- Instruct the agent to carefully re-read the relevant sections of the plan. ❌❌You can't just say, "read the relevant sections of the plan". ✅✅In the description of the issue, list exactly what sections of the plan apply to this particular issue.
- Though the sub-sections of `## Phase 3 — Implementation (build order)` have essential details for each corresponding sub-issue, I want you to carefully consider if there are additional gating tests you can add so that as the agent proceeds from one task to the next, the likelihood of rework is reduced.
```

</details>


---

<sub>13s</sub>

### `sql`

**Track stage twenty workflow**

<details>
<summary>Arguments</summary>

```json
{
  "description": "Track stage twenty workflow",
  "query": "INSERT OR REPLACE INTO todos (id,title,description,status) VALUES ('validate-stage20','Validating stage 20 inputs','Validate repository, campaign, plan, scripts, parent issue, issue type, and baseline children','in_progress'),('draft-stage20','Drafting implementation issues','Create and validate two persisted issue bodies from plan resolutions and findings','pending'),('create-stage20','Creating ordered child issues','Create, verify, and link issues serially while persisting the ledger','pending'),('verify-stage20','Verifying stage 20 postconditions','Verify child linkage, bodies, state, assignees, type, and persist complete result','pending'); INSERT OR IGNORE INTO todo_deps(todo_id,depends_on) VALUES ('draft-stage20','validate-stage20'),('create-stage20','draft-stage20'),('verify-stage20','create-stage20');"
}
```

</details>

<details>
<summary>5 lines</summary>

```
Executed 2 statement(s):

1. INSERT
   4 row(s) inserted. Last inserted row ID: 4.

2. INSERT
   3 row(s) inserted. Last inserted row ID: 3.
```

</details>


---

<sub>16s</sub>

### Copilot

The plan has exactly two serial implementation tasks, both blocking questions have complete concrete resolutions, and the campaign manifest matches the supplied campaign ID and lesson mode. I’m now establishing the GitHub baseline and checking whether `Task` issue types are available.

---

<sub>22s</sub>

### `bash`

**Validate GitHub parent and baseline**

$ set -euo pipefail
REPO='edburns/dd-3069621-darwin-arm64-01'
PARENT=1
LOG='/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103'
mkdir -p "$LOG/issue-bodies"
repo_json="$(gh api "repos/$REPO")"
owner_type="$(jq -r '.owner.type' <<<"$repo_json")"
owner_login="$(jq -r '.owner.login' <<<"$repo_json")"
default_branch="$(jq -r '.default_branch' <<<"$repo_json")"
[ "$owner_type" = 'User' ] || { [ "$owner_type" = 'Organization' ] || { echo "unrecognized owner type: $owner_type" >&2; exit 1; }; }
[ "$default_branch" != 'experiment/shepherd-control' ]
parent_json="$(gh api "repos/$REPO/issues/$PARENT")"
[ "$(jq -r '.state' <<<"$parent_json")" = 'open' ]
[ "$(jq -r '.repository_url' <<<"$parent_json")" = "https://api.github.com/repos/$REPO" ]
children_pages="$(gh api "repos/$REPO/issues/$PARENT/sub_issues" --paginate --slurp)"
children_flat="$(jq 'if length == 0 then [] elif all(.[]; type == "array") then add else . end' <<<"$children_pages")"
printf '%s\n' "$children_flat" | jq -e 'type == "array" and all(.[]; type == "object")' >/dev/null
tmp="$LOG/pre-creation-children.json.tmp.$$"
printf '%s\n' "$children_flat" >"$tmp"
mv "$tmp" "$LOG/pre-creation-children.json"
printf 'owner=%s type=%s default=%s selected_issue_type=<none> parent=#%s state=open baseline_children=%s\n' "$owner_login" "$owner_type" "$default_branch" "$PARENT" "$(jq length <<<"$children_flat")"
jq '[.[] | {id,number,title}]' <<<"$children_flat"

```
owner=edburns type=User default=main selected_issue_type=<none> parent=#1 state=open baseline_children=0
[]
<shellId: 1 completed with exit code 0>
```


---

<sub>22s</sub>

### `bash`

**List campaign supporting resources**

$ set -euo pipefail
git ls-tree -r --name-only experiment/shepherd-control -- '1-math-control-remove-before-merge' | sed -n '1,200p'

```
1-math-control-remove-before-merge/campaign-lessons.md
1-math-control-remove-before-merge/math-tool-ignorance-reduction-plan.md
1-math-control-remove-before-merge/shepherd-campaign.json
1-math-control-remove-before-merge/shepherd-test-experiment.json
<shellId: 2 completed with exit code 0>
```


---

<sub>22s</sub>

### `view`

**view the file at /Users/edburns/.copilot/plugins/shepherd-task/scripts/validate-stage20-drafts.sh.**

/Users/edburns/.copilot/plugins/shepherd-task/scripts/validate-stage20-drafts.sh

<details>
<summary>65 lines</summary>

```
#!/usr/bin/env bash
# shepherd-task-version: 1.0.5

set -euo pipefail

[[ $# -eq 3 ]] || {
    echo "Usage: $0 <body-directory> <expected-count> <off|campaign>" >&2
    exit 1
}

body_directory="$1"
expected_count="$2"
lesson_propagation="$3"

[[ -d "$body_directory" ]] || {
    echo "Stage-20 body directory does not exist: $body_directory" >&2
    exit 1
}
[[ "$expected_count" =~ ^[1-9][0-9]*$ ]] || {
    echo "Expected count must be a positive integer." >&2
    exit 1
}
[[ "$lesson_propagation" == "off" || "$lesson_propagation" == "campaign" ]] || {
    echo "Lesson propagation must be off or campaign." >&2
    exit 1
}

body_files=()
for body_file in "$body_directory"/*-body.md; do
    [[ -f "$body_file" ]] || continue
    [[ "$body_file" != *-observed-body.md ]] || continue
    body_files+=("$body_file")
done
[[ ${#body_files[@]} -eq $expected_count ]] || {
    echo "Expected $expected_count persisted stage-20 body files; found ${#body_files[@]}." >&2
    exit 1
}

required_headings=(
    '## Campaign context and required reading'
    '## Branch and execution order'
    '## Implement'
    '## Completion gates'
    '## Out of scope'
)

for body_file in "${body_files[@]}"; do
    [[ -s "$body_file" && "$(awk 'END { print NR }' "$body_file")" -gt 1 ]] || {
        echo "Persisted issue body must contain physical Markdown lines: $body_file" >&2
        exit 1
    }
    first_nonblank="$(awk 'NF { print; exit }' "$body_file")"
    [[ "$first_nonblank" =~ ^##[[:space:]]+[^[:space:]] ]] || {
        echo "Persisted issue body must begin with a level-two heading: $body_file" >&2
        exit 1
    }
    for heading in "${required_headings[@]}"; do
        grep -Fqx -- "$heading" "$body_file" || {
            echo "Persisted issue body is missing the physical heading '$heading': $body_file" >&2
            exit 1
        }
    done
    if [[ "$lesson_propagation" == "campaign" ]]; then
        grep -Fqx -- '## Campaign lessons (REQUIRED)' "$body_file" || {
            echo "Treatment issue body is missing its campaign-lessons heading: $body_file" >&2
            exit 1
        }
    elif grep -Fqx -- '## Campaign lessons (REQUIRED)' "$body_file"; then
        echo "Control issue body unexpectedly contains a campaign-lessons heading: $body_file" >&2
        exit 1
    fi
done
```

</details>


---

<sub>22s</sub>

### `view`

**view the file at /Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-stage20-child-links.sh.**

/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-stage20-child-links.sh

<details>
<summary>30 lines</summary>

```
#!/usr/bin/env bash
# shepherd-task-version: 1.0.5

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <PRE_CREATION_CHILDREN_JSON> <FINAL_CHILDREN_JSON> <CREATION_LEDGER_JSON>" >&2
    exit 2
fi

for command_name in jq; do
    command -v "$command_name" >/dev/null 2>&1 || {
        echo "Error: Required command '$command_name' was not found." >&2
        exit 1
    }
done

script_dir="$(cd "$(dirname "$0")" && pwd)"
filter_path="$script_dir/verify-stage20-child-links.jq"
[[ -f "$filter_path" ]] || {
    echo "Error: Stage-20 child-link verification filter was not found: $filter_path" >&2
    exit 1
}

for input_path in "$@"; do
    [[ -f "$input_path" ]] || {
        echo "Error: Stage-20 child-link verification input was not found: $input_path" >&2
        exit 1
    }
done

jq -n \
    --slurpfile baseline "$1" \
    --slurpfile final "$2" \
    --slurpfile ledger "$3" \
    -f "$filter_path"
```

</details>


---

<sub>27s</sub>

### Copilot

GitHub validation passed: the parent is open, the base branch differs from `main`, the owner is a user account, and children will therefore be created **without an issue type**. The parent currently has no children; I’m persisting the two complete specifications and validating them before mutation.

---

<sub>42s</sub>

### `apply_patch`

<details>
<summary>Arguments</summary>

```json
"*** Begin Patch\n*** Add File: 1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/01-1-implement-fibonacci-body.md\n+## Campaign context and required reading\n+\n+On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.\n+\n+Before implementation, read the entire plan. Then carefully re-read these exact sections:\n+\n+- `## Ignorance reduction`\n+- `### Repository-owned validation`\n+- `### Output and ordering contracts`\n+- `## Implementation`\n+- `### 1. Implement Fibonacci with unit and isolated CLI coverage`\n+\n+Apply these resolved decisions:\n+\n+- The sole canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing pull-request workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner; do not replace or bypass either contract.\n+- Direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`.\n+- `Get-Fibonacci` returns only the numeric value, with no incidental output.\n+- Inputs are non-negative integers.\n+- The production and test files are repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.\n+\n+There are no separate spike findings or spike-derived implementation patterns for this task. Implement from the plan's resolved behavior and the repository's production dependencies; do not copy research code.\n+\n+## Branch and execution order\n+\n+Use `experiment/shepherd-control` as the base branch. This is serial task 1 of 2. Tasks are assigned, completed, and merged in the order listed in the plan. Do not begin until this issue is assigned. Task 2 must not begin until this task is complete and merged to the base branch.\n+\n+## Implement\n+\n+Create repository-root `math-tool.ps1` with:\n+\n+- A script parameter named `N` for a non-negative integer.\n+- A pure `Get-Fibonacci` function that computes and returns the Fibonacci value without writing progress, diagnostics, formatting, or other incidental output.\n+- Direct-script behavior that invokes the function and writes exactly `Fibonacci(N) = value` followed only by the normal line terminator.\n+\n+Create repository-root `math-tool.Tests.ps1` with:\n+\n+- Dot-sourced unit coverage for `Get-Fibonacci`.\n+- Unit cases for `N=0`, `N=1`, and at least one small representative value beyond the base cases.\n+- Isolated direct-CLI coverage that starts a child `pwsh` process rather than treating a dot-sourced invocation as CLI coverage.\n+- Assertions for exact stdout content and successful process exit for `N=0`, `N=1`, and a small representative value.\n+- A check that direct execution produces exactly one result line and no incidental stdout.\n+\n+Keep the implementation objective and small. Follow existing repository PowerShell and Pester conventions.\n+\n+## Completion gates\n+\n+- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero.\n+- The dot-sourced function tests prove the return value is numeric and is not accompanied by extra pipeline output.\n+- The isolated child-process tests distinguish direct execution from dot-sourced use and compare the complete stdout contract, not a substring.\n+- Fibonacci base cases `0` and `1` and a representative nontrivial value pass through both the appropriate unit and CLI layers.\n+- The pinned pull-request CI passes without changing its Pester version or bypassing the repository-owned runner.\n+- Only `math-tool.ps1`, `math-tool.Tests.ps1`, and directly necessary repository metadata are changed.\n+\n+## Out of scope\n+\n+- Factorial, operation dispatch, or any task-2 behavior.\n+- Replacing or weakening `eng/test-math-tool.ps1` or `.github/workflows/shepherd-task-math-tool.yml`.\n+- Changing the pinned Pester 5.7.1 environment.\n+- Adding unrelated operations, user interfaces, dependencies, broad refactors, or speculative behavior for negative/non-integer input.\n+- Reading, adapting, or copying spike source code.\n*** Add File: 1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/02-2-add-factorial-dispatch-body.md\n+## Campaign context and required reading\n+\n+On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.\n+\n+Before implementation, read the entire plan. Then carefully re-read these exact sections:\n+\n+- `## Ignorance reduction`\n+- `### Repository-owned validation`\n+- `### Output and ordering contracts`\n+- `## Implementation`\n+- `### 1. Implement Fibonacci with unit and isolated CLI coverage`\n+- `### 2. Add factorial and operation dispatch`\n+\n+Apply these resolved decisions:\n+\n+- The sole canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing pull-request workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner; do not replace or bypass either contract.\n+- Direct CLI execution writes exactly one result line: `Fibonacci(N) = value` for Fibonacci or `Factorial(N) = value` for factorial.\n+- Both calculation functions return only their numeric values, with no incidental output.\n+- Inputs are non-negative integers.\n+- This task extends repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.\n+- Task 2 depends on task 1 being merged, and all existing Fibonacci behavior must remain intact.\n+\n+There are no separate spike findings or spike-derived implementation patterns for this task. Implement from the plan's resolved behavior and the repository's production dependencies; do not copy research code.\n+\n+## Branch and execution order\n+\n+Use `experiment/shepherd-control` as the base branch. This is serial task 2 of 2. Tasks are assigned, completed, and merged in the order listed in the plan. Do not begin until this issue is assigned and task 1 has been completed and merged to the base branch.\n+\n+## Implement\n+\n+Extend the task-1 implementation in repository-root `math-tool.ps1`:\n+\n+- Add a pure `Get-Factorial` function for non-negative integer input.\n+- Add an `Operation` parameter that dispatches between `fibonacci` and `factorial` while retaining the `N` parameter.\n+- Preserve the existing Fibonacci invocation and output behavior. An invocation that previously selected Fibonacci implicitly must continue to work, so Fibonacci remains the default operation.\n+- For `fibonacci`, direct execution must emit exactly `Fibonacci(N) = value`.\n+- For `factorial`, direct execution must emit exactly `Factorial(N) = value`.\n+- Each function must return only its numeric result, without incidental output.\n+\n+Extend repository-root `math-tool.Tests.ps1` with objective, small coverage:\n+\n+- Dot-sourced unit coverage for `Get-Factorial` at `N=0`, `N=1`, and at least one small representative value.\n+- Isolated child-`pwsh` coverage for explicit factorial dispatch and its exact one-line stdout contract.\n+- Regression coverage proving the existing Fibonacci function, default CLI invocation, and exact Fibonacci output remain unchanged.\n+- Dispatch coverage proving each supported operation selects the correct calculation and label without cross-operation output.\n+\n+Use the production script and production dependencies in tests. Do not recreate or import research-only helpers.\n+\n+## Completion gates\n+\n+- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite.\n+- Factorial edge cases satisfy `0! = 1` and `1! = 1`, and a representative nontrivial factorial value is correct.\n+- Dot-sourced function tests prove numeric-only return values with no extra pipeline output.\n+- Isolated child-process tests compare complete stdout and successful exit status for both operations.\n+- Existing task-1 Fibonacci unit and CLI tests continue to pass unchanged in meaning, including the default Fibonacci invocation.\n+- The pinned pull-request CI passes without changing its Pester version or bypassing the repository-owned runner.\n+- Changes remain limited to the math tool, its tests, and directly necessary repository metadata.\n+\n+## Out of scope\n+\n+- Operations other than Fibonacci and factorial.\n+- Replacing or weakening `eng/test-math-tool.ps1` or `.github/workflows/shepherd-task-math-tool.yml`.\n+- Changing the pinned Pester 5.7.1 environment.\n+- Adding unrelated user interfaces, dependencies, broad refactors, or speculative behavior for negative/non-integer input.\n+- Reading, adapting, or copying spike source code.\n*** End Patch\n"
```

</details>

```
Added 2 file(s): /Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/01-1-implement-fibonacci-body.md, /Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/02-2-add-factorial-dispatch-body.md
```


---

<sub>47s</sub>

### `bash`

**Validate persisted issue drafts**

$ set -euo pipefail
LOG='/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103'
'/Users/edburns/.copilot/plugins/shepherd-task/scripts/validate-stage20-drafts.sh' "$LOG/issue-bodies" 2 off
for body in "$LOG"/issue-bodies/*-body.md; do printf '%s: %s lines\n' "$(basename "$body")" "$(awk 'END {print NR}' "$body")"; done

```
01-1-implement-fibonacci-body.md: 60 lines
02-2-add-factorial-dispatch-body.md: 65 lines
<shellId: 3 completed with exit code 0>
```


---

<sub>47s</sub>

### `view`

**view the file at /Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/01-1-implement-fibonacci-body.md.**

/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/01-1-implement-fibonacci-body.md

<details>
<summary>42 lines</summary>

```
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
```

</details>


---

<sub>47s</sub>

### `view`

**view the file at /Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/02-2-add-factorial-dispatch-body.md.**

/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/issue-bodies/02-2-add-factorial-dispatch-body.md

<details>
<summary>47 lines</summary>

```
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
```

</details>


---

<sub>53s</sub>

### Copilot

Both persisted drafts pass the stage validator and preserve physical Markdown structure. I’m beginning the one-shot mutation phase now: each issue will be created, body-verified, linked, and ledgered before the next issue is created.

---

<sub>1m 1s</sub>

### `bash`

**Create and link first issue**

$ set -euo pipefail
REPO='edburns/dd-3069621-darwin-arm64-01'
PARENT=1
LOG='/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103'
LEDGER="$LOG/creation-ledger.json"
RESULT="$LOG/stage-20-result.json"
BODY="$LOG/issue-bodies/01-1-implement-fibonacci-body.md"
TITLE='1. Implement Fibonacci with unit and isolated CLI coverage'
atomic_write() {
  local path="$1" content="$2" tmp
  tmp="${path}.tmp.$$"
  printf '%s\n' "$content" >"$tmp"
  mv "$tmp" "$path"
}
update_ledger_flag() {
  local number="$1" field="$2" value="$3" updated
  updated="$(
    jq \
      --argjson number "$number" \
      --arg field "$field" \
      --argjson value "$value" \
      'map(if .number == $number then .[$field] = $value else . end)' \
      "$LEDGER"
  )" || return 1
  atomic_write "$LEDGER" "$updated"
}
[ ! -e "$LEDGER" ] && [ ! -e "$RESULT" ]
atomic_write "$LEDGER" '[]'
atomic_write "$RESULT" '{"schemaVersion":1,"status":"in_progress","ledgerFile":"creation-ledger.json","operationError":null}'
issue_json="$(gh api "repos/$REPO/issues" -X POST -f title="$TITLE" -F "body=@$BODY")"
entry="$(jq --arg subsection '1. Implement Fibonacci with unit and isolated CLI coverage' --arg bodyFile 'issue-bodies/01-1-implement-fibonacci-body.md' '{implementationSubsection:$subsection,bodyFile:$bodyFile,id:.id,number:.number,title:.title,url:.html_url,body_verified:false,linked:false}' <<<"$issue_json")"
updated="$(jq --argjson entry "$entry" '. + [$entry]' "$LEDGER")"
atomic_write "$LEDGER" "$updated"
number="$(jq -r '.number' <<<"$issue_json")"
id="$(jq -r '.id' <<<"$issue_json")"
verified="$(
  '/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-github-issue-body.sh' \
    "$REPO" \
    "$number" \
    "$BODY" \
    6 \
    5 \
    "$LOG/issue-$number-body-verification-failure.json"
)"
update_ledger_flag "$number" body_verified true
linked=false
for attempt in 1 2 3; do
  if printf '{"sub_issue_id": %s}' "$id" | gh api "repos/$REPO/issues/$PARENT/sub_issues" -X POST --input - >/dev/null; then linked=true; break; fi
  sleep 2
done
[ "$linked" = true ]
update_ledger_flag "$number" linked true
jq '{number,title,html_url,state,assignees}' <<<"$verified"
printf 'created_verified_linked=#%s\n' "$number"

<details>
<summary>9 lines</summary>

```
{
  "number": 2,
  "title": "1. Implement Fibonacci with unit and isolated CLI coverage",
  "html_url": "https://github.com/edburns/dd-3069621-darwin-arm64-01/issues/2",
  "state": "open",
  "assignees": []
}
created_verified_linked=#2
<shellId: 4 completed with exit code 0>
```

</details>


---

<sub>1m 9s</sub>

### `bash`

**Create and link second issue**

$ set -euo pipefail
REPO='edburns/dd-3069621-darwin-arm64-01'
PARENT=1
LOG='/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103'
LEDGER="$LOG/creation-ledger.json"
BODY="$LOG/issue-bodies/02-2-add-factorial-dispatch-body.md"
TITLE='2. Add factorial and operation dispatch'
atomic_write() {
  local path="$1" content="$2" tmp
  tmp="${path}.tmp.$$"
  printf '%s\n' "$content" >"$tmp"
  mv "$tmp" "$path"
}
update_ledger_flag() {
  local number="$1" field="$2" value="$3" updated
  updated="$(
    jq \
      --argjson number "$number" \
      --arg field "$field" \
      --argjson value "$value" \
      'map(if .number == $number then .[$field] = $value else . end)' \
      "$LEDGER"
  )" || return 1
  atomic_write "$LEDGER" "$updated"
}
[ "$(jq length "$LEDGER")" -eq 1 ]
issue_json="$(gh api "repos/$REPO/issues" -X POST -f title="$TITLE" -F "body=@$BODY")"
entry="$(jq --arg subsection '2. Add factorial and operation dispatch' --arg bodyFile 'issue-bodies/02-2-add-factorial-dispatch-body.md' '{implementationSubsection:$subsection,bodyFile:$bodyFile,id:.id,number:.number,title:.title,url:.html_url,body_verified:false,linked:false}' <<<"$issue_json")"
updated="$(jq --argjson entry "$entry" '. + [$entry]' "$LEDGER")"
atomic_write "$LEDGER" "$updated"
number="$(jq -r '.number' <<<"$issue_json")"
id="$(jq -r '.id' <<<"$issue_json")"
verified="$(
  '/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-github-issue-body.sh' \
    "$REPO" \
    "$number" \
    "$BODY" \
    6 \
    5 \
    "$LOG/issue-$number-body-verification-failure.json"
)"
update_ledger_flag "$number" body_verified true
linked=false
for attempt in 1 2 3; do
  if printf '{"sub_issue_id": %s}' "$id" | gh api "repos/$REPO/issues/$PARENT/sub_issues" -X POST --input - >/dev/null; then linked=true; break; fi
  sleep 2
done
[ "$linked" = true ]
update_ledger_flag "$number" linked true
jq '{number,title,html_url,state,assignees}' <<<"$verified"
printf 'created_verified_linked=#%s\n' "$number"

<details>
<summary>9 lines</summary>

```
{
  "number": 3,
  "title": "2. Add factorial and operation dispatch",
  "html_url": "https://github.com/edburns/dd-3069621-darwin-arm64-01/issues/3",
  "state": "open",
  "assignees": []
}
created_verified_linked=#3
<shellId: 5 completed with exit code 0>
```

</details>


---

<sub>1m 11s</sub>

### Copilot

Issues #2 and #3 were created, exact-body verified, left open and unassigned, and linked serially. I’m running the authoritative linkage/order verifier plus the required final body/state checks before marking the stage complete.

---

<sub>1m 17s</sub>

### `bash`

**Verify final stage postconditions**

$ set -euo pipefail
REPO='edburns/dd-3069621-darwin-arm64-01'
PARENT=1
LOG='/Users/edburns/workareas/dd-3069621-darwin-arm64-01-shepherd-control/1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103'
LEDGER="$LOG/creation-ledger.json"
RESULT="$LOG/stage-20-result.json"
atomic_write() {
  local path="$1" content="$2" tmp
  tmp="${path}.tmp.$$"
  printf '%s\n' "$content" >"$tmp"
  mv "$tmp" "$path"
}
children_pages="$(gh api "repos/$REPO/issues/$PARENT/sub_issues" --paginate --slurp)"
children_flat="$(jq 'if length == 0 then [] elif all(.[]; type == "array") then add else . end' <<<"$children_pages")"
printf '%s\n' "$children_flat" | jq -e 'type == "array" and all(.[]; type == "object")' >/dev/null
tmp="$LOG/final-children.json.tmp.$$"
printf '%s\n' "$children_flat" >"$tmp"
mv "$tmp" "$LOG/final-children.json"
'/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-stage20-child-links.sh' \
  "$LOG/pre-creation-children.json" \
  "$LOG/final-children.json" \
  "$LEDGER"
while IFS=$'\t' read -r number body_file; do
  observed="$(
    '/Users/edburns/.copilot/plugins/shepherd-task/scripts/verify-github-issue-body.sh' \
      "$REPO" \
      "$number" \
      "$LOG/$body_file" \
      6 \
      5 \
      "$LOG/issue-$number-final-body-verification-failure.json"
  )"
  jq -e '.state == "open" and (.assignees | length == 0)' <<<"$observed" >/dev/null
  printf 'final_verified=#%s state=open assignees=0\n' "$number"
done < <(jq -r '.[] | [.number,.bodyFile] | @tsv' "$LEDGER")
complete="$(jq '.status = "complete" | .operationError = null' "$RESULT")"
atomic_write "$RESULT" "$complete"
printf '%s\n' '--- ledger ---'
jq . "$LEDGER"
printf '%s\n' '--- result ---'
jq . "$RESULT"

<details>
<summary>42 lines</summary>

```
{
  "baselineCount": 0,
  "ledgerCount": 2,
  "finalCount": 2,
  "newIssueIds": [
    5599896604,
    5599897673
  ]
}
final_verified=#2 state=open assignees=0
final_verified=#3 state=open assignees=0
--- ledger ---
[
  {
    "implementationSubsection": "1. Implement Fibonacci with unit and isolated CLI coverage",
    "bodyFile": "issue-bodies/01-1-implement-fibonacci-body.md",
    "id": 5599896604,
    "number": 2,
    "title": "1. Implement Fibonacci with unit and isolated CLI coverage",
    "url": "https://github.com/edburns/dd-3069621-darwin-arm64-01/issues/2",
    "body_verified": true,
    "linked": true
  },
  {
    "implementationSubsection": "2. Add factorial and operation dispatch",
    "bodyFile": "issue-bodies/02-2-add-factorial-dispatch-body.md",
    "id": 5599897673,
    "number": 3,
    "title": "2. Add factorial and operation dispatch",
    "url": "https://github.com/edburns/dd-3069621-darwin-arm64-01/issues/3",
    "body_verified": true,
    "linked": true
  }
]
--- result ---
{
  "schemaVersion": 1,
  "status": "complete",
  "ledgerFile": "creation-ledger.json",
  "operationError": null
}
<shellId: 6 completed with exit code 0>
```

</details>


---

<sub>1m 21s</sub>

### `rg`

**shepherd-task-25-given-list**

"shepherd-task-25-given-list" (~/.copilot/plugins/shepherd-task)

<details>
<summary>100 matches</summary>

```
[grep content: 90 matches across 69 file(s) under /Users/edburns/.copilot/plugins/shepherd-task]

figure (2 match(es)):
  01- shepherd-task-25-given-list.md:Stage 25 (`shepherd-task-25-given-list`) owns one serial run. It validates the durable campaign
  01- shepherd-task-25-given-list.md:    participant GL as Stage 25: shepherd-task-25-given-list
making-of.md:`shepherd-task:25- given-list-run.json`. The run begins as `running` and is

skills/shepherd-task (3 match(es)):
  20- create-issues-from-plan/SKILL.md:2. Comma-separated child issue numbers for `shepherd-task-25-given-list`.
  50- create-post-mortem/SKILL.md:This skill is designed to be invoked from `shepherd-task-25-given-list.ps1` / `shepherd-task-25-given-list.sh` in a `finally` / `trap EXIT` path so it runs for **all outcomes**, not only after success.
  50- create-post-mortem/SKILL.md:2. If `shepherd-task-25-given-list-run.json` exists, verify its campaign ID,
workshop.md:& 'C:/Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task:25- given-list.ps1' `
workshop.md:/Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task:25- given-list.sh 2\,3 1-math-control-remove-before-merge
workshop.md:By the time you have invoked `shepherd-task:25- given-list` the work proceeds in an entirely human hands-off manner. See `awesome-copilot-01/plugins/shepherd-task/README.md` Sections **Stage 30 readiness boundary** through **Workflow approval helper** and **Post-mortem behavior**.

test/simple-math/20260924 (10 match(es)):
  1406- job-logs.txt:[shepherd] Planned invocation of shepherd-task-25-given-list.sh:
  1406- job-logs.txt:  /Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task-25-given-list.sh <TASK_ISSUE_LIST> 1-math-control-remove-before-merge
  1406- job-logs.txt:[shepherd] Actual invocation of shepherd-task-25-given-list.sh:
  1406- job-logs.txt:  /Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task-25-given-list.sh 2\,3 1-math-control-remove-before-merge
  1347- job-logs.txt:[shepherd] Planned invocation of shepherd-task-25-given-list.sh:
  1347- job-logs.txt:  /Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task-25-given-list.sh <TASK_ISSUE_LIST> 1-math-control-remove-before-merge
  1637- job-logs.txt:[shepherd] Planned invocation of shepherd-task-25-given-list.sh:
  1637- job-logs.txt:  /Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task-25-given-list.sh <TASK_ISSUE_LIST> 1-math-control-remove-before-merge
  1637- job-logs.txt:[shepherd] Actual invocation of shepherd-task-25-given-list.sh:
  1637- job-logs.txt:  /Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task-25-given-list.sh 2\,3 1-math-control-remove-before-merge
README.md:- one or more `shepherd-task:25- given-list` runs.
README.md:| 25         |                                                    | `shepherd-task:25- given-list`                     | Runs selected child issues serially, invokes `shepherd-task` separately for each issue to perform stages 30 and 40, and always invokes stage 50 |

README.md:./plugins/shepherd-task/scripts/shepherd-task (2 match(es)):
  25- given-list.sh \
  25- given-list.ps1 `
README.md:- [Figure 01 — stage 25 given-list batch orchestration](figure:01- shepherd-task-25-given-list.md)
README.md:`shepherd-task:25- given-list-run.json`:
README.md:    ├── shepherd-task:25- given-list-run.json
README.md:| `scripts/shepherd-task:25- given-list.*` | Run stage 25: create a run and dispatch issues serially |
test/simple-math/10-simple-math-fixture-contract.ps1:    "scripts//shepherd-task:25- given-list\.ps1"
scripts/shepherd-task.ps1:    Existing shepherd-task:25- given-list run directory.
scripts/shepherd-task-monitor.ps1:    Run this in a SEPARATE terminal while shepherd-task:25- given-list.ps1 is running.

scripts/shepherd-task (5 match(es)):
  25- given-list.ps1:$runManifestPath = Join-Path $logDirFull 'shepherd-task-25-given-list-run.json'
  25- given-list.ps1:    Write-Host "Logging shepherd-task-25-given-list run to: $logDirFull"
  25- given-list.sh:#   ./shepherd-task-25-given-list.sh <TASK_ISSUES> <CAMPAIGN_METADATA_DIRECTORY>
  25- given-list.sh:RUN_MANIFEST="$LOG_DIR_FULL/shepherd-task-25-given-list-run.json"
  25- given-list.sh:echo "Logging shepherd-task-25-given-list run to: $LOG_DIR_FULL"
test/simple-math/07-driver-encoding-contract.ps1:        'shepherd-task:25- given-list.ps1',
scripts/shepherd-task-monitor.sh:# Run this in a SEPARATE terminal while shepherd-task:25- given-list.sh is running.
test/simple-math/07-driver-encoding-contract.sh:    'shepherd-task:25- given-list.sh'
test/lesson-propagation-default-contract.sh:STAGE25="$SCRIPTS_DIR/shepherd-task:25- given-list.sh"
test/simple-math/run-campaign.ps1:                $manifestPath = Join-Path $_.FullName 'shepherd-task:25- given-list-run.json'
test/simple-math/run-campaign.ps1:        'scripts/shepherd-task:25- given-list.ps1'
test/simple-math/06-stage40-review-contract.sh:STAGE25="$REPO_ROOT/plugins/shepherd-task/scripts/shepherd-task:25- given-list.sh"
test/simple-math/02-create-issues.sh:stage25="$scripts_directory/shepherd-task:25- given-list.sh"
test/simple-math/10-simple-math-fixture-contract.sh:[[ "$(grep -Fc 'scripts/shepherd-task:25- given-list.sh' "$driver")" -eq 1 ]] ||
test/cargotracker-add-change-arrival-deadline-feature/07-driver-encoding-contract.ps1:        'shepherd-task:25- given-list.ps1',
test/lesson-propagation-default-contract.ps1:$stage25 = Join-Path $scriptsDirectory 'shepherd-task:25- given-list.ps1'
test/lesson-propagation-default-contract.ps1:        (Join-Path $harnessDirectory 'shepherd-task:25- given-list.ps1'),
test/lesson-propagation-default-contract.ps1:            Join-Path $harnessDirectory 'shepherd-task:25- given-list.ps1'
test/lesson-propagation-default-contract.ps1:        Join-Path $runDirectories[0].FullName 'shepherd-task:25- given-list-run.json'
test/simple-math/06-stage40-review-contract.ps1:$stage25Path = Join-Path $repoRoot 'plugins/shepherd-task/scripts/shepherd-task:25- given-list.ps1'
test/simple-math/02-create-issues.ps1:    (Join-Path $PSScriptRoot '..' '..' 'scripts' 'shepherd-task:25- given-list.ps1')
test/cargotracker-add-change-arrival-deadline-feature/07-driver-encoding-contract.sh:    'shepherd-task:25- given-list.sh'
test/simple-math/run-campaign.sh:        local manifest="$directory/shepherd-task:25- given-list-run.json"
test/simple-math/run-campaign.sh:    local stage25_script="$shepherd_plugin/scripts/shepherd-task:25- given-list.sh"
test/simple-math/08-psncpps-contract.ps1:$stage25 = Join-Path $scriptsDirectory 'shepherd-task:25- given-list.ps1'
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/06-stage40-review-contract.sh:STAGE25="$REPO_ROOT/plugins/shepherd-task/scripts/shepherd-task:25- given-list.sh"
test/simple-math/08-psncpps-contract.sh:stage25="$scripts_directory/shepherd-task:25- given-list.sh"
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/20260902-run-treatment-control-experiment.ps1:                $manifestPath = Join-Path $_.FullName 'shepherd-task:25- given-list-run.json'

test/cargotracker-add-change-arrival-deadline-feature-treatment-control/20260902-run-treatment-control-experiment.ps1:        -Path (Join-Path $ShepherdPlugin 'scripts/shepherd-task (2 match(es)):
  25- given-list.ps1') `
  25- given-list.ps1') `
test/cargotracker-add-change-arrival-deadline-feature/08-psncpps-contract.ps1:$stage25 = Join-Path $scriptsDirectory 'shepherd-task:25- given-list.ps1'

test/cargotracker-add-change-arrival-deadline-feature-treatment-control/README.md:& "$ShepherdPlugin/scripts/shepherd-task (2 match(es)):
  25- given-list.ps1" `
  25- given-list.ps1" `
test/cargotracker-add-change-arrival-deadline-feature/10-cargotracker-fixture-contract.sh:[[ "$(grep -Fc 'shepherd-task:25- given-list.sh' "$driver")" -eq 1 ]] ||
test/cargotracker-add-change-arrival-deadline-feature/run-campaign.ps1:                $manifestPath = Join-Path $_.FullName 'shepherd-task:25- given-list-run.json'
test/cargotracker-add-change-arrival-deadline-feature/run-campaign.ps1:        'scripts/shepherd-task:25- given-list.ps1'
test/cargotracker-add-change-arrival-deadline-feature/run-campaign.sh:        local manifest="$directory/shepherd-task:25- given-list-run.json"
test/cargotracker-add-change-arrival-deadline-feature/run-campaign.sh:stage25_script="$shepherd_plugin/scripts/shepherd-task:25- given-list.sh"
test/cargotracker-add-change-arrival-deadline-feature/02-create-issues.ps1:    (Join-Path $PSScriptRoot '..' '..' 'scripts' 'shepherd-task:25- given-list.ps1')
test/simple-math-treatment-control/06-stage40-review-contract.sh:STAGE25="$REPO_ROOT/plugins/shepherd-task/scripts/shepherd-task:25- given-list.sh"
test/cargotracker-add-change-arrival-deadline-feature/08-psncpps-contract.sh:stage25="$scripts_directory/shepherd-task:25- given-list.sh"
test/simple-math-treatment-control/20260831-run-treatment-control-experiment.ps1:                $manifestPath = Join-Path $_.FullName 'shepherd-task:25- given-list-run.json'

test/simple-math-treatment-control/20260831-run-treatment-control-experiment.ps1:        -Path (Join-Path $ShepherdPlugin 'scripts/shepherd-task (2 match(es)):
  25- given-list.ps1') `
  25- given-list.ps1') `
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/02-create-issues.ps1:    (Join-Path $PSScriptRoot '..' '..' 'scripts' 'shepherd-task:25- given-list.ps1')
test/simple-math-treatment-control/02-create-issues.ps1:    (Join-Path $PSScriptRoot '..' '..' 'scripts' 'shepherd-task:25- given-list.ps1')
test/cargotracker-add-change-arrival-deadline-feature/06-stage40-review-contract.sh:STAGE25="$REPO_ROOT/plugins/shepherd-task/scripts/shepherd-task:25- given-list.sh"

test/simple-math-treatment-control/README.md:& "$ShepherdPlugin/scripts/shepherd-task (2 match(es)):
  25- given-list.ps1" `
  25- given-list.ps1" `
test/simple-math-treatment-control/06-stage40-review-contract.ps1:$stage25Path = Join-Path $repoRoot 'plugins/shepherd-task/scripts/shepherd-task:25- given-list.ps1'
test/simple-math-treatment-control/08-psncpps-contract.ps1:$stage25 = Join-Path $scriptsDirectory 'shepherd-task:25- given-list.ps1'
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/06-stage40-review-contract.ps1:$stage25Path = Join-Path $repoRoot 'plugins/shepherd-task/scripts/shepherd-task:25- given-list.ps1'
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/202609023-1638Z-run-treatment-control-experiment-resumeable.ps1:            'shepherd-task:25- given-list-run.json'
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/202609023-1638Z-run-treatment-control-experiment-resumeable.ps1:        'shepherd-task:25- given-list-run.json'
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/202609023-1638Z-run-treatment-control-experiment-resumeable.ps1:                'scripts/shepherd-task:25- given-list.ps1') `
test/cargotracker-add-change-arrival-deadline-feature-treatment-control/08-psncpps-contract.ps1:$stage25 = Join-Path $scriptsDirectory 'shepherd-task:25- given-list.ps1'
test/cargotracker-add-change-arrival-deadline-feature/06-stage40-review-contract.ps1:$stage25Path = Join-Path $repoRoot 'plugins/shepherd-task/scripts/shepherd-task:25- given-list.ps1'
test/cargotracker-add-change-arrival-deadline-feature/10-cargotracker-fixture-contract.ps1:    "scripts//shepherd-task:25- given-list\.ps1"
test/cargotracker-add-change-arrival-deadline-feature/02-create-issues.sh:    "$scripts_directory/shepherd-task:25- given-list.sh" \
test/version-lineup-contract.sh:grep -Fq 'stageOutcomeProtocolVersion:' "$plugin_root/scripts/shepherd-task:25- given-list.sh"
```

</details>


---

<sub>1m 21s</sub>

### `sql`

**Complete stage twenty todos**

<details>
<summary>Arguments</summary>

```json
{
  "description": "Complete stage twenty todos",
  "query": "UPDATE todos SET status='done' WHERE id IN ('validate-stage20','draft-stage20','create-stage20','verify-stage20'); SELECT id,status FROM todos ORDER BY created_at;"
}
```

</details>

<details>
<summary>11 lines</summary>

```
Executed 2 statement(s):

1. UPDATE
   4 row(s) updated.

2. SELECT
   4 row(s) returned:
   
   | id | status |
   | --- | --- |
   | validate-stage20 | done |
   | draft-stage20 | done |
   | create-stage20 | done |
   | verify-stage20 | done |
```

</details>


---

<sub>1m 28s</sub>

### `glob`

**shepherd-task*25*given-list.sh**

"shepherd-task*25*given-list.sh" in ~/.copilot/plugins/shepherd-task/scripts

```
/Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task-25-given-list.sh
```


---

<sub>1m 29s</sub>

### Copilot

Created and verified two ordered child issues under #1. Both are open, unassigned, linked exactly once in plan order, and created **without an issue type**.

| Implementation subsection | Issue | Title | URL |
|---|---:|---|---|
| 1 | #2 | Implement Fibonacci with unit and isolated CLI coverage | https://github.com/edburns/dd-3069621-darwin-arm64-01/issues/2 |
| 2 | #3 | Add factorial and operation dispatch | https://github.com/edburns/dd-3069621-darwin-arm64-01/issues/3 |

**Ordered child list:** `2,3`

**Suggested stage 25 invocation:**
```bash
/Users/edburns/.copilot/plugins/shepherd-task/scripts/shepherd-task-25-given-list.sh 2,3 1-math-control-remove-before-merge
```

The durable stage result is `complete` in `1-math-control-remove-before-merge/prompts/shepherd-task-20-20260927-0103/stage-20-result.json`.

---

<sub>Generated by [GitHub Copilot CLI](https://github.com/features/copilot/cli)</sub>
