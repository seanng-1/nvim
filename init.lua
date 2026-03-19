-- Neovim >= 0.11 compatible init.lua
--------------------------------------------------
-- Leader keys (must be first)
--------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

--------------------------------------------------
-- Options
--------------------------------------------------
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.showmode = false
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = 'yes'
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.inccommand = 'split'
opt.cursorline = true
opt.scrolloff = 10

vim.schedule(function()
  opt.clipboard = 'unnamedplus'
end)

--------------------------------------------------
-- Keymaps
--------------------------------------------------
local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics → loclist' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<C-h>', '<C-w><C-h>')
map('n', '<C-j>', '<C-w><C-j>')
map('n', '<C-k>', '<C-w><C-k>')
map('n', '<C-l>', '<C-w><C-l>')

--------------------------------------------------
-- Autocommands
--------------------------------------------------
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

--------------------------------------------------
-- lazy.nvim bootstrap
--------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------
-- Plugins
--------------------------------------------------
require('lazy').setup({
  ------------------------------------------------
  -- Core utilities
  ------------------------------------------------
  'tpope/vim-sleuth',

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      current_line_blame = true,
      numhl = true,
      signs = { delete = { text = '┃' } },
    },
  },

  ------------------------------------------------
  -- Treesitter (single definition – 0.11 strict)
  ------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "cpp",
        "python",
        "bash",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    opts = { mode = 'cursor', max_lines = 3 },
  },

  ------------------------------------------------
  -- UI
  ------------------------------------------------
  { 'akinsho/bufferline.nvim', opts = {} },

  {
    'petertriho/nvim-scrollbar',
    opts = { handlers = { gitsigns = true } },
  },

  'mg979/vim-visual-multi',

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()
      require('which-key').add {
        { '<leader>s', group = '[S]earch' },
        { '<leader>g', group = '[G]it' },
        { '<leader>t', group = '[T]oggle' },
      }
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = true,
    },
  },

  {
    -- Adds sticky scroll to functions
    -- http://www.lazyvim.org/extras/ui/treesitter-context
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    opts = function()
      --  local tsc = require 'treesitter-context'
      return { mode = 'cursor', max_lines = 3 }
    end,
  },

  { -- NOTE: add github copilot
    'github/copilot.vim',
  },

  { -- NOTE: copitol chat
    {
      'CopilotC-Nvim/CopilotChat.nvim',
      dependencies = {
        { 'github/copilot.vim' },                       -- or zbirenbaum/copilot.lua
        { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
      },
      build = 'make tiktoken',                          -- Only on MacOS or Linux
      opts = {
        -- See Configuration section for options
      },
      -- See Commands section for default commands if you want to lazy load on them
    },
  },

  require 'kickstart.plugins.neo-tree',

  ------------------------------------------------
  -- Telescope
  ------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make',                cond = vim.fn.executable('make') == 1 },
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-tree/nvim-web-devicons',              enabled = vim.g.have_nerd_font },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup {
        extensions = {
          ['ui-select'] = require('telescope.themes').get_dropdown(),
        },
      }
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    end,
  },

  ------------------------------------------------
  -- LSP (0.11 APIs)
  ------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    commit = '702f69fb167e9119f14adc4dfd4fcadf4d1b07a0',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.lsp.config('clangd', {
        cmd = {
          "/usr/bin/clangd",
          "--background-index",
          "--header-insertion=never",
          "--offset-encoding=utf-16",
        },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", "package.xml", ".git" },
      })

      -- This is the new way to 'setup' a server in nvim-lspconfig 0.11+
      vim.lsp.enable('clangd', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      -- other servers
      local servers = {
        pyright = {},
        rust_analyzer = {},
        lua_ls = { settings = { Lua = { completion = { callSnippet = "Replace" } } } },
      }

      for name, opts in pairs(servers) do
        vim.lsp.config(name, opts)
        vim.lsp.enable(name, { capabilities = capabilities })
      end

      -- optional: LspAttach keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local buf = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local function lspmap(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
          end
          lspmap('gd', vim.lsp.buf.definition, 'Go to definition')
          lspmap('gr', vim.lsp.buf.references, 'References')
          lspmap('<leader>rn', vim.lsp.buf.rename, 'Rename')
          lspmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')
        end,
      })
    end,
  },

  {
    "p00f/clangd_extensions.nvim",
    config = function()
      require("clangd_extensions").setup {}
    end
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        python = { 'isort', 'black' },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  ------------------------------------------------
  -- Completion
  ------------------------------------------------
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup {
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  ------------------------------------------------
  -- Formatting
  ------------------------------------------------
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
      },
    },
  },

  ------------------------------------------------
  -- Theme
  ------------------------------------------------
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme('tokyonight-night')
    end,
  },
})

--------------------------------------------------
-- Diagnostics (0.11 style)
--------------------------------------------------
vim.diagnostic.config {
  virtual_text = { spacing = 4, prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
}

--------------------------------------------------
-- Custom keymaps
--------------------------------------------------
require('custom')
