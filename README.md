# Claude Code Plugins

Monorepo for custom Claude Code plugins.

## Plugins

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
│   └── dev-org/          # Development organization plugin
├── package.json          # Workspace configuration
└── README.md
```

## Installation

### Local Development

```bash
# Install dependencies
npm install

# Use plugin in Claude Code
cc --plugin-dir ./packages/dev-org
```

### Project Installation

Copy the plugin to your project's `.claude-plugin` directory:

```bash
cp -r packages/dev-org /path/to/your/project/.claude-plugin/
```

## Future Plugins

- Analytics toolkit
- Database migration assistant
- API documentation generator

## License

MIT
