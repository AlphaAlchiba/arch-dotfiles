-- Python-specific Treesitter highlight overrides
-- Colors use the Catppuccin Mocha palette

local function setup()
  -- Function definitions: green, bold
  vim.api.nvim_set_hl(0, '@function', { fg = '#a6e3a1', bold = true })
  -- Function calls: blue
  vim.api.nvim_set_hl(0, '@function.call', { fg = '#89b4fa' })
  -- Function parameters: italic
  vim.api.nvim_set_hl(0, '@variable.parameter', { italic = true })
  vim.api.nvim_set_hl(0, '@parameter', { italic = true })
  -- Class / type definitions: yellow
  vim.api.nvim_set_hl(0, '@type', { fg = '#f9e2af' })
  vim.api.nvim_set_hl(0, '@type.definition', { fg = '#f9e2af', bold = true })
  -- Built-in functions (print, len, etc.): peach
  vim.api.nvim_set_hl(0, '@function.builtin', { fg = '#fab387' })
  -- Keywords (def, class, if, return, etc.): mauve
  vim.api.nvim_set_hl(0, '@keyword', { fg = '#cba6f7' })
  -- Strings: teal
  vim.api.nvim_set_hl(0, '@string', { fg = '#94e2d5' })
  -- Docstrings: teal italic
  vim.api.nvim_set_hl(0, '@string.documentation', { fg = '#94e2d5', italic = true })
  -- Decorators: peach italic
  vim.api.nvim_set_hl(0, '@attribute', { fg = '#fab387', italic = true })
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  once = true,
  callback = setup,
})
