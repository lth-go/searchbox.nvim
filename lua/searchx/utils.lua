local M = {}

M.win_call = function(winid, fn)
  return vim.api.nvim_win_call(winid, fn)
end

M.build_search = function(value)
  value = value:gsub([[\]], [[\\]])
  return string.format("%s%s", [[\V]], value)
end

M.search_count = function()
  local ok, res = pcall(vim.fn.searchcount, { maxcount = -1 })
  if not ok then
    return { total = 0, current = 0 }
  end

  return res
end

M.search_pos = function(query)
  local ok, pos = pcall(vim.fn.searchpos, query, "cn")
  if not ok then
    return nil
  end

  return { pos[1], pos[2] - 1 }
end

return M
