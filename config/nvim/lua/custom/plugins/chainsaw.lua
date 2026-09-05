-- ── nvim-chainsaw: quick log statement insertion ─────────────
-- Log the variable under the cursor (or visual selection) with a single keypress.
-- All operations are dot-repeatable; <leader>lr strips every chainsaw log line.
vim.pack.add { 'https://github.com/chrisgrieser/nvim-chainsaw' }
require('chainsaw').setup {}

-- [[ Log keymaps (<leader>l) — normal + visual mode ]]
vim.keymap.set({ 'n', 'v' }, '<leader>lp', function() require('chainsaw').variableLog() end, { desc = '[L]og [p]rint variable under cursor' })
vim.keymap.set({ 'n', 'v' }, '<leader>lo', function() require('chainsaw').objectLog() end, { desc = '[L]og [o]bject under cursor' })
vim.keymap.set({ 'n', 'v' }, '<leader>lt', function() require('chainsaw').typeLog() end, { desc = '[L]og [t]ype of variable under cursor' })
vim.keymap.set({ 'n', 'v' }, '<leader>lr', function() require('chainsaw').removeLogs() end, { desc = '[L]og [r]emove all chainsaw log statements' })
vim.keymap.set('n', '<leader>lc', function() require('chainsaw').clearLog() end, { desc = '[L]og [c]lear console' })