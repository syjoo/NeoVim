return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local langs = { "lua", "vim", "vimdoc", "python", "javascript", "typescript", "json", "markdown", "cpp", "rust", "java" }
    require("nvim-treesitter").install(langs)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = langs,
      callback = function() vim.treesitter.start() end,
    })
  end,
}