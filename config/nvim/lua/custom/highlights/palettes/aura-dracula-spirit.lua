-- Aura Dracula Spirit text palette
--
-- Based on the "Aura Dracula Spirit" VSCode theme by JoseMurilloc
-- (https://github.com/JoseMurilloc/aura-spirit-dracula), plus custom
-- textMateRules: namespace #ff8d8d, constants #c9c5ff, classes #FFCA77,
-- variables/properties/parameters #82e2ff.
--
-- Applied on top of the catppuccin-mocha colorscheme: only code text colors
-- change; backgrounds and UI colors come from the colorscheme.
--
-- `groups` maps highlight groups to a hex color (fg only) or a table with
-- fg + style attributes. `rainbow` lists the 7 rainbow-delimiter colors in
-- order. `aerial` maps aerial outline symbol types to colors.
--
-- Python-specific: `@module.import` (imported names like `models`) is
-- captured by after/queries/python/highlights.scm.

return {
  name = 'Aura Dracula Spirit',
  groups = {
    -- Default text (plain/unmatched code)
    ['Normal'] = '#a9b1d6',

    -- Comments and docstrings
    ['@comment'] = '#64548E',
    ['@string.documentation'] = { fg = '#64548E', italic = true },

    -- Keywords and control flow
    ['@keyword'] = '#a277ff',
    ['@keyword.coroutine'] = '#a277ff',
    ['@keyword.function'] = '#a277ff',
    ['@keyword.operator'] = '#a277ff',
    ['@keyword.import'] = '#a277ff',
    ['@keyword.return'] = '#a277ff',
    ['@keyword.exception'] = '#a277ff',
    ['@keyword.type'] = '#a277ff',
    ['@keyword.modifier'] = '#a277ff',
    ['@keyword.debug'] = '#a277ff',
    ['@keyword.directive'] = '#a277ff',
    ['@conditional'] = '#a277ff',
    ['@repeat'] = '#a277ff',
    ['@include'] = '#a277ff',
    ['@exception'] = '#a277ff',
    ['@label'] = '#a277ff',
    ['@operator'] = '#a277ff',
    ['@storageclass'] = '#a277ff',
    -- self/cls and other language builtins: salmon, like module paths
    ['@variable.builtin'] = '#ff8d8d',

    -- Module paths in imports (django.db) and namespaces
    ['@module'] = '#ff8d8d',
    ['@module.builtin'] = '#ff8d8d',
    ['@namespace'] = '#ff8d8d',
    -- Imported names (from django.db import models)
    ['@module.import'] = '#FFCA77',

    -- Strings
    ['@string'] = '#61ffca',
    ['@string.escape'] = '#61ffca',
    ['@string.regex'] = '#61ffca',
    ['@string.special'] = '#61ffca',
    ['@character'] = '#61ffca',

    -- Numbers: muted orange — softer than the burning orange, still distinct
    -- from the light function orange and the string mint
    ['@number'] = '#ff9e64',
    ['@number.float'] = '#ff9e64',
    -- Booleans: pink, their own distinctive color
    ['@boolean'] = '#f694ff',

    -- Named constants: muted lavender — subdued so it doesn't compete with
    -- classes/functions, but more saturated than the original #c9c5ff
    ['@constant'] = '#c4b5fd',
    ['@constant.builtin'] = '#c4b5fd',
    ['@constant.macro'] = '#c4b5fd',

    -- Functions and methods
    ['@function'] = '#ffca85',
    ['@function.call'] = '#ffca85',
    ['@function.method'] = '#ffca85',
    ['@function.method.call'] = '#ffca85',
    ['@function.builtin'] = '#ffca85',
    ['@function.macro'] = '#ffca85',
    ['@macro'] = '#ffca85',

    -- Types and classes: class names golden (same as constructors and the
    -- member/import golden, per the original theme where classes and
    -- constructor references share a color), type annotations muted pink —
    -- distinct from class names, the light function orange, and the vivid
    -- pink booleans. Class names, annotations, and function names are all
    -- upright for a consistent look.
    ['@type'] = '#d98cb3',
    ['@type.builtin'] = '#d98cb3',
    ['@type.definition'] = '#FFCA77',
    ['@type.qualifier'] = '#d98cb3',
    -- Constructors (CharField(...)): golden like class names — clearly
    -- distinct from the light cyan variables
    ['@constructor'] = '#FFCA77',
    ['@structure'] = '#FFCA77',

    -- Variables and parameters: light cyan (parameters italic, per the
    -- theme's meta.function.parameters)
    ['@variable'] = '#82e2ff',
    ['@variable.parameter'] = { fg = '#82e2ff', italic = true },
    ['@parameter'] = { fg = '#82e2ff', italic = true },
    -- Properties and fields
    ['@property'] = '#82e2ff',
    ['@field'] = '#82e2ff',
    -- Attribute access (models.something, self.x): golden
    ['@variable.member'] = '#FFCA77',

    -- Attributes (decorators italic)
    ['@attribute'] = { fg = '#f694ff', italic = true },
    ['@tag.attribute'] = '#f694ff',

    -- Punctuation
    ['@punctuation.delimiter'] = '#f694ff',
    ['@punctuation.bracket'] = '#a9b1d6',
    ['@punctuation.special'] = '#a9b1d6',

    -- Tags
    ['@tag'] = '#a277ff',
    ['@tag.delimiter'] = '#a9b1d6',

    -- Errors
    ['@error'] = '#ff6767',
  },
  rainbow = {
    '#ff6767', -- red
    '#ffca85', -- yellow
    '#82e2ff', -- blue
    '#f694ff', -- orange (pink slot for distinctness)
    '#61ffca', -- green
    '#a277ff', -- violet
    '#76d4FF', -- cyan
  },
  aerial = {
    Class = '#FFCA77',
    Function = '#ffca85',
    Method = '#ffca85',
    Variable = '#82e2ff',
    Field = '#82e2ff',
  },
}