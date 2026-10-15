local map = vim.keymap.set

-- ── Editor ────────────────────────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "J", "mzJ`z")              -- Join line without moving cursor
map("n", "<C-d>", "<C-d>zz")        -- Keep cursor centered on page down
map("n", "<C-u>", "<C-u>zz")        -- Keep cursor centered on page up

-- ── Window navigation ─────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- ── Move lines ────────────────────────────────────────────────────────────────
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- ── Clipboard ─────────────────────────────────────────────────────────────────
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
-- Paste without clobbering clipboard register
map("x", "<leader>P", '"_dP', { desc = "Paste without yanking selection" })

-- ── Quickfix ──────────────────────────────────────────────────────────────────
map("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>qn", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "<leader>qp", "<cmd>cprev<CR>", { desc = "Prev quickfix" })
