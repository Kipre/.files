require("kipr.remap")
require("kipr.set")

vim.cmd [[
  au TextYankPost * silent! lua vim.highlight.on_yank {}
]]


vim.lsp.enable({'ts_ls', 'biome', 'zls', 'clangd'})

function find_git_root(bufnr, on_dir)
  project_root = vim.fs.root(bufnr, {'.git'});
  if not project_root then
    return
  end
  return on_dir(project_dir)
end

vim.lsp.config('biome', { root_dir = find_git_root })
vim.lsp.config('ts_ls', { root_dir = find_git_root })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.diagnostic.config({ virtual_text = true })
