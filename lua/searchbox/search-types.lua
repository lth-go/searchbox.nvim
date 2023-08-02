local M = {}
local utils = require("searchbox.utils")
local noop = function() end

local buf_call = function(state, fn)
  return vim.api.nvim_buf_call(state.bufnr, fn)
end

local clear_matches = function(state)
  utils.clear_matches(state.bufnr)
end

local highlight_text = function(bufnr, pos)
  utils.highlight_text(bufnr, utils.hl_name, pos)
end

M.match_all = {
  buf_leave = noop,
  on_close = function(state)
    clear_matches(state)
  end,
  on_submit = function(value, opts, state)
    if opts.clear_matches then
      clear_matches(state)
    end

    vim.opt.hlsearch = vim.opt.hlsearch
    vim.v.searchforward = opts.reverse and 0 or 1

    -- Make sure you land on the first match.
    -- Y'all can blame netrw for this one.
    if state.first_match ~= nil then
      vim.api.nvim_win_set_cursor(state.winid, { state.first_match.line, state.first_match.col - 1 })
    end
  end,
  on_change = function(value, opts, state)
    utils.clear_matches(state.bufnr)

    if value == "" then
      return
    end

    opts = opts or {}
    local query = utils.build_search(value, opts, state)

    local searchpos = function(flags)
      local stopline = state.range.ends[1]
      local ok, pos = pcall(vim.fn.searchpos, query, flags, stopline)
      if not ok then
        return { line = 0, col = 0 }
      end

      local offset = vim.fn.searchpos(query, "cne", stopline)

      return {
        line = pos[1],
        col = pos[2],
        end_line = offset[1],
        end_col = offset[2],
        one_line = offset[1] == pos[1],
      }
    end

    vim.fn.setreg("/", query)

    local results = buf_call(state, function()
      local ok, res = pcall(vim.fn.searchcount, { maxcount = -1 })
      if not ok then
        return { total = 0, current = 0 }
      end

      return res
    end)

    local cursor_pos = opts.visual_mode and state.range.start or state.start_cursor

    if results.total == 0 then
      -- restore cursor position
      buf_call(state, function()
        vim.fn.setpos(".", { 0, cursor_pos[1], cursor_pos[2] })
        vim.api.nvim_win_set_cursor(state.winid, cursor_pos)
      end)
      return
    end

    buf_call(state, function()
      local start = state.range.start
      vim.fn.setpos(".", { 0, start[1], start[2] })
    end)

    -- highlight all the things
    for i = 1, results.total, 1 do
      local flags = i == 1 and "c" or ""
      local pos = buf_call(state, function()
        return searchpos(flags)
      end)

      -- check if there is a match
      if pos.line == 0 and pos.col == 0 then
        break
      end

      highlight_text(state.bufnr, pos)
    end

    -- move to nearest match
    buf_call(state, function()
      vim.fn.setpos(".", { 0, cursor_pos[1], cursor_pos[2] })
      local flags = opts.reverse and "cb" or "c"
      local nearest = searchpos(flags)
      state.first_match = nearest
      vim.api.nvim_win_set_cursor(state.winid, { nearest.line, nearest.col })
    end)
  end,
}

return M
