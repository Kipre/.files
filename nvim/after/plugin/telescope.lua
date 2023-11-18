local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pp', builtin.planets, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>gr', builtin.lsp_references, {})
vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

-- vim.keymap.set('n', '<leader>pd', builtin.lsp_definitions, {noremap=true, silent=true})
vim.keymap.set('n', '<leader>gv', function() builtin.lsp_definitions({jump_type="vsplit"}) end, {noremap=true, silent=true})



local telescope = require("telescope")
-- load refactoring Telescope extension
telescope.load_extension("refactoring")

vim.keymap.set(
	{"n", "x"},
	"<leader>rr",
	function() telescope.extensions.refactoring.refactors() end
)


