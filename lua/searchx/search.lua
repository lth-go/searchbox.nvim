local M = {}

local vim = vim
local utils = require("searchx.utils")

local win_call = function(state, fn)
  return vim.api.nvim_win_call(state.winid, fn)
end

M.match_all = {
  on_close = function(state)
    vim.api.nvim_win_set_cursor(state.winid, { state.start_cursor[1], state.start_cursor[2] - 1 })
    vim.cmd("nohlsearch")
  end,
  on_submit = function(value, opts, state)
    if #value > 0 then
      local query = utils.build_search(value, opts, state)
      vim.fn.setreg("/", query)
      vim.fn.histadd("search", query)
    end

    -- Make sure you land on the first match.
    -- Y'all can blame netrw for this one.
    if state.first_match ~= nil then
      vim.api.nvim_win_set_cursor(state.winid, { state.first_match.line, state.first_match.col - 1 })
    else
      vim.api.nvim_win_set_cursor(state.winid, { state.start_cursor[1], state.start_cursor[2] - 1 })
      vim.cmd("nohlsearch")
    end
  end,
  on_change = function(value, opts, state)
    local cursor_pos = opts.visual_mode and state.range.start or state.start_cursor

    if value == "" then
      win_call(state, function()
        vim.fn.setreg("/", "")
        vim.opt.hlsearch = vim.opt.hlsearch
        state.first_match = nil
        vim.api.nvim_win_set_cursor(state.winid, cursor_pos)
      end)
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

      return {
        line = pos[1],
        col = pos[2],
      }
    end

    vim.fn.setreg("/", query)

    local results = win_call(state, function()
      local ok, res = pcall(vim.fn.searchcount, { maxcount = -1 })
      if not ok then
        return { total = 0, current = 0 }
      end

      return res
    end)

    if results.total == 0 then
      -- restore cursor position
      win_call(state, function()
        vim.fn.setpos(".", { 0, cursor_pos[1], cursor_pos[2] })

        state.first_match = nil
        vim.api.nvim_win_set_cursor(state.winid, cursor_pos)
      end)
      return
    end

    -- move to nearest match
    win_call(state, function()
      vim.fn.setpos(".", { 0, cursor_pos[1], cursor_pos[2] })

      local flags = opts.reverse and "bcn" or "cn"
      local nearest = searchpos(flags)
      state.first_match = nearest
      vim.api.nvim_win_set_cursor(state.winid, { nearest.line, nearest.col })
      vim.opt.hlsearch = vim.opt.hlsearch
    end)
  end,
}

return M
