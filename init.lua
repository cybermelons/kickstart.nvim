-- ============================================================================
-- External binaries this config expects on $PATH (install per-platform):
--
--   Required everywhere:    git, neovim (>= 0.11 recommended)
--   Lazygit (<leader>lg):   lazygit
--   Node-based LSPs:        node              (ts_ls, astro, tailwindcss,
--                                              svelte, bashls, jsonls, yamlls,
--                                              html, marksman)
--   Python LSP:             python3 + pip     (pylsp)
--   Formatters (conform):   prettier/prettierd (npm), stylua, codespell, gdformat
--   Godot LSP:              netcat            (or ncat — Windows)
--   Telescope fzf-native:   make + cc         (built once at install)
--
--   macOS:    brew install git lazygit node python stylua codespell
--   Windows:  scoop install git lazygit nodejs python stylua make gcc ncat
--   Linux:    apt/dnf install git lazygit nodejs python3 build-essential
--
--   Missing binaries are non-fatal — the relevant feature just no-ops silently.
-- ============================================================================

-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local lazy_installed = vim.uv.fs_stat(lazypath) ~= nil
if not lazy_installed then
  lazy_installed = pcall(vim.fn.system, {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }) and vim.uv.fs_stat(lazypath) ~= nil
end
if lazy_installed then
  vim.opt.rtp:prepend(lazypath)
end

-- A function to generate UUID
local function generate_uuid()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

local add_statemachine_snippet = function()
  local ls = require 'luasnip'
  local s = ls.snippet
  local t = ls.text_node
  local f = ls.function_node
  local sn = ls.snippet_node
  local d = ls.dynamic_node
  local r = ls.restore_node
  local i = ls.insert_node
  local l = require('luasnip.extras').lambda
  local rep = require('luasnip.extras').rep
  local p = require('luasnip.extras').partial
  local m = require('luasnip.extras').match
  local n = require('luasnip.extras').nonempty
  local dl = require('luasnip.extras').dynamic_lambda
  local fmt = require('luasnip.extras.fmt').fmt
  local fmta = require('luasnip.extras.fmt').fmta
  local types = require 'luasnip.util.types'
  local conds = require 'luasnip.extras.conditions'
  local conds_expand = require 'luasnip.extras.conditions.expand'
  -- local i = ls.insert_node
  -- local fmt = require('luasnip.extras.fmt').fmt
  ls.add_snippets('all', {
    s('uuidgen', {
      f(generate_uuid, {}),
    }),
  })

  ls.add_snippets('typescriptreact', {

    -- useState hook
    ls.s(
      'us',
      fmt(
        [[
  const [{}, set{}] = useState({})
  ]],
        { i(1), l(l._1:sub(1, 1):upper() .. l._1:sub(2)), i(2) }
      ),
      { descr = 'useState hook' }
    ),

    -- useEffect hook
    ls.s(
      'ue',
      fmt(
        [[
  useEffect(() => {{
   {}
  }}, [{}])
  ]],
        { i(1), i(2) }
      ),
      { descr = 'useEffect hook' }
    ),

    -- Try-catch
    ls.s(
      'errtoast',
      fmt(
        [[
  try {{
   {}
  }} catch (e) {{
   const msg = `${{e.message}}`
   console.error()
   toast({{
     description: error.message,
     variant: "destructive",
   }});
   {}
  }}
  ]],
        { i(1), i(2) }
      ),
      { descr = 'try-catch block with an error toast' }
    ),
  })

  ls.add_snippets('typescriptreact', {
    s(
      {
        trig = 'fcp=',
        ---------------------------------------------
        dscr = 'Function Component with props',
      },
      ---------------------------------------------
      -- Nodes
      fmt(
        [[
    function [name](props: [name]Props) {
      return (
        <>
        [content]
        </>
      )
    }
    []
    ]],
        {
          name = i(1),
          content = i(2),
          i(0),
        },
        {
          delimiters = '[]',
          repeat_duplicates = true,
        }
      )
    ),
    ---------------------------------------------
    s(
      {
        trig = 'fct=',
        ---------------------------------------------
        dscr = 'Function Component with props AND type definition, with export default',
      },
      ---------------------------------------------
      -- Nodes
      fmt(
        [[
    import type { ReactNode } from "react";
    type [name]Props = {
    children: ReactNode
    }
    export default function [name]({}: [name]Props) {
      return (
        <div>
        [content]
        </div>
      )
    }
    []
    ]],
        {
          name = i(1),
          content = i(2),
          i(0),
        },
        {
          delimiters = '[]',
          repeat_duplicates = true,
        }
      )
    ),
  })

  ls.add_snippets('gdscript', {
    s('state', {
      t {
        'class_name State',
        'extends Node',

        '@export',
        'var root: RootNode',
        '',
        '@export',
        '@onready',
        'var state: State = $%InitialState', -- Add a Node named InitialState in the editor, right click, give it a "Unique Node Name"
        '',
        '# Initialize the state machine by giving each child state a reference to the',
        '# parent object it belongs to and enter the default starting_state.',
        '',
        'func enter() -> void:',
        'pass',
        'func exit() -> void:',
        'pass',
        '',
        '',
        'func process_physics(delta: float) -> void:',
        '\tpass',
        '',
        'func process(delta: float) -> void:',
        '\tpass',
        '',
      },
    }),

    s('statemachine', {
      t {
        [[
        class_name StateMachine
        extends Node

        @export
        var state: State:
          set(value):
            state = value
            _change_state(value)

        # Initialize the state machine by giving each child state a reference to the
        # parent object it belongs to and enter the default starting_state.
        func init(parent: RootNode) -> void:
          for child in get_children():
            child.parent = parent

          # Initialize to the default state
          if (state):
            state.enter()

        # Change to the new state by first calling any exit logic on the current state.
        func _change_state(new_state: State) -> void:
          if state:
            state.exit()

          new_state.enter()


        func process_physics(delta: float) -> void:
          var new_state = state.process_physics(delta)
          if new_state:
            state = new_state

        func process(delta: float) -> void:
          var new_state = state.process_physics(delta)
          if new_state:
            state = new_state
        ]],
      },
    }),
  })
end

local configure_telescope = function()
  -- [[ Configure Telescope ]]
  -- See `:help telescope` and `:help telescope.setup()`
  require('telescope').setup {
    defaults = {
      mappings = {
        i = {
          ['<C-u>'] = false,
          ['<C-d>'] = false,
        },
      },
    },
  }

  -- Enable telescope fzf native, if installed
  pcall(require('telescope').load_extension, 'fzf')

  -- Telescope live_grep in git root
  -- Function to find the git root directory based on the current buffer's path
  local function find_git_root()
    -- Use the current buffer's path as the starting point for the git search
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir
    local cwd = vim.fn.getcwd()
    -- If the buffer is not associated with a file, return nil
    if current_file == '' then
      current_dir = cwd
    else
      -- Extract the directory from the current file's path
      current_dir = vim.fn.fnamemodify(current_file, ':h')
    end

    -- Check if we're in a worktree
    local git_dir_res = vim.system({ 'git', '-C', current_dir, 'rev-parse', '--git-dir' }, { text = true }):wait()
    if git_dir_res.code == 0 and (git_dir_res.stdout or ''):match('%.git[/\\]worktrees[/\\]') then
      -- We're in a worktree, use the worktree root (current working directory)
      return cwd
    end

    -- Find the Git root directory from the current file's path
    local root_res = vim.system({ 'git', '-C', current_dir, 'rev-parse', '--show-toplevel' }, { text = true }):wait()
    if root_res.code ~= 0 then
      print 'Not a git repository. Searching on current working directory'
      return cwd
    end
    return (root_res.stdout or ''):gsub('[\r\n]+$', '')
  end

  -- Custom live_grep function to search in git root
  local function live_grep_git_root()
    local git_root = find_git_root()
    if git_root then
      require('telescope.builtin').live_grep {
        search_dirs = { git_root },
      }
    end
  end

  vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

  -- See `:help telescope.builtin`
  vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
  vim.keymap.set('n', '<leader><space>', require('telescope.builtin').builtin, { desc = '[ ] Select pickers' })
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = true,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  local function telescope_live_grep_open_files()
    require('telescope.builtin').live_grep {
      grep_open_files = true,
      enable_preview = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end

  -- This function is basically find_files() combined with git_files(). The appeal of this function over the default find_files() is that you can find files that are not tracked by git. Also, find_files() only finds files in the current directory but this function finds files regardless of your current directory as long as you're in the project directory.
  local find_files_from_project_git_root = function()
    local function is_git_repo()
      return vim.system({ 'git', 'rev-parse', '--is-inside-work-tree' }, { text = true }):wait().code == 0
    end
    local function get_git_root()
      -- For worktrees, use the current working directory or the worktree root
      local current_dir = vim.fn.getcwd()
      -- Check if we're in a worktree
      local res = vim.system({ 'git', 'rev-parse', '--git-dir' }, { text = true }):wait()
      if res.code == 0 and (res.stdout or ''):match('%.git[/\\]worktrees[/\\]') then
        return current_dir
      end
      local dot_git_path = vim.fn.finddir('.git', '.;')
      return vim.fn.fnamemodify(dot_git_path, ':h')
    end
    local opts = {}
    if is_git_repo() then
      opts = {
        cwd = get_git_root(),
      }
    end
    require('telescope.builtin').find_files(opts)
  end

  vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
  vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
  vim.keymap.set('n', '<leader>sf', find_files_from_project_git_root, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<C-P>', find_files_from_project_git_root, { desc = 'Search Files' })
  vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sG', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep in current dir' })
  vim.keymap.set('n', '<leader>sg', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [g]rep on Git Root' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
end

local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  vim.keymap.set('n', '<C-space>', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction', buffer = bufnr, noremap = true })

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<leader>gk', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    -- vim.lsp.buf.format()
    require('conform').format {
      async = true,
      lsp_fallback = true,
    }
  end, { desc = 'Format current buffer with LSP' })
end

local configure_lsp = function()
  -- [[ Configure LSP ]]
  --  This function gets run when an LSP connects to a particular buffer.
  --
  --

  -- document existing key chains

  require('which-key').add {
    { '<leader>c', group = '[C]ode' },
    { '<leader>c_', hidden = true },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>d_', hidden = true },
    { '<leader>g', group = '[G]it' },
    { '<leader>g_', hidden = true },
    { '<leader>h', group = 'Git [H]unk' },
    { '<leader>h_', hidden = true },
    { '<leader>r', group = '[R]ename' },
    { '<leader>r_', hidden = true },
    { '<leader>s', group = '[S]earch' },
    { '<leader>s_', hidden = true },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>t_', hidden = true },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>w_', hidden = true },
  }

  -- register which-key VISUAL mode
  -- required for visual <leader>hs (hunk stage) to work
  require('which-key').add({
    { '<leader>', group = 'VISUAL <leader>', mode = 'v' },
    { '<leader>h', desc = 'Git [H]unk', mode = 'v' },
  }, { mode = 'v' })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --
  --  Add any additional override configuration in the following tables. They will be passed to
  --  the `settings` field of the server config. You must look up that documentation yourself.
  --
  --  If you want to override the default filetypes that your language server will attach to you can
  --  define the property 'filetypes' to the map in question.
  local servers = {
    astro = { filetypes = { 'astro' } },
    clangd = { filetypes = { 'c', 'cpp', 'objc', 'objcpp' } },
    ts_ls = {
      filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      root_dir = require('lspconfig').util.root_pattern 'package.json',
    },
    pylsp = { filetypes = { 'python' } },
    omnisharp = { filetypes = { 'cs' } },
    tailwindcss = {
      filetypes = { 'astro', 'html', 'css', 'scss', 'typescriptreact', 'javascriptreact', 'vue', 'svelte' },
    },
    svelte = { filetypes = { 'svelte' } },
    marksman = { filetypes = { 'markdown', 'mdx', 'md' } },
    lua_ls = {
      filetypes = { 'lua' },
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        diagnostics = { disable = { 'missing-fields' } },
      },
    },
    bashls = { filetypes = { 'sh', 'bash', 'zsh' } },
    jsonls = { filetypes = { 'json', 'jsonc' } },
    yamlls = { filetypes = { 'yaml' } },
    html = { filetypes = { 'html' } },
  }

  -- mason-lspconfig requires that these setup functions are called in this order
  -- before setting up the servers.
  require('mason').setup()
  require('mason-lspconfig').setup {
    automatic_installation = false,
    automatic_enable = false,
  }

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, 'blink.cmp')
  if ok_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  vim.lsp.config('*', {
    capabilities = capabilities,
    on_attach = on_attach,
  })

  for server_name, server_cfg in pairs(servers) do
    vim.lsp.config(server_name, {
      settings = server_cfg,
      filetypes = server_cfg.filetypes,
      root_dir = server_cfg.root_dir,
    })
    vim.lsp.enable(server_name)
  end

  -- On-demand LSP install: when a filetype opens, install its server via mason
  -- if missing, then start LSP. Silent if mason/network unavailable.
  do
    local ft_to_servers = {}
    for name, cfg in pairs(servers) do
      for _, ft in ipairs(cfg.filetypes or {}) do
        ft_to_servers[ft] = ft_to_servers[ft] or {}
        table.insert(ft_to_servers[ft], name)
      end
    end

    -- mason package names differ from lspconfig server names for some entries
    local lspconfig_to_mason = {
      ts_ls = 'typescript-language-server',
      lua_ls = 'lua-language-server',
      bashls = 'bash-language-server',
      jsonls = 'json-lsp',
      yamlls = 'yaml-language-server',
      html = 'html-lsp',
      pylsp = 'python-lsp-server',
      omnisharp = 'omnisharp',
      tailwindcss = 'tailwindcss-language-server',
      svelte = 'svelte-language-server',
      marksman = 'marksman',
      astro = 'astro-language-server',
      clangd = 'clangd',
    }

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('LspOnDemandInstall', { clear = true }),
      callback = function(args)
        local servers_for_ft = ft_to_servers[args.match]
        if not servers_for_ft then return end
        local ok, registry = pcall(require, 'mason-registry')
        if not ok then return end
        for _, server_name in ipairs(servers_for_ft) do
          local mason_name = lspconfig_to_mason[server_name] or server_name
          local pkg_ok, pkg = pcall(registry.get_package, mason_name)
          if pkg_ok and not pkg:is_installed() then
            vim.notify('Installing ' .. mason_name .. '...', vim.log.levels.INFO)
            local install_ok, handle = pcall(function() return pkg:install() end)
            if install_ok and handle then
              handle:once('closed', function()
                vim.schedule(function()
                  if pkg:is_installed() then
                    vim.notify(mason_name .. ' ready', vim.log.levels.INFO)
                    pcall(vim.cmd, 'LspStart ' .. server_name)
                  end
                end)
              end)
            end
          end
        end
      end,
    })
  end

  -- gdscript LSP needs `netcat` (or `ncat` on Windows) on PATH; connects to running Godot editor
  local nc = vim.fn.executable('netcat') == 1 and 'netcat' or (vim.fn.executable('ncat') == 1 and 'ncat' or nil)
  if nc then
    vim.lsp.config('gdscript', {
      cmd = { nc, 'localhost', '6005' },
      filetypes = { 'gd', 'gdscript', 'gdscript3' },
      root_dir = function(_, on_dir)
        on_dir(vim.fs.root(0, { 'project.godot', '.git' }) or vim.fn.getcwd())
      end,
    })
    vim.lsp.enable('gdscript')
  end

  vim.lsp.config('ts_ls', {
    root_dir = function(bufnr, on_dir)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      -- Skip deno projects so tsserver doesn't attach there
      if vim.fs.root(fname, { 'deno.json', 'deno.jsonc' }) then
        return
      end
      local root = vim.fs.root(fname, { 'package.json' })
      if root then
        on_dir(root)
      end
    end,
    single_file_support = false,
  })
end

-- Godot setup function
local setup_godot_dap = function()
  local dap = require 'dap'

  dap.adapters.godot = {
    type = 'server',
    host = '127.0.0.1',
    port = 6006,
  }

  dap.configurations.gdscript = {
    {
      launch_game_instance = false,
      launch_scene = false,
      name = 'Launch scene',
      project = '${workspaceFolder}',
      request = 'launch',
      type = 'godot',
    },
  }
end

-- nvim-treesitter `main` branch: parsers managed via :TSInstall / setup().install,
-- highlight/indent/folds wired manually per-buffer via FileType autocmd.
local treesitter_ensure_installed = {
  'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript',
  'vimdoc', 'vim', 'bash', 'astro', 'query', 'markdown', 'markdown_inline',
}

-- LuaSnip post-setup: load snippets from vim-snippets / astro-snippets and
-- register any custom snippets. Invoked from LuaSnip's plugin config.
local configure_luasnip = function()
  local luasnip = require 'luasnip'
  luasnip.config.setup {}
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_snipmate').lazy_load()

  add_statemachine_snippet()
  --add_plugin_snippets()
end

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
if lazy_installed then
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-sleuth',
    event = { 'BufReadPost', 'BufNewFile' },
  },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'folke/which-key.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        'j-hui/fidget.nvim',
        opts = {
          -- top right
          notification = {
            window = {
              align = 'top',
            },
          },
        },
      },

      -- Additional lua configuration, makes nvim stuff amazing!
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
      },
    },
    config = configure_lsp,
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspStart', 'Mason' },
  },

  {
    'folke/zen-mode.nvim',
    keys = {
      {
        '<leader>mz',
        function()
          require('zen-mode').toggle {}
        end,
        desc = 'Toggle [z]en-mode',
      },
    },
  },

  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    build = (function()
      if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return nil end
      return 'make install_jsregexp'
    end)(),
    dependencies = {
      'honza/vim-snippets',
      'louiss0/astro-snippets',
    },
    config = function()
      configure_luasnip()
    end,
  },

  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '*', -- use prebuilt fuzzy matcher binary from release
    dependencies = {
      'L3MON4D3/LuaSnip',
      { 'giuxtaposition/blink-cmp-copilot', dependencies = { 'zbirenbaum/copilot.lua' } },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' = Ctrl-y to confirm, Tab/Shift-Tab to navigate, Ctrl-n/p alternates.
      -- 'super-tab' = Tab confirms and snippet-jumps; falls back to native Tab.
      keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        default = { 'copilot', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = 'rounded' },
      },
      signature = { enabled = true },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },

  {
    'mattn/emmet-vim',
    ft = { 'typescriptreact', 'html', 'astro' },
  },

  {
    'norcalli/nvim-colorizer.lua',
    cmd = { 'ColorizerToggle', 'ColorizerAttachToBuffer', 'ColorizerReloadAllBuffers' },
    --ft = { 'typescriptreact', 'typescript', 'javascript', 'css' },
  },

  {
    'mfussenegger/nvim-dap',
    ft = { 'gdscript' },
    keys = {
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'DAP: Toggle [B]reakpoint',
      },
      {
        '<leader>df',
        function()
          local widgets = require 'dap.ui.widgets'
          widgets.centered_float(widgets.frames)
        end,
        desc = 'DAP: Show [F]rames',
      },
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
      },
      {
        '<F10>',
        function()
          require('dap').step_over()
        end,
      },
      {
        '<F11>',
        function()
          require('dap').step_into()
        end,
      },
      {
        '<F12>',
        function()
          require('dap').step_out()
        end,
      },
    },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'neovim/nvim-lspconfig',
      -- fancy UI for the debugger
      {
        'rcarriga/nvim-dap-ui',
      -- stylua: ignore
      keys = {
        { "<leader>du", function() require("dapui").toggle({ }) end, desc = "DAP: UI" },
        { "<leader>de", function() require("dapui").eval() end, desc = "DAP: Eval", mode = {"n", "v"} },
      },
        opts = {},
        config = function(_, opts)
          -- setup dap config by VsCode launch.json file
          -- require("dap.ext.vscode").load_launchjs()
          local dap = require 'dap'
          local dapui = require 'dapui'
          dapui.setup(opts)
          dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open {}
          end
          dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close {}
          end
          dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close {}
          end
        end,
      },

      -- virtual text for the debugger
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },

      -- which key integration
      {
        'folke/which-key.nvim',
        optional = true,
        opts = {
          defaults = {
            ['<leader>d'] = { name = '+debug' },
          },
        },
      },

      -- mason.nvim integration
      {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = 'mason.nvim',
        cmd = { 'DapInstall', 'DapUninstall' },
        opts = {
          -- Makes a best effort to setup the various debuggers with
          -- reasonable debug configurations
          automatic_installation = true,

          -- You can provide additional configuration to the handlers,
          -- see mason-nvim-dap README for more information
          handlers = {},

          -- You'll need to check that you have the required things installed
          -- online, please don't ask me how to install them :)
          ensure_installed = {
            -- Update this to ensure that you have the debuggers for the langs you want
          },
        },
      },
    },
    config = function()
      setup_godot_dap()
    end,
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {},
    event = 'UIEnter',
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    cmd = { 'MasonToolsInstall', 'MasonToolsUpdate', 'MasonToolsClean' },
    dependencies = { 'williamboman/mason.nvim' },
  },

  -- Works in conjunction with LSP for faster formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      -- Autoformat with space-f
      {
        '<leader>f',
        function()
          require('conform').format {
            async = true,
            lsp_fallback = true,
          }
        end,
        desc = '[F]ormat code',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua', 'trim_whitespace' },
        -- Use the "*" filetype to run formatters on all filetypes.
        ['*'] = { 'codespell' },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ['_'] = { 'trim_whitespace' },
        ['astro'] = { 'prettierd', 'prettier' },
        ['javascript'] = { 'prettierd', 'prettier' },
        ['javascriptreact'] = { 'prettierd', 'prettier' },
        ['typescript'] = { 'prettierd', 'prettier' },
        ['typescriptreact'] = { 'prettierd', 'prettier' },
        ['vue'] = { 'prettierd', 'prettier' },
        ['css'] = { 'prettierd', 'prettier' },
        ['scss'] = { 'prettierd', 'prettier' },
        ['less'] = { 'prettierd', 'prettier' },
        ['html'] = { 'prettierd', 'prettier' },
        ['jsonc'] = { 'prettierd', 'prettier' },
        ['yaml'] = { 'prettierd', 'prettier' },
        ['markdown'] = { 'prettierd', 'prettier' },
        ['markdown.mdx'] = { 'prettierd', 'prettier' },
        ['graphql'] = { 'prettierd', 'prettier' },
        ['handlebars'] = { 'prettierd', 'prettier' },
        ['gdscript'] = { 'gdformat' },
      },
    },
  },

  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').load_extension 'file_browser'
    end,
    keys = {
      {
        '<leader>sb',
        '<cmd>Telescope file_browser<cr>',
        desc = '[S]earch File [B]rowser',
      },
    },
  },

  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      --
    },
    keys = {
      { '<leader>st', '<cmd>TodoTelescope cwd=%:p:h<cr>', desc = '[S]earch [T]odo' },
    },
    event = 'BufRead',
  },

  -- Sets fontsizes on GUIs
  {
    'mkropat/vim-ezguifont',
    event = 'UIEnter',
    keys = {
      { '<C-->', '<cmd>DecreaseFont<cr>', desc = 'GUI: Decrease font size' },
      { '<C-=>', '<cmd>IncreaseFont<cr>', desc = 'GUI: Increase font size' },
      { '<C-0>', '<cmd>ResetFontSize<cr>', desc = 'GUI: Reset font size' },
    },
    config = function()
      vim.cmd 'SetFont CaskaydiaCove Nerd Font:h14'
    end,
  },

  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- TODO: configure this dashboard
      local dashboard = require('alpha.themes.startify').config
      -- dashboard.section.
      require('alpha').setup(dashboard)

      vim.keymap.set('n', '<leader>H', '<cmd>Alpha<cr>', { desc = '[H]ome' }) --
    end,
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  -- Adds a lazygit wrapper
  {
    'kdheepak/lazygit.nvim',
    cmd = { 'LazyGit', 'LazyGitCurrentFile', 'LazyGitConfig', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>lg', '<cmd>LazyGitCurrentFile<cr>', desc = '[L]azy[g]it' },
    },
    init = function()
      vim.g.lazygit_floating_window_use_plenary = 0
    end,
  },

  {
    'stevearc/dressing.nvim',
    event = 'UIEnter',
    opts = {},
  },

  -- session management
  {
    'olimorris/persisted.nvim',
    keys = { '<leader>ss' },
    cmd = { 'SessionLoad', 'SessionLoadLast', 'SessionSave', 'SessionDelete' },
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('persisted').setup {
        save_dir = vim.fn.expand(vim.fn.stdpath 'data' .. '/sessions/'), -- directory where session files are saved
        silent = false, -- silent nvim message when sourcing session file
        use_git_branch = true, -- create session files based on the branch of a git enabled repository
        default_branch = 'main', -- the branch to load if a session file is not found for the current branch
        autosave = true, -- automatically save session files when exiting Neovim
        should_autosave = nil, -- function to determine if a session should be autosaved
        autoload = false, -- automatically load the session for the cwd on Neovim startup
        on_autoload_no_session = nil, -- function to run when `autoload = true` but there is no session to load
        follow_cwd = true, -- change session file name to match current working directory if it changes
        allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
        ignored_dirs = nil, -- table of dirs that are ignored when auto-saving and auto-loading
        telescope = {
          reset_prompt = true, -- Reset the Telescope prompt after an action?
        },
      }
      require('telescope').load_extension 'persisted'
    end,
    keys = {
      -- { '<leader>tp', [[<cmd>lua require("persistence").stop()<cr>]], desc = 'Sto[p] Session Management' },
      -- { '<leader>ts', [[<cmd>lua require("persistence").start()<cr>]], desc = '[S]tart Session Management' },
      { '<leader>ss', [[<cmd>Telescope persisted<cr>]], desc = '[S]essions' },
    },
  },

  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    -- blink-cmp-copilot drives completion; disable copilot.lua's own ghost-text and panel.
    opts = {
      filetypes = {},
      panel = { enabled = false },
      suggestion = { enabled = false },
    },
  },

  {
    'nanozuki/tabby.nvim',

    event = 'VimEnter',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {},
    enabled = true,
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    opts = {},
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = {
      {
        '<C-n>',
        function()
          vim.cmd 'Neotree toggle %:p:h'
        end,
        desc = 'Toggle [N]eoTree on current file',
      },
      {
        '<C-N>',
        function()
          vim.cmd 'Neotree toggle'
        end,
        desc = 'Toggle [N]eoTree on curdir',
      },
      {
        '<leader>nb',
        function()
          vim.cmd 'Neotree toggle show buffers right'
        end,
        desc = 'Toggle [N]eoTree on [b]uffers',
      },
      {
        '<leader>ng',
        function()
          vim.cmd 'Neotree float git_status'
        end,
        desc = 'Show [N]eoTree on [g]it',
      },
    },
  },
  {
    'ziontee113/icon-picker.nvim',
    opts = { disable_legacy_commands = true },
    keys = {
      { '<Leader><Leader>i', '<cmd>IconPickerNormal<cr>', mode = 'n', desc = 'Open [I]con Picker', silent = true },
      { '<Leader><Leader>y', '<cmd>IconPickerYank<cr>', mode = 'n', desc = '[Y]ank from Icon Picker', silent = true }, --> Yank the selected icon into register
      { '<C-i>', '<cmd>IconPickerInsert<cr>', mode = 'i', desc = 'Open [I]con Picker', silent = true },
    },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {}, -- this is equalent to setup({}) function
  },

  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('mini.animate').setup()
    end,
    -- enable only if neovide isn't available
    enabled = not vim.g.neovide,
  },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'tokyonight-moon'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    event = 'VimEnter',
    dependencies = { 'folke/tokyonight.nvim' },
    opts = function()
      require('lazy').load { plugins = { 'tokyonight.nvim' } }
      local theme_ok, theme = pcall(require, 'lualine.themes.tokyonight')
      return {
        options = {
        component_separators = '|',
        section_separators = { left = '', right = '' },
        icons_enabled = true,
        theme = theme_ok and theme or 'auto',
      },
      extensions = {
        'neo-tree',
        'nvim-dap-ui',
        'mason',
        'lazy',
      },
    }
    end,
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
    event = 'VimEnter',
  },

  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<leader>tr',
        '<cmd>Trouble<cr>',
        desc = '[Tr]ouble - Show diagnostics',
      },
    },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      '<leader>?', '<leader><space>', '<leader>/',
      '<leader>sf', '<leader>sg', '<leader>sG', '<leader>sw', '<leader>sd', '<leader>sr',
      '<leader>sk', '<leader>sh', '<leader>st',
      '<leader>gf', '<C-P>', '<leader>sb',
    },
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        lazy = true,
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    opts = {
      defaults = {
        prompt_prefix = '   ',
      },
      extensions = {
        persisted = {
          layout_config = { width = 0.55, height = 0.55 },
        },
      },
    },

    config = function(self, opts)
      require('telescope').setup(opts) -- might be an unneeded line? dunno if opts already calls this
      configure_telescope()
    end,
  },

  {
    'nvim-telescope/telescope-ui-select.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    lazy = true,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    -- `build` runs on install and on every `:Lazy update` — exactly when parsers
    -- need (re)compiling. It does NOT run on normal startup.
    build = function()
      require('nvim-treesitter').install(treesitter_ensure_installed):wait(300000)
    end,
    config = function()
      require('nvim-treesitter').setup()

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-setup', { clear = true }),
        callback = function(args)
          local buf = args.buf
          local ft = vim.bo[buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if not lang or lang == '' then return end
          if not pcall(vim.treesitter.start, buf, lang) then return end

          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      local function sel(obj) return function() select.select_textobject(obj, 'textobjects') end end
      for _, m in ipairs { 'x', 'o' } do
        vim.keymap.set(m, 'aa', sel '@parameter.outer', { desc = 'a parameter' })
        vim.keymap.set(m, 'ia', sel '@parameter.inner', { desc = 'inner parameter' })
        vim.keymap.set(m, 'af', sel '@function.outer', { desc = 'a function' })
        vim.keymap.set(m, 'if', sel '@function.inner', { desc = 'inner function' })
        vim.keymap.set(m, 'ac', sel '@class.outer', { desc = 'a class' })
        vim.keymap.set(m, 'ic', sel '@class.inner', { desc = 'inner class' })
      end

      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer', 'textobjects') end, { desc = 'Next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer', 'textobjects') end, { desc = 'Next class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() move.goto_next_end('@function.outer', 'textobjects') end, { desc = 'Next function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function() move.goto_next_end('@class.outer', 'textobjects') end, { desc = 'Next class end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'Prev function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end, { desc = 'Prev class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() move.goto_previous_end('@function.outer', 'textobjects') end, { desc = 'Prev function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() move.goto_previous_end('@class.outer', 'textobjects') end, { desc = 'Prev class end' })

      vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap next parameter' })
      vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap previous parameter' })
    end,
  },

  {
    'davidmh/mdx.nvim',
    ft = { 'mdx', 'markdown.mdx' },
    config = function()
      require('mdx').setup()
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

  {
    url = 'https://codeberg.org/andyg/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    priority = 51, -- set to 51 for the 'S' mapping to work
    keys = {
      { 's', '<Plug>(leap-forward)', mode = { 'n', 'x', 'o' } },
      { 'S', '<Plug>(leap-backward)', mode = { 'n', 'x', 'o' } },
      { 'gs', '<Plug>(leap-from-window)', mode = { 'n', 'x', 'o' } },
    },
  },

  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    keys = {
      { 'ys', mode = 'n' },
      { 'yS', mode = 'n' },
      { 'ds', mode = 'n' },
      { 'cs', mode = 'n' },
      { 'gz', mode = 'v' },
      { 'gZ', mode = 'v' },
    },
    opts = {
      keymaps = {
        visual = 'gz',
        visual_line = 'gZ',
      },
    },
  },

  {
    'numToStr/Comment.nvim',
    keys = {
      { 'gc', mode = { 'n', 'v' } },
      { 'gb', mode = { 'n', 'v' } },
      'gcc',
      'gbc',
      { '<C-/>', mode = { 'n', 'v', 'x' } },
    },
    opts = {
      -- add any options here
    },
  },
  {
    'vhyrro/luarocks.nvim',
    config = true,
  },

  {
    'nvim-neorg/neorg',
    ft = 'norg',
    dependencies = { 'vhyrro/luarocks.nvim' },
    cmd = { 'Neorg', 'NeorgOpen', 'NeorgNew' },
    keys = {
      {
        '<leader>N',
        '<cmd>Neorg journal today<cr>',
        desc = '[N]otes',
      },
      {
        '<leader>nt',
        '<cmd>Neorg toc<cr>',
        desc = '[N]eorg [T]able of Contents',
      },
    },
    config = function()
      require('neorg').setup {
        load = {
          ['core.defaults'] = {}, -- Loads default behaviour
          ['core.concealer'] = {}, -- Adds pretty icons to your documents
          ['core.dirman'] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = '~/notes',
              },
              default_workspace = 'notes',
            },
          },
          -- ["core.keybinds"] = {
          --   config = {
          --     default_keybinds = false,
          --   }
          -- }
        },
      }

      -- in neorg files, map c-shift-n
      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  },

  {
    'cybermelons/bookmarks.nvim',
    dependencies = { 'telescope.nvim' },
    keys = {
      '<leader>mm', '<leader>me', '<leader>mc',
      '<leader>mn', '<leader>mp', '<leader>ml', '<leader>b',
    },
    config = function()
      require('bookmarks').setup()
      require('telescope').load_extension 'bookmarks'
      -- Extra Keymaps
      local bm = require 'bookmarks'
      vim.keymap.set('n', '<leader>mm', bm.bookmark_toggle, { desc = 'Toggle book[m]ark' }) -- add or remove bookmark at current line
      vim.keymap.set('n', '<leader>me', bm.bookmark_ann, { desc = '[E]dit mark annotation at current line' }) --
      vim.keymap.set('n', '<leader>mc', bm.bookmark_clean, { desc = '[C]lean all marks in local buffer' }) --
      vim.keymap.set('n', '<leader>mn', bm.bookmark_next, { desc = 'Jump to [n]ext mark in local buffer' }) --
      vim.keymap.set('n', '<leader>mp', bm.bookmark_prev, { desc = 'Jump to [p]revious mark in local buffer' }) --
      vim.keymap.set('n', '<leader>ml', bm.bookmark_list, { desc = 'Show marked file [l]ist' }) --
      vim.keymap.set('n', '<leader>b', require('telescope').extensions.bookmarks.list, { desc = '[B]ookmarks' })
    end,
  },

  -- End lazy plugin list

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {
  performance = {
    rtp = {
      -- Disable Neovim's bundled vim-era plugins we don't use; saves startup time.
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'rplugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
end

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true
vim.o.autoindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Auto-cd into the dir of file
-- disabled because it messes up plugins, like git write, neotree, and git worktrees
vim.o.autochdir = false

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- overridden by ez-guifont, so commenting out.
-- vim.o.guifont = 'CaskaydiaCove Nerd Font:h14'

vim.o.scrolloff = 8

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[n', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']n', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Comment with Ctrl-/
vim.keymap.set('n', '<C-/>', '<Plug>(comment_toggle_linewise_current)', { desc = '[Ctrl-/] Comment toggle linewise' })
vim.keymap.set('x', '<C-/>', '<Plug>(comment_toggle_linewise_visual)', { desc = '[Ctrl-/] Comment toggle linewise' })
vim.keymap.set('v', '<C-/>', '<Plug>(comment_toggle_linewise_visual)', { desc = '[Ctrl-/] Comment toggle linewise' })
vim.keymap.set('n', ';', ':', { desc = ':Command mode' })

-- Window management Hotkeys
-- <Control-HJKL> moves windows
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below', noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above', noremap = true, silent = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to window left', noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to window right', noremap = true, silent = true })

-- Bind shift+j/k to move lines in visual mode
vim.keymap.set('v', 'K', 'k', { noremap = true, silent = true })
vim.keymap.set('v', 'J', 'j', { noremap = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {

  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- autoruns on BufEnter
-- create autocommand to set tabs
-- Set shiftwidth and tabstop to 4 only for gdscript files

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = { '*.gd', '*.gdscript' },
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = { '*.norg' },
  callback = function()
    vim.o.number = false
  end,
})

-- Default tabwidth 2 for everything except languages that set their own
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if args.match == 'gd' or args.match == 'gdscript' or args.match == 'gdscript3' then
      return
    end
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

-- Function to get the git repository name
function GetRepoName()
  local res = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  local root = (res.stdout or ''):gsub('[\r\n]+$', '')
  return vim.fs.basename(root)
end

-- Function to dump repository contents
function DumpRepoContents()
  local repo_name = GetRepoName()
  if repo_name == nil then
    vim.notify('Not in a git repository', vim.log.levels.ERROR)
    return
  end

  -- Construct the output filename
  local output_file = repo_name .. '-wiki.txt'

  -- Execute your shell script with the output file
  local cmd = string.format('~/bin/cat_git_repo.sh -o %s -e "*.xml" -e "*.webp"', output_file)
  vim.fn.system(cmd)

  -- Notify user of completion
  vim.notify('Repository dumped to ' .. output_file, vim.log.levels.INFO)
end

-- Set up the keymapping (change the key combination as needed)
vim.keymap.set('n', '<leader>rd', DumpRepoContents, { desc = 'Dump repository to wiki file' })

-- Disable auto-commenting when pressing o/O
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove { "c", "r", "o" }
  end,
})

-- Autoindent astro
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = { "astro" },
--   callback = function()
--     vim.bo.expandtab = true
--     vim.bo.shiftwidth = 2
--     vim.bo.softtabstop = 2
--     vim.bo.tabstop = 2
--     vim.bo.smartindent = true
--     vim.bo.autoindent = true
--   end,
-- })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
