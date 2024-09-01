local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pp', builtin.planets, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>gr', builtin.lsp_references, {})
vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
vim.keymap.set('n', '<leader>fs', builtin.grep_string, {})

vim.keymap.set('n', '<leader>gv', function() builtin.lsp_definitions({jump_type="vsplit"}) end, {noremap=true, silent=true})

local telescope = require("telescope")


telescope.setup {
  defaults = { path_display = { "smart" } },
  pickers = {
    buffers = {
      mappings = {
        n = {
          ["<c-d>"] = "delete_buffer",
        }
      }
    }
  }
}
