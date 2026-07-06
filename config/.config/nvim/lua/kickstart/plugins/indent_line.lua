-- ============================================================
-- INDENT GUIDES & SCOPE INDICATOR
--
-- indent-blankline.nvim  → static indent guides at every level
-- mini.indentscope       → animated scope indicator (current block)
-- ============================================================

-- [[ Static Indent Guides ]]
vim.pack.add { 'https://github.com/lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {
  indent = {
    -- Thin, uniform guide character that looks the same at any indent width
    char = '▏',
  },
  -- Disable ibl's scope entirely (no horizontal lines at function boundaries).
  -- mini.indentscope handles scope visualization with animation instead.
  scope = { enabled = false },
  -- Skip indent guides in non-code buffers
  exclude = {
    filetypes = {
      'help', 'terminal', 'dashboard', 'lspinfo',
      'TelescopePrompt', 'TelescopeResults', 'NvimTree',
      'minifiles', 'neo-tree',
    },
  },
}

-- [[ Animated Scope Indicator ]]
-- Shows a solid vertical line that expands smoothly from the cursor line
-- outward to the top and bottom of the current indentation scope.
-- NO horizontal lines are drawn -- only a clean vertical scope indicator.
--
-- Animation uses the default constant 20ms per step, producing a uniform
-- smooth expansion from the cursor line outward in both directions.
require('mini.indentscope').setup {
  -- Solid continuous vertical line (no gaps) for the scope indicator
  symbol = '│',
  options = {
    -- When cursor is on a scope border (e.g. `def my_function():`),
    -- treat it as the border and show the scope of the body below.
    try_as_border = true,
  },
  -- Disable textobject mappings to avoid conflict with mini.ai's `ii`/`ai`
  mappings = {
    object_scope = '',
    object_scope_with_border = '',
    -- Jump to scope boundaries
    goto_top = '[i',
    goto_bottom = ']i',
  },
}

-- Disable scope indicator in non-code buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'Trouble',
    'alpha',
    'dashboard',
    'fzf',
    'help',
    'lazy',
    'mason',
    'neo-tree',
    'notify',
    'snacks_dashboard',
    'snacks_notif',
    'snacks_terminal',
    'snacks_win',
    'toggleterm',
    'trouble',
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

-- [[ Highlight Styling ]]
-- Static indent guides: subtle, muted color (barely visible)
vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#45475a' })
-- Subtle tint on indent characters at the cursor's indent level
vim.api.nvim_set_hl(0, 'IblScope', { fg = '#585b70' })
-- Active scope indicator (solid vertical line): bright mauve from Catppuccin Mocha palette
vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#cba6f7' })
