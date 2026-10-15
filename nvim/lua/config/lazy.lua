-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to continue..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core + all its default plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ── Language extras ──────────────────────────────────────────────────────
    -- Each extra wires up: LSP server, treesitter parser, formatter, linter
    { import = "lazyvim.plugins.extras.lang.terraform" }, -- terraform-ls, tflint, HCL
    { import = "lazyvim.plugins.extras.lang.go" },        -- gopls, gofmt, goimports
    { import = "lazyvim.plugins.extras.lang.python" },    -- pyright, ruff, black
    { import = "lazyvim.plugins.extras.lang.json" },      -- jsonls, prettier
    { import = "lazyvim.plugins.extras.lang.yaml" },      -- yaml-language-server, prettier
    { import = "lazyvim.plugins.extras.lang.toml" },      -- taplo
    { import = "lazyvim.plugins.extras.lang.docker" },    -- dockerls, docker-compose-ls

    -- ── Custom overrides & additions ─────────────────────────────────────────
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
