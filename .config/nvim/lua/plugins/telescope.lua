-- Replaced in favor of live_grep_args
-- vim.keymap.set("n", "<Leader>fg", ":Telescope live_grep<CR>", opts )
local function get_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return nil -- not in visual mode
  end

  local bufnr = 0
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  -- Adjust order (getpos("v") can be after getpos(".") depending on selection direction)
  local start_row = math.min(start_pos[2], end_pos[2]) - 1
  local end_row = math.max(start_pos[2], end_pos[2]) - 1

  local start_col = math.min(start_pos[3], end_pos[3]) - 1
  local end_col = math.max(start_pos[3], end_pos[3]) - 1

  -- Get text
  local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col + 1, {})
  return table.concat(lines, "\n")
end
return {
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
            "nvim-telescope/telescope-fzf-native.nvim"
        },
        init = function()
            local telescope = require("telescope")
            -- mappings

            local opts = { noremap = true, silent = true }
            vim.keymap.set("n", "<Leader>ff", ":Telescope find_files<CR>", opts)
            -- Replaced in favor of live_grep_args
            -- vim.keymap.set("n", "<Leader>fg", ":Telescope live_grep<CR>", opts )
            vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
            vim.keymap.set("n", "<Leader>fb", ":Telescope buffers<CR>", opts)
            vim.keymap.set("n", "<Leader>fh", ":Telescope help_tags<CR>", opts)
            vim.keymap.set("n", "<Leader>@", ":Telescope treesitter<CR>", opts)
            vim.keymap.set("v", "<leader>fg", function()
                require("telescope-live-grep-args.shortcuts").grep_visual_selection()
            end, { desc = "call elescope-live-grep-args.shortcuts.grep_visual_selection" })
        end,
        opts = {
            fzf = {
                fuzzy = true,                   -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true,    -- override the file sorter
                case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            }
        },
        config = function()
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("live_grep_args")
        end
    }
}
