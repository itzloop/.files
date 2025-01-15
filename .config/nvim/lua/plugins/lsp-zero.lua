return {
    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig"

    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        opts = {},
    },
    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        config = function()
            local cmp = require('cmp')

            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                },
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
                        vim.snippet.expand(args.body)
                    end,
                },
            })
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
                    local opts = { buffer = event.buf }

                    vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float)
                    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
                    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
                    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
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
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)

                    local id = vim.tbl_get(event, 'data', 'client_id')
                    local client = id and vim.lsp.get_client_by_id(id)
                    if client == nil then
                        return
                    end

                    if client.server_capabilities.document_formatting then
                        vim.api.nvim_exec([[
                 augroup LspAutocommands
                     autocmd! * <buffer>
                     autocmd BufWritePost <buffer> lua buf.formatting()
                 augroup END
                 ]], true)
                    end
                end,
            })

            require('mason-lspconfig').setup({
                ensure_installed = {
                    "gopls",
                    "bashls",
                    "yamlls",
                    "jsonls",
                    "buf_ls",
                    "pyright",
                    "biome",
                    "lua_ls"
                },
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                    lua_ls = function()
                        require('lspconfig').lua_ls.setup({
                            on_attach = function(client, bufnr)
                                require("nvim-navic").attach(client, bufnr)
                            end,
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
                        })
                    end,
                    gopls = function()
                        require("lspconfig").gopls.setup({
                            on_attach = function(client, bufnr)
                                require("nvim-navic").attach(client, bufnr)
                            end,
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
                            },
                        })
                    end
                }
            })
        end
    }
}
