vim.pack.add {
  'https://github.com/nvim-lualine/lualine.nvim',
}
local bar_bg = '#24243a'
local subtle_fg = '#a9b1d6'
local breadcrumb = require 'custom.breadcrumb'

require('lualine').setup {
  options = {
    theme = 'auto',
    icons_enabled = vim.g.have_nerd_font,
    component_separators = '',
    section_separators = '',
    globalstatus = true,
  },

  -- this is a comment
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(mode) return mode end,
      },
    },

    lualine_b = {
      'branch',
    },

    lualine_c = {
      {
        -- Repo breadcrumb: "dotfiles > … > plugins > " (empty outside git repos)
        breadcrumb.dirs,
        color = { fg = '#7f849c', bg = bar_bg },
        padding = { left = 1, right = 0 },
      },
      {
        -- Filename keeps lualine's [No Name] / [+] / [-] handling
        'filename',
        path = 0,
        color = { fg = subtle_fg, bg = bar_bg },
        padding = { left = 0, right = 1 },
      },
      {
        -- Git change counts for the current file: +added ~modified -removed
        'diff',
        color = { fg = subtle_fg, bg = bar_bg },
      },
    },

    lualine_x = {
      {
        -- Show chainsaw log statement count (icon + N) while logs exist
        function() return require('chainsaw.visuals.statusline').countInBuffer() end,
        cond = function() return require('chainsaw.visuals.statusline').countInBuffer() ~= '' end,
      },
      {
        'encoding',
        color = { fg = subtle_fg, bg = bar_bg },
      },
      {
        'filetype',
        color = { fg = subtle_fg, bg = bar_bg },
      },
    },

    lualine_y = {
      'progress',
    },

    lualine_z = {
      'location',
    },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        path = 1,
        color = { fg = subtle_fg, bg = bar_bg },
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}
