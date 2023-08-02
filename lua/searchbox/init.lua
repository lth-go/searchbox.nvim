local M = {}

local utils = require("searchbox.utils")
local search_type = require("searchbox.search-types")
local input = require("searchbox.inputs")

local merge = utils.merge

local search_defaults = {
  reverse = false,
  exact = false,
  prompt = " ",
  modifier = "disabled",
  visual_mode = false,
  range = { -1, -1 },
}

local defaults = {
  defaults = {}, -- search config defaults
  popup = {
    relative = "editor",
    position = {
      row = "100%",
      col = "0%",
    },
    size = "100%",
    border = {
      style = "none",
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  },
}

local user_opts = nil

local merge_config = function(opts)
  opts = opts or {}
  local u = user_opts.defaults
  return vim.tbl_deep_extend("force", {}, search_defaults, {
    reverse = u.reverse,
    exact = u.exact,
    prompt = u.prompt,
    modifier = u.modifier,
    clear_matches = u.clear_matches,
    confirm = u.confirm,
  }, opts)
end

M.setup = function(config)
  user_opts = merge(defaults, config)
end

M.match_all = function(config)
  if not user_opts then
    M.setup({})
  end

  local search_opts = merge_config(config)
  search_opts._type = "match_all"

  if search_opts.clear_matches == nil then
    search_opts.clear_matches = true
  end

  input.search(user_opts, search_opts, search_type.match_all)
end

return M
