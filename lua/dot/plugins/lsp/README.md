# Neovim LSP Configuration

## Overview
This is a modular LSP configuration that replaces the previous LSP Zero setup with a more flexible and maintainable architecture.

## Structure
```
lua/dot/plugins/lsp/
├── init.lua           # Entry point - returns lspconfig
├── lspconfig.lua      # Main LSP configuration (includes all others as dependencies)
├── schemastore.lua    # JSON/YAML schema support
├── lsp-utils.lua      # Trouble.nvim for diagnostics navigation
├── lsp-info.lua       # Fidget.nvim for LSP progress indicators
└── README.md          # This file
```

The architecture follows a dependency-based approach where:
- `init.lua` simply returns the main lspconfig module
- `lspconfig.lua` is the primary plugin that declares all other LSP plugins as dependencies
- This ensures proper loading order and keeps related functionality together

## Features

### Language Servers (19 configured)
- **Lua** (lua_ls) - With Neovim API support
- **Python** (pyright) - With type checking
- **JavaScript/TypeScript** (tsserver, eslint) - With inlay hints
- **C/C++** (clangd) - With clang-tidy integration
- **Rust** (via rustfmt formatter)
- **Go** (via formatters)
- **Java** (jdtls)
- **Haskell** (hls)
- **Clojure** (clojure_lsp)
- **Nix** (nixd) - With nixpkgs-fmt
- **Docker** (dockerls, docker_compose_language_service)
- **Web** (html, cssls, jsonls, yamlls)
- **Shell** (bashls)
- **Others** (marksman, vimls, arduino_language_server, beancount, jqls, intelephense)

### Key Mappings
- `gR` - Show LSP references
- `gD` - Go to declaration
- `gd` - Show LSP definitions
- `gi` - Show LSP implementations
- `gt` - Show LSP type definitions
- `<leader>ca` - Code actions
- `<leader>rn` - Smart rename
- `<leader>D` - Buffer diagnostics
- `<leader>d` - Line diagnostics
- `[d` / `]d` - Navigate diagnostics
- `K` - Hover documentation
- `<leader>k` - Signature help
- `<leader>ih` - Toggle inlay hints (when supported)
- `<leader>rs` - Restart LSP

### Formatting (via conform.nvim)
- Auto-format on save with LSP fallback
- Multiple formatters per filetype
- Timeout: 2 seconds
- Commands:
  - `:FormatDisable` - Disable auto-format globally
  - `:FormatDisable!` - Disable auto-format for current buffer
  - `:FormatEnable` - Re-enable auto-format
  - `<leader>mp` - Manual format

### Linting (via nvim-lint)
- Automatic linting on file events
- Multiple linters configured
- `<leader>l` - Manual lint trigger
- `<leader>li` - Show running linters

### Diagnostics
- Custom signs: Error (  ), Warning (  ), Hint ( 󰠠 ), Info (  )
- Virtual text with prefix ●
- Floating windows with rounded borders
- Severity sorting enabled

## LSP Server Management
All LSP servers, formatters, and linters are managed through Nix on NixOS:
- LSP servers: installed via Nix packages
- Formatters: prettier, stylua, black, isort, shfmt, nixpkgs-fmt, clang-format (via Nix)
- Linters: pylint, eslint_d, shellcheck, hadolint, markdownlint, jsonlint, yamllint (via Nix)
- Debug adapters: debugpy, codelldb (via Nix)

## NixOS Installation

Install LSP servers and tools via nix:

```nix
# In your configuration.nix or shell.nix
environment.systemPackages = with pkgs; [
  # Language servers
  lua-language-server
  nodePackages.typescript-language-server
  pyright
  nil # Nix language server
  clangd
  rust-analyzer
  gopls

  # Formatters
  stylua
  black
  nixpkgs-fmt
  prettier

  # Linters
  pylint
  shellcheck
];
```

Or use a development shell:
```bash
nix-shell -p lua-language-server stylua clangd
```

## Troubleshooting

### Check LSP Status
```vim
:LspInfo
:ConformInfo
```

### View Logs
Check LSP logs for errors:
```vim
:lua vim.cmd('e ' .. vim.lsp.get_log_path())
```

## Migration Notes
- Removed: LSP Zero dependency
- Removed: Mason package manager (incompatible with NixOS)
- Updated: Uses new `vim.lsp.config()` and `vim.lsp.enable()` API (Neovim 0.11+)
- Updated: Fixed deprecated `vim.lsp.get_active_clients()` → `vim.lsp.get_clients()`
- Updated: `tsserver` → `ts_ls` for TypeScript/JavaScript
- Updated: All LSP servers use system-installed binaries from Nix
- Added: Direct nvim-lspconfig setup with enhanced features
- Added: SchemaStore for JSON/YAML validation
- Added: Fidget for LSP progress
- Added: Trouble for better diagnostics navigation
- Enhanced: Better server-specific configurations