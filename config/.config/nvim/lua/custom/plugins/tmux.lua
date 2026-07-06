vim.pack.add {
  'https://github.com/christoomey/vim-tmux-navigator',
}
-- Disable the plugin default mappings so we define them explicitly
vim.g.tmux_navigator_no_mappings = 1

-- Move between Neovim splits and tmux panes with Ctrl h j k l
vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', { desc = 'Move left' })
vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', { desc = 'Move down' })
vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', { desc = 'Move up' })
vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', { desc = 'Move right' })

-- Previous split or tmux pane
vim.keymap.set('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<CR>', { desc = 'Move previous' })
