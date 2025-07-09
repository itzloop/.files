local pickers      = require("telescope.pickers")
local finders      = require("telescope.finders")
local previewers   = require("telescope.previewers")
local conf         = require("telescope.config").values
local actions      = require("telescope.actions")
local action_state = require("telescope.actions.state")


local M = {}

function M.list_breakpoints(opts)
    print("i might be working :)")
    opts = opts or {}

    -- Gather all breakpoints from nvim-dap
    local bps_by_bufnr = require("dap.breakpoints").get()
    for x, y in ipairs(bps_by_bufnr) do
        print()
    end

    if vim.tbl_isempty(entries) then
        vim.notify("No breakpoints set", vim.log.levels.INFO)
        return
    end

    pickers.new(opts, {
        prompt_title = "DAP Breakpoints",
        finder = finders.new_table {
            results = entries,
            entry_maker = function(item)
                return {
                    value    = item,
                    display  = item.display,
                    ordinal  = item.ordinal,
                    filename = item.filename,
                    lnum     = item.lnum,
                }
            end,
        },
        previewer = previewers.new_termopen_previewer({
            get_command = function(entry)
                -- If you have `bat` installed, highlight the current line:
                return {
                    "bat",
                    "--style=plain",
                    "--color=always",
                    "--highlight-line", tostring(entry.lnum),
                    entry.filename
                }
            end
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(_, map)
            -- Define what happens when you press <Enter> on an item
            actions.select_default:replace(function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                -- Open file and jump to line
                vim.cmd(string.format("edit %s", selection.filename))
                vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
            end)
            return true
        end,
    }):find()
end

return M
