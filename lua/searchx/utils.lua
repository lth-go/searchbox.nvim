local M = {}

local format = string.format

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

return M
