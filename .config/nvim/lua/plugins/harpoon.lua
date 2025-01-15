return {
    "ThePrimeagen/harpoon",
    lazy = false,
    init = function()
        vim.g.harpoon_log_level="info"
        local ui = require("harpoon.ui")
        vim.keymap.set("n", "<leader>a", require("harpoon.mark").add_file)
        vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)
        vim.keymap.set("n", "<Tab>", ui.nav_next)
        vim.keymap.set("n", "<S-Tab>", ui.nav_prev)
        vim.keymap.set("n", "<leader>2", function () ui.nav_file(2) end)
        vim.keymap.set("n", "<leader>3", function () ui.nav_file(3) end)
        vim.keymap.set("n", "<leader>4", function () ui.nav_file(4) end)
        vim.keymap.set("n", "<leader>5", function () ui.nav_file(5) end)
        vim.keymap.set("n", "<leader>6", function () ui.nav_file(6) end)
        vim.keymap.set("n", "<leader>7", function () ui.nav_file(7) end)
        vim.keymap.set("n", "<leader>8", function () ui.nav_file(8) end)
        vim.keymap.set("n", "<leader>9", function () ui.nav_file(9) end)
    end,
    opts = {
        global_settings = {
            -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
            save_on_toggle = false,

            -- saves the harpoon file upon every change. disabling is unrecommended.
            save_on_change = true,

            -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
            enter_on_sendcmd = false,

            -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
            tmux_autoclose_windows = false,

            -- filetypes that you want to prevent from adding to the harpoon list menu.
            excluded_filetypes = { "harpoon" },

            -- set marks specific to each git branch inside git repository
            mark_branch = false,

            -- enable tabline with harpoon marks
            tabline = false,
            tabline_prefix = "   ",
            tabline_suffix = "   ",
        }
    },
}
