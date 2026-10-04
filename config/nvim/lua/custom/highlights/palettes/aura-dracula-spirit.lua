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
-- Design notes:
-- - Types and classes (class names, superclasses, type annotations) are
--   golden #FFCA77 and italic; functions and methods are light orange
--   #ffca85 and italic. The two families are distinguished by color.
-- - Constructors (CharField(...)), imported names, and attribute objects
--   (models, HttpResponse) are lavender #c4b5fd — a class/module reference
--   is lavender whether imported or used.
-- - Variables, parameters, and properties are light cyan #82e2ff
--   (parameters italic, per the theme's meta.function.parameters).
-- - Module paths and self/cls are salmon #ff8d8d; attribute access
--   (self.title) is golden #FFCA77.
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
    -- Imported names (from django.http import HttpResponse) and attribute
    -- objects (models in models.CharField): lavender like constructors —
    -- a class/module reference is lavender whether imported or used
    ['@module.import'] = '#c4b5fd',

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

    -- Named constants: lavender — subdued so it doesn't compete with
    -- classes/functions, but more saturated than the original #c9c5ff.
    -- Constructors share this lavender (see below).
    ['@constant'] = '#c4b5fd',
    ['@constant.builtin'] = '#c4b5fd',
    ['@constant.macro'] = '#c4b5fd',

    -- Functions and methods: light orange, italic like class names
    ['@function'] = { fg = '#ffca85', italic = true },
    ['@function.call'] = { fg = '#ffca85', italic = true },
    ['@function.method'] = { fg = '#ffca85', italic = true },
    ['@function.method.call'] = { fg = '#ffca85', italic = true },
    ['@function.builtin'] = { fg = '#ffca85', italic = true },
    ['@function.macro'] = { fg = '#ffca85', italic = true },
    ['@macro'] = { fg = '#ffca85', italic = true },

    -- Types and classes: golden, italic — class names, superclasses, and
    -- type annotations share the golden (same as the member/import golden),
    -- and the whole type family is italic like the function family.
    ['@type'] = { fg = '#FFCA77', italic = true },
    ['@type.builtin'] = { fg = '#FFCA77', italic = true },
    ['@type.definition'] = { fg = '#FFCA77', italic = true },
    ['@type.qualifier'] = { fg = '#FFCA77', italic = true },
    -- Constructors (CharField(...)): lavender — distinct from golden
    -- classes, light cyan variables, and the light orange functions
    ['@constructor'] = '#c4b5fd',
    ['@structure'] = '#c4b5fd',

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