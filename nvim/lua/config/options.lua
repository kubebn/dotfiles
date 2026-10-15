local opt = vim.opt

-- ── Indentation ───────────────────────────────────────────────────────────────
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- ── Line numbers ──────────────────────────────────────────────────────────────
opt.number = true
opt.relativenumber = true

-- ── Display ───────────────────────────────────────────────────────────────────
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "120"

-- ── Search ────────────────────────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true

-- ── Splits ────────────────────────────────────────────────────────────────────
opt.splitbelow = true
opt.splitright = true

-- ── Performance ───────────────────────────────────────────────────────────────
opt.updatetime = 200
opt.timeoutlen = 300

-- ── Misc ──────────────────────────────────────────────────────────────────────
opt.undofile = true       -- Persistent undo history across sessions
opt.termguicolors = true
