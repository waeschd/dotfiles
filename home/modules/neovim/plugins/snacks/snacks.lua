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
      cmd = 'date +"%H:%M:%S" | figlet -f standard | lolcat',
      height = 5,
      indent = 10,
      padding = 5,
      interactive = false,
      ttl = 0,
    },
    { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
    { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    {
      pane = 2,
      icon = " ",
      title = "Projects",
      section = "projects",
      indent = 2,
      padding = 1,
      dirs = function()
        -- auto-session isn't ported yet -- degrade to an empty list rather
        -- than erroring the whole dashboard when it's missing.
        local ok, auto_session_lib = pcall(require, "auto-session.lib")
        if not ok then
          return {}
        end

        local sessions_dir = vim.fn.stdpath("data") .. "/sessions/"
        local session_list = auto_session_lib.get_session_list(sessions_dir)

        local session_paths = {}
        for _, session in ipairs(session_list) do
          table.insert(session_paths, session.display_name)
        end
        return session_paths
      end,
    },
    function()
      local in_git = Snacks.git.get_root() ~= nil
      local cmds = {
        {
          icon = " ",
          title = "Git Status",
          cmd = [[ git fetch > /dev/null 2>&1
                if git rev-parse --abbrev-ref @{u} > /dev/null 2>&1; then
                  if [ "$(git rev-list --count HEAD..@{u})" -gt 0 ]; then
                    echo "󱞩 Current branch is behind."
                  else
                    echo " Current branch is up-to-date."
                  fi
                else
                  echo "󱇯 Remote is not set up."
                fi
                echo "──────────────────────────────────"
                git status -s]],
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
  },
  -- was a dead sibling key next to `opts` in the original lazy.nvim spec
  -- (only `opts` is actually passed to setup()), so this never took effect.
  statuscolumn = { enabled = true },
})

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
