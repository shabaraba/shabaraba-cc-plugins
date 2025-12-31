---
name: content
description: Create marketing content (ASO, SNS, blog)
argument-hint: "<content-type> <topic>"
---

# Content Command

Start an async marketing content creation task.

## Input

<request>$ARGUMENTS</request>

## Content Types

| Type | Description | Output |
|------|-------------|--------|
| `aso` | App Store optimization | Description, keywords, screenshots |
| `sns` | Social media posts | X, Threads posts |
| `blog` | Blog article | Full article with SEO |
| `release` | Release notes | What's New text |

## Execution

### Step 1: Parse Request

Extract:
- Content type: `aso`, `sns`, `blog`, or `release`
- Topic or feature reference

If type not specified, ask CEO:
```
What type of content?
1. ASO (App Store)
2. SNS (X/Threads)
3. Blog article
4. Release notes
```

### Step 2: Initialize Work Environment

```bash
# Branch name
BRANCH="content/<type>-<topic-slug>"

# Create worktree
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init
WORKTREE_PATH=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh create-worktree "$BRANCH")

# Initialize context
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init-context "$BRANCH"

# Generate task ID
TASK_ID="task-$(date +%s)-$RANDOM"
```

### Step 3: Launch Marketing Content Agent

```
Task:
  description: "Content: <type> for <topic>"
  subagent_type: marketing-content
  run_in_background: true
  prompt: |
    # Marketing Content Task

    ## Environment
    - Task ID: $TASK_ID
    - Branch: $BRANCH
    - Worktree: $WORKTREE_PATH

    ## Request
    - Type: <content-type>
    - Topic: <topic>

    ## Context
    <related PRD or feature description if available>

    ## Instructions
    1. cd to worktree
    2. Research competitors if needed (WebSearch)
    3. Update daily log
    4. Create content following brand guidelines
    5. Optimize for platform requirements
    6. Commit content
    7. Create handoff file
    8. Return completion JSON

    ## Output Location
    docs/marketing/<type>-<topic>.md
```

### Step 4: Record and Report

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh add-task \
  "$TASK_ID" "$AGENT_ID" "marketing-content" "$BRANCH" "<type> content for <topic>"
```

```markdown
## Content Task Started

| Item | Value |
|------|-------|
| Task ID | $TASK_ID |
| Branch | $BRANCH |
| Agent | marketing-content |
| Type | <content-type> |
| Topic | <topic> |
| Status | Running |

The marketing agent is creating content.

Use `/claude-org:status` to check progress.
```

## Examples

```bash
# ASO update
/claude-org:content aso "v2.0 アップデート"

# SNS announcement
/claude-org:content sns "Live Activities リリース"

# Blog article
/claude-org:content blog "ウィジェット活用術"

# Release notes
/claude-org:content release "v2.1.0"
```
