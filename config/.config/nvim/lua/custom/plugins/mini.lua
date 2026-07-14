require('mini.files').setup {}
require('mini.colors').setup()

-- Smooth scrolling only. Cursor animation disabled (clashes with Kitty native cursor).
-- Open/close animations disabled (conflict with Noice UI).
require('mini.animate').setup {
  cursor = { enable = false },
  scroll = { enable = true },
  resize = { enable = false },
  open   = { enable = false },
  close  = { enable = false },
}

-- Inline highlights for hex color codes (#fff, #ff8800, etc.) in any file
require('mini.hipatterns').setup {
  highlighters = {
    hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
  },
}

vim.keymap.set('n', '<leader>e', MiniFiles.open, { desc = 'Open mini.files' })
