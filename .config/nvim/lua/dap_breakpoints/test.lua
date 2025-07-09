local pickers      = require("telescope.pickers")
local finders      = require("telescope.finders")
local previewers   = require("telescope.previewers")
local conf         = require("telescope.config").values
local actions      = require("telescope.actions")
local action_state = require("telescope.actions.state")
local Path         = require("plenary.path")

local function test(bufnr)
    local cwd = vim.fn.getcwd()
    local bps_by_bufnr;
    if bufnr then
        bps_by_bufnr = require("dap.breakpoints").get(bufnr)
    else
        bps_by_bufnr = require("dap.breakpoints").get()
    end

    local results = {}
    for bufnr, bps in pairs(bps_by_bufnr) do
        local file_path = vim.api.nvim_buf_get_name(bufnr)
        local relative_path = Path:new(file_path):make_relative(cwd)
        for _, bp in pairs(bps) do
            table.insert(results, {
                file_path = file_path,
                display   = relative_path .. ":" .. bp.line,
                bp        = bp,
                ordinal   = relative_path,
            })
        end
    end

    print(vim.inspect(results))
    pickers.new({}, {
        prompt_title = "DAP Breakpoints",
        finder = finders.new_table {
            results = results,
            entry_maker = function(item)
                return {
                    value   = item,
                    display = item.display,
                    ordinal = item.ordinal,
                }
            end,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
            -- Define what happens when you press <Enter> on an item
            actions.select_default:replace(function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                print(vim.inspect(selection))
            end)
            return true
        end,
    }):find()
end

-- local group = vim.api.nvim_create_augroup("DapBreakpoints", { clear = true })

-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--     group = group,
--     callback = function(args)
--         local bufnr = args.buf
--         test(bufnr)
--     end,
-- })


-- vim.api.nvim_create_autocmd({ "User" }, {
--     group = group,
--     pattern = { "AutoSaveWritePost" },
--     callback = function(args)
--         local bufnr = args.buf
--         test(bufnr)
--     end,
-- })

-- test()
-- local items = {
--     {
--         label = "normal breakpoint",
--     },
--     {
--         label = "conditional breakpoint",
--     },
--     {
--         label = "hit condition",
--     }
-- }

-- vim.ui.select(items,
--     {
--         prompt = "Pick an option:",
--         format_item = function(item)
--             return item.label
--         end,
--     },
--     function(item)
--         print(vim.inspect(item))
--     end)
--
local function create_floating_menu(items)
    local buf = vim.api.nvim_create_buf(false, true) -- scratch, no file

    -- Optionally set lines to your items
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)

    -- Some basic config for a float near the cursor
    local win = vim.api.nvim_open_win(buf, true, {
        title = "modify breakpoint",
        title_pos = "center",
        relative = "cursor",
        row = 1,
        col = 0,
        width = 30,
        height = #items,
        style = "minimal",
        border = "single",
    })

    -- Example keymap: press <CR> on an item to select it
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
        nowait = true,
        noremap = true,
        callback = function()
            local row = vim.api.nvim_win_get_cursor(win)[1]
            local choice = items[row]
            print("You chose: " .. choice)
            vim.api.nvim_win_close(win, true)
            require("dap").toggle_breakpoint(condition?, hit_condition?, log_message?, replace_old?)
        end,
    })

    -- Also a key to close (like <Esc>)
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
        nowait = true,
        noremap = true,
        callback = function()
            vim.api.nvim_win_close(win, true)
        end,
    })
end

create_floating_menu({ "Add hit con", "Option B", "Option C", "Add hit con", "Option B", "Option C",  "Add hit con", "Option B", "Option C", "Add hit con", "Option B", "Option C",   "Add hit con", "Option B", "Option C", "Add hit con", "Option B", "Option C",   "Add hit con", "Option B", "Option C", "Add hit con", "Option B", "Option C",   })
