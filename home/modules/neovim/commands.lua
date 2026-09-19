local function escape_regex(str)
  local specials = "^$()%.[]*+-?{}|\\"
  return (str:gsub(".", function(c)
    if specials:find(c, 1, true) then
      return "\\" .. c
    end
    return c
  end))
end

local root_markers = { ".git", "compile_commands.json", "compile_flags.txt", "Makefile", "CMakeLists.txt" }

local function project_root()
  return vim.fs.root(0, root_markers) or vim.fn.getcwd()
end

vim.api.nvim_create_user_command("FindMacro", function(opts)
  local macro = escape_regex(opts.args)
  local pattern = [[^\s*#\s*define\s*\b]] .. macro .. [[\b]]
  local search_dir = project_root()

  -- Args passed as a list (not a shell string), so no shell-injection risk
  -- regardless of what's in `macro`.
  local result = vim.system({ "rg", "--type=c", "--vimgrep", pattern, search_dir }, { text = true }):wait()

  if result.code ~= 0 and result.code ~= 1 then
    -- exit code 1 just means "no matches", anything else is a real error
    vim.notify("FindMacro: rg failed: " .. result.stderr, vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(result.stdout, "\n", { trimempty = true })

  if #lines == 0 then
    vim.notify("FindMacro: no definition found for " .. opts.args, vim.log.levels.WARN)
    return
  end

  if #lines == 1 then
    -- Exactly one match: jump straight to it, skip the quickfix list.
    local file, lnum, col = lines[1]:match("^(.-):(%d+):(%d+):")
    vim.cmd.edit(file)
    vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
    return
  end

  -- Multiple matches: let the user pick from the quickfix list.
  vim.fn.setqflist({}, " ", {
    title = "FindMacro: " .. opts.args,
    lines = lines,
    efm = "%f:%l:%c:%m", -- matches ripgrep's --vimgrep output format
  })
  vim.cmd("copen")
end, { nargs = 1, desc = "Find where a C macro is #define'd (jumps directly if unambiguous)" })

vim.api.nvim_create_user_command("BufOnly", function()
  vim.cmd("%bd|e#|bd#")
end, { desc = "Close every buffer except the current one" })
