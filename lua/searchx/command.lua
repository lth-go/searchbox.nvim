local input = require("searchx.inputs")
local search = require("searchx.search")

local M = {}

M.search_raw = function()
  input.search(search.search_raw)
end

return M
