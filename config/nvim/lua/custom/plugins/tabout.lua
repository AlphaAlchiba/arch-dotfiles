-- ── tabout: jump out of brackets/quotes with Tab ─────────────
-- <Tab>/<S-Tab> in insert mode move past the closing pair (or back inside).
-- Falls back to normal Tab indentation when no pair is found (act_as_tab).
-- blink.cmp's <Tab> fallback resolves to tabout's <Plug>(Tabout), so snippet
-- navigation via Tab keeps working (blink applies its keymaps on InsertEnter).
vim.pack.add { 'https://github.com/abecodes/tabout.nvim' }
require('tabout').setup {}