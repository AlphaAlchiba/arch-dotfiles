vim.pack.add {
  { src = 'https://github.com/vimpostor/vim-tpipeline' },
}

vim.opt.termguicolors = true
vim.opt.laststatus = 0
vim.opt.cmdheight = 0

-- Don't prepend StatusLine bg (let lualine handle its own background)
vim.g.tpipeline_preservebg = 1

-- tpipeline autoembed; #S is rendered via window_start_flag in tmux config
vim.g.tpipeline_embedopts = {
  "status-left '#(cat #{socket_path}-\\#{session_id}-vimbridge)'",
  "status-right '#(cat #{socket_path}-\\#{session_id}-vimbridge-R)'",
}
