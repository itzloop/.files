return {
    {

        "okuuva/auto-save.nvim",
        version = '^1.0.0',                       -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
        cmd = "ASToggle",                         -- optional for lazy loading on command
        event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
        lazy = false,
        opts = {
            -- your config goes here
            -- or just leave it empty :)
        }
    },
    -- {
    --     "Pocco81/auto-save.nvim",
    --     config = function()
    --         require("auto-save").setup()
    --     end
    -- },
}
