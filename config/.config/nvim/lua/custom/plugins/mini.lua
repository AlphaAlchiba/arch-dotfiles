require('mini.files').setup {}
require('mini.colors').setup()
vim.keymap.set('n', '<leader>e', MiniFiles.open, { desc = 'Open mini.files' })
