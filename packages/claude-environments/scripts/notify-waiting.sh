#!/bin/bash
# Sound notification when Claude is waiting for user input
# Triggered on Notification event with idle_prompt matcher

# Read hook input from stdin
input=$(cat)

# Verify this is an idle_prompt notification
notification_type=$(echo "$input" | jq -r '.notification_type // ""' 2>/dev/null)
if [ "$notification_type" != "idle_prompt" ]; then
  exit 0
fi

# Play notification sound
# macOS: Use afplay with system sound
# Linux: Use paplay or aplay
if command -v afplay >/dev/null 2>&1; then
  # macOS - Play system sound "Tink" (attention sound)
  afplay /System/Library/Sounds/Tink.aiff 2>/dev/null &
elif command -v paplay >/dev/null 2>&1; then
  # Linux (PulseAudio) - Play system message sound
  paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null &
elif command -v aplay >/dev/null 2>&1; then
  # Linux (ALSA) - Play system message sound
  aplay /usr/share/sounds/freedesktop/stereo/message.wav 2>/dev/null &
fi

# Exit successfully
exit 0
