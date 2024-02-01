local M = {}

local input = require("searchx.inputs")
local search = require("searchx.search")

local search_opts = {
  reverse = false,
  exact = false,
  prompt = " ",
  modifier = "plain",
  visual_mode = false,
  range = { -1, -1 },
  clear_matches = true,
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
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,Search:Normal,CurSearch:Normal",
    },
  },
}

M.run = function()
  input.search(search_opts, search.match_all)
end

return M
