return require("telescope").register_extension {
    setup = function(ext_config, config)
        -- access extension config and user config
        print("hello from the other side")
    end,
    exports = {
        dap_breakpoints = require("dap_breakpoints").list_breakpoints
    },
}
