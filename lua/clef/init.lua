local M = {}

-- Utils
-- Pythonic formatting specifications
-- "%(key)s is %(val)7.2f%" % {key = "concentration", val = 56.2795}
getmetatable("").__mod = function(s, tab)
  return (
    s:gsub("%%%(([%a_][%w_]*)%)([-0-9%.]*[cdeEfgGiouxXsq])", function(k, fmt)
      return tab[k] and ("%" .. fmt):format(tab[k]) or "%(" .. k .. ")" .. fmt
    end)
  )
end

-- Local config
---@class ClefConfig
local defaults = {
  -- Events that trigger switching back to the English input method
  normal_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
  -- Events that trigger restoring the previous input method
  insert_events = { "InsertEnter" },

  -- Escape code wrapper, can be customized if needed
  -- Default: "\033]1337;Custom=id=%(secret)s:%(command)s\a"
  escape_code = table.concat({
    "\x1b]1337;",
    "Custom=id=%(secret)s:%(command)s",
    "\x07",
  }),
  -- Pattern for normal mode
  normal_pattern = "InputMethod2VimNormalMode",
  -- Pattern for insert mode
  insert_pattern = "InputMethod2VimInsertMode",
  -- Security consideration:
  -- Derived from the definition in iTerm2
  -- Primarily designed to prevent abuse by untrusted applications
  -- If you want to customize the secret
  -- you need to change the value of wsLocalSecret in the .diff file
  -- The default secret is in leetspeek form, meaning 'ClefSecret'
  secret_pattern = "1337_C13f53cr37",

  -- Since tmux intercepts escape codes, tmux_mode should be enabled when using within tmux
  tmux_mode = false,
  tmux_passthrough = table.concat({
    "\x1bPtmux;\x1b",
    "%(escape_code)s",
    "\x1b\\",
  }),
}

-- Users config
---@type ClefConfig
local options

-- Create escape code to be sent
---@param cmd string
---@return string
local function create_escape_code(cmd)
  return options.escape_code % {
    secret = options.secret_pattern or "",
    command = cmd or "",
  }
end

-- Wrap passthrough escape sequence for tmux user
---@param escape_code string
---@return string
local function passthrough_tmux(escape_code)
  if not options.tmux_mode then
    -- Return unchange
    return escape_code
  end

  return options.tmux_passthrough % {
    escape_code = escape_code,
  }
end

-- Sending escape code to STDERR
---@param escape_code string
---@return boolean
local function send_escape_code(escape_code)
  escape_code = passthrough_tmux(escape_code)

  local success = false
  if vim.fn.filewritable("/dev/fd/2") == 1 then
    success = vim.fn.writefile({ escape_code }, "/dev/fd/2", "b") == 0
  else
    success = vim.fn.chansend(vim.v.stderr, escape_code) > 0
  end

  return success
end

---@param opts? ClefConfig
M.setup = function(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {})

  -- set autocmd
  local group_id = vim.api.nvim_create_augroup("clef", { clear = true })

  if #options.normal_events > 0 then
    vim.api.nvim_create_autocmd(options.normal_events, {
      group = group_id,
      callback = function()
        send_escape_code(create_escape_code(options.normal_pattern))
      end,
    })
  end

  if #options.insert_events > 0 then
    vim.api.nvim_create_autocmd(options.insert_events, {
      group = group_id,
      callback = function()
        send_escape_code(create_escape_code(options.insert_pattern))
      end,
    })
  end
end

return M
