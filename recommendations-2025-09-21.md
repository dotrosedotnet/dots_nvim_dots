# Neovim Configuration - Code Quality Analysis & Recommendations
**Date: 2025-09-21**
**Neovim Version: v0.12.0-nightly+f91d416**

## Executive Summary
Analysis of the Neovim configuration revealed significant opportunities for improving code reuse, reducing duplication, and following DRY (Don't Repeat Yourself) principles. While the configuration is functional and includes some good practices (like the `simple_servers` table pattern), there are several areas where abstraction and modularization would greatly improve maintainability.

## Major Code Quality Issues

### 1. Repetitive LSP Server Configurations
**Issue:** Each LSP server configuration repeats the same pattern with `vim.lsp.config()` and `vim.lsp.enable()` calls. While simple servers are handled with a table-driven approach, complex servers (lua_ls, pyright, clangd, nixd, jsonls, ts_ls, yamlls) are configured individually with significant duplication.

**Current Pattern:**
```lua
vim.lsp.config("server_name", {
    cmd = { ... },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = { ... }
})
vim.lsp.enable("server_name")
```

**Recommendation:** Extract all server configurations into a unified data structure that can be iterated over, similar to how `simple_servers` is handled.

### 2. Duplicated Language-to-Tool Mappings
**Issue:** Language definitions are duplicated across `formatting.lua` and `linting.lua`:
- JavaScript appears in both files with different tools (prettier for formatting, eslint_d for linting)
- Python appears with black+isort for formatting, pylint for linting
- Shell languages (sh, bash, zsh) are repeated in both configurations

**Files Affected:**
- `/lua/dot/plugins/formatting.lua` (lines 9-40)
- `/lua/dot/plugins/linting.lua` (lines 8-21)

**Recommendation:** Create a unified language configuration module that defines all tools for each language in one place.

### 3. Scattered Constants and Magic Values
**Issue:** Multiple types of values are hardcoded throughout the configuration:
- Event triggers: `{ "BufReadPre", "BufNewFile" }` appears in 6+ files
- Hardcoded paths: `/etc/profiles/per-user/dot/bin/` (platform-specific, non-portable)
- Timeout values: 2000ms in formatting, 120s in git operations
- UI elements: Border styles, diagnostic signs defined inline

**Recommendation:** Create a centralized constants module for shared values.

### 4. Inconsistent Keymap Definition Patterns
**Issue:** Keymap definitions use different patterns across files:
- Some files use `local keymap = vim.keymap` (7 occurrences)
- Others use `vim.keymap.set` directly
- Keymaps are scattered across plugin configurations instead of being centralized

**Files with `local keymap = vim.keymap`:**
- substitute.lua, lspconfig.lua, telescope.lua, todo-comments.lua, auto-session.lua, nvim-tree.lua, core/keymaps.lua

**Recommendation:** Standardize keymap patterns and consider centralizing related keymaps.

### 5. Missing Error Handling
**Issue:** Only 3 files use `pcall` for error protection (bufferline.lua, minibase16-watcher.lua.bak, which-key.lua). Most plugin configurations could fail and crash the startup process.

**Recommendation:** Implement a safe setup utility function that wraps plugin configurations in error handling.

## Proposed Solutions

### Solution 1: Unified Language Configuration
Create `lua/dot/config/languages.lua`:
```lua
return {
  javascript = {
    formatters = { "prettier" },
    linters = { "eslint_d" },
    lsp = "ts_ls",
    filetypes = { "javascript", "javascriptreact" }
  },
  python = {
    formatters = { "isort", "black" },
    linters = { "pylint" },
    lsp = "pyright",
    filetypes = { "python" }
  },
  -- ... other languages
}
```

### Solution 2: Constants Module
Create `lua/dot/config/constants.lua`:
```lua
return {
  events = {
    LAZY_FILE = { "BufReadPre", "BufNewFile" },
    LAZY_INSERT = "InsertEnter",
  },
  paths = {
    LSP_BIN = "/etc/profiles/per-user/dot/bin/",
  },
  timeouts = {
    FORMAT_MS = 2000,
    LSP_STARTUP = 120,
  },
  ui = {
    BORDER = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    DIAGNOSTIC_SIGNS = {
      Error = " ",
      Warn = " ",
      Hint = "󰠠 ",
      Info = " "
    },
  }
}
```

### Solution 3: LSP Server Configuration Module
Create `lua/dot/config/lsp_servers.lua`:
```lua
return {
  -- Complex servers with settings
  lua_ls = {
    cmd = { "/etc/profiles/per-user/dot/bin/lua-language-server" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        -- ... rest of settings
      }
    }
  },
  pyright = {
    cmd = { "pyright" },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          -- ... rest of settings
        }
      }
    }
  },
  -- Simple servers
  clojure_lsp = { cmd = { "clojure-lsp" } },
  marksman = { cmd = { "marksman" } },
  -- ... all other servers
}
```

### Solution 4: Safe Setup Utility
Create `lua/dot/utils/setup.lua`:
```lua
local M = {}

function M.safe_setup(module_name, config)
  local ok, module = pcall(require, module_name)
  if not ok then
    vim.notify("Failed to load " .. module_name, vim.log.levels.ERROR)
    return nil
  end

  if config and module.setup then
    local setup_ok = pcall(module.setup, config)
    if not setup_ok then
      vim.notify("Failed to setup " .. module_name, vim.log.levels.ERROR)
      return nil
    end
  end

  return module
end

return M
```

## Benefits of Proposed Changes

1. **Single Source of Truth**: Each piece of configuration data is defined in exactly one place
2. **Easier Maintenance**: Changing a formatter or linter for a language requires editing only one file
3. **Better Testability**: Extracted configuration modules can be validated and tested independently
4. **Reduced Duplication**: No more copy-pasting of event triggers, paths, or language lists
5. **Improved Readability**: Plugin files become cleaner and focus only on plugin-specific logic
6. **Enhanced Portability**: System-specific paths and configurations are centralized
7. **Type Safety Potential**: Configuration modules could include type annotations for validation

## Implementation Priority

Based on impact and ease of implementation:

1. **High Priority** (Easy wins with big impact):
   - Extract constants module for events, timeouts, and UI elements
   - Create unified language configuration

2. **Medium Priority** (More complex but valuable):
   - Consolidate LSP server configurations
   - Implement safe setup utility

3. **Low Priority** (Nice to have):
   - Centralize all keymaps
   - Add type checking/validation to configs

## Files Most Affected

1. `/lua/dot/plugins/lsp/lspconfig.lua` - Would be significantly simplified
2. `/lua/dot/plugins/formatting.lua` - Would use shared language config
3. `/lua/dot/plugins/linting.lua` - Would use shared language config
4. Multiple plugin files - Would use constants for events

## Conclusion

The current configuration works well functionally but has significant room for improvement in terms of code organization and reuse. Implementing these recommendations would make the configuration more maintainable, reduce the chance of inconsistencies, and make it easier to add or modify language support in the future.

The most impactful change would be creating a unified language configuration, as this would eliminate the most obvious duplication between formatting and linting configurations. The constants module would be a close second, as it would standardize commonly used values across the entire configuration.