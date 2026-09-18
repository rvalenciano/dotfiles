-- ==============================================================================
-- Neovim / LazyVim bootstrap
-- Docs: https://www.lazyvim.org
-- ==============================================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key (must be set before lazy)
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
    spec = {
        -- LazyVim base distribution
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },

        -- Import your custom plugin specs from lua/plugins/
        { import = "plugins" },
    },
    defaults = { lazy = false, version = false },
    install  = { colorscheme = { "tokyonight" } },
    checker  = { enabled = true },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "matchit", "matchparen",
                "netrwPlugin", "tarPlugin", "tohtml",
                "tutor", "zipPlugin",
            },
        },
    },
})
