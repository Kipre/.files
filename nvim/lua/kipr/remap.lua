vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv")

vim.keymap.set("n", "<A-j>", ":m +1<CR>")
vim.keymap.set("n", "<A-k>", ":m -2<CR>")

vim.keymap.set("n", "<A-l>", "xp")
vim.keymap.set("n", "<A-h>", "xhhp")

-- vim.keymap.set('n', '<CR>', 'm`o<Esc>``')
-- vim.keymap.set('n', '<S-CR>', 'm`O<Esc>``')


-- Map <leader>r to initiate a search and replace operation for the word under the cursor
vim.keymap.set('n', '<leader>r', [[:%s/\<<C-r><C-w>\>//gc<left><left>]], { noremap = true, silent = true })
-- vim.keymap.set('v', '<leader>r', [[:%s/\<y<C-R>\>//gc<left><left>]], { noremap = true, silent = true })

-- -- Mapping for adding empty lines below current line
-- function addEmptyLinesBelow()
--     local count = vim.v.count
--     local currentLine = vim.api.nvim_win_get_cursor(0)[1]
--     for _ = 1, count do
--         vim.api.nvim_buf_set_lines(0, currentLine - 1, currentLine - 1, false, {""})
--         currentLine = currentLine + 1
--     end
-- end
--
-- -- Mapping for adding empty lines above current line
-- function addEmptyLinesAbove()
--     local count = vim.v.count
--     local currentLine = vim.api.nvim_win_get_cursor(0)[1]
--     for _ = 1, count do
--         vim.api.nvim_buf_set_lines(0, currentLine - 2, currentLine - 2, false, {""})
--     end
-- end
--
-- -- Set key mappings for <leader>o and <leader>O
-- vim.keymap.set('n', '<leader>o', ':<C-u>lua addEmptyLinesBelow()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>O', ':<C-u>lua addEmptyLinesAbove()<CR>', { noremap = true, silent = true })
