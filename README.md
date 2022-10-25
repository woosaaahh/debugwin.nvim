- [Requirements](#requirements)
- [Usage](#usage)
- [Configuration](#configuration)

# DebugWin

DebugWin helps to visualize messages or Lua results in a separate window.

## Requirements

To use this plugin, you need :

- to have [Neovim](https://github.com/neovim/neovim)
  [`0.8+`](https://github.com/neovim/neovim/releases) version installed ;
- to add `woosaaahh/debugwin.nvim` in your plugin manager configuration.

Here are some plugin managers :

- [vim-plug](https://github.com/junegunn/vim-plug) ;
- [packer.nvim](https://github.com/wbthomason/packer.nvim) ;
- [paq-nvim](https://github.com/savq/paq-nvim).

## Usage

- `debugwin.show()` will open the window and display `:messages` ;
- `debugwin.show(variable)` will open the window and display the content of `variable` ;
- `debugwin.focus()` will focus the `DebugWin` window.
- `debugwin.close()` will close the `DebugWin` window.

## Configuration

No configuration needed, only keymaps :

```lua
local debugwin = require("debugwin")
vim.keymap.set({ "", "i" }, "<F8>", debugwin.show) -- to display `:messages` in a window
vim.keymap.set({ "", "i" }, "<F9>", debugwin.focus)
vim.keymap.set({ "", "i" }, "<F10>", debugwin.close)
```
