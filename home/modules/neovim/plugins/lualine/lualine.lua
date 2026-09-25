local function get_hex(group, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
  if not ok or not hl then
    return nil
  end

  local value = hl[attr]
  if not value then
    return nil
  end

  -- Convert decimal color to hex
  return string.format("#%06x", value)
end

local function normal_bg()
  return get_hex("Normal", "bg")
end

local function normal_fg()
  return get_hex("Normal", "fg")
end

local function component_bg()
  return get_hex("Normal", "bg")
end

local function component_fg()
  return get_hex("Normal", "fg")
end

-- lualine.nvim re-runs this on every ColorScheme change
local function build_lualine_theme()
  local custom_ayu = require("lualine.themes.ayu_dark")
  local fg, bg = normal_fg(), normal_bg()

  for _, mode in ipairs({ "normal", "insert", "visual", "replace", "inactive" }) do
    custom_ayu[mode].c = { fg = fg, bg = bg }
    custom_ayu[mode].x = { fg = fg, bg = bg }
  end

  return custom_ayu
end
-----------------------------------------------------------------------------------------------------
local function seperator(opts)
  return {
    function()
      if opts.pos == "left" then
        return ""
      else
        return ""
      end
    end,
    color = function(section)
      local fg = type(opts.fg) == "function" and opts.fg(section) or opts.fg
      local bg = type(opts.bg) == "function" and opts.bg(section) or opts.bg
      return { fg = fg, bg = bg }
    end,
    cond = function()
      local val = type(opts.cond) == "function" and opts.cond() or opts.cond
      return val
    end,
  }
end
-----------------------------------------------------------------------------------------------------
local function space_component(cond)
  return {
    function()
      return " "
    end,
    color = function(section)
      return { fg = normal_fg(), bg = normal_bg() }
    end,
    cond = function()
      local val = type(cond) == "function" and cond() or cond
      return val
    end,
  }
end
-----------------------------------------------------------------------------------------------------
local function get_mode_color()
  local mode = vim.fn.mode()
  local hl_group = ""

  if mode:match("^n") then
    hl_group = "lualine_a_normal"
  elseif mode:match("^i") then
    hl_group = "lualine_a_insert"
  elseif mode:match("^R") then
    hl_group = "lualine_a_replace"
  elseif mode:match("^[vV\22]") then -- visual, visual line, visual block
    hl_group = "lualine_a_visual"
  elseif mode:match("^c") then
    hl_group = "lualine_a_command"
  elseif mode:match("^t") then
    hl_group = "lualine_a_terminal"
  elseif mode:match("^[sS\19]") then -- select, select line, select block
    hl_group = "lualine_a_visual"
  else
    hl_group = ""
  end

  if hl_group == "" then
    vim.notify(
      "Unknown mode entered: \"" .. tostring(mode) .. "\". Could not adjust color for mode in statusline.",
      vim.log.levels.ERROR
    )
    hl_group = "lualine_a_inactive"
  end


  return get_hex(hl_group, "bg")

end

local mode = {
  seperator({ pos = "left", fg = get_mode_color, bg = normal_bg, cond = true }),
  {
    "mode",
    fmt = function(str)
      return " " .. str:sub(1, 1) .. " "
    end,
  },
  seperator({ pos = "right", fg = get_mode_color, bg = normal_bg, cond = true }),
}
-----------------------------------------------------------------------------------------------------
local function in_git_repo()
  local git_dir = vim.fn.finddir(".git", ".;")
  return git_dir ~= ""
end

local git = {
  seperator({ pos = "left", fg = "#dbb671", bg = normal_bg, cond = in_git_repo }),
  {
    function()
      return ""
    end,
    color = function(section)
      return { fg = "#1d1a2b", bg = "#dbb671" }
    end,
    cond = in_git_repo,
  },
  {
    "branch",
    icon = "",
    color = function(section)
      return { fg = "#000000", bg = "#dbb671" }
    end,
    cond = in_git_repo,
  },
  seperator({ pos = "right", fg = "#dbb671", bg = normal_bg, cond = in_git_repo }),
  {
    function()
      return " "
    end,
    color = function(section)
      return { fg = normal_fg(), bg = normal_bg()}
    end,
    cond = in_git_repo,
  },
  {
    function()
      return " "
    end,
    color = function(section)
      return { fg = component_fg(), bg = component_bg() }
    end,
    cond = in_git_repo,
  },
  {
    "diff",
    symbols = { added = " ", modified = " ", removed = " " },
    cond = in_git_repo,
  },
  space_component(in_git_repo),
  seperator({ pos = "right", fg = "#bdee67", bg = normal_bg, cond = false }),
}
-----------------------------------------------------------------------------------------------------
local function diagnostics_enabled()
  local diagnostics = vim.diagnostic.get(vim.api.nvim_get_current_buf())
  if #diagnostics == 0 then
    return false
  else
    return true
  end
end

local diagnostics = {
  seperator({ pos = "left", fg = "#34a4d9", bg = normal_bg, cond = diagnostics_enabled }),
  {
    function()
      return " "
    end,
    color = function(section)
      return { fg = "#1d1a2b", bg = "#34a4d9" }
    end,
    cond = diagnostics_enabled,
  },
  space_component(diagnostics_enabled),
  {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
    cond = diagnostics_enabled,
  },
  space_component(diagnostics_enabled),
  seperator({ pos = "right", fg = "#34a4d9", bg = normal_bg, cond = false }),
}
-----------------------------------------------------------------------------------------------------
-- auto-session isn't guaranteed to be installed, so this degrades to
-- "no project shown" instead of erroring when it's missing.
local function current_session_name()
  local ok, auto_session_lib = pcall(require, "auto-session.lib")
  if not ok then
    return ""
  end
  return auto_session_lib.current_session_name(true)
end

local function in_project()
  return current_session_name() ~= ""
end

local project = {
  seperator({ pos = "left", fg = "#fcb5e2", bg = normal_bg, cond = in_project }),
  {
    function()
      return " "
    end,
    color = function(section)
      return { fg = "#1d1a2b", bg = "#fcb5e2" }
    end,
    cond = in_project,
  },
  {
    function()
      return " " .. current_session_name()
    end,
    color = function(section)
      return { fg = component_fg(), bg = component_bg() }
    end,
    cond = in_project,
  },
  space_component(in_project),
  seperator({ pos = "right", fg = "#fcb5e2", bg = normal_bg, cond = false }),
}
-----------------------------------------------------------------------------------------------------
local time = {
  seperator({ pos = "left", fg = "#ffa474", bg = normal_bg, cond = true }),
  {
    function()
      return " "
    end,
    color = function(section)
      return { fg = "#1d1a2b", bg = "#ffa474" }
    end,
  },
  {
    function()
      return " " .. os.date("%H:%M %Y-%m-%d")
    end,
    color = function(section)
      return { fg = component_fg(), bg = component_bg() }
    end,
  },
  space_component(true),
  seperator({ pos = "right", fg = "#ffa474", bg = normal_bg, cond = false }),
}
-----------------------------------------------------------------------------------------------------
local file_info = {
  seperator({ pos = "left", fg = "#87e091", bg = normal_bg, cond = true }),
  {
    function()
      return " "
    end,
    color = function(section)
      return { fg = "#1d1a2b", bg = "#87e091" }
    end,
  },
  {
    function()
      local fmt_icon = {
        unix = " ",
        dos = " ",
        mac = " ",
      }

      local ft = vim.bo.filetype
      local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
      local fileformat = vim.bo.fileformat
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local total_lines = vim.api.nvim_buf_line_count(0)
      local percent = math.floor((row / total_lines) * 100)

      local function pad_num(num, max_num, reverse)
        local max_digits = tostring(max_num):len()
        local s = tostring(num)
        local pad = string.rep(" ", max_digits - #s)

        if reverse then
          return s .. pad -- padding at the end
        else
          return pad .. s -- padding at the start (default)
        end
      end

      return " "
          .. (fmt_icon[fileformat] or fileformat)
          .. enc
          .. " "
          .. ft
          .. " "
          .. pad_num(row, total_lines, false)
          .. ":"
          .. pad_num(col + 1, 999, true)
          .. " "
          .. pad_num(percent, 100, false)
          .. "%%"
    end,
    color = function(section)
      return { fg = component_fg(), bg = component_bg() }
    end,
  },
  space_component(true),
  seperator({ pos = "right", fg = "#87e091", bg = normal_bg, cond = false }),
}
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
local sections = {}
-----------------------------------------------------------------------------------------------------
sections.lualine_a = {}
vim.list_extend(sections.lualine_a, mode)
-----------------------------------------------------------------------------------------------------
sections.lualine_b = {}
-----------------------------------------------------------------------------------------------------
sections.lualine_c = {}
vim.list_extend(sections.lualine_c, { space_component(true) })
vim.list_extend(sections.lualine_c, git)
-----------------------------------------------------------------------------------------------------
sections.lualine_x = {}
vim.list_extend(sections.lualine_x, { "searchcount", maxcount = 999, timeout = 500 })
vim.list_extend(sections.lualine_x, { space_component(true) })

vim.list_extend(sections.lualine_x, diagnostics)
vim.list_extend(sections.lualine_x, { space_component(diagnostics_enabled) })

vim.list_extend(sections.lualine_x, project)
vim.list_extend(sections.lualine_x, { space_component(in_project) })

vim.list_extend(sections.lualine_x, time)
vim.list_extend(sections.lualine_x, { space_component(true) })

vim.list_extend(sections.lualine_x, file_info)
-----------------------------------------------------------------------------------------------------
sections.lualine_y = {}
-----------------------------------------------------------------------------------------------------
sections.lualine_z = {}
-----------------------------------------------------------------------------------------------------
require("lualine").setup({
  options = {
    component_separators = "",
    section_separators = "",
    padding = 0,
    theme = build_lualine_theme,
    globalstatus = true,
    always_divide_middle = true,
    disabled_filetypes = {
      statusline = { "snacks_dashboard", "snacks_picker_list", "aerial" },
    },
  },
  sections = sections,
  inactive_sections = sections,
})
