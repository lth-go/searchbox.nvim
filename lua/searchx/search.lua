local utils = require("searchx.utils")

local M = {}

M.search_raw = {
  on_close = function(state)
    vim.fn.setreg("/", state.reg)
    vim.api.nvim_win_set_cursor(state.winid, state.start_cursor)
    vim.cmd("nohlsearch")
  end,
  on_submit = function(value, state)
    if #value > 0 then
      local query = utils.build_search(value)
      vim.fn.setreg("/", query)
      vim.fn.histadd("search", query)
    end

    if state.first_match == nil then
      vim.api.nvim_win_set_cursor(state.winid, state.start_cursor)
      vim.cmd("nohlsearch")
      return
    end

    -- set jumplist
    vim.api.nvim_win_set_cursor(state.winid, state.start_cursor)
    vim.cmd("normal! m'")

    vim.api.nvim_win_set_cursor(state.winid, state.first_match)
  end,
  on_change = function(value, state)
    utils.win_call(state.winid, function()
      if value == "" then
        state.first_match = nil
        vim.fn.setreg("/", "")
        vim.api.nvim_win_set_cursor(state.winid, state.start_cursor)
        return
      end

      local query = utils.build_search(value)
      vim.fn.setreg("/", query)

      local results = utils.search_count()
      if results.total == 0 then
        state.first_match = nil
        vim.api.nvim_win_set_cursor(state.winid, state.start_cursor)
        return
      end

      vim.api.nvim_win_set_cursor(state.winid, state.start_cursor)

      -- move to nearest match
      local nearest_pos = utils.search_pos(query)
      if nearest_pos == nil then
        return
      end

      state.first_match = nearest_pos
      vim.api.nvim_win_set_cursor(state.winid, state.first_match)
      vim.opt.hlsearch = vim.opt.hlsearch
    end)
  end,
}

return M
