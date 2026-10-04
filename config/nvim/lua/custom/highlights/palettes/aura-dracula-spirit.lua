-- Aura Dracula Spirit text palette
--
-- Based on the "Aura Dracula Spirit" VSCode theme by JoseMurilloc
-- (https://github.com/JoseMurilloc/aura-spirit-dracula), plus custom
-- textMateRules: namespace #ff8d8d, constants #c9c5ff, classes #ffca85,
-- variables/properties/parameters #94ccfa.
--
-- Applied on top of the catppuccin-mocha colorscheme: only code text colors
-- change; backgrounds and UI colors come from the colorscheme.
--
-- `groups` maps highlight groups to a hex color (fg only) or a table with
-- fg + style attributes. `rainbow` lists the 7 rainbow-delimiter colors in
-- order. `aerial` maps aerial outline symbol types to colors.
--
-- Design notes:
-- - Types and classes are gold #ffca85 and bold — the heavy, structural
--   parts of the code; functions and methods are the same gold but italic,
--   so classes read as imposing without adding a color.
-- - Keywords and control flow are violet #a277ff; @keyword.repeat and
--   @keyword.conditional are set explicitly because current treesitter
--   queries capture for/while/if/else under those names, not the legacy
--   @repeat/@conditional.
-- - Constructors (CharField(...)), imported names, and attribute objects
--   (models, HttpResponse) are lavender #c4b5fd — a class/module reference
--   is lavender whether imported or used.
-- - Variables, parameters, and properties are a light blue #94ccfa —
--   lighter than the original cyan (not flashy) but darker than the
--   lavender #c4b5fd so the two stay distinct (parameters italic, per
--   the theme's meta.function.parameters).
--   light and soft, matching the lavender's lightness so the cool family
--   (blue variables, lavender constants, violet keywords) reads as one
--   airy ramp (parameters italic, per the theme's meta.function.parameters).
--   clearly darker and less saturated than the original #82e2ff so it
--   sits back against the background (parameters italic, per the theme's
--   meta.function.parameters).
--   temporary, to verify palette changes apply; pick the final color after.
--   (parameters italic, per the theme's meta.function.parameters).
-- - Module paths and self/cls are salmon #ff8d8d; attribute access
--   (self.title) is gold #ffca85.
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
    ['@keyword.repeat'] = '#a277ff',
    ['@keyword.conditional'] = '#a277ff',
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
    ['@string.regexp'] = '#61ffca',
    ['@string.special'] = '#61ffca',
    ['@character'] = '#61ffca',

    -- Numbers: muted orange — softer than the burning orange, still distinct
    -- from the light function orange and the string mint
    ['@number'] = '#e8935f',
    ['@number.float'] = '#e8935f',
    -- Booleans: pink, their own distinctive color
    ['@boolean'] = '#f694ff',

    -- Named constants: lavender — subdued so it doesn't compete with
    -- classes/functions, but more saturated than the original #c9c5ff.
    -- Constructors share this lavender (see below).
    ['@constant'] = '#c4b5fd',
    ['@constant.builtin'] = '#c4b5fd',
    ['@constant.macro'] = '#c4b5fd',

    -- Functions and methods: gold, italic — the light counterpart to the
    -- bold types
    ['@function'] = { fg = '#ffca85', italic = true },
    ['@function.call'] = { fg = '#ffca85', italic = true },
    ['@function.method'] = { fg = '#ffca85', italic = true },
    ['@function.method.call'] = { fg = '#ffca85', italic = true },
    ['@function.builtin'] = { fg = '#ffca85', italic = true },
    ['@function.macro'] = { fg = '#ffca85', italic = true },
    ['@macro'] = { fg = '#ffca85', italic = true },

    -- Types and classes: gold, bold — class names, superclasses, and type
    -- annotations are bold so classes read as the heavy, structural parts
    -- of the code, distinct from the italic functions
    ['@type'] = { fg = '#ffca85', bold = true },
    ['@type.builtin'] = { fg = '#ffca85', bold = true },
    ['@type.definition'] = { fg = '#ffca85', bold = true },
    ['@type.qualifier'] = { fg = '#ffca85', bold = true },
    -- Constructors (CharField(...)): lavender — distinct from the gold
    -- classes/functions and the cyan variables
    ['@constructor'] = '#c4b5fd',
    ['@structure'] = '#c4b5fd',

    -- Variables and parameters: light blue #94ccfa — lighter than the original
    -- cyan, darker than the lavender (parameters italic, per the theme's
    -- meta.function.parameters)
    ['@variable'] = '#94ccfa',
    ['@variable.parameter'] = { fg = '#94ccfa', italic = true },
    ['@parameter'] = { fg = '#94ccfa', italic = true },
    -- Properties and fields
    ['@property'] = '#94ccfa',
    ['@field'] = '#94ccfa',
    -- Attribute access (models.something, self.x): gold, like functions
    ['@variable.member'] = '#ffca85',

    -- Attributes (decorators italic)
    ['@attribute'] = { fg = '#f694ff', italic = true },
    -- Builtin decorators (property/classmethod/staticmethod) — without
    -- this, Neovim's default link (@attribute.builtin -> Special) renders
    -- them light pink instead of the palette pink
    ['@attribute.builtin'] = { fg = '#f694ff', italic = true },
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
    '#f7768e', -- rose (not the error red #ff6767)
    '#ffca85', -- yellow
    '#94ccfa', -- blue
    '#f694ff', -- orange (pink slot for distinctness)
    '#61ffca', -- green
    '#a277ff', -- violet
    '#5f8fd6', -- deep blue (distinct from the light variable blue #94ccfa)
  },
  aerial = {
    Class = '#ffca85',
    Function = '#ffca85',
    Method = '#ffca85',
    Variable = '#94ccfa',
    Field = '#94ccfa',
  },
}