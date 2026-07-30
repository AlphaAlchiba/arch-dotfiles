vim.pack.add { 'https://github.com/goolord/alpha-nvim' }

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
local alpha = require 'alpha'
local theta = require 'alpha.themes.theta'
local dashboard = require 'alpha.themes.dashboard'

-- Replace entire layout: vertically centered, polished
theta.config.layout = {
  {
    type = 'group',
    opts = { position = 'v_center' },
    val = {
      { type = 'padding', val = 2 },
      -- Header: project name + dynamic separator
      { type = 'text', val = project_name, opts = { hl = 'Type', position = 'center' } },
      { type = 'text', val = string.rep('━', math.max(12, vim.fn.strdisplaywidth(project_name) + 4)), opts = { hl = 'Comment', position = 'center' } },
      { type = 'padding', val = 2 },
      -- Recent files section
      {
        type = 'group',
        val = {
          { type = 'text', val = 'Recent files', opts = { hl = 'Comment', position = 'center' } },
          { type = 'padding', val = 1 },
          {
            type = 'group',
            val = function()
              local mru = theta.mru(0, vim.fn.getcwd(), 10)
              for _, item in ipairs(mru.val) do
                if item.type == 'button' and item.opts and item.opts.shortcut then
                  local num = item.opts.shortcut:match('^(%d+)')
                  if num then item.opts.shortcut = '[' .. num .. '] ' end
                end
              end
              return { mru }
            end,
            opts = { shrink_margin = false },
          },
        },
      },
      { type = 'padding', val = 2 },
      -- Bottom buttons: find file + quit with icons
      {
        type = 'group',
        val = function()
          local btn_f = dashboard.button('f', '󰈞  Find file', '<cmd>Telescope find_files<CR>')
          local btn_q = dashboard.button('q', '󰅚  Quit', '<cmd>qa<CR>')
          btn_f.opts.shortcut = '[f] '
          btn_q.opts.shortcut = '[q] '
          return { btn_f, btn_q }
        end,
      },
    },
  },
}

theta.file_icons.provider = 'mini'
alpha.setup(theta.config)
