-- Treesitter-aware text objects and motion
vim.pack.add { 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' }

local textobjects_config = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ['af'] = '@function.outer',
      ['if'] = '@function.inner',
      ['ac'] = '@class.outer',
      ['ic'] = '@class.inner',
      ['ap'] = '@parameter.outer',
      ['ip'] = '@parameter.inner',
    },
  },
  move = {
    enable = true,
    set_jumps = true,
    goto_next_start = { [']]'] = '@function.outer' },
    goto_previous_start = { ['[['] = '@function.outer' },
  },
}

local function setup_textobjects()
  local ok, tsconfigs = pcall(require, 'nvim-treesitter.configs')
  if ok then
    tsconfigs.setup { textobjects = textobjects_config }
    return true
  end
  return false
end

-- Try immediately; if plugin isn't compiled yet, wait for PackChanged
if not setup_textobjects() then
  vim.api.nvim_create_autocmd('User', {
    pattern = 'PackChanged',
    once = true,
    callback = setup_textobjects,
  })
end
