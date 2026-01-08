# Claude Code Plugins

Monorepo for custom Claude Code plugins.

## Plugins

### claude-environments

🔔 Environment enhancements for vibe coding with Claude Code.

**Status**: ✅ Ready to Use

**Features**:
- 🎵 Audio notifications on response completion
- ⏰ Sound alerts when waiting for user input
- 🔐 Permission request notifications
- 🖥️ Cross-platform support (macOS, Linux)

See [packages/claude-environments/README.md](packages/claude-environments/README.md) for details.

### claude-org

⭐ Star-topology AI organization with async sub-agents, worktree isolation, and automated workflows.

**Status**: ✅ Production Ready

**Features**:
- 4-phase development workflow (design→develop→review→QA)
- 7 specialized agents with async task management
- Daily logs and context handoff
- 6 commands, 5 skills for orchestration

See [packages/claude-org/README.md](packages/claude-org/README.md) for details.

### dev-org (Development Organization)

Comprehensive development workflow plugin featuring AI-driven refactoring, code analysis, and quality assurance.

**Status**: 🚧 In Development

**Features**:
- `/refactor`: Multi-phase AI-driven refactoring workflow
- Parallel code analysis (SOLID, complexity, security, etc.)
- Automated test generation and review
- 7 language support (TS/JS/Java/PHP/Lua/Go/Python)

See [packages/dev-org/README.md](packages/dev-org/README.md) for details.

## Structure

```
claude-code-plugins/
├── packages/
│   ├── claude-environments/  # Audio notifications & UX enhancements
│   ├── claude-org/           # Multi-agent orchestration system
│   ├── dev-org/              # Development workflow & refactoring
│   └── parallel-worktree/    # Git worktree management
├── package.json              # Workspace configuration
└── README.md
```

## Installation

### Local Development

```bash
# Install dependencies (if needed)
npm install

# Use a specific plugin in Claude Code
cc --plugin-dir ./packages/claude-environments

# Or load via Agent SDK
# See individual plugin READMEs for SDK usage examples
```

### Project Installation

Copy a plugin to your project's `.claude-plugin` directory:

```bash
# Copy claude-environments plugin
cp -r packages/claude-environments /path/to/your/project/.claude-plugin/

# Or create a symlink for development
ln -s $(pwd)/packages/claude-environments /path/to/your/project/.claude-plugin/
```

### Global Installation

Install plugins globally for use across all projects:

```bash
# Copy to Claude Code plugins directory
cp -r packages/claude-environments ~/.claude/plugins/

# Or symlink for active development
ln -s $(pwd)/packages/claude-environments ~/.claude/plugins/
```

## Future Plugins

- Analytics toolkit
- Database migration assistant
- API documentation generator

## License

MIT
