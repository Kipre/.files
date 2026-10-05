local builtin = require('telescope.builtin')
local telescope = require("telescope")
telescope.load_extension("live_grep_args")

vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope git files' })
vim.keymap.set('n', '<leader>fr', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fg', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = 'Telescope live grep with raw args' })
vim.keymap.set('x', '<leader>fg', function()
  local selection = table.concat(
    vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() }),
    ' '
  )
  builtin.live_grep_raw({ default_text = selection })
end, { desc = 'Telescope live grep selection' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

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
