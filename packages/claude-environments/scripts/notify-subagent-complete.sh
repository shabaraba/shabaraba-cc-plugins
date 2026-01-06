#!/bin/bash
# Sound notification when subagent finishes
# Triggered on SubagentStop event

# Read hook input from stdin
input=$(cat)

# Prevent infinite loops
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$stop_hook_active" = "true" ]; then
  exit 0
fi

# Play notification sound
# macOS: Use afplay with system sound
# Linux: Use paplay or aplay
if command -v afplay >/dev/null 2>&1; then
  # macOS - Play system sound "Ping" (subagent completion sound)
  afplay /System/Library/Sounds/Ping.aiff 2>/dev/null &
elif command -v paplay >/dev/null 2>&1; then
  # Linux (PulseAudio) - Play system completion sound
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
elif command -v aplay >/dev/null 2>&1; then
  # Linux (ALSA) - Play system completion sound
  aplay /usr/share/sounds/freedesktop/stereo/complete.wav 2>/dev/null &
fi

# Exit successfully
exit 0
