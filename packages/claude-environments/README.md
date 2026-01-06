# claude-environments

🔔 Environment enhancements for vibe coding with Claude Code

Audio notifications plugin that plays sounds when Claude finishes responding or waits for your input, making your coding session more interactive and aware.

## Features

### 🎵 Audio Notifications

- **Response Complete** 🎉
  - Plays when Claude finishes responding (Stop event)
  - Plays when subagent completes (SubagentStop event)
  - Sound: "Glass" (macOS) / "complete" (Linux)

- **Waiting for Input** ⏰
  - Plays when Claude is idle for 60+ seconds (idle_prompt)
  - Sound: "Tink" (macOS) / "message" (Linux)

- **Permission Request** 🔐
  - Plays when Claude requests permission
  - Sound: "Funk" (macOS) / "dialog-information" (Linux)

## Installation

### Option 1: Copy to Project (Recommended for testing)

```bash
# Copy plugin to your project
cp -r packages/claude-environments /path/to/your/project/.claude-plugin/

# Or create a symlink for development
ln -s $(pwd)/packages/claude-environments /path/to/your/project/.claude-plugin/claude-environments
```

### Option 2: Install Globally

```bash
# Copy to Claude Code plugins directory
cp -r packages/claude-environments ~/.claude/plugins/

# Or create a symlink
ln -s $(pwd)/packages/claude-environments ~/.claude/plugins/claude-environments
```

### Option 3: Load via SDK

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Hello",
  options: {
    plugins: [
      { type: "local", path: "./packages/claude-environments" }
    ]
  }
})) {
  // Plugin hooks are now active
}
```

## Configuration

The plugin works out of the box with no configuration needed. However, you can customize the sounds by editing the scripts in `scripts/`:

- `notify-complete.sh` - Response completion sound
- `notify-waiting.sh` - Waiting for input sound
- `notify-permission.sh` - Permission request sound

### Custom Sound Files

Edit the scripts to use your own sound files:

```bash
# In notify-complete.sh
afplay /path/to/your/custom-sound.aiff
```

### Disable Specific Notifications

Remove or comment out entries in `hooks/hooks.json` to disable specific notifications:

```json
{
  "Stop": [],  // Disabled
  "Notification": [
    {
      "matcher": "idle_prompt",
      "hooks": [...]  // Still enabled
    }
  ]
}
```

## Platform Support

### macOS
Uses `afplay` with system sounds:
- ✅ Works out of the box
- 🎵 System sounds: Glass, Tink, Funk

### Linux
Uses `paplay` (PulseAudio) or `aplay` (ALSA):
- ✅ Requires PulseAudio or ALSA
- 🎵 System sounds from `/usr/share/sounds/freedesktop/stereo/`

### Windows (WSL)
- ⚠️ Requires WSL sound configuration
- May need `wsl-audio` or similar tools

## How It Works

The plugin uses Claude Code's [hooks system](https://code.claude.com/docs/en/hooks) to listen for lifecycle events:

1. **Stop/SubagentStop** - Triggered when Claude finishes responding
2. **Notification (idle_prompt)** - Triggered when waiting 60+ seconds for input
3. **Notification (permission_prompt)** - Triggered when permission is needed

Each hook executes a shell script that plays a system sound using platform-specific audio tools.

## Troubleshooting

### No sound playing

1. **Check audio tools availability**:
   ```bash
   # macOS
   which afplay

   # Linux
   which paplay
   which aplay
   ```

2. **Verify plugin is loaded**:
   - Check Claude Code logs with `--debug` flag
   - Look for "Loaded plugins" in init message

3. **Test scripts manually**:
   ```bash
   echo '{"stop_hook_active": false}' | ./scripts/notify-complete.sh
   ```

### Scripts not executing

- Ensure scripts have execute permissions: `chmod +x scripts/*.sh`
- Check `CLAUDE_PLUGIN_ROOT` environment variable is set
- Verify `jq` is installed: `brew install jq` (macOS) or `apt install jq` (Linux)

### Permission errors

- Scripts are sandboxed and can only access files your user can access
- Check file permissions in the plugin directory

## Development

### Testing Hooks

Enable debug mode to see hook execution:

```bash
claude --debug
```

### Hook Input Schema

Each hook receives JSON input via stdin:

**Stop/SubagentStop:**
```json
{
  "session_id": "abc123",
  "hook_event_name": "Stop",
  "stop_hook_active": false
}
```

**Notification:**
```json
{
  "hook_event_name": "Notification",
  "notification_type": "idle_prompt",
  "message": "Claude is waiting for input"
}
```

## Contributing

Contributions welcome! Ideas for enhancements:

- [ ] Visual notifications (desktop notifications)
- [ ] Customizable sound themes
- [ ] Volume control
- [ ] Text-to-speech announcements
- [ ] Integration with notification centers

## Related Projects

Part of [shabaraba-cc-plugins](https://github.com/shabaraba/shabaraba-cc-plugins) monorepo:
- [claude-org](../claude-org) - Multi-agent development workflows
- [dev-org](../dev-org) - AI-driven refactoring toolkit

## License

MIT

## References

- [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks)
- [Claude Code Plugin Development](https://code.claude.com/docs/en/plugins)
- [Agent SDK Plugins Guide](https://platform.claude.com/docs/en/agent-sdk/plugins)
