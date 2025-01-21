# blink-copilot

Configurable multi-backend supported Copilot [blink.cmp](https://github.com/Saghen/blink.cmp) completion source.

![sample](https://github.com/user-attachments/assets/94ba611a-12d9-4aba-bb97-ad8a433a47ad)

## 📋 Requirements

- Neovim >= 0.9.0

## 🌟 Key Features

1. Fully async `blink.cmp` integration for seamless completion.
2. Superior Unicode handling for better character compatibility.
3. Auto LSP client switching on buffer changes for smooth workflows.
4. Customizable completion candidates for maximum flexibility.
5. Latest LSP API with minimal processing for faster results.
6. Rewritten native LSP interaction for high-speed, low-resource performance.
7. Enhanced preview with smart indentation and snippet optimization.
8. Support both `copilot.lua` and Official `copilot.vim` for compliant environments.

## 🥘 Recipes

Here are some example configuration for using `blink-copilot` with [lazy.nvim](https://github.com/folke/lazy.nvim).

### Without LazyVim

<details>
<summary><code>blink-copilot</code> + <code>zbirenbaum/copilot.lua</code> (Third-party GitHub Copilot written in Lua)</summary>

```lua
{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
},
{
  "saghen/blink.cmp",
  optional = true,
  dependencies = {
    "fang2hou/blink-copilot",
    opts = {
      max_completions = 3,
      max_attempts = 5,
    },
  },
  opts = {
    sources = {
      default = { "copilot" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          -- You need a icon source to show it, check https://cmp.saghen.dev/recipes#mini-icons
          kind = "Copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  },
},
```

</details>

<details>
<summary><code>blink-copilot</code> + <code>github/copilot.vim</code> (Official GitHub Copilot Vim/Neovim Plugin)</summary>

```lua
{
  "github/copilot.vim",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufWinEnter",
  init = function()
    vim.g.copilot_no_maps = true
    vim.g.copilot_filetypes = {
      markdown = true,
      help = false,
    }
  end,
  config = function()
    vim.api.nvim_create_augroup("github_copilot", { clear = true })
    -- Only register the autocmds needed
    for _, event in pairs({ "FileType", "BufUnload", "BufEnter" }) do
      vim.api.nvim_create_autocmd({ event }, {
        group = "github_copilot",
        callback = function()
          vim.fn["copilot#On" .. event]()
        end,
      })
    end
  end,
},
{
  "saghen/blink.cmp",
  dependencies = {
    "fang2hou/blink-copilot",
    opts = {
      max_completions = 3,
      max_attempts = 5,
    },
  },
  opts = {
    sources = {
      default = { "copilot" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          -- You need a icon source to show it, check https://cmp.saghen.dev/recipes#mini-icons
          kind = "Copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  },
},
```

</details>

### LazyVim

<details>
<summary>Use <code>blink-copilot</code> to replace <code>blink-cmp-copilot</code> in LazyVim extra <a href="https://www.lazyvim.org/extras/ai/copilot">copilot</a></summary>

```lua
{ import = "lazyvim.plugins.extras.ai.copilot" },
{
  "saghen/blink.cmp",
  dependencies = {
    "fang2hou/blink-copilot",
    opts = {
      max_completions = 3,
      max_attempts = 5,
    },
  },
  opts = {
    sources = {
      default = { "copilot" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          kind = "Copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  },
}
```

</details>

<details>
<summary>Replace <code>copilot.lua</code> with official <code>copilot.vim</code></summary>

```lua
{
  "zbirenbaum/copilot.lua",
  enabled = false,
},
{
  "github/copilot.vim",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufWinEnter",
  init = function()
    vim.g.copilot_no_maps = true
    vim.g.copilot_filetypes = {
      markdown = true,
      help = false,
    }
  end,
  config = function()
    vim.api.nvim_create_augroup("github_copilot", { clear = true })
    -- Only register the autocmds needed
    for _, event in pairs({ "FileType", "BufUnload", "BufEnter" }) do
      vim.api.nvim_create_autocmd({ event }, {
        group = "github_copilot",
        callback = function()
          vim.fn["copilot#On" .. event]()
        end,
      })
    end
  end,
}
```

## 🔄 Alternatives and Related Projects

- [hrsh7th/cmp-copilot](https://github.com/hrsh7th/cmp-copilot) -
  The copilot.vim source for nvim-cmp.
- [zbirenbaum/copilot-cmp](https://github.com/zbirenbaum/copilot-cmp) -
  The copilot.lua source for nvim-cmp.
- [giuxtaposition/blink-cmp-copilot](https://github.com/giuxtaposition/blink-cmp-copilot) -
  The cmp source for blink-cmp.

## 🪪 License

MIT
