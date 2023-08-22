# 🎼 clef.nvim

<div align="center">

[![GLWTPL](https://img.shields.io/badge/GLWT-Public_License-red.svg)](https://github.com/me-shaon/GLWTPL)

🌐
•
[**中文**](./docs/README.zh.md)

</div>

### 📄 TL;DR

Ensure that you will never be bothered by switching input methods again.

### 😂 Purpose
Some people prefer to set up their development environment within containers, allowing for easy and instant access. However, when working in a production environment isolated from the host system, synchronizing input method switches can be frustrating. This project was developed to address this issue.

## ✨ Features

- 🤖 Automatically switches to the English input method when leaving "INSERT" or other input modes.
- 💾 Automatically saves the current input method to be restored when returning to the input mode.

### 🔢 Principle

To support color and font display changes, the terminal listens for Escape codes. This project utilizes OSC (Operating System Command) as a one-way channel, where Neovim outputs custom Escape codes to the terminal. By modifying the terminal's OSC listener handler, the input method can be switched upon receiving specific control characters.

### 🗺️ Source

The functionality of "Custom Control Sequences" is provided by iTerm2. This project emulates the behavior of iTerm2. If there is a need for the same functionality as iTerm2, you can add your own [listener](https://iterm2.com/python-api/examples/create_window.html).

## 📦 Usage

### 💻 Terminal Configuration

#### 📥 Patching

You need to patch the terminal you are using to support input method switching via OSC.

In this project, a patch file for Windows Terminal is provided. After applying the patch, compile and run the terminal. For other terminals, you can patch their OSC handler accordingly.

``` Powershell
git clone https://github.com/microsoft/Terminal.git
cd Terminal
git submodule update --init --recursive

git apply /path/to/WindowsTerminal.patch

nuget restore OpenConsole.sln
```

#### ✅ Testing
```python
# Test switching to NORMAL mode and verify if the English input method is active
print("\033]1337;Custom=id=1337_C13f53cr37:InputMethod2VimNormalMode\a")
# Test switching to INSERT mode and verify if the previous input method is restored
print("\033]1337;Custom=id=1337_C13f53cr37:InputMethod2VimInsertMode\a")
```

### 📝 Neovim Configuration

#### 📥 Installation

Install the plugin with your preferred package manager.

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Xx1gS/clef.nvim",
  opts = {
    tmux_mode = true,
  },
}
```

#### ⚙️ Configuration

``` lua
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
```

#### ✅ Testing

If everything is set up correctly, the input method should automatically switch when changing modes. Enjoy!

## 💡 Note

Since this method solves the input method switching problem for Vim when used remotely, if the network conditions are extremely poor, well, good luck with this!