return {
  -- ── Colorscheme: Catppuccin Mocha (matches Ghostty theme) ──────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        cmp = true,
        gitsigns = true,
        neotree = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
        mason = true,
        mini = { enabled = true },
      },
    },
  },
  -- Tell LazyVim to use catppuccin
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },

  -- ── YAML: add schema awareness (k8s, GitHub Actions, Docker Compose) ────────
  {
    "someone-stole-my-name/yaml-companion.nvim",
    ft = { "yaml" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
    keys = {
      { "<leader>cy", "<cmd>Telescope yaml_schema<CR>", desc = "Select YAML schema" },
    },
  },

  -- Override yaml-language-server and jsonls to use schema store
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.yamlls = vim.tbl_deep_extend("force", opts.servers.yamlls or {}, {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })
      opts.servers.jsonls = vim.tbl_deep_extend("force", opts.servers.jsonls or {}, {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })
      return opts
    end,
  },

  -- Schema store (powers yaml + json LSP schema awareness)
  { "b0o/SchemaStore.nvim", lazy = true },

  -- ── Helm template support ────────────────────────────────────────────────────
  {
    "towolf/vim-helm",
    ft = "helm",
  },

  -- ── Treesitter: add nushell parser ───────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "nushell",    -- your shell
        "bash",
        "regex",
        "diff",
      },
    },
  },

  -- ── conform.nvim: ensure terraform fmt runs on .tf and .tfvars ──────────────
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
      },
    },
  },
}
