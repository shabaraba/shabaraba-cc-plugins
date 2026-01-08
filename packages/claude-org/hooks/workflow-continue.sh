#!/bin/bash
# Workflow Auto-Continue Hook
# This hook checks for active workflows and instructs Claude to continue them

WORK_DIR=".claude-work"
WORKFLOW_FILE="$WORK_DIR/workflow.json"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Only run if workflow file exists
if [ ! -f "$WORKFLOW_FILE" ]; then
  exit 0
fi

# Get workflow status
workflow_status=$(jq -r '.status // "none"' "$WORKFLOW_FILE" 2>/dev/null)

# Only proceed if workflow is running
if [ "$workflow_status" != "running" ]; then
  exit 0
fi

# Get current phase info
current_phase=$(jq -r '.current_phase // 0' "$WORKFLOW_FILE")
phase_status=$(jq -r ".phases.\"$current_phase\".status // \"none\"" "$WORKFLOW_FILE")
phase_agent_id=$(jq -r ".phases.\"$current_phase\".agent_task_id // \"\"" "$WORKFLOW_FILE")
phase_name=$(jq -r ".phases.\"$current_phase\".name // \"unknown\"" "$WORKFLOW_FILE")
task_id=$(jq -r '.task_id // ""' "$WORKFLOW_FILE")
branch=$(jq -r '.branch // ""' "$WORKFLOW_FILE")

# If current phase is running and has an agent task ID, check completion
if [ "$phase_status" = "running" ] && [ -n "$phase_agent_id" ]; then
  cat << EOF

<workflow-auto-continue>
## 🔄 Active Workflow Detected

**Task**: $task_id
**Branch**: $branch
**Current Phase**: $current_phase ($phase_name)
**Status**: Running
**Agent Task ID**: $phase_agent_id

### Auto-Continue Protocol

1. **Check phase completion**: Use \`TaskOutput\` with \`block=false\` to check if agent \`$phase_agent_id\` has completed
2. **If completed**:
   - Update workflow: \`bash ${SCRIPT_DIR}/scripts/work-manager.sh complete-phase $current_phase\`
   - Start next phase (if not phase 4)
3. **If still running**: Report status and continue with user's request
4. **If phase 4 complete**: Complete workflow and report final results

**IMPORTANT**: Check completion first, then respond to user's message.
</workflow-auto-continue>

EOF
fi

# If phase is pending (next phase ready to start)
if [ "$phase_status" = "pending" ]; then
  prev_phase=$((current_phase - 1))
  if [ $prev_phase -gt 0 ]; then
    prev_status=$(jq -r ".phases.\"$prev_phase\".status // \"none\"" "$WORKFLOW_FILE")
    if [ "$prev_status" = "complete" ]; then
      cat << EOF

<workflow-auto-continue>
## ⏭️ Ready for Next Phase

**Task**: $task_id
**Branch**: $branch
**Ready Phase**: $current_phase ($phase_name)

Previous phase completed. Start Phase $current_phase now using the orchestrator skill protocol.
</workflow-auto-continue>

EOF
    fi
  fi
fi
