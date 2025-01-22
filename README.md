<!-- markdownlint-disable no-inline-html -->
<!-- markdownlint-disable first-line-heading -->

<div align="center">

![Completion Sample][title-image]

# blink-copilot

⚙️ Configurable GitHub Copilot [blink.cmp][blink-cmp-github] source

</div>

<details>

<summary><code>Table of Contents</code></summary>

- [📋 Requirements](#-requirements)
- [🌟 Key Features](#-key-features)
- [⚙️ Configuration](#️-configuration)
  - [`max_completions`](#max_completions)
  - [`max_attempts`](#max_attempts)
- [🥘 Recipes](#-recipes)
  - [Not Using LazyVim?](#not-using-lazyvim)
  - [With LazyVim copilot extra](#with-lazyvim-copilot-extra)
- [📚 Frequently Asked Questions](#-frequently-asked-questions)
- [🔄 Alternatives and Related Projects](#-alternatives-and-related-projects)
- [🪪 License](#-license)

</details>

## 📋 Requirements

- Neovim >= 0.9.0
- GitHub Copilot LSP Provider (choose one of the following)
  - [copilot.vim][copilot-vim-github] - Official GitHub Copilot Vim/Neovim Plugin
  - [copilot.lua][copilot-lua-github] - Third-party GitHub Copilot written in Lua

## 🌟 Key Features

1. Fully async `blink.cmp` integration.
2. Smarter LSP client detecting on buffer switching.
3. Customizable completion candidates for maximum flexibility.
4. Latest LSP API with minimal processing for faster results.
5. Rewritten native LSP interaction for high-speed, low-resource performance.
6. Enhanced preview with smart indentation and snippet optimization.
7. Support both `copilot.lua` and official `copilot.vim` as backend (LSP Provider).

## ⚙️ Configuration

Here is the default configuration for `blink-copilot`:

```lua
{
  max_completions = 3,
  max_attempts = 4,
}
```

### `max_completions`

Maximum number of completions to show.

> [!NOTE]
> Sometimes Copilot do not provide any completions, even you set `max_completions`
> to a large number. This is a limitation of Copilot itself, not the plugin.

Default: `3`

### `max_attempts`

Maximum number of attempts to fetch completions.

> [!NOTE]
> Each attempt will fetch 0 ~ 10 completions. Considering the possibility of failure,
> it is generally recommended to set it to `max_completions+1`.

Default: `4`

## 🥘 Recipes

Here are some example configuration for using `blink-copilot` with [lazy.nvim][lazy-nvim-github].

### Not Using LazyVim?

<details>
<summary><code>blink-copilot</code> + <code>zbirenbaum/copilot.lua</code></summary>

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
    opts = {},
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
}
```

</details>

<details>
<summary><code>blink-copilot</code> + <code>github/copilot.vim</code></summary>

```lua
{
  "github/copilot.vim",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufWinEnter",
  init = function()
    vim.g.copilot_no_maps = true
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
    opts = {},
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
}
```

</details>

### With LazyVim [copilot][lazyvim-copilot-extra] extra

<details>
<summary><code>blink-cmp-copilot</code> ➡️ <code>blink-copilot</code></summary>

```lua
{ import = "lazyvim.plugins.extras.ai.copilot" },
{
  "giuxtaposition/blink-cmp-copilot",
  enabled = false,
},
{
  "saghen/blink.cmp",
  dependencies = {
    "fang2hou/blink-copilot",
    opts = {},
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
<summary><i>(Optional)</i><code>copilot.lua</code> ➡️ <code>copilot.vim</code></summary>

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

</details>

## 📚 Frequently Asked Questions

> The number of completions does not match my settings.

This is because the number of completions provided by Copilot is not fixed.
The `max_completions` setting is only an upper limit, and the actual number of
completions may be less than this value.

> What's the difference between `blink-copilot` and `blink-cmp-copilot`?

- Completion Preview is now correctly deindented.
- Support both `copilot.lua` and `copilot.vim` as a backend.
- Support multiple completions, and it is configurable.
- LSP interaction no longer relies on `copilot.lua`, ensuring improved
  performance and compliance with the latest official LSP API specifications.

> The completion isn't working after restarting Copilot. What should I do?

The Copilot plugin doesn't automatically attach the new LSP client to buffers.
To resolve this, manually reopen your current buffer to attach the LSP client.
`blink-copilot` will automatically detect the new client and resume completions.

> Why aren't blink completions showing up?

Blink intentionally pauses completions during macro recording.
If you see `recording @x` in your statusline, press `q` to stop recording.

## 🔄 Alternatives and Related Projects

- [hrsh7th/cmp-copilot][cmp-copilot-github] -
  The copilot.vim source for `nvim-cmp`.
- [zbirenbaum/copilot-cmp][copilot-cmp-github] -
  The copilot.lua source for `nvim-cmp`.
- [giuxtaposition/blink-cmp-copilot][blink-cmp-copilot-github] -
  The copilot.lua source for `blink.cmp`.

## 🪪 License

MIT

<!-- LINKS -->

[title-image]: https://github.com/user-attachments/assets/94ba611a-12d9-4aba-bb97-ad8a433a47ad
[copilot-vim-github]: https://github.com/github/copilot.vim
[copilot-lua-github]: https://github.com/zbirenbaum/copilot.lua
[lazyvim-copilot-extra]: https://www.lazyvim.org/extras/ai/copilot
[lazy-nvim-github]: https://github.com/folke/lazy.nvim
[blink-cmp-github]: https://github.com/Saghen/blink.cmp
[cmp-copilot-github]: https://github.com/hrsh7th/cmp-copilot
[copilot-cmp-github]: https://github.com/hrsh7th/cmp-copilot
[blink-cmp-copilot-github]: https://github.com/giuxtaposition/blink-cmp-copilot
