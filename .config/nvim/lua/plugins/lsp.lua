return {
    { 'nvim-java/nvim-java' },
    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
        lazy = false,
        priority = 999,
        opts = {
            lsp = {
                auto_attach = true,
            }
        }
    },
    {
        'towolf/vim-helm',
        ft = 'helm'
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        opts = {},
    },
    -- Autocompletion
    {
        "hrsh7th/cmp-nvim-lsp-signature-help",
        dependencies = "hrsh7th/nvim-cmp",
    },
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
    },
    { 'saadparwaiz1/cmp_luasnip', dependencies = "L3MON4D3/LuaSnip" },
    {
        "Dan7h3x/signup.nvim",
        branch = "main",
        opts = {
            active_parameter_colors = {
                fg = "#f5c2e7",
                bg = "#3b4261",
            },
            max_height = 10,
            max_width = 120,
        },
        config = function(_, opts)
            require("signup").setup(opts)
        end
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        opts = function()
            local cmp = require("cmp")
            local defaults = require("cmp.config.default")()
            local auto_select = true

            return {
                auto_brackets = {}, -- configure any filetype to auto add brackets
                completion = {
                    completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
                },
                preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
                -- sources = {
                --     {
                --         name = 'nvim_lsp',
                --     },
                --     { name = "nvim_lsp_signature_help" },
                --     { name = 'render-markdown' },
                --     {
                --         name = "lazydev",
                --         group_index = 0, -- set group index to 0 to skip loading LuaLS completions
                --     },
                -- },
                sources = cmp.config.sources({
                    { name = 'luasnip' },
                    { name = "lazydev", group_index = 0 },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    -- { name = "nvim_lsp_signature_help" },
                }, {
                    { name = "buffer" },
                }),
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),

                }),
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end
                },
            }
        end
    },

    -- LSP
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        init = function()
            -- Reserve a space in the gutter
            -- This will avoid an annoying layout shift in the screen
            vim.opt.signcolumn = 'yes'
        end,
        config = function()
            -- setup java before lspconfig
            -- require('java').setup()
            local lsp_defaults = require('lspconfig').util.default_config

            -- Add cmp_nvim_lsp capabilities settings to lspconfig
            -- This should be executed before you configure any language server
            lsp_defaults.capabilities = vim.tbl_deep_extend(
                'force',
                lsp_defaults.capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            -- LspAttach is where you enable features that only work
            -- if there is a language server active in the file
            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    local builtin = require("telescope.builtin")
                    local opts = { buffer = event.buf }

                    vim.keymap.set('n', '<leader>di', vim.diagnostic.open_float)
                    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
                    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
                    vim.keymap.set('n', '<leader>df', builtin.diagnostics)


                    -- Reformat and Refactor
                    vim.keymap.set("n", '<leader>rn', function() vim.lsp.buf.rename() end, opts)
                    vim.keymap.set("n", '<leader>ca', function() vim.lsp.buf.code_action() end, opts)
                    vim.keymap.set("n", '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)

                    -- Workspace
                    vim.keymap.set("n", '<leader>wa', function() vim.lsp.buf.add_workspace_folder() end, opts)
                    vim.keymap.set("n", '<leader>wr', function() vim.lsp.buf.remove_workspace_folder() end, opts)
                    vim.keymap.set("n", '<leader>wl',
                        function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)

                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
                    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
                    vim.keymap.set('n', 'go', builtin.lsp_type_definitions, opts)
                    vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
                    vim.keymap.set("n", "<Leader>ds", builtin.lsp_document_symbols, opts)
                end,
            })
            -- fix helmls
            vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
                desc = "Fix helm ls",
                pattern = "*.yaml",
                callback = function()
                    local file_path = vim.fn.expand("%:p") -- Get full path of current file
                    if string.match(file_path, "/chart/") then
                        vim.opt_local.filetype = 'helm'
                    end
                end
            })


            vim.lsp.config.lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace"
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { 'vim' },
                        },
                    },
                }
            }

            vim.lsp.config.gopls = {
                -- cmd = { "gopls", "serve", "-mcp.listen=localhost:8092" },
                cmd = { "gopls", "serve" },
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                        },
                        staticcheck = true,
                    },
                },
                flags = {
                    debounce_text_changes = 150,
                    exit_timeout = 30,
                },
            }

            require('mason-lspconfig').setup({
                automatic_enable = {
                    "gopls",
                    "bashls",
                    "yamlls",
                    "jsonls",
                    "buf_ls",
                    "basedpyright",
                    "biome",
                    "lua_ls",
                    "helm_ls",
                    "jdtls",
                    "jinja_lsp"
                },
                ensure_installed = {
                    "gopls",
                    "bashls",
                    "yamlls",
                    "jsonls",
                    "buf_ls",
                    "basedpyright",
                    "biome",
                    "lua_ls",
                    "helm_ls",
                    "jdtls"
                },
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        print("default handler:" .. server_name .. ": hello?")
                        vim.lsp.config(server_name, {})
                    end,
                    lua_ls = function()
                    end,
                    gopls = function()
                    end,
                }
            })
        end
    }
}
