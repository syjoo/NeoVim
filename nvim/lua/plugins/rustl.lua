return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "rust_analyzer" },
            })

            vim.lsp.config("rust-analyzer", {
                settings = {
                    ["rust-analyzer"] = {},
                },
            })

            vim.lsp.enable("rust_analyzer")

        end,
    },
}
