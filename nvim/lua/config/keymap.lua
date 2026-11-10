local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")                 -- 검색 하이라이트 해제
map("n", "<leader>w", "<cmd>w<cr>", { desc = "저장" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "종료" })

-- 창 이동
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- 비주얼 모드 들여쓰기 후 선택 유지
map("v", "<", "<gv")
map("v", ">", ">gv")

-- 선택한 줄 위아래 이동
map("v", "J", ":m '>+1<cr>gv=gv")
map("v", "K", ":m '<-2<cr>gv=gv")