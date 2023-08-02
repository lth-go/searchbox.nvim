local M = {}
local format = string.format

M.hl_name = "SearchBoxMatch"
M.hl_namespace = vim.api.nvim_create_namespace(M.hl_name)

M.clear_matches = function(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.hl_namespace, 0, -1)
  vim.cmd("nohlsearch")
end

M.merge = function(defaults, override)
  return vim.tbl_deep_extend("force", {}, defaults, override or {})
end

M.get_modifier = function(name)
  local mods = {
    ["disabled"] = "",
    ["ignore-case"] = "\\c",
    ["case-sensitive"] = "\\C",
    ["no-magic"] = "\\M",
    ["magic"] = "\\m",
    ["very-magic"] = "\\v",
    ["very-no-magic"] = "\\V",
    ["plain"] = "\\V",
  }

  local modifier = mods[name]

  if modifier then
    return modifier
  end

  if type(name) == "string" and name:sub(1, 1) == ":" then
    return name:sub(2)
  end
end

M.build_search = function(value, opts, state)
  local query = value

  if opts.exact then
    query = format("\\<%s\\>", query)
  end

  if opts.visual_mode then
    query = format("\\%%V%s", query)
  elseif state.use_range then
    query = format("\\%%>%sl\\%%<%sl%s", state.range.start[1] - 1, state.range.ends[1] + 1, value)
  end

  query = format("%s%s", state.search_modifier, query)

  return query
end

M.nearest_match = function(search_term, flags)
  local pos = vim.fn.searchpos(search_term, flags)
  local off = vim.fn.searchpos(search_term, "cne")

  return {
    line = pos[1],
    col = pos[2],
    end_line = off[1],
    end_col = off[2],
    one_line = pos[1] == off[1],
  }
end

M.highlight_text = function(bufnr, hl_name, pos)
  local h = function(line, col, offset)
    vim.api.nvim_buf_add_highlight(bufnr, M.hl_namespace, hl_name, line - 1, col - 1, offset)
  end

  if pos.one_line then
    h(pos.line, pos.col, pos.end_col)
  else
    -- highlight first line
    h(pos.line, pos.col, -1)

    -- highlight last line
    h(pos.end_line, 1, pos.end_col)

    -- do the rest
    for curr_line = pos.line + 1, pos.end_line - 1, 1 do
      h(curr_line, 1, -1)
    end
  end
end

return M
