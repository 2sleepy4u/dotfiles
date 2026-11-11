-- Vendored from api.noctalia.dev/templates/neovim (matugen-template.lua).
-- Instead of base16-nvim (which paints every identifier with base08/red), the
-- noctalia palette replaces catppuccin.nvim's 26 colors, so its highlight design
-- applies to whatever scheme is selected (and is plain Catppuccin for Catppuccin).
local M = {}

function M.setup()
  local palette = {
    rosewater = '{{colors.terminal_foreground.default.hex}}',
    flamingo  = '{{colors.terminal_bright_magenta.default.hex}}',
    pink      = '{{colors.terminal_normal_magenta.default.hex}}',
    mauve     = '{{colors.primary.default.hex}}',
    red       = '{{colors.terminal_normal_red.default.hex}}',
    maroon    = '{{colors.terminal_bright_red.default.hex}}',
    peach     = '{{colors.secondary.default.hex}}',
    yellow    = '{{colors.terminal_normal_yellow.default.hex}}',
    green     = '{{colors.terminal_normal_green.default.hex}}',
    teal      = '{{colors.terminal_normal_cyan.default.hex}}',
    sky       = '{{colors.terminal_bright_cyan.default.hex}}',
    sapphire  = '{{colors.terminal_bright_blue.default.hex}}',
    blue      = '{{colors.terminal_normal_blue.default.hex}}',
    lavender  = '{{colors.on_surface_variant.default.hex}}',
    text      = '{{colors.on_surface.default.hex}}',
    subtext1  = '{{colors.terminal_bright_white.default.hex}}',
    subtext0  = '{{colors.terminal_normal_white.default.hex}}',
    overlay2  = '{{colors.terminal_normal_white.default.hex}}',
    overlay1  = '{{colors.outline.default.hex}}',
    overlay0  = '{{colors.outline.default.hex}}',
    surface2  = '{{colors.terminal_bright_black.default.hex}}',
    surface1  = '{{colors.terminal_normal_black.default.hex}}',
    surface0  = '{{colors.surface_container.default.hex}}',
    base      = '{{colors.surface.default.hex}}',
    mantle    = '{{colors.surface_dim.default.hex}}',
    crust     = '{{colors.shadow.default.hex}}',
  }

  require('catppuccin').setup({
    flavour = '{{mode}}' == 'light' and 'latte' or 'mocha',
    color_overrides = { all = palette },
  })
  vim.cmd.colorscheme('catppuccin')
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
