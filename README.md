# Windows에서 Neovim 설치 및 초기 설정

Windows 11 기준으로 Neovim, 필수 도구, lazy.nvim, Telescope, Treesitter를 설정하는 방법입니다.

## 1. 설치

### 한 번에 설치 (권장)

[install-nvim.ps1](install-nvim.ps1)을 실행합니다. 관리자 권한은 필요 없습니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\install-nvim.ps1
```

설치되는 항목:

| 항목 | 용도 |
|------|------|
| Neovim | 에디터 본체 |
| Git | 플러그인 다운로드 |
| ripgrep, fd | Telescope의 파일/텍스트 검색 |
| zig | treesitter 파서 빌드용 C 컴파일러 |
| JetBrainsMono Nerd Font | 아이콘 표시용 폰트 |
| tree-sitter CLI | 파서 빌드 (릴리스 exe를 직접 설치) |

끝나면 **새 터미널**을 열고 확인합니다.

```powershell
nvim --version
tree-sitter --version
```

Windows Terminal의 폰트는 직접 `JetBrainsMono Nerd Font`로 바꿔야 합니다. (설정 → 프로필 → 기본값 → 모양 → 글꼴)

### 수동 설치

```powershell
winget install Neovim.Neovim
winget install Git.Git
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install zig.zig
winget install DEVCOM.JetBrainsMonoNerdFont
```

tree-sitter CLI는 [릴리스 페이지](https://github.com/tree-sitter/tree-sitter/releases)에서 `tree-sitter-windows-x64.gz`를 받아 압축을 풀고, `tree-sitter.exe`를 PATH에 있는 폴더에 둡니다.

> `npm install -g tree-sitter-cli`는 postinstall에서 exe 다운로드가 실패하면 `spawn ... tree-sitter.exe ENOENT` 오류가 납니다. 이 경우 위 방법을 쓰세요.

## 2. 설정 폴더 구조

설정 루트는 `%LOCALAPPDATA%\nvim`입니다.

```
nvim/
├─ init.lua              ← 진입점 (lua/ 밖)
└─ lua/
   ├─ config/
   │  ├─ options.lua
   │  ├─ lazy.lua
   │  └─ keymap.lua
   └─ plugins/
      ├─ telescope.lua
      ├─ treesitter.lua
      └─ colorscheme.lua
```

```powershell
mkdir $env:LOCALAPPDATA\nvim\lua\config, $env:LOCALAPPDATA\nvim\lua\plugins
```

## 3. 파일별 내용

### `init.lua`

`mapleader`는 lazy.nvim 로드 전에 설정해야 하므로 options를 먼저 불러옵니다.

```lua
require("config.options")
require("config.lazy")
require("config.keymap")
```

### `lua/config/options.lua`

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.cursorline = true
o.signcolumn = "yes"
o.scrolloff = 8
o.splitright = true
o.splitbelow = true
o.undofile = true
o.clipboard = "unnamedplus"
o.updatetime = 250
```

### `lua/config/lazy.lua`

lazy.nvim을 자동 설치하고 `lua/plugins/` 폴더의 파일을 모두 읽습니다.

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  checker = { enabled = false },
})
```

### `lua/config/keymap.lua`

플러그인과 무관한 공통 키맵입니다. 플러그인 전용 키는 각 플러그인 파일의 `keys`에 둡니다.

```lua
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>w", "<cmd>w<cr>", { desc = "저장" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "종료" })

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("v", "<", "<gv")
map("v", ">", ">gv")

map("v", "J", ":m '>+1<cr>gv=gv")
map("v", "K", ":m '<-2<cr>gv=gv")
```

### `lua/plugins/telescope.lua`

```lua
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
```

### `lua/plugins/treesitter.lua`

nvim-treesitter의 `main` 브랜치 방식입니다 (Neovim 0.11 이상, tree-sitter CLI 필요). 옛 `require("nvim-treesitter.configs").setup{}` 방식은 동결된 `master` 브랜치용이라 동작하지 않습니다.

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local langs = { "lua", "vim", "vimdoc", "python", "javascript", "typescript", "json", "markdown" }
    require("nvim-treesitter").install(langs)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = langs,
      callback = function() vim.treesitter.start() end,
    })
  end,
}
```

파일타입 이름과 파서 이름이 다른 언어(예: `typescriptreact` ↔ `tsx`)는 `pattern`에 파일타입 이름을 따로 추가하세요.

### `lua/plugins/colorscheme.lua`

```lua
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function() vim.cmd.colorscheme("tokyonight") end,
}
```

## 4. 첫 실행과 확인

```powershell
nvim
```

lazy.nvim이 플러그인을 자동 설치합니다. 이후 다음을 확인합니다.

- `:Lazy` : 플러그인 설치 상태
- `:checkhealth` : 누락된 도구
- `:checkhealth nvim-treesitter` : treesitter 상태
- `:InspectTree` : 코드 파일에서 구문 트리 확인

기본 키맵(leader = Space): `<leader>ff` 파일 찾기, `<leader>fg` 텍스트 검색.

## 5. 문제 해결

| 증상 | 원인과 해결 |
|------|-------------|
| `spawn ...tree-sitter.exe ENOENT` | npm 설치의 exe 다운로드 실패. npm 버전을 지우고 스크립트나 릴리스 exe로 설치 |
| 파서 빌드 실패 | tree-sitter CLI나 C 컴파일러가 PATH에 없음. 새 터미널에서 `tree-sitter --version`, `zig version` 확인 |
| `module 'nvim-treesitter.configs' not found` | 옛 API 사용. 3장의 `main` 방식으로 교체 |
| 아이콘이 네모로 보임 | 터미널 폰트를 Nerd Font로 변경 |
| 명령을 찾을 수 없음 | 설치 직후에는 PATH가 갱신되지 않음. 터미널을 새로 열기 |
| Telescope 검색이 동작하지 않음 | `rg --version`, `fd --version` 확인 |
