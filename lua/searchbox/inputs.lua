local M = {}

local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local utils = require("searchbox.utils")

M.search = function(config, search_opts, handlers)
  local cursor = vim.fn.getcurpos()

  local state = {
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
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  if search_opts.visual_mode and state.range.start[1] == 0 then
    local msg = "[Searchbox] Could not find any text selected."
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  local input = Input(config.popup, {
    prompt = search_opts.prompt,
    default_value = "",
    on_close = function()
      handlers.on_close(state)
    end,
    on_submit = function(value)
      handlers.on_submit(value, search_opts, state)
    end,
    on_change = function(value)
      handlers.on_change(value, search_opts, state)
    end,
  })

  input:mount()

  input._prompt = search_opts.prompt
  M.default_mappings(input, search_opts, state)

  input:on(event.BufLeave, function()
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
