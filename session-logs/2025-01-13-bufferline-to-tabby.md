# Session Log: Bufferline to Tabby Migration
**Date**: 2025-01-13  
**Issue**: Icon backgrounds appearing black in bufferline visible tabs

## Problem Discovered
- **Issue**: Icon backgrounds in bufferline tabs appeared black on visible (non-selected) tabs
- **Root Cause**: Bufferline dynamically creates ~1,884 BufferLineDevIcon* highlights that fail to inherit parent backgrounds properly
- **Duration**: This has been a known issue since 2021 (GitHub issues #1012, #1027, #954)

## Research & Investigation

### 1. Analyzed bufferline's architecture
- Found it creates dynamic highlights like `BufferLineDevIconLuaVisible`
- Discovery: Icon highlight cache prevents fixes from working
- Identified inheritance mechanism was broken at line 109 of `/home/dot/.local/share/nvim/lazy/bufferline.nvim/lua/bufferline/highlights.lua`

### 2. Community Research
- Searched GitHub issues and forums
- Found widespread reports of the same problem
- Common workarounds included double-loading and manual overrides
- Issues tracked: #1012, #1027, #954, #240, #251

### 3. Scope Assessment
- Counted 628 unique DevIcon types in nvim-web-devicons
- Calculated ~1,884 dynamic highlights created by bufferline (628 × 3 states)
- Determined manual override wasn't practical

## Solutions Attempted

### 1. Added missing highlight groups
Added to bufferline configuration:
- BufferLineBuffer
- BufferLineBufferVisible
- BufferLineTabVisible
- Other missing groups

**Result**: No improvement

### 2. Double-colorscheme loading workaround
Implemented deferred reload with cache clearing after 50ms

**Result**: Did not fix the black background issue

### 3. Decided to switch plugins
After discovering this is a 4+ year old architectural issue, decided switching was more practical than continuing to fight the system.

## Final Solution: Tabby.nvim

### Why Tabby?
- Declarative configuration (you control rendering)
- No dynamic highlight creation
- Direct control over icon highlights
- Simpler architecture

### Implementation Steps
1. **Disabled bufferline**:
   ```lua
   -- /home/dot/.config/nvim/lua/dot/plugins/bufferline.lua
   enabled = false, -- Disabled to test tabby.nvim
   ```

2. **Created tabby configuration**:
   ```lua
   -- /home/dot/.config/nvim/lua/dot/plugins/tabby.lua
   return {
     "nanozuki/tabby.nvim",
     dependencies = { "nvim-tree/nvim-web-devicons" },
     config = function()
       require('tabby').setup({
         preset = 'tab_only',
       })
       vim.o.showtabline = 2
     end,
   }
   ```

3. **Cleaned up keymaps**:
   - Removed `reload_bufferline()` function
   - Removed `<leader>rb` keymap
   - Kept all tab navigation keymaps (they work with native vim commands)

## Results
- ✅ Theme colors inherit properly
- ✅ No icon background issues
- ✅ All existing keymaps still work
- ✅ Simpler, more maintainable setup

## Key Learning
Bufferline's dynamic highlight creation with caching makes icon theming problematic. Tabby's simpler approach of explicit highlight control avoids these issues entirely. Sometimes switching tools is better than fighting architectural limitations.

## Files Modified
- `/home/dot/.config/nvim/lua/dot/plugins/bufferline.lua` - Disabled
- `/home/dot/.config/nvim/lua/dot/plugins/tabby.lua` - Created
- `/home/dot/.config/nvim/lua/dot/core/keymaps.lua` - Removed bufferline functions

## Technical Details
- **Bufferline approach**: Creates BufferLineDevIcon[Type][State] dynamically
- **Tabby approach**: Uses render functions with explicit highlight control
- **Lazy.nvim**: Each plugin is a separate .lua file returning a table spec