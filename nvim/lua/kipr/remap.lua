vim.g.mapleader = " "

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv")

vim.keymap.set("n", "<A-j>", ":m +1<CR>")
vim.keymap.set("n", "<A-k>", ":m -2<CR>")

vim.keymap.set("n", "<A-l>", "xp")
vim.keymap.set("n", "<A-h>", "xhhp")

vim.keymap.set("t", "²", "<C-\\><C-n>")
vim.keymap.set("n", "²", "<esc>")
vim.keymap.set("v", "²", "<esc>")
vim.keymap.set("i", "²", "<esc>")

vim.api.nvim_create_user_command('Ex', function()
  vim.cmd('e ' .. vim.fn.expand('%:p:h'))
end, { force = true })
