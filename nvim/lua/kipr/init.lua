require("kipr.remap")
require("kipr.set")

vim.cmd [[
  au TextYankPost * silent! lua vim.highlight.on_yank {}
]]

vim.pack.add({
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/hat0uma/csvview.nvim.git',
  'https://github.com/samjwill/nvim-unception',
})

vim.lsp.enable({
  'tsc', 'biome', 'zls', 'clangd', 'copilot', 'rust_analyzer', 'ruff', 'ty',
})

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

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

      vim.keymap.set(
        'i',
        '<C-F>',
        vim.lsp.inline_completion.get,
        { desc = 'LSP: accept inline completion', buffer = bufnr }
      )
      vim.keymap.set(
        'i',
        '<C-E>',
        function()
          vim.lsp.inline_completion.get({
            on_accept = function(completion)
              local len = completion.range[4]
              local start = string.sub(completion.insert_text, 0, len)
              local rest_of_string = string.sub(completion.insert_text, len + 1)
              completion.insert_text = start .. string.match(rest_of_string, "%s*%S+")
              return completion
            end
          })
        end,
        { desc = 'LSP: accept one word in inline completion', buffer = bufnr }
      )
      vim.keymap.set(
        'i',
        '<C-G>',
        vim.lsp.inline_completion.select,
        { desc = 'LSP: switch inline completion', buffer = bufnr }
      )
    end
  end
})

require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hX', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hX', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hp', gitsigns.preview_hunk)
  end
}


vim.keymap.set("n", "<leader>yl", function()
  local location = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", location)
  vim.notify("Copied: " .. location)
end, { desc = "Copy file path and line" })

