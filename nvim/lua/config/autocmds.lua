local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
  group = "highlight_yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Remove trailing whitespace on save (except markdown where trailing spaces = line break)
augroup("trim_whitespace", { clear = true })
autocmd("BufWritePre", {
  group = "trim_whitespace",
  pattern = { "*.tf", "*.hcl", "*.yaml", "*.yml", "*.json", "*.toml", "*.go", "*.py", "*.lua" },
  command = [[%s/\s\+$//e]],
})

-- Set filetype for .tfvars and .tfbackend files
augroup("terraform_filetypes", { clear = true })
autocmd({ "BufRead", "BufNewFile" }, {
  group = "terraform_filetypes",
  pattern = { "*.tfvars", "*.tfbackend" },
  callback = function()
    vim.bo.filetype = "terraform"
  end,
})

-- Set filetype for Helm templates (yaml with Go templating)
augroup("helm_filetypes", { clear = true })
autocmd({ "BufRead", "BufNewFile" }, {
  group = "helm_filetypes",
  pattern = { "*/templates/*.yaml", "*/templates/*.tpl" },
  callback = function()
    vim.bo.filetype = "helm"
  end,
})
