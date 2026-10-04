-- Rainbow-colored matching brackets via Treesitter
--
-- Uses rainbow-delimiters.nvim to colorize (), [], {}, and language-specific
-- delimiters at each nesting level with distinct colors.
--
-- Strategy: "local" — highlights only the bracket tree around your cursor,
-- reducing visual noise compared to coloring everything globally.
--
-- The RainbowDelimiter* highlight groups are defined by the active text
-- palette (lua/custom/highlights/palettes/*.lua), not here.

vim.pack.add { 'https://github.com/HiPhish/rainbow-delimiters.nvim' }

-- Helper to configure rainbow-delimiters once the module is available
local function setup_rainbow()
  local ok, rd = pcall(require, 'rainbow-delimiters')
  if not ok then return false end

  vim.g.rainbow_delimiters = {
    -- Highlight only the bracket sub-tree around the cursor (less noisy)
    strategy = {
      [''] = rd.strategy['local'],
    },
    -- Highlight groups are defined by the active text palette
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
