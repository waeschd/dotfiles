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
  -- was a dead sibling key next to `opts` in the original lazy.nvim spec
  -- (only `opts` is actually passed to setup()), so this never took effect.
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

  -- Keep each line's original record (pattern/search/live) so editing
  -- doesn't change how it behaves on recall -- only genuinely new lines
  -- (no matching original) fall back to the source's own default.
  local lines = {}
  local orig_by_text = {}
  for _, k in ipairs(keys) do
    local rec = data[k]
    local text = (rec.search and rec.search ~= "") and rec.search or rec.pattern or ""
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

  local default_live = (require("snacks.picker.config.sources")[source] or {}).live

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local new_data = {}
      local idx = 1
      for _, line in ipairs(new_lines) do
        if line:match("%S") then
          new_data[idx] = orig_by_text[line] or { pattern = line, search = line, live = default_live }
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

vim.keymap.set("n", "<leader>fg", function()
  Snacks.picker.grep()
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
