local group

-- On yank
group = vim.api.nvim_create_augroup("TextYankPost", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Print amount of bytes selected",
  group = group,
  callback = function()
    local lines = vim.v.event.regcontents
    local byte_count = 0

    for _, line in ipairs(lines) do
      byte_count = byte_count + #line + 1
    end

    byte_count = math.max(0, byte_count - 1)

    if byte_count > 100 then
      vim.notify(
        "Yanked " .. byte_count .. " bytes over " .. #lines .. " lines",
        vim.log.levels.INFO,
        { title = "Clipboard" }
      )
    end
  end,
})

-- Terminal window settings
group = vim.api.nvim_create_augroup("TerminalSettings", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Terminal Settings",
  group = group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false

    vim.opt_local.signcolumn = "no"
    --vim.cmd.startinsert()
  end,
})

-- Closing Neovim
group = vim.api.nvim_create_augroup("CursorReset", { clear = true })

vim.api.nvim_create_autocmd("VimLeave", {
  desc = "Settings for closing NeoVim",
  group = group,
  pattern = "*",
  callback = function()
    vim.opt.guicursor = "a:ver25-blinkon0"
  end,
})

-- Important
vim.opt.updatetime = 400
-- Important
--
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "LspReferenceText", { link = "CursorLine" })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "CursorLine" })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "CursorLine" })
  end,
})

local lsp_highlight_group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    if not client or not client.server_capabilities.documentHighlightProvider then
      return
    end

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      group = lsp_highlight_group,
      callback = vim.lsp.buf.document_highlight,
      desc = "LSP document highlight",
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = bufnr,
      group = lsp_highlight_group,
      callback = vim.lsp.buf.clear_references,
      desc = "Clear LSP references",
    })
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    vim.api.nvim_clear_autocmds({
      group = lsp_highlight_group,
      buffer = args.buf,
    })
    vim.lsp.buf.clear_references()
  end,
})
