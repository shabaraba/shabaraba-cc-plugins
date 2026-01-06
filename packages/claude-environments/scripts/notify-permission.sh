#!/bin/bash
# Sound notification when Claude requests permission
# Triggered on Notification event with permission_prompt matcher

# Read hook input from stdin
input=$(cat)

# Verify this is a permission_prompt notification
notification_type=$(echo "$input" | jq -r '.notification_type // ""' 2>/dev/null)
if [ "$notification_type" != "permission_prompt" ]; then
  exit 0
fi

# Play notification sound
# macOS: Use afplay with system sound
# Linux: Use paplay or aplay
if command -v afplay >/dev/null 2>&1; then
  # macOS - Play system sound "Funk" (notification sound)
  afplay /System/Library/Sounds/Funk.aiff 2>/dev/null &
elif command -v paplay >/dev/null 2>&1; then
  # Linux (PulseAudio) - Play system dialog sound
  paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga 2>/dev/null &
elif command -v aplay >/dev/null 2>&1; then
  # Linux (ALSA) - Play system dialog sound
  aplay /usr/share/sounds/freedesktop/stereo/dialog-information.wav 2>/dev/null &
fi

# Exit successfully
exit 0
