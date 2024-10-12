local M = {}

local vim = vim
local nui_input = require("nui.input")
local nui_event = require("nui.utils.autocmd").event
local utils = require("searchx.utils")

M.search = function(search_opts, handler)
  local cursor = vim.fn.getcurpos()

  local state = {
    winid = vim.fn.win_getid(),
    bufnr = vim.fn.bufnr(),
    line = cursor[2],
    line_prev = -1,
    use_range = false,
    start_cursor = { cursor[2], cursor[3] },
    range = { start = { 0, 0 }, ends = { 0, 0 } },
    reg = vim.fn.getreginfo("/"),
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
    local msg = "[Searchx] - Invalid value for 'modifier' argument"
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  if search_opts.visual_mode and state.range.start[1] == 0 then
    local msg = "[Searchx] Could not find any text selected."
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  local input = nui_input(search_opts.popup, {
    prompt = search_opts.prompt,
    default_value = "",
    on_close = function()
      handler.on_close(state)
    end,
    on_submit = function(value)
      handler.on_submit(value, search_opts, state)
    end,
    on_change = function(value)
      handler.on_change(value, search_opts, state)
    end,
  })

  input:mount()

  input._prompt = search_opts.prompt
  M.default_mappings(input)

  input:on(nui_event.BufLeave, function()
    input:unmount()
  end)
end

M.default_mappings = function(input)
  local bind = function(modes, lhs, rhs, noremap)
    vim.keymap.set(modes, lhs, rhs, { noremap = noremap, buffer = input.bufnr })
  end

  bind({ "", "i" }, "<Plug>(searchx-close)", input.input_props.on_close, true)
  bind({ "i" }, "<C-c>", "<Plug>(searchx-close)", false)
  bind({ "i" }, "<Esc>", "<Plug>(searchx-close)", false)
  bind({ "i" }, "<C-p>", "<Nop>", false)
  bind({ "i" }, "<C-n>", "<Nop>", false)
  bind({ "i" }, "<C-j>", "<Nop>", false)
end

return M
