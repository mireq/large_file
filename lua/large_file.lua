-- Create a new autocommand group for large file optimizations
local group = vim.api.nvim_create_augroup("LargeFileAutocmds", {})
-- Variable to store the previous state of eventignore
local old_eventignore = false

-- Default settings for handling large files
local default_settings = {
	size_limit = 4 * 1024 * 1024,  -- 4 MB size limit for a file to be considered large
	buffer_options = {  -- Buffer options to apply for large files
		swapfile = false,  -- Disable swapfile for large files
		bufhidden = 'unload',  -- Unload buffer when hidden
		buftype = 'nowrite',  -- Set buffer type to nowrite
		undolevels = -1,  -- Disable undo levels
	},
	on_large_file_read_pre = function(ev) end  -- Placeholder for a callback before reading a large file
}

-- Settings variable that will be configured by the user or default settings
local settings = {}

-- Function to handle BufReadPre event
local buf_read_pre = function(ev)
	if ev.file then
		local status, size = pcall(function() return vim.loop.fs_stat(ev.file).size end)
		if status and size > settings.size_limit then
			old_eventignore = vim.o.eventignore  -- Store the current eventignore setting
			vim.b[ev.buf].is_large_file = true  -- Mark buffer as containing a large file
			vim.o.eventignore = 'FileType'  -- Ignore FileType events to optimize performance
			for option, value in pairs(settings.buffer_options) do
				vim.bo[option] = value  -- Apply buffer options for large files
			end
			settings.on_large_file_read_pre(ev)  -- Invoke callback for large file read pre-event
		end
	end
end

-- Function to handle BufWinEnter event
local buf_win_enter = function(ev)
	if old_eventignore ~= false then
		vim.o.eventignore = old_eventignore  -- Restore the eventignore setting
		old_eventignore = false
	end
	if vim.b[ev.buf].is_large_file then
		vim.wo.wrap = false  -- Disable line wrapping for large files
	else
		vim.wo.wrap = vim.o.wrap  -- Restore line wrapping setting
	end
end

-- Function to handle BufEnter event
local buf_enter = function(ev)
	if vim.b[ev.buf].is_large_file then
		if vim.g.loaded_matchparen then
			vim.cmd('NoMatchParen')  -- Disable matching parentheses highlighting for large files
		end
	else
		if not vim.g.loaded_matchparen then
			vim.cmd('DoMatchParen')  -- Enable matching parentheses highlighting
		end
	end
end

-- Module table
M = {}

-- Setup function to configure the module
M.setup = function(opts)
	if opts == nil then
		opts = {}
	end

	for __, option in ipairs({'size_limit', 'buffer_options', 'on_large_file_read_pre'}) do
		if opts[option] == nil then
			settings[option] = default_settings[option]  -- Use default setting if not provided
		else
			settings[option] = opts[option]  -- Use provided setting
		end
	end

	-- Create autocommands for the specified events
	vim.api.nvim_create_autocmd({"BufReadPre"}, {
		group = group,
		callback = buf_read_pre
	})

	vim.api.nvim_create_autocmd({"BufWinEnter"}, {
		group = group,
		callback = buf_win_enter
	})

	vim.api.nvim_create_autocmd({"BufEnter"}, {
		group = group,
		callback = buf_enter
	})
end

-- Return the module table
return M
