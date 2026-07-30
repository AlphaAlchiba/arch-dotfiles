vim.pack.add {
  'https://github.com/nvim-lualine/lualine.nvim',
}
local bar_bg = '#24243a'
local subtle_fg = '#a9b1d6'

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
        'filename',
        path = 0,
        color = { fg = subtle_fg, bg = bar_bg },
      },
    },

    lualine_x = {
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
