-- Catppuccin Mocha text palette — the original colors, kept so you can
-- switch back with :TextPalette.
--
-- Matches the colorscheme's own treesitter defaults, plus the previous
-- per-language overrides (bold/italic styles, teal strings).

return {
  name = 'Catppuccin Mocha',
  groups = {
    -- Comments
    ['@comment'] = '#6c7086',

    -- Keywords and control flow
    ['@keyword'] = '#cba6f7',
    ['@keyword.coroutine'] = '#cba6f7',
    ['@keyword.function'] = '#cba6f7',
    ['@keyword.operator'] = '#cba6f7',
    ['@keyword.import'] = '#cba6f7',
    ['@keyword.return'] = '#cba6f7',
    ['@keyword.exception'] = '#cba6f7',
    ['@keyword.type'] = '#cba6f7',
    ['@keyword.modifier'] = '#cba6f7',
    ['@keyword.debug'] = '#cba6f7',
    ['@keyword.directive'] = '#cba6f7',
    ['@conditional'] = '#cba6f7',
    ['@repeat'] = '#cba6f7',
    ['@include'] = '#cba6f7',
    ['@exception'] = '#f38ba8',
    ['@label'] = '#f9e2af',
    ['@operator'] = '#89b4fa',

    -- Strings
    ['@string'] = '#94e2d5',
    ['@string.documentation'] = { fg = '#94e2d5', italic = true },
    ['@string.escape'] = '#f38ba8',
    ['@string.regex'] = '#f38ba8',
    ['@string.special'] = '#f38ba8',
    ['@character'] = '#a6e3a1',

    -- Functions and methods
    ['@function'] = { fg = '#a6e3a1', bold = true },
    ['@function.call'] = '#89b4fa',
    ['@function.method'] = '#a6e3a1',
    ['@function.method.call'] = '#89b4fa',
    ['@function.builtin'] = '#fab387',
    ['@function.macro'] = '#fab387',

    -- Types and constructors
    ['@type'] = '#f9e2af',
    ['@type.builtin'] = '#f9e2af',
    ['@type.definition'] = { fg = '#f9e2af', bold = true },
    ['@type.qualifier'] = '#f9e2af',
    ['@constructor'] = '#fab387',
    ['@storageclass'] = '#f9e2af',
    ['@structure'] = '#f9e2af',

    -- Constants and numbers
    ['@constant'] = '#fab387',
    ['@constant.builtin'] = '#fab387',
    ['@constant.macro'] = '#fab387',
    ['@number'] = '#fab387',
    ['@number.float'] = '#fab387',
    ['@boolean'] = '#fab387',

    -- Variables
    ['@variable'] = '#cdd6f4',
    ['@variable.builtin'] = '#f38ba8',
    ['@variable.member'] = '#cdd6f4',
    ['@variable.parameter'] = { fg = '#cdd6f4', italic = true },
    ['@parameter'] = { fg = '#cdd6f4', italic = true },
    ['@namespace'] = '#cdd6f4',

    -- Properties, fields, attributes
    ['@property'] = '#94e2d5',
    ['@field'] = '#94e2d5',
    ['@attribute'] = { fg = '#fab387', italic = true },
    ['@macro'] = '#fab387',

    -- Punctuation
    ['@punctuation.delimiter'] = '#cdd6f4',
    ['@punctuation.bracket'] = '#cdd6f4',
    ['@punctuation.special'] = '#cba6f7',

    -- Tags (HTML/XML)
    ['@tag'] = '#f38ba8',
    ['@tag.attribute'] = '#a6e3a1',
    ['@tag.delimiter'] = '#89b4fa',
  },
  rainbow = {
    '#f38ba8', -- red
    '#f9e2af', -- yellow
    '#89b4fa', -- blue
    '#fab387', -- orange
    '#a6e3a1', -- green
    '#cba6f7', -- violet
    '#94e2d5', -- cyan
  },
  aerial = {
    Class = '#f9e2af',
    Function = '#89b4fa',
    Method = '#a6e3a1',
    Variable = '#fab387',
    Field = '#94e2d5',
  },
}