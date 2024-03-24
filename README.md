# Large File Optimization for Neovim

This module enhances the performance of Neovim when working with large files. It automatically adjusts buffer settings and disables certain features that can degrade performance when editing large files.

## Installation

You can install this module using your preferred Neovim package manager. For users utilizing `lazy.nvim`, here's a straightforward setup:

### Using `lazy.nvim`

First, ensure you have `lazy.nvim` installed. If not, you can set it up with the following script:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",  -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
```

Next, add the `large_file` module to your `lazy.nvim` configuration:

```lua
require("lazy").setup({
	{
		"mireq/large_file",
		config = function()
			require("large_file").setup()
		end
	},
})
```

## Usage

After installation, the module will automatically optimize the settings for large files. You can manually set it up with the following command:

```lua
require("large_file").setup()
```

## Configuration

The module provides several optional settings that you can customize:

- `size_limit`: The size threshold (in bytes) for a file to be considered large. Default is 4 MB.
- `buffer_options`: A table of buffer-specific options to be applied for large files. These include disabling swap files, setting the buffer type to `nowrite`, among others.
- `on_large_file_read_pre`: A callback function that is called before the module applies optimizations for a large file.

### Default Settings

```lua
local default_settings = {
	size_limit = 4 * 1024 * 1024,  -- 4 MB
	buffer_options = {
		swapfile = false,
		bufhidden = 'unload',
		buftype = 'nowrite',
		undolevels = -1,
	},
	on_large_file_read_pre = function(ev) end
}
```

### Custom Configuration Example

To customize the settings, pass your desired configuration to the `setup` function:

```lua
require("large_file").setup({
	size_limit = 10 * 1024 * 1024,  -- 10 MB
	buffer_options = {
		swapfile = false,
		bufhidden = 'delete',
		buftype = 'nowrite',
		undolevels = 0,
	},
	on_large_file_read_pre = function(ev)
		print("Opening a large file!")
	end
})
```

## Support

If you encounter any issues or have suggestions for improvements, please feel free to open an issue or a pull request on the repository. Your contributions are highly appreciated!
