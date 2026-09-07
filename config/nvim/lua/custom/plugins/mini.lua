require('mini.files').setup {}
require('mini.colors').setup()

-- Smooth scrolling only. Cursor animation disabled (clashes with Kitty native cursor).
-- Open/close animations disabled (conflict with Noice UI).
local animate = require('mini.animate')
animate.setup {
  cursor = { enable = false },
  scroll = {
    enable = true,
    -- Snappier than default (250ms): 100ms total, and cap each step at
    -- 10ms so rapid trackpad/key scrolls don't lag behind (see
    -- mini.animate docs on mouse wheel scrolling)
    timing = function(_, n) return math.min(100 / n, 10) end,
    subscroll = animate.gen_subscroll.equal { max_output_steps = 40 },
  },
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

-- Move lines/blocks with Alt+hjkl: current line in normal mode,
-- visual selection in visual mode (same keys, mode-dependent)
require('mini.move').setup {
  mappings = {
    left = '<A-h>',
    right = '<A-l>',
    down = '<A-j>',
    up = '<A-k>',
    line_left = '<A-h>',
    line_right = '<A-l>',
    line_down = '<A-j>',
    line_up = '<A-k>',
  },
}

-- Highlight trailing whitespace and strip it on save
require('mini.trailspace').setup {}
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('mini-trailspace-trim', { clear = true }),
  callback = function() MiniTrailspace.trim() end,
})

vim.keymap.set('n', '<leader>e', MiniFiles.open, { desc = 'Open mini.files' })
