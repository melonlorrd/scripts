# AGENTS.md

## Purpose
Maintain a minimal Neovim configuration that is Vim-native, modular, and stable over time. The system should support modern development features (LSP, formatting, diagnostics) without turning Neovim into an IDE.

## Core Principles
- Never override default Neovim keybindings.
- Prefer native Vim workflows over abstraction layers.
- Add features only as modular, optional layers.
- Keep configuration minimal and easy to reason about.
- Avoid UI-heavy or opinionated editor setups.

## Package Management
- Use **`vim.pack` (Neovim 0.12+)** as the native package manager.
- Do not introduce external package managers (e.g. lazy.nvim, packer).
- Keep plugin installation declarative and minimal.

## Language Support Model
- Language support is modular and isolated.
- Each language defines its own:
  - LSP server config
  - formatter
  - optional linters
- No global language assumptions.

Adding a language must not require modifying unrelated configs.

## LSP System
- LSP is the core intelligence layer.
- Must support per-language configuration.
- Required capabilities:
  - go to definition
  - go to type definition
  - references
  - rename
  - hover
  - code actions

## Formatting
- Formatting is per-language.
- Format-on-save preferred.
- Use external tools via LSP or direct formatter hooks.
- No global formatter logic.

## Diagnostics
- Unified LSP diagnostics system.
- Minimal UI noise.
- Navigation via standard quickfix and LSP methods.

## Completion
- LSP-based completion only.
- Avoid additional completion engines unless strictly required.
- Completion must not interfere with default insert-mode behavior.

## Navigation
- Vim-native movement is primary.
- LSP enhances navigation but does not replace it.

## Keybinding Policy
- Do not modify default Neovim bindings.
- Any new mappings must:
  - map to LSP or clear Vim analogs
  - remain consistent across all languages
- Avoid per-language keybinding divergence.

## Plugin Policy
Allowed:
- LSP configuration
- Treesitter
- Formatting integration
- Minimal fuzzy finder (optional)

Disallowed:
- IDE-like UI frameworks
- heavy statusline/dashboard systems
- language-specific plugin ecosystems tied globally

## UI / Icons Policy
- **Nerd Fonts are NOT used.**
- All plugin configurations must:
  - disable icon usage where optional
  - disable glyph-based UI features when available
- Prefer plain text UI over icon-based decoration.

## Architecture
Configuration must be modular:

- `lua/lsp/` → language servers
- `lua/format/` → formatters
- `lua/diagnostics/` → diagnostics handling
- `lua/keymaps/` → global mappings only
- `lua/languages/` → language registry layer
- `lua/plugins/` → plugin definitions (vim.pack based)

## Extension Rule
To add a new language:
1. Add LSP config in `lua/lsp/<lang>.lua`
2. Add formatter in `lua/format/<lang>.lua`
3. Register language module if required
4. Ensure no global changes are needed

## Goal
A stable Vim-first editor with:
- clean separation of concerns
- LSP-driven intelligence layer
- modular language support
- zero dependency on IDE-style assumptions

