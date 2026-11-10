return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "파일 찾기" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "텍스트 검색" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "버퍼" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "도움말" },
  },
  opts = {},
}