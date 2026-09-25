local dashboard = {
  pane_gap = 15, -- empty columns between vertical panes
  preset = {
    header = [[
███████╗ ███╗   ██╗ ███████╗ ███████╗ ██████╗   █████╗  ██╗    
██╔════╝ ████╗  ██║ ██╔══██╗ ██╔════╝ ██╔══██╗ ██╔══██╗ ██║    
█████╗   ██╔██╗ ██║ ██║  ██║ █████╗   ██████╔╝ ███████║ ██║    
██╔══╝   ██║╚██╗██║ ██║  ██║ ██╔══╝   ██╔══██╗ ██╔══██║ ██║    
███████╗ ██║ ╚████║ ██████╔╝ ███████╗ ██║  ██║ ██║  ██║ ██████╗
╚══════╝ ╚═╝  ╚═══╝ ╚═════╝  ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═════╝
]],
    keys = {
      { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
      {
        icon = " ",
        key = "r",
        desc = "Recent Files",
        action = ":lua Snacks.picker.recent({filter = { cwd = true } })",
      },
      {
        icon = " ",
        key = "c",
        desc = "Config",
        action = ":lua Snacks.picker.files({dirs = { vim.env.HOME .. '/nixos/nixos-system/home/modules/neovim' }})",
      },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
  },
  sections = {
    { section = "header" },
    {
      pane = 2,
      section = "terminal",
      cmd = 'while true; do clear; date +"%H:%M:%S" | figlet -f standard; sleep 1; done',
      height = 5,
      indent = 10,
      padding = 4,
      ttl = 0,
    },
    { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
    { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    { pane = 2, icon = " ", title = "Sessions", section = "sessions", indent = 2, padding = 1 },
    function()
      local in_git = Snacks.git.get_root() ~= nil
      local cmds = {
        {
          icon = " ",
          title = "Git Status",
          cmd = [[ if git rev-parse --abbrev-ref @{u} > /dev/null 2>&1; then
                  if [ "$(git rev-list --count HEAD..@{u})" -gt 0 ]; then
                    echo "󱞩 Current branch is behind."
                  else
                    echo " Current branch is up-to-date."
                  fi
                else
                  echo "󱇯 Remote is not set up."
                fi
                echo "──────────────────────────────────"
                git status -s
                sleep infinity]],
          height = 10,
        },
      }
      return vim.tbl_map(function(cmd)
        return vim.tbl_extend("force", {
          pane = 2,
          section = "terminal",
          enabled = in_git,
          padding = 1,
          ttl = 0,
          indent = 3,
        }, cmd)
      end, cmds)
    end,
  },
}

require("snacks").setup({
  dashboard = dashboard,
  indent = {
    indent = {
      enabled = true,
      char = "╎",
    },
    scope = {
      enabled = true,
      char = "╎",
      underline = false,
    },
    chunk = {
      enabled = false,
      char = {
        corner_top = "╭",
        corner_bottom = "╰",
      },
    },
    filter = function(buf, win)
      return vim.g.snacks_indent ~= false
          and vim.b[buf].snacks_indent ~= false
          and vim.bo[buf].buftype == ""
          and vim.bo[buf].filetype ~= "markdown"
    end,
  },
  notifier = { enabled = true },
  input = { enabled = false, prompt_pos = "left" },
  image = { enabled = true, force = true },
  scroll = { enabled = false },
  picker = {
    sources = {
      files = {},
    },
    debug = {
      files = false, -- show file debug info
      grep = false, -- show file debug info
      proc = false, -- show proc debug info
    },
    win = {
      input = {
        keys = {
          ["<c-g>"] = false,
          ["<a-g>"] = { "toggle_live", mode = { "i", "n" } },
        },
      },
      list = {
        keys = {
          ["<c-g>"] = false,
          ["<a-g>"] = "toggle_live",
        },
      },
    },
  },
  statuscolumn = { enabled = true },
})

-- Per-project picker search history. Snacks keeps one global history file
-- per source (~/.local/share/nvim/snacks/picker_<source>.history) with no
-- project awareness at all -- this patches the one place that builds that
-- filename so it also incorporates the current project root, giving each
-- project its own separate history instead of one shared across all of them.
do
  local History = require("snacks.picker.util.history")
  local orig_history_new = History.new
  History.new = function(name, opts)
    local root = Snacks.git.get_root() or vim.fn.getcwd()
    local suffix = vim.fn.fnamemodify(root, ":t"):gsub("[^%w_-]", "_") .. "_" .. vim.fn.sha256(root):sub(1, 8)
    return orig_history_new(name .. "_" .. suffix, opts)
  end
end

-- :HistoryEdit [source] -- edit the current project's picker search history
-- (default source: grep) as a plain text buffer, one search per line.
-- snacks' own .history file is LuaJIT string.buffer binary, not text --
-- hand-editing it isn't viable (no reliable delimiter between entries, and
-- every length-prefix after an edit point would go stale). This instead
-- decodes it into a real table, shows it as editable lines, and re-encodes
-- on save. Deleting a line removes that search; adding a line adds one;
-- reordering changes chronological order (oldest at the top).
local function history_path(source)
  local root = Snacks.git.get_root() or vim.fn.getcwd()
  local suffix = vim.fn.fnamemodify(root, ":t"):gsub("[^%w_-]", "_") .. "_" .. vim.fn.sha256(root):sub(1, 8)
  local name = "picker_" .. source .. "_" .. suffix
  return vim.fn.stdpath("data") .. "/snacks/" .. name .. ".history", name
end

vim.api.nvim_create_user_command("HistoryEdit", function(cmd_args)
  local source = cmd_args.args ~= "" and cmd_args.args or "grep"
  local path, name = history_path(source)

  local data = {}
  local fd = io.open(path, "rb")
  if fd then
    local raw = fd:read("*a")
    fd:close()
    local ok, decoded = pcall(require("string.buffer").decode, raw)
    if ok and type(decoded) == "table" then
      data = decoded
    end
  end

  local keys = {}
  for k in pairs(data) do
    table.insert(keys, k)
  end
  table.sort(keys)

  -- Keep each line's original record so editing doesn't change how it
  -- behaves on recall -- only genuinely new lines (no matching original)
  -- fall back to the source's own default. Real picker sources (e.g.
  -- "grep") record {pattern=, search=, live=} dicts; scoped Snacks.input
  -- prompts (e.g. "grep_include"/"grep_exclude", see scoped_input below)
  -- record plain strings -- tolerate both.
  local lines = {}
  local orig_by_text = {}
  for _, k in ipairs(keys) do
    local rec = data[k]
    local text = type(rec) == "table" and ((rec.search and rec.search ~= "") and rec.search or rec.pattern or "") or rec
    if text ~= "" then
      table.insert(lines, text)
      orig_by_text[text] = rec
    end
  end

  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "snacks_history_edit"
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_name(buf, "HistoryEdit: " .. source)

  -- Only real picker sources (e.g. "grep") use the {pattern=, search=,
  -- live=} dict format; brand-new lines with no original record fall back
  -- to that shape only for those, and to a plain string otherwise (see
  -- the read side above for why both shapes need to round-trip).
  local source_cfg = require("snacks.picker.config.sources")[source]

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local new_data = {}
      local idx = 1
      for _, line in ipairs(new_lines) do
        if line:match("%S") then
          new_data[idx] = orig_by_text[line]
            or (source_cfg and { pattern = line, search = line, live = source_cfg.live } or line)
          idx = idx + 1
        end
      end

      vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
      local out = io.open(path, "w+b")
      if not out then
        vim.notify("Failed to save history file: " .. path, vim.log.levels.ERROR)
        return
      end
      out:write(require("string.buffer").encode(new_data))
      out:close()

      -- Drop the in-memory cache so the next picker for this source reads
      -- our freshly written file instead of a stale copy from earlier in
      -- this session (History.new caches loaded stores by name).
      require("snacks.picker.util.history").stores[name] = nil

      vim.bo[buf].modified = false
      vim.notify(("Saved %s history: %d entries"):format(source, idx - 1))
    end,
  })

  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].modified = false
end, {
  nargs = "?",
  desc = "Edit the current project's picker search history (default source: grep) as plain text",
})

Snacks.dashboard.sections.sessions = function()
  local ok, auto_session_lib = pcall(require, "auto-session.lib")
  if not ok then
    return {}
  end

  local sessions_dir = vim.fn.stdpath("data") .. "/sessions/"
  local session_list = auto_session_lib.get_session_list(sessions_dir)

  local items = {}
  for _, session in ipairs(session_list) do
    local is_path = session.session_name:sub(1, 1) == "/"
    table.insert(items, {
      icon = "directory",
      desc = is_path and vim.fn.fnamemodify(session.session_name, ":t") or session.session_name,
      autokey = true,
      action = function()
        if is_path then
          vim.fn.chdir(session.session_name)
        end
        require("auto-session").restore_session(is_path and nil or session.session_name)
      end,
    })
  end
  return items
end

vim.keymap.set("n", "<leader>sm", function()
  Snacks.picker()
end, { desc = "(Snacks) Menu", silent = true })

vim.keymap.set("n", "<leader>fm", function()
  Snacks.picker.man()
end, { desc = "(Snacks) Find manual pages", silent = true })

vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "(Snacks) Find files", silent = true })

-- Snacks.input() (= vim.ui.input(), the small floating prompt with
-- <Up>/<Down> history navigation) always records to one shared "input"
-- history bucket: snacks/input.lua calls
-- `require("snacks.picker.util.history").new("input", ...)` with that name
-- hardcoded, with no option to override it. History.new() itself takes an
-- arbitrary name, though, and is only ever asked for *synchronously*,
-- before Snacks.input opens its window -- so rather than reimplementing
-- that window, swap History.new out for just that one call so it gets the
-- name we actually want, then immediately put it back.
--
-- This is what gives "picker_grep_include" and "picker_grep_exclude" their
-- own separate, non-mixed history, editable the same way as any other
-- picker source via `:HistoryEdit grep_include` / `:HistoryEdit
-- grep_exclude` (same "picker_" .. source naming convention).
--
-- Also prefills the prompt with the last value it was confirmed with, so
-- the common case of repeating/tweaking the last search doesn't need an
-- <Up> press first. This is tracked separately from history browsing,
-- in a small sidecar "<name>.last" file next to the "<name>.history" one,
-- because input.lua's own `record()` drops empty confirms (never adds
-- them to history) -- if "last used" were read back from history like
-- <Up>/<Down> browsing is, confirming empty (no include/exclude filter)
-- could never stick as the next default; it'd always fall back to
-- whatever non-empty value was last recorded.
local function scoped_input(history_name, opts, on_confirm)
  local History = require("snacks.picker.util.history")
  local wrapped_new = History.new
  local last_path
  History.new = function(_, o)
    History.new = wrapped_new
    local history = wrapped_new(history_name, o)
    last_path = history.path:gsub("%.history$", ".last")
    if opts.default == nil then
      local fd = io.open(last_path, "r")
      if fd then
        opts.default = fd:read("*a")
        fd:close()
      else
        opts.default = ""
      end
    end
    return history
  end
  Snacks.input(opts, function(value)
    if value ~= nil and last_path then
      vim.fn.mkdir(vim.fn.fnamemodify(last_path, ":h"), "p")
      local fd = io.open(last_path, "w")
      if fd then
        fd:write(value)
        fd:close()
      end
    end
    on_confirm(value)
  end)
end

local function split_globs(raw)
  local out = {}
  for pat in raw:gmatch("[^,]+") do
    table.insert(out, vim.trim(pat))
  end
  return out
end

vim.keymap.set("n", "<leader>fg", function()
  scoped_input("picker_grep_include", { prompt = "Include (comma-separated globs)" }, function(include_raw)
    if include_raw == nil then
      return -- cancelled
    end
    scoped_input("picker_grep_exclude", { prompt = "Exclude (comma-separated globs)" }, function(exclude_raw)
      if exclude_raw == nil then
        return -- cancelled
      end
      Snacks.picker.grep({ glob = split_globs(include_raw), exclude = split_globs(exclude_raw) })
    end)
  end)
end, { desc = "(Snacks) Find text", silent = true })

vim.keymap.set("n", "<leader>cd", function()
  if Snacks.dim.enabled then
    Snacks.dim.disable()
  else
    Snacks.dim.enable()
  end
end, { desc = "(Snacks) Toggle dimming", silent = true })

vim.keymap.set("n", "<leader>fc", function()
  Snacks.picker.files({ cwd = vim.env.HOME .. "/nixos/nixos-system/home/modules/neovim" })
end, { desc = "(Snacks) Find config file" })

vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent({ filter = { cwd = true } })
end, { desc = "(Snacks) Find recent file (cwd)" })

vim.keymap.set("n", "<leader>fR", function()
  Snacks.picker.recent()
end, { desc = "(Snacks) Find recent file" })

vim.keymap.set("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "(Snacks) Find buffer" })

vim.keymap.set("n", "<leader>sd", function()
  if vim.bo.filetype ~= "snacks_dashboard" then
    Snacks.dashboard.open({ win = vim.api.nvim_get_current_win() })
  end
end, { desc = "(Snacks) Open dashboard" })
