-- Rainbow-colored matching brackets via Treesitter
--
-- Uses rainbow-delimiters.nvim to colorize (), [], {}, and language-specific
-- delimiters at each nesting level with distinct colors.
--
-- Strategy: "local" — highlights only the bracket tree around your cursor,
-- reducing visual noise compared to coloring everything globally.

vim.pack.add { 'https://github.com/HiPhish/rainbow-delimiters.nvim' }

-- Define Catppuccin Mocha colors for the rainbow delimiter highlight groups.
-- These are set manually rather than relying on Catppuccin's auto-detection,
-- because the plugin module isn't available at colorscheme load time.
local rainbow_colors = {
  RainbowDelimiterRed    = { fg = '#f38ba8' },  -- red
  RainbowDelimiterYellow = { fg = '#f9e2af' },  -- yellow
  RainbowDelimiterBlue   = { fg = '#89b4fa' },  -- blue
  RainbowDelimiterOrange = { fg = '#fab387' },  -- peach
  RainbowDelimiterGreen  = { fg = '#a6e3a1' },  -- green
  RainbowDelimiterViolet = { fg = '#cba6f7' },  -- mauve
  RainbowDelimiterCyan   = { fg = '#94e2d5' },  -- teal
}

for group, opts in pairs(rainbow_colors) do
  vim.api.nvim_set_hl(0, group, opts)
end

-- Helper to configure rainbow-delimiters once the module is available
local function setup_rainbow()
  local ok, rd = pcall(require, 'rainbow-delimiters')
  if not ok then return false end

  vim.g.rainbow_delimiters = {
    -- Highlight only the bracket sub-tree around the cursor (less noisy)
    strategy = {
      [''] = rd.strategy['local'],
    },
    -- These highlight groups were defined above using Catppuccin Mocha colors
    highlight = {
      'RainbowDelimiterRed',
      'RainbowDelimiterYellow',
      'RainbowDelimiterBlue',
      'RainbowDelimiterOrange',
      'RainbowDelimiterGreen',
      'RainbowDelimiterViolet',
      'RainbowDelimiterCyan',
    },
  }
  return true
end

-- Try to configure immediately (works when plugin was already compiled)
if not setup_rainbow() then
  -- Otherwise wait for PackChanged (fresh install being compiled)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'PackChanged',
    group = vim.api.nvim_create_augroup('rainbow-delimiters-setup', { clear = true }),
    callback = setup_rainbow,
  })
end
