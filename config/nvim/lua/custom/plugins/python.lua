-- ── Neotest: in-editor test runner (pytest) ────────────────────
vim.pack.add {
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/nvim-neotest/neotest-python',
}
-- nvim-nio (async support) and plenary.nvim are already installed (via dap-ui and telescope)

require('neotest').setup {
  adapters = {
    require('neotest-python')({
      dap = { justMyCode = false },
    }),
  },
}

-- ── Python DAP (debugpy) via nvim-dap (already installed) ─────
-- Requires debugpy installed: uv tool install debugpy
local dap = require 'dap'
dap.adapters.python = {
  type = 'executable',
  command = 'uv',
  args = { 'run', 'python', '-m', 'debugpy.adapter' },
}
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
  },
}

-- ── nvim-treesitter-context: sticky class/function header ─────
vim.pack.add { 'https://github.com/nvim-treesitter/nvim-treesitter-context' }
require('treesitter-context').setup {
  max_lines = 5, -- show at most 5 lines of context
}

-- ── Django template highlighting (htmldjango treesitter parser) ──
require('nvim-treesitter').install { 'htmldjango' }

-- ============================================================
-- KEYMAPS
-- ============================================================

-- [[ Test keymaps (<leader>t) ]]
vim.keymap.set('n', '<leader>tt', function() require('neotest').run.run() end, { desc = '[T]est nearest (cursor on test)' })
vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, { desc = '[T]est [f]ile' })
vim.keymap.set('n', '<leader>tl', function() require('neotest').run.run_last() end, { desc = '[T]est [l]ast' })
vim.keymap.set('n', '<leader>ts', function() require('neotest').run.stop() end, { desc = '[T]est [s]top' })
vim.keymap.set('n', '<leader>to', function() require('neotest').output_panel.toggle() end, { desc = '[T]est [o]utput panel' })

-- [[ Debug keymaps (<leader>d) — no F-keys needed ]]
vim.keymap.set('n', '<leader>dd', function() dap.continue() end, { desc = '[D]ebug [D]efault (continue/start)' })
vim.keymap.set('n', '<leader>ds', function() dap.step_over() end, { desc = '[D]ebug [S]tep over' })
vim.keymap.set('n', '<leader>di', function() dap.step_into() end, { desc = '[D]ebug step [I]nto' })
vim.keymap.set('n', '<leader>do', function() dap.step_out() end, { desc = '[D]ebug step [O]ut' })
vim.keymap.set('n', '<leader>dt', function() dap.toggle_breakpoint() end, { desc = '[D]ebug [T]oggle breakpoint' })
vim.keymap.set('n', '<leader>dT', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = '[D]ebug conditional breakpoin[T]' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = '[D]ebug [U]I toggle' })
