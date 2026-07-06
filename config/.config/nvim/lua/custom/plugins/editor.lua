vim.pack.add {
  'https://github.com/folke/persistence.nvim',
  'https://github.com/mbbill/undotree',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/folke/flash.nvim',
}

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

-- Load per-language syntax highlight overrides
require('custom.highlights')
