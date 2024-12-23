local input = require("searchx.inputs")
local search = require("searchx.search")

local buf_is_valid = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ~= "" then
    return false
  end

  if vim.api.nvim_get_option_value("bufhidden", { buf = bufnr }) ~= "" then
    return false
  end

  return true
end

local M = {}

M.search_raw = function()
  if not buf_is_valid(vim.api.nvim_get_current_buf()) then
    vim.api.nvim_feedkeys("/", "n", false)
    return
  end

  input.search(search.search_raw)
end

return M
