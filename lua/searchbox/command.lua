local M = {}

M.run = function(search_type, line1, line2, count, input)
  local opts = {}

  if line2 == count then
    opts.range = { line1, line2 }
  end

  require("searchbox")[search_type](opts)
end

return M
