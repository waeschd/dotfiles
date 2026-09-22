local get_hex = require("cokeline.hlgroups").get_hl_attr

local function focused_fg()
  return get_hex("lualine_a_normal", "fg")
end

local function focused_bg()
  return get_hex("lualine_a_normal", "bg")
end

local function other_fg()
  return get_hex("TabLine", "fg")
end

local function other_bg()
  return get_hex("TabLine", "bg")
end

local function normal_bg()
  return get_hex("Normal", "bg")
end

require("cokeline").setup({
  fill_hl = "Normal",
  show_if_buffers_are_at_least = 0,
  buffers = {
    -- Only show buffers that are in the *current* window's own list
    -- (win-buffers.lua), not every buffer open anywhere.
    filter_visible = function(buffer)
      for _, buf in ipairs(WinBufList()) do
        if buf == buffer.number then
          return true
        end
      end
      return false
    end,
  },
  tabs = {
    placement = "left",
    components = {
      {
        text = function(tab)
          return " " .. tab.number .. " "
        end,
        fg = focused_fg,
        bg = focused_bg,
      },
      {
        text = function(tab)
          return " "
        end,
        fg = normal_bg,
        bg = normal_bg,
      },
    }
  },
  components = {
    {
      text = function(buffer)
        return " " .. ""
      end,
      fg = function(buffer)
        return buffer.is_focused and focused_bg() or other_bg()
      end,
      bg = normal_bg,
    },
    {
      text = function(buffer)
        return " " .. buffer.devicon.icon
      end,
      fg = function(buffer)
        return buffer.is_focused and focused_fg() or buffer.devicon.color
      end,
      bg = function(buffer)
        return buffer.is_focused and focused_bg() or other_bg()
      end,
    },
    {
      text = function(buffer)
        -- Get relative path from Neovim root
        local root_dir = vim.fn.getcwd()

        if root_dir then
          local rel_path = vim.fn.fnamemodify(buffer.path, ":.")
          if rel_path:sub(1, #root_dir) == root_dir then
            rel_path = rel_path:sub(#root_dir + 2)
          end
          return " " .. rel_path .. " "
        end

        return " " .. buffer.filename .. " "
      end,
      fg = function(buffer)
        return buffer.is_focused and focused_fg() or other_fg()
      end,
      bg = function(buffer)
        return buffer.is_focused and focused_bg() or other_bg()
      end,
    },
    {
      text = function(buffer)
        if buffer.is_modified then
          return "" .. " "
        else
          return " " .. " "
        end
      end,
      fg = function(buffer)
        return buffer.is_focused and focused_fg() or buffer.devicon.color
      end,
      bg = function(buffer)
        return buffer.is_focused and focused_bg() or other_bg()
      end,
    },
    {
      text = " ",
      on_click = function(_, _, _, _, buffer)
        buffer:delete()
      end,
      fg = function(buffer)
        if buffer.is_hovered then
          return "#ff0000"
        elseif buffer.is_focused then
          return focused_fg()
        else
          return other_fg()
        end
      end,
      bg = function(buffer)
        return buffer.is_focused and focused_bg() or other_bg()
      end,
    },
    {
      text = function(buffer)
        return ""
      end,
      fg = function(buffer)
        return buffer.is_focused and focused_bg() or other_bg()
      end,
      bg = normal_bg,
    },
    {
      text = " ",
      bg = normal_bg,
    },
  },
})
