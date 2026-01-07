
-- ==========================
-- Global keymaps & user commands
-- ==========================

-- ROS2 telescope topic viewer
vim.keymap.set('n', '<leader>st', ':Telescope ros2 topics_info<CR>', { noremap = true, silent = true })

-- Vertical staged vs working diff
local function vertical_staged_diff()
  local abs_path = vim.fn.expand '%:p'
  if abs_path == '' then
    print 'No file detected in current buffer'
    return
  end

  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(vim.fn.fnamemodify(abs_path, ':h')) .. ' rev-parse --show-toplevel')[1]
  if not git_root or git_root == '' then
    print 'Not inside a git repository'
    return
  end

  local rel_path
  if vim.fn.stridx(abs_path, git_root) == 0 then
    rel_path = abs_path:sub(#git_root + 2)
  else
    rel_path = vim.fn.fnamemodify(abs_path, ':~:.')
  end

  local current_win = vim.api.nvim_get_current_win()
  vim.cmd 'vsplit'
  vim.cmd 'enew'

  local staged_contents = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(git_root) .. ' show :' .. vim.fn.shellescape(rel_path))
  if vim.v.shell_error ~= 0 then
    print('Failed to load staged file: ' .. rel_path)
    vim.cmd 'bd!'
    vim.api.nvim_set_current_win(current_win)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, staged_contents)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.cmd('file ' .. rel_path .. ' (staged)')

  vim.cmd 'diffthis'
  vim.api.nvim_set_current_win(current_win)
  vim.cmd 'diffthis'
end

vim.api.nvim_create_user_command('GitsignsVerticalDiff', vertical_staged_diff, {
  desc = 'Open vertical diff split between working and staged version of current file',
})
vim.keymap.set('n', '<leader>gd', ':GitsignsVerticalDiff<CR>', { desc = 'Vertical staged vs working diff' })

-- Indentation command
vim.api.nvim_create_user_command('Indent', function()
  vim.opt.autoindent = true
  vim.opt.expandtab = true
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
end, {})

-- Diagnostic config
vim.diagnostic.config {
  virtual_text = { spacing = 4, prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
}

-- ==========================
-- LSP-specific keymaps
-- ==========================
-- Setup LSP-attached keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Setup buffer-local LSP keymaps",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Only set keymap for clangd
    if client.name == "clangd" then
      vim.keymap.set(
        'n',
        '<leader>o',
        '<cmd>ClangdSwitchSourceHeader<CR>',
        { buffer = bufnr, desc = 'Swap between header and source file buffers' }
      )
    end
  end,
})

-- Clangd: swap header/source
-- IMPORTANT: don't put this at top-level; it has to be in on_attach
-- local lspconfig = require('lspconfig')
-- lspconfig.clangd.setup {
--   on_attach = function(client, bufnr)
--     vim.keymap.set('n', '<leader>o', '<cmd>ClangdSwitchSourceHeader<CR>', { buffer = bufnr, desc = 'Swap between header and source file buffers' })
--   end,
-- }
