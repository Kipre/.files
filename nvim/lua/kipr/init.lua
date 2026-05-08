require("kipr.remap")
require("kipr.set")

vim.cmd [[
  au TextYankPost * silent! lua vim.highlight.on_yank {}
]]

vim.pack.add({
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/airblade/vim-gitgutter',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/tpope/vim-fugitive',
})


vim.lsp.enable({'ts_ls', 'biome', 'zls', 'clangd'})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_defintition, bufnr) then
      vim.keymap.set(
        'n',
        'gd',
        vim.lsp.buf.definition,
        { desc = 'LSP: go to definition', buffer = bufnr }
      )
    end
  end,
})

vim.diagnostic.config({ virtual_text = true })
