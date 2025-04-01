vim.g.mapleader = " "

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv")

vim.keymap.set("n", "<A-j>", ":m +1<CR>")
vim.keymap.set("n", "<A-k>", ":m -2<CR>")

vim.keymap.set("n", "<A-l>", "xp")
vim.keymap.set("n", "<A-h>", "xhhp")

