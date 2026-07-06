require('mini.files').setup {}
require('mini.colors').setup()
vim.keymap.set('n', '<leader>e', MiniFiles.open, { desc = 'Open mini.files' })

local starter = require 'mini.starter'
starter.setup {
  autoopen = true,
  evaluate_single = false,
  query_updaters = 'abcdefgimnopqrstuvwxyz0123456789_-.',
  header = table.concat({
    '                                        ',
    '     ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
    '     ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
    '     ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
    '     ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '     ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '     ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
    '                                        ',
    '              Write. Edit. Build.',
    '                                        ',
  }, '\n'),
  footer = table.concat({
    '',
    '    Quit                        q',
    '    Session restore             s',
    '    Find File                   f',
    '    Recent Files                r',
    '    Grep                        g',
    '    Configure Neovim            c',
    '    Go to recent                t',
  }, '\n'),
  content_hooks = {
    starter.gen_hook.adding_bullet '▸ ',
    starter.gen_hook.aligning('center', 'center'),
  },
  items = {
    starter.sections.builtin_actions(),
    starter.sections.recent_files(4, true),
    starter.sections.recent_files(4, false),
    starter.sections.sessions(4),
  },
}
