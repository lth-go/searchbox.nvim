local M = {}

local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

M.state = {}

local utils = require("searchbox.utils")

M.search = function(config, search_opts, handlers)
  local cursor = vim.fn.getcurpos()

  local state = {
    match_ns = utils.hl_namespace,
    winid = vim.fn.win_getid(),
    bufnr = vim.fn.bufnr(),
    line = cursor[2],
    line_prev = -1,
    use_range = false,
    start_cursor = { cursor[2], cursor[3] },
    range = { start = { 0, 0 }, ends = { 0, 0 } },
  }

  if search_opts.visual_mode then
    state.range = {
      start = { vim.fn.line("'<"), vim.fn.col("'<") },
      ends = { vim.fn.line("'>"), vim.fn.col("'>") },
    }
  elseif search_opts.range[1] > 0 and search_opts.range[2] > 0 then
    state.use_range = true
    state.range = {
      start = {
        search_opts.range[1],
        1,
      },
      ends = {
        search_opts.range[2],
        vim.fn.col({ search_opts.range[2], "$" }),
      },
    }
  end

  state.search_modifier = utils.get_modifier(search_opts.modifier)

  if state.search_modifier == nil then
    local msg = "[SearchBox] - Invalid value for 'modifier' argument"
    vim.notify(msg:format(search_opts.modifier), vim.log.levels.WARN)
    return
  end

  local popup_opts = config.popup
  local input = nil

  if search_opts.visual_mode and state.range.start[1] == 0 then
    local msg = "[Searchbox] Could not find any text selected."
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  input = Input(popup_opts, {
    prompt = search_opts.prompt,
    default_value = search_opts.default_value or "",
    on_close = function()
      vim.api.nvim_win_set_cursor(state.winid, state.start_cursor)

      handlers.on_close(state)
    end,
    on_submit = function(value)
      if #value > 0 then
        local query = utils.build_search(value, search_opts, state)
        vim.fn.setreg("/", query)
        vim.fn.histadd("search", query)
      end

      handlers.on_submit(value, search_opts, state, popup_opts)
    end,
    on_change = function(value)
      handlers.on_change(value, search_opts, state)
    end,
  })

  input:mount()

  input._prompt = search_opts.prompt
  M.default_mappings(input, search_opts, state)

  input:on(event.BufLeave, function()
    handlers.buf_leave(state)
    input:unmount()
  end)
end

M.default_mappings = function(input, search_opts, state)
  local bind = function(modes, lhs, rhs, noremap)
    vim.keymap.set(modes, lhs, rhs, { noremap = noremap, buffer = input.bufnr })
  end

  bind({ "", "i" }, "<Plug>(searchbox-close)", input.input_props.on_close, true)
  bind({ "i" }, "<C-c>", "<Plug>(searchbox-close)", false)
  bind({ "i" }, "<Esc>", "<Plug>(searchbox-close)", false)
end

return M
