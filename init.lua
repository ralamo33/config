-- -----------------------------------------------------------------------------------------------
vim.opt.hlsearch = true
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.spelllang = 'en_us'
vim.opt.title = true
vim.opt.titlestring = "nvim"
vim.g.mapleader = ' '

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

vim.opt.termguicolors = true
vim.o.background = "dark"

vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.signcolumn = 'yes'
vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.wo.number = true
vim.wo.relativenumber = false

vim.lsp.inlay_hint.enable(true)

vim.cmd("language en_US.UTF-8")

-- -----------------------------------------------------------------------------------------------
-- Auto-reload files when changed outside of Neovim
-- -----------------------------------------------------------------------------------------------
vim.opt.autoread = true

-- Trigger autoread when files change on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

-- Notification when file changes
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

-- -----------------------------------------------------------------------------------------------
-- Plugin list
-- -----------------------------------------------------------------------------------------------
local plugins = {
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {}},
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-neotest/neotest-python',
      'akinsho/toggleterm.nvim',
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-python')({
            runner = "pytest",
          })
        },

        strategies = {
          toggleterm = function(opts)
            local Terminal = require("toggleterm.terminal").Terminal
            local term = Terminal:new({
              cmd = opts.command,
              direction = "horizontal",
              size = function() return math.max(8, math.floor(vim.o.lines / 3)) end,
              auto_close = true,
              start_in_insert = false,
            })
            term:toggle()
          end,
        },

        default_run_strategy = "toggleterm",
        status = { enabled = true },
      })
    end,
  },
  { 
    "nvim-lualine/lualine.nvim",
     dependencies = { 'nvim-neotest/neotest' },
     config = function()
      require("lualine").setup({
        options = {
          theme="tokyonight",
          icons_enabled = true,
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
        },
        sections = {
          lualine_x = {
            function()
              local ok, neotest = pcall(require, "neotest")
              if not ok then return "" end
              return neotest.status
            end,
        },
      },
      })
    end
  },
  { "nvim-tree/nvim-tree.lua" },                           -- File browser

  -- Telescope command menu
  { "nvim-telescope/telescope.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  
  -- TreeSitter
  { "nvim-treesitter/nvim-treesitter",          priority = 1000, build = ":TSUpdate" },

  -- display buffers
  {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},

  -- icons
  { "nvim-tree/nvim-web-devicons", opts = {} },


  -- LSP
  { 'neovim/nvim-lspconfig' },                     -- LSP configuration helper
  { 'mason-org/mason.nvim' },                      -- installs LSP servers
  { 'williamboman/mason-lspconfig.nvim' },         -- bridges mason and lspconfig
  { 'stevearc/conform.nvim' },                     -- Formatting

  {
    'saghen/blink.cmp',                           -- Blink completion tool (LSP, snippets etc)
    version = '1.*',                              -- see keymap here:
    lazy = false,                                 -- Load immediately
    dependencies = { 'neovim/nvim-lspconfig' },   -- Ensure LSP config is loaded
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        menu = { auto_show = true }
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lsp = {
            name = 'LSP',
            module = 'blink.cmp.sources.lsp',
            enabled = true,
          },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }           -- https://cmp.saghen.dev/configuration/keymap.html#default
  },
  -- file navigation
  {
    "wojciech-kulik/filenav.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("filenav").setup {
      next_file_key = "<leader>ii",
      prev_file_key = "<leader>oo",
      max_history = 100,
      remove_duplicates = false,
      }
    end,
  },
  { "nvim-neotest/nvim-nio" },
  { "folke/snacks.nvim" },  -- Required for claudecode bottom split
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      require("claudecode").setup({
        terminal = {
          provider = "snacks",  -- Required for bottom positioning
          snacks_win_opts = {
            position = "bottom",
            height = 0.33,  -- Bottom third of screen
            width = 1.0,    -- Full width
            border = "single",
          }
        }
      })
    end,
  }
}

-- -----------------------------------------------------------------------------------------------
-- Plugin installation
-- -----------------------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup(plugins)

-- -----------------------------------------------------------------------------------------------
-- Plugin config
-- -----------------------------------------------------------------------------------------------
--vim.cmd.colorscheme("gruvbox")  -- activate the theme
vim.cmd.colorscheme("tokyonight")

require("nvim-tree").setup()
require("telescope").setup({
    file_ignore_patterns = { 
      "node_modules" 
    }
})

-- -----------------------------------------------------------------------------------------------
-- Treesitter (syntax highlighting and related stuff!)
-- -----------------------------------------------------------------------------------------------
-- NB: Make sure to add more from this list!
require("nvim-treesitter.configs").setup({
  ensure_installed = { "typescript", "python", "rust", "go", "regex" },
  sync_install = false,
  auto_install = true,
  highlight = { enable = true, },
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-- -----------------------------------------------------------------------------------------------
-- LSP Configuration (loaded from separate file)
-- -----------------------------------------------------------------------------------------------
-- IMPORTANT: This must be loaded AFTER blink.cmp is set up so capabilities are available
dofile(vim.fn.stdpath("config") .. "/lsp.lua")

-- -----------------------------------------------------------------------------------------------
-- Keymap settings
-- -----------------------------------------------------------------------------------------------
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- nvim-tree (file browser settings)
-- vim.keymap.set("n", "<C-t>", ":NvimTreeFocus<CR>")
-- vim.keymap.set("n", "<C-f>", ":NvimTreeFindFile<CR>")
-- vim.keymap.set("n", "<C-c>", ":NvimTreeClose<CR>")

-- Formatting
vim.keymap.set("n", "<leader>fo", require('conform').format)

local tele_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fz", tele_builtin.git_files, {})  -- ,ff to find git files
vim.keymap.set("n", "<leader>ff", tele_builtin.find_files, {}) -- ,fa to find any files
vim.keymap.set("n", "<leader>fg", tele_builtin.live_grep, {})  -- ,fg to ripgrep
vim.keymap.set("n", "<leader>fb", tele_builtin.buffers, {})    -- ,fb to see recent buffers
vim.keymap.set("n", "<leader>fh", tele_builtin.help_tags, {})  -- ,fh to search help
vim.keymap.set("n", "<leader>fs", tele_builtin.lsp_document_symbols, {})
vim.keymap.set("n", "<leader>fd", tele_builtin.diagnostics, {})

vim.keymap.set('n', 'K', vim.lsp.buf.hover)

vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition)

-- Diagnostics (errors, warnings, etc.)
vim.keymap.set('n', '[d', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set('n', ']d', function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set('n', '<leader>d', function()
  vim.diagnostic.open_float({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Show line errors" })

-- Signature help for function calls
-- vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help)

-- -----------------------------------------------------------------------------------------------
-- Diagnostic Display
-- -----------------------------------------------------------------------------------------------
-- Show error messages inline (virtual text)
vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>ci", function()
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.title:lower():match("import") or action.kind == "quickfix"
    end,
    apply = true,
  })
end, { desc = "Add import quickfix" })

-- Test keymaps (for neotest)
vim.keymap.set("n", "<leader>rr", function() require("neotest").run.run() end, { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>rf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run tests in current file" })
vim.keymap.set("n", "<leader>ra", function() require("neotest").run.run({ suite = true }) end, { desc = "Run all tests" })
vim.keymap.set("n", "<leader>rs", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })
vim.keymap.set("n", "<leader>ro", function() require("neotest").output.open() end, { desc = "Show test output" })

vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", {desc = "Accept diff"})
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", {desc = "Deny diff"})
vim.keymap.set("n", "<leader>at", "<cmd>ClaudeCode<cr>", {desc = "Claude toggle"})
vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode --continue<cr>", {desc = "Claude toggle"})

---- -----------------------------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------------------------

-- Create a reusable augroup
local augroup = vim.api.nvim_create_augroup("MyCustomAutocmds", { clear = true })

-- Automatically save Python files when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  pattern = "*.py", -- Only applies to Python files
  desc = "Auto-save Python files when leaving insert mode",
  callback = function()
    -- :update only writes the file if it has been modified
    vim.cmd("update")
  end,
})
