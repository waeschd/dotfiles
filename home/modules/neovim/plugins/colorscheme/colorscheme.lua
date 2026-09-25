require("onedark").setup({
  style = "warmer",
  highlights = {
    NormalFloat = { bg = "NONE" },
  },
})

require("github-theme").setup({
  options = {
    transparent = false,
    dim_inactive = false,
    darken = { -- Darken floating windows and sidebar-like windows
      floats = false,
      sidebars = {
        enable = false,
        list = {}, -- Apply dark background to specific windows
      },
    },
  },
  specs = {
    github_light = {
      -- A palette defines the following:
      --   bg0, bg1, bg2, bg3, bg4, fg0, fg1, fg2, fg3, sel0, sel1, comment
      bg0 = "#c9c9c9",
      bg1 = "#d4d4d4",
    },
  },
})

-- Activate ondedark per default
vim.cmd.colorscheme("github_dark")
