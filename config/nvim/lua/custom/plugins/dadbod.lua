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
  callback = function() vim.omnifunc = 'vim_dadbod_completion#omni' end,
})
