local nui_input = require("nui.input")
local nui_event = require("nui.utils.autocmd").event

local M = {}

M.search = function(handler)
  local state = {
    winid = vim.fn.win_getid(),
    bufnr = vim.fn.bufnr(),
    start_cursor = vim.api.nvim_win_get_cursor(0),
    reg = vim.fn.getreginfo("/"),
    first_match = nil,
  }

  local popup_options = {
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
  }

  local input_options = {
    prompt = " ",
    default_value = "",
    on_close = function()
      handler.on_close(state)
    end,
    on_submit = function(value)
      handler.on_submit(value, state)
    end,
    on_change = function(value)
      handler.on_change(value, state)
    end,
  }

  local input = nui_input(popup_options, input_options)

  input:mount()

  M.default_mappings(input)

  input:on(nui_event.BufLeave, function()
    input:unmount()
  end)
end

M.default_mappings = function(input)
  local bind = function(modes, lhs, rhs)
    vim.keymap.set(modes, lhs, rhs, { buffer = input.bufnr })
  end

  bind({ "i" }, "<C-c>", input.input_props.on_close)
  bind({ "i" }, "<Esc>", input.input_props.on_close)
  bind({ "i" }, "<C-p>", "<Nop>")
  bind({ "i" }, "<C-n>", "<Nop>")
  bind({ "i" }, "<C-j>", "<Nop>")
  bind({ "i" }, "<C-k>", "<Nop>")
end

return M
