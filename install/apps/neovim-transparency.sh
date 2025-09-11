#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/.config/nvim/plugin/after"
TARGET_FILE="$TARGET_DIR/transparency.lua"

mkdir -p "$TARGET_DIR"

cat > "$TARGET_FILE" <<'EOF'
-- EzDora: Neovim transparency helper
-- Makes the editor background transparent so the terminal background shows through.

vim.g.ezdora_transparency = vim.g.ezdora_transparency ~= false

local groups = {
  'Normal', 'NormalFloat', 'SignColumn', 'LineNr', 'NonText', 'EndOfBuffer',
  'MsgArea', 'FloatBorder', 'Pmenu', 'PmenuSel', 'StatusLine', 'StatusLineNC',
  'TelescopeNormal', 'TelescopeBorder',
}

local function apply()
  if vim.g.ezdora_transparency then
    for _, g in ipairs(groups) do
      pcall(vim.api.nvim_set_hl, 0, g, { bg = 'none' })
    end
  else
    -- Reload colorscheme to restore defaults
    local scheme = vim.g.colors_name or ''
    if scheme ~= '' then pcall(vim.cmd, 'silent! colorscheme ' .. scheme) end
  end
end

apply()

vim.api.nvim_create_user_command('EzTransparencyToggle', function()
  vim.g.ezdora_transparency = not vim.g.ezdora_transparency
  apply()
end, {})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    if vim.g.ezdora_transparency then apply() end
  end,
})

-- Optional keymap: <leader>ut toggles transparency
pcall(vim.keymap.set, 'n', '<leader>ut', '<cmd>EzTransparencyToggle<CR>', { desc = 'Toggle Transparency' })
EOF

echo "[ezdora][neovim] Transparência configurada em $TARGET_FILE (com comando :EzTransparencyToggle)."

