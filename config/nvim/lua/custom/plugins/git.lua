-- ── Diffview: split-window diff viewer ──────────────────────────
vim.pack.add { 'https://github.com/sindrets/diffview.nvim' }

require('diffview').setup {
  enhanced_diff_hl = true, -- Better staged/unstaged diff coloring
}

-- ── Neogit: Magit-like Git interface ────────────────────────────
--  (like VSCode's Source Control panel — stage, unstage, commit,
--   branch operations, log, all from inside nvim)
vim.pack.add { 'https://github.com/NeogitOrg/neogit' }

require('neogit').setup {
  kind = 'tab',
  integrations = {
    diffview = true, -- Press <Enter> on a file in neogit → opens diffview
  },
}

-- ── Keymaps (all under <leader>g prefix) ────────────────────────
vim.keymap.set('n', '<leader>gg', function()
  local git_root = vim.fs.root(0, '.git')
  if git_root then
    require('neogit').open { cwd = git_root }
  else
    require('neogit').open()
  end
end, { desc = '[G]it status (Neo[g]it)' })
vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { desc = '[G]it [D]iff (staged vs working)' })
vim.keymap.set('n', '<leader>gD', ':DiffviewOpen HEAD~1<CR>', { desc = '[G]it [D]iff against last commit' })
vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', { desc = '[G]it diffview [C]lose' })
vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory %<CR>', { desc = '[G]it file [H]istory' })
vim.keymap.set('n', '<leader>gH', ':DiffviewFileHistory<CR>', { desc = '[G]it repo [H]istory' })
vim.keymap.set('n', '<leader>gb', ':Gitsigns blame<CR>', { desc = '[G]it [B]lame (gitsigns)' })
