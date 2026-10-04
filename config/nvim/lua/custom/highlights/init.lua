-- Text palette system
--
-- Each code-text colorscheme lives in lua/custom/highlights/palettes/<name>.lua
-- as a pure data table:
--   { name, groups = { [hl group] = hex | { fg, bold, italic, ... } },
--     rainbow = { 7 colors }, aerial = { SymbolType = hex } }
--
-- Only code text colors change; backgrounds and UI colors come from the
-- base colorscheme (catppuccin-mocha) and are left untouched.
--
-- Switch the default by editing `default_palette` below, or at runtime with
-- :TextPalette (session-only; a restart uses the default again).

local default_palette = 'aura-dracula-spirit'

-- LSP semantic tokens (priority 125) override treesitter (priority 120), so
-- an LSP that sends tokens (e.g. basedpyright) would wash out palette
-- colors: Neovim's default links map @lsp.type.* to treesitter groups, but
-- catppuccin overrides some of them (e.g. @lsp.type.variable = {} renders
-- variables uncolored). Re-link explicitly so semantic tokens render with
-- the active palette's colors. Class names link to @type.definition and
-- type annotations to @type, matching the treesitter captures.
local lsp_type_links = {
  ['@lsp.type.class'] = '@type.definition',
  ['@lsp.type.comment'] = '@comment',
  ['@lsp.type.decorator'] = '@attribute',
  ['@lsp.type.enum'] = '@type.definition',
  ['@lsp.type.enumMember'] = '@constant',
  ['@lsp.type.event'] = '@type.definition',
  ['@lsp.type.function'] = '@function',
  ['@lsp.type.interface'] = '@type',
  ['@lsp.type.keyword'] = '@keyword',
  ['@lsp.type.macro'] = '@macro',
  ['@lsp.type.method'] = '@function.method',
  ['@lsp.type.modifier'] = '@type.qualifier',
  ['@lsp.type.namespace'] = '@module',
  ['@lsp.type.number'] = '@number',
  ['@lsp.type.operator'] = '@operator',
  ['@lsp.type.parameter'] = '@variable.parameter',
  ['@lsp.type.property'] = '@property',
  ['@lsp.type.regexp'] = '@string.regexp',
  ['@lsp.type.string'] = '@string',
  ['@lsp.type.struct'] = '@structure',
  ['@lsp.type.type'] = '@type',
  ['@lsp.type.typeParameter'] = '@type.qualifier',
  ['@lsp.type.variable'] = '@variable',
}

local palettes_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'highlights', 'palettes')

local function palette_names()
  local names = {}
  for file_name, type in vim.fs.dir(palettes_dir, { follow = true }) do
    if (type == 'file' or type == 'link') and file_name:match '%.lua$' then
      names[#names + 1] = file_name:gsub('%.lua$', '')
    end
  end
  table.sort(names)
  return names
end

local function load_palette(name)
  local ok, palette = pcall(require, 'custom.highlights.palettes.' .. name)
  if not ok then
    vim.notify(
      'Text palette "' .. name .. '" not found. Available: ' .. table.concat(palette_names(), ', '),
      vim.log.levels.WARN
    )
    return nil
  end
  return palette
end

local function apply_palette(name)
  local palette = load_palette(name)
  if not palette then return end

  -- Treesitter groups: replace fg + style, keep any existing bg/underline/sp
  for group, spec in pairs(palette.groups) do
    local existing = vim.api.nvim_get_hl(0, { name = group })
    local opts = type(spec) == 'table' and vim.deepcopy(spec) or { fg = spec }
    opts.bg = existing.bg
    opts.underline = existing.underline
    opts.sp = existing.sp
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- Catppuccin compatibility: the treesitter highlighter resolves captures
  -- as @capture.<lang> (e.g. @constructor.python), not @capture. Undefined
  -- @capture.<lang> groups fall back to @capture, but catppuccin v4 defines
  -- some explicitly — @constructor.python = sky (#89dceb) and
  -- @constructor.lua — which overrode the palette's @constructor color
  -- (CharField rendered light blue instead of the palette color). Re-link
  -- them to @constructor so they follow the active palette. If catppuccin
  -- adds more <lang>-specific overrides, add them here.
  for _, group in ipairs({ '@constructor.python', '@constructor.lua' }) do
    vim.api.nvim_set_hl(0, group, { link = '@constructor' })
  end

  -- Rainbow delimiter groups (7 colors, in order)
  local rainbow_groups = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterOrange',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  }
  for i, color in ipairs(palette.rainbow) do
    vim.api.nvim_set_hl(0, rainbow_groups[i], { fg = color })
  end

  -- Aerial outline groups
  for group, color in pairs(palette.aerial) do
    vim.api.nvim_set_hl(0, 'Aerial' .. group, { fg = color })
  end

  -- LSP semantic tokens: link to the palette's treesitter groups
  for group, link in pairs(lsp_type_links) do
    vim.api.nvim_set_hl(0, group, { link = link })
  end

  vim.g.active_text_palette = name
end

-- Re-apply the active palette whenever the colorscheme is (re)loaded
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    apply_palette(vim.g.active_text_palette or default_palette)
  end,
})

-- Apply now (runs after the colorscheme was loaded in init.lua)
apply_palette(default_palette)

-- :TextPalette — pick a palette from the list of files
vim.api.nvim_create_user_command('TextPalette', function()
  local names = palette_names()
  vim.ui.select(names, {
    prompt = 'Text palette:',
    format_item = function(name)
      local palette = load_palette(name)
      return palette and (palette.name .. ' (' .. name .. ')') or name
    end,
  }, function(name)
    if name then apply_palette(name) end
  end)
end, { desc = 'Choose a text palette' })

-- :HlUnder — show the treesitter captures and winning color under the cursor
-- (persists in the message area, unlike :Inspect's floating window)
vim.api.nvim_create_user_command('HlUnder', function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- row is 1-indexed, col is 0-indexed (get_captures_at_pos wants both 0-indexed)
  local captures = vim.treesitter.get_captures_at_pos(0, row - 1, col)
  local names = {}
  for _, c in ipairs(captures) do
    names[#names + 1] = c.capture
  end
  local last = captures[#captures]
  local hl = last and vim.api.nvim_get_hl(0, { name = '@' .. last.capture }) or {}
  local fg = hl.fg and string.format('#%06x', hl.fg) or 'nil'
  print(('captures: %s | winner: %s | fg: %s'):format(table.concat(names, ', '), last and last.capture or 'none', fg))
end, { desc = 'Show treesitter captures and color under cursor' })