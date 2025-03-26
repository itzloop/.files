local function get_arguments()
    return coroutine.create(function(dap_run_co)
        local args = {}
        vim.ui.input({ prompt = "Args: " }, function(input)
            args = vim.split(input or "", " ")
            coroutine.resume(dap_run_co, args)
        end)
    end)
end


-- A helper function to walk up parent directories until we find a venv.
local function find_venv_python()
    local cwd = vim.fn.getcwd()
    -- Break the current path into parts so we can go up one by one
    local path_parts = vim.split(cwd, '/')

    -- Iterate from deepest folder to root
    for i = #path_parts, 1, -1 do
        local candidate = table.concat(vim.list_slice(path_parts, 1, i), '/')
        local dot_venv  = candidate .. '/.venv/bin/python'
        local venv      = candidate .. '/venv/bin/python'

        -- Check if either .venv/bin/python or venv/bin/python is executable
        if vim.fn.executable(dot_venv) == 1 then
            return dot_venv
        elseif vim.fn.executable(venv) == 1 then
            return venv
        end
    end

    -- If nothing found, just fall back to whatever python is in your PATH
    return 'python'
end

return {
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        lazy = false,
        init = function()
            vim.keymap.set('n', '<F5>', function() require("dap").continue() end, { noremap = true, silent = true })
            vim.keymap.set('n', '<F8>', function() require("dap").step_over() end, { noremap = true, silent = true })
            vim.keymap.set('n', '<F9>', function() require("dap").step_into() end, { noremap = true, silent = true })
            vim.keymap.set('n', '<F10>', function() require("dap").step_out() end, { noremap = true, silent = true })
            vim.keymap.set('n', '<Leader>b', function() require("dap").toggle_breakpoint() end,
                { noremap = true, silent = true })
            vim.keymap.set('n', '<Leader>B', function() require("dap").set_breakpoint() end,
                { noremap = true, silent = true })
            vim.keymap.set('n', '<Leader>lp',
                function() require("dap").set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
                { noremap = true, silent = true })
            vim.keymap.set('n', '<Leader>dr', function() require("dap").repl.open() end,
                { noremap = true, silent = true })
            vim.keymap.set('n', '<Leader>dl', function() require("dap").run_last() end, { noremap = true, silent = true })
            vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
                require('require("dap").ui.widgets').hover()
            end, { noremap = true, silent = true })
            vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
                require('require("dap").ui.widgets').preview()
            end, { noremap = true, silent = true })
            vim.keymap.set('n', '<Leader>df', function()
                local widgets = require('require("dap").ui.widgets')
                widgets.centered_float(widgets.frames)
            end, { noremap = true, silent = true })
            vim.keymap.set('n', '<Leader>ds', function()
                local widgets = require('require("dap").ui.widgets')
                widgets.centered_float(widgets.scopes)
            end, { noremap = true, silent = true })
        end,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter" }
    },
    {
        "leoluz/nvim-dap-go",
        opts = function(_, opts)
            opts.dap_configurations = opts.dap_configurations or {}
            table.insert(opts.dap_configurations, {
                args = get_arguments,
                mode = "debug",
                name = "Debug Package (Arguments)",
                program = "${fileDirname}",
                request = "launch",
                type = "go",
            })
        end
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = {
            "mfussenegger/nvim-dap",
            -- If you use dap-ui, also add: "rcarriga/nvim-dap-ui"
        },
        ft = { "python" },
        config = function()
            require("dap-python").setup(find_venv_python())
        end
    }
}
