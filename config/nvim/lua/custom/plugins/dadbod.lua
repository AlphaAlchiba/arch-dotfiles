vim.pack.add {
  'https://github.com/tpope/vim-dadbod',
  'https://github.com/kristijanhusak/vim-dadbod-ui',
  'https://github.com/kristijanhusak/vim-dadbod-completion',
}

vim.g.db_ui_use_nerd_fonts = vim.g.have_nerd_font
vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/dadbod_queries'

vim.keymap.set('n', '<leader>db', ':DBUI<CR>', { desc = '[D]ad[B]od UI' })
vim.keymap.set('n', '<leader>dq', ':DB ', { desc = '[D]adbod [Q]uery' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'plsql' },
  callback = function()
    -- Buffer-local so this wins over the builtin sql ftplugin's
    -- sqlcomplete#Complete (which is set per-buffer during FileType).
    vim.bo.omnifunc = 'vim_dadbod_completion#omni'
    -- Run the SQL statement under the cursor (paragraph) via dadbod-ui's
    -- visual execute: vip selects the statement block, the plug runs only the
    -- selection. Requires a dadbod-ui-bound buffer (opened via DBUI or
    -- :DBUIFindBuffer).
    vim.keymap.set('n', '<leader>ds', 'vip<Plug>(DBUI_ExecuteQuery)', { buffer = true, desc = '[D]adbod [S]tatement' })
    -- Run the whole buffer as one query (dadbod-ui's normal-mode plug =
    -- its <Leader>S / %DB behavior), without needing to save first.
    vim.keymap.set('n', '<leader>da', '<Plug>(DBUI_ExecuteQuery)', { buffer = true, desc = '[D]adbod [A]ll (whole buffer)' })
  end,
})
