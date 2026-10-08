-- Repo breadcrumb for the statusline: a "root > … > parent > " folder trail
-- rendered ahead of the built-in filename component by lualine
-- (custom/plugins/lualine.lua).
--
-- Only buffers inside a git repo get a breadcrumb; everywhere else the bar
-- falls back to the bare filename, and the folder trail is capped at 3
-- segments (root + the two folders directly above the file), so deep paths
-- collapse to e.g. "dotfiles > … > custom > plugins > ".

---@param buf integer
---@return string|nil File path of {buf} with symlinks resolved (nil for
---              unnamed or scheme-based buffers like term://, oil://)
local function realpath(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' or name:match '^%a+://' then return nil end
  -- Buffer paths may go through symlinks (e.g. ~/.config/nvim ->
  -- ~/dotfiles/config/nvim); vim.fs.root doesn't follow them, so resolve
  -- first or the .git anchor is never found.
  return vim.uv.fs_realpath(name) or name
end

---@return string Breadcrumb ending in " > " (%-escaped), or '' when the
---              buffer has no repo-anchored path
local function dirs()
  local buf = vim.api.nvim_get_current_buf()
  -- Terminal, quickfix, help, prompt, ... buffers have no file path
  if vim.bo[buf].buftype ~= '' then return '' end
  local real = realpath(buf)
  if not real then return '' end

  local root = vim.fs.root(real, '.git')
  if not root then return '' end

  local folders = {}
  local rel = vim.fs.relpath(root, real)
  if rel then
    local dir = vim.fs.dirname(rel)
    if dir ~= '.' then folders = vim.split(dir, '/', { plain = true }) end
  end

  local segments = { vim.fs.basename(root) }
  for _, folder in ipairs(folders) do
    segments[#segments + 1] = folder
  end

  -- Cap at root + the two folders directly above the file
  if #segments > 3 then
    local prev, last = segments[#segments - 1], segments[#segments]
    -- segments = { segments[1], '…', prev, last }
    segments = { '…', prev, last }
  end

  -- vim-tpipeline evaluates the statusline (nvim_eval_statusline), so a
  -- literal % in any segment would be interpreted as an item and corrupt
  -- the bar; double it like the built-in filename component does.
  return (table.concat(segments, ' > ') .. ' > '):gsub('%%', '%%%%')
end

return { dirs = dirs }
