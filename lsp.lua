-- ===============================================================================
-- LSP and Type Checking Configuration
-- ===============================================================================
-- This file contains all LSP server configurations and formatters.
-- Add new language servers here as you work with different languages.

-- -----------------------------------------------------------------------------------------------
-- Mason setup
-- -----------------------------------------------------------------------------------------------
-- Mason installs and manages LSP servers
require("mason").setup()

-- Mason-lspconfig ensures LSP servers are installed
require("mason-lspconfig").setup({
  ensure_installed = {
    "basedpyright",  -- Python type checking
    "ruff",          -- Python linting and formatting
    "biome",         -- JavaScript/TypeScript linting and formatting (replaces ESLint + Prettier)
    "lua_ls",        -- Lua LSP
    "ts_ls",         -- TypeScript/JavaScript LSP
    "tailwindcss",   -- Tailwind CSS autocomplete
    --"sqls"           -- SQL language server
  },
  automatic_installation = true,
})

-- ───────────────────────────────────────────────────────────────────────────────
-- LSP Capabilities Configuration
-- ───────────────────────────────────────────────────────────────────────────────
-- Unified LSP capabilities with blink.cmp integration
local caps = vim.lsp.protocol.make_client_capabilities()

-- Get blink.cmp capabilities
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
  caps = blink.get_lsp_capabilities(caps)
  print("Blink.cmp capabilities loaded successfully")
else
  print("Warning: blink.cmp not loaded, using default capabilities")
end

-- Force consistent position encoding across all LSP clients
caps.general = caps.general or {}
caps.general.positionEncodings = { "utf-16" }

-- -----------------------------------------------------------------------------------------------
-- Formatter Configuration (Conform)
-- -----------------------------------------------------------------------------------------------
require("conform").setup({
  formatters_by_ft = {
    -- Python
    python = { "ruff_format" },

    -- JavaScript/TypeScript (using Biome)
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },

    -- Web
    json = { "biome" },
    jsonc = { "biome" },
    css = { "biome" },

    -- SQL
    sql = { "sql_formatter" },
  },
})

-- Auto-format Python files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    require("conform").format({ timeout_ms = 2000 })
  end,
})

-- -----------------------------------------------------------------------------------------------
-- LSP Server Configurations
-- -----------------------------------------------------------------------------------------------
-- Configure and enable LSP servers using the new vim.lsp.config API

if vim.lsp and vim.lsp.config and vim.lsp.enable then
  -- ─────────────────────────────────────────────────────────
  -- Python LSP Servers
  -- ─────────────────────────────────────────────────────────

  -- Basedpyright: Python type checking and language server
  vim.lsp.config("basedpyright", {
    capabilities = caps,
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "standard",
          autoImportCompletions = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
        },
      },
    },
  })

  -- Ruff: Python linting and formatting
  vim.lsp.config("ruff", {
    capabilities = caps,
  })

  -- ─────────────────────────────────────────────────────────
  -- JavaScript/TypeScript LSP Servers
  -- ─────────────────────────────────────────────────────────

  -- ts_ls: TypeScript/JavaScript language server
  vim.lsp.config("ts_ls", {
    capabilities = caps,
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
    settings = {
      completions = {
        completeFunctionCalls = true,
      },
    },
  })

  -- ─────────────────────────────────────────────────────────
  -- Tailwind CSS
  -- ─────────────────────────────────────────────────────────

  -- tailwindcss: Tailwind CSS autocomplete and class validation
  vim.lsp.config("tailwindcss", {
    capabilities = caps,
    settings = {
      tailwindCSS = {
        experimental = {
          classRegex = {
            -- Support for classnames in various formats
            { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
            { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
            { "clsx\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          },
        },
      },
    },
  })

  -- ─────────────────────────────────────────────────────────
  -- SQL (for Supabase queries)
  -- ─────────────────────────────────────────────────────────

  -- sqls: SQL language server for completion and validation
  vim.lsp.config("sqls", {
    capabilities = caps,
  })

  -- ─────────────────────────────────────────────────────────
  -- Lua LSP Server
  -- ─────────────────────────────────────────────────────────

  -- lua_ls: Lua language server (for Neovim config)
  vim.lsp.config("lua_ls", {
    capabilities = caps,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        diagnostics = {
          globals = { 'vim' },
        },
      },
    },
  })

  -- ─────────────────────────────────────────────────────────
  -- Enable all configured servers
  -- ─────────────────────────────────────────────────────────

  vim.lsp.enable("basedpyright")
  vim.lsp.enable("ruff")
  vim.lsp.enable("lua_ls")
  vim.lsp.enable("ts_ls")
  vim.lsp.enable("tailwindcss")
  vim.lsp.enable("sqls")
end

-- -----------------------------------------------------------------------------------------------
-- LSP Customizations
-- -----------------------------------------------------------------------------------------------

-- Prefer Basedpyright hover over Ruff's (Ruff's hover is less informative)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    -- Debug: print when LSP attaches
    if client then
      print(string.format("LSP attached: %s (buffer %d)", client.name, args.buf))
    end
  end,
})

-- ===============================================================================
-- Adding New Language Servers
-- ===============================================================================
-- To add a new language server:
--
-- 1. Add the server name to the ensure_installed table in mason.setup()
-- 2. Add formatter config to conform.setup() formatters_by_ft if needed
-- 3. Add vim.lsp.config() configuration for the server
-- 4. Add vim.lsp.enable() call to enable it
--
-- Example for Go:
--   In mason.setup(): "gopls"
--   In conform.setup(): go = { "gofmt" }
--   vim.lsp.config("gopls", { capabilities = caps })
--   vim.lsp.enable("gopls")
--
-- Current Stack (Next.js + Supabase):
--   - ts_ls: TypeScript/JavaScript language server
--   - biome: Fast linting and formatting (replaces ESLint + Prettier)
--   - tailwindcss: Tailwind CSS autocomplete
--   - sqls: SQL completion for Supabase queries
-- ===============================================================================
