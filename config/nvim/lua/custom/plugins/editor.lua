vim.pack.add {
  'https://github.com/folke/persistence.nvim',
  'https://github.com/mbbill/undotree',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/folke/flash.nvim',
  'https://github.com/stevearc/aerial.nvim',
  'https://github.com/kevinhwang91/nvim-ufo',
  'https://github.com/kevinhwang91/promise-async',
}

-- Code outline sidebar — shows class/function structure
require('aerial').setup {
  layout = {
    default_direction = 'right',
    max_width = 40,
  },
  -- Show context for all buffers, not just current
  manage_folds = true,
}

-- Distinct Catppuccin Mocha colors per symbol type in the aerial outline
local aerial_colors = {
  AerialClass    = { fg = '#f9e2af' }, -- yellow
  AerialFunction = { fg = '#89b4fa' }, -- blue
  AerialMethod   = { fg = '#a6e3a1' }, -- green
  AerialVariable = { fg = '#fab387' }, -- peach
  AerialField    = { fg = '#94e2d5' }, -- teal
}
for group, opts in pairs(aerial_colors) do
  vim.api.nvim_set_hl(0, group, opts)
end

vim.keymap.set('n', '<leader>a', require('aerial').toggle, { desc = 'Toggle aerial (code outline)' })

-- Ctrl+Backspace: delete previous word (like <C-w> in most editors)
-- Works in insert mode and command-line mode.
-- Requires Kitty + tmux CSI-u passthrough (already configured).
vim.keymap.set({ 'i', 'c' }, '<C-BS>', '<C-w>', { desc = 'Delete previous word' })

require('persistence').setup {
  dir = vim.fn.stdpath 'state' .. '/sessions',
  options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help' },
}

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle undotree' })

require('render-markdown').setup {}

require('flash').setup {}

-- nvim-ufo: treesitter-based folding with fold preview
require('ufo').setup {
  provider_selector = function()
    return { 'treesitter', 'indent' }
  end,
}
vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
-- zi: toggle all folds open/closed (ufo APIs keep foldlevel unchanged)
vim.keymap.set('n', 'zi', function()
  local any_closed = false
  for lnum = 1, vim.fn.line '$' do
    if vim.fn.foldclosed(lnum) ~= -1 then
      any_closed = true
      break
    end
  end
  if any_closed then
    require('ufo').openAllFolds()
  else
    require('ufo').closeAllFolds()
  end
end, { desc = 'Toggle all folds' })

-- Load per-language syntax highlight overrides
require('custom.highlights')
