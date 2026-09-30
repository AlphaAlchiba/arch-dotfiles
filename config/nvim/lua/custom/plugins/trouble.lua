-- ── trouble.nvim: quickfix-style diagnostics panel ────────────
-- <leader>xx toggles the diagnostics list; <leader>xX scopes it to the buffer.
vim.pack.add { 'https://github.com/folke/trouble.nvim' }
require('trouble').setup {}

require('which-key').add { { '<leader>x', group = '[X] Trouble', mode = { 'n' } } }

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = '[X] Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = '[X] Buffer Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble loclist toggle<CR>', { desc = '[X] Location List (Trouble)' })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', { desc = '[X] Quickfix List (Trouble)' })