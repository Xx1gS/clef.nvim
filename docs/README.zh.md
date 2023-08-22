# 🎼 clef.nvim

<div align="center">

[![GLWTPL](https://img.shields.io/badge/GLWT-Public_License-red.svg)](https://github.com/me-shaon/GLWTPL)

🌐
•
[**English**](../README.md)

</div>

### 📄 TL;DR

能让你再也不会因为烦人的输入法切换而困扰。

### 😂 目的

相信有些人喜欢把自己的开发环境设置在容器之中，随用随开。但是作为与主机隔离的生产环境，同步切换输入法很令人头疼，本项目是为了此目的开发的。

## ✨ 特性

- 🤖 当离开“INSERT”等输入模式时，自动切换为英语输入法。
- 💾 自动保存当前使用的输入法，以便在回到输入模式时使用。

## 🔢 原理

终端为了支持颜色、字体的显示变化，会监听收到的Escape code。本项目利用OSC作为单向信道，由Neovim向终端输出自定义的Escape code。修改所使用的终端OSC监听Handler，在收到特定控制字符的时候切换输入法。

### 🗺️ 来源

iTerm2中提供了“Custom Control Sequences”的功能，本项目是模仿iTerm2的行为实现的，如果有iTerm2中使用的需求可以自行增加[监听器](https://iterm2.com/python-api/examples/create_window.html)。

## 📦 使用方法

### 💻 终端配置

#### 📥 魔改

你需要自行Patch所使用的终端，以支持操作输入法切换的OSC功能。

在本项目中，给出了Windows Terminal的补丁文件。应用后，之后编译运行。其他的终端可以自行Patch其OSC Handler。

``` Powershell
git clone https://github.com/microsoft/Terminal.git
cd Terminal
git submodule update --init --recursive

git apply /path/to/WindowsTerminal.patch

nuget restore OpenConsole.sln
```

#### ✅ 测试

``` python
# 切换NORMAL模式，测试是否切换为英语输入法
print("\033]1337;Custom=id=1337_C13f53cr37:InputMethod2VimNormalMode\a")
# 切换INSERT模式，测试是否恢复为先前输入法
print("\033]1337;Custom=id=1337_C13f53cr37:InputMethod2VimInsertMode\a")
```

### 📝 Neovim配置

#### 📥 安装

这不得用你喜欢的管理器安装。

[lazy.nvim](https://github.com/folke/lazy.nvim):

``` lua
{
  "Xx1gS/clef.nvim",
  opts = {
    tmux_mode = true,
  },
}
```

#### ⚙️ 配置项

``` lua
local defaults = {
  -- 需要切换回英语输入法的激活事件
  normal_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
  -- 需要恢复先前输入法的的激活事件
  insert_events = { "InsertEnter" },

  -- Escape code的包装器，如果有自己定制需求的话
  -- 默认: "\033]1337;Custom=id=%(secret)s:%(command)s\a"
  escape_code = table.concat({
    "\x1b]1337;",
    "Custom=id=%(secret)s:%(command)s",
    "\x07",
  }),
  -- 切换为NORMAL模式的控制字段
  normal_pattern = "InputMethod2VimNormalMode",
  -- 切换为INSERT模式的控制字段
  insert_pattern = "InputMethod2VimInsertMode",
  -- 安全性考量：
  -- 来源于iTerm2中的定义
  -- 主要是为了让非授信应用滥用该功能
  -- secret如果要定制修改，需要在diff文件中更改wsLocalSecret的值
  -- 默认的secret是leetspeek的形式，意为'ClefSecret'
  secret_pattern = "1337_C13f53cr37",

  -- 由于tmux会拦截escape code，于tmux中使用时，需要开启tmux的拦截绕过
  tmux_mode = false,
  tmux_passthrough = table.concat({
    "\x1bPtmux;\x1b",
    "%(escape_code)s",
    "\x1b\\",
  }),
}
```

#### ✅ 测试

如果一切正常，就能在切换模式的时候自动切换输入法了，尽情享受吧。

## 💡 注意

由于这个方法是解决Vim在远程使用时的输入法切换问题，所以如果网络状况非常糟糕的话，哈哈哈，祝你好运。
