-- FIXME: crashing on q! sometimes. it's not the sessions... probably ShaDa file.
-- TODO: Dashboard projects don't load. consider a diff session manager
-- TODO: turn off diagnostics with a hydra toggle
-- TODO: add symbols tree
-- TODO: add bindings to show Norg as a window while i hold a key down
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local setup_window_keymaps = function()
  -- map C-h/j/k/l to move windows
  vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
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
        trig = 'fctnodefault=',
        ---------------------------------------------
        dscr = 'Function Component with props AND type definition',
      },
      ---------------------------------------------
      -- Nodes
      fmt(
        [[
    type [name]Props = {
    }
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
        trig = 'fctchildrennodefault=',
        ---------------------------------------------
        dscr = 'Function Component with chilren',
      },
      ---------------------------------------------
      -- Nodes
      fmt(
        [[
    type [name]Props = {
      children?: React.ReactNode
    }
    function [name]({children}: [name]Props) {
      return (
        <>
        [content]
        {children}
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
        trig = 'fctchildren=',
        ---------------------------------------------
        dscr = 'Function Component with children, with export default',
      },
      ---------------------------------------------
      -- Nodes
      fmt(
        [[
    type [name]Props = {
      children?: React.ReactNode
    }
    function [name]({children}: [name]Props) {
      return (
        <>
        [content]
        {children}
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
    type [name]Props = {
    }
    export default function [name]({}: [name]Props) {
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

  local function setup_search_and_replace()
    local telescope = require 'telescope'
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'

    telescope.setup {
      defaults = {
        mappings = {
          i = {
            ['<C-r>'] = function(prompt_bufnr)
              local current_text = action_state.get_current_line()
              local search_text = vim.fn.input('Search for: ', current_text)
              local replace_text = vim.fn.input 'Replace with: '
              if search_text ~= '' then
                require('telescope.builtin').grep_string { search = search_text }
                vim.schedule(function()
                  local confirm = vim.fn.input 'Replace in all files? (y/n): '
                  if confirm:lower() == 'y' then
                    vim.cmd('%s/' .. search_text .. '/' .. replace_text .. '/g')
                    print('Replaced "' .. search_text .. '" with "' .. replace_text .. '" in all files.')
                  end
                end)
              end
            end,
          },
        },
      },
    }

    -- To invoke this search and replace functionality, you may bind it to a hotkey or command, like so:
    vim.api.nvim_set_keymap('n', '<Leader>sr', ':Telescope live_grep<CR>', { noremap = true, silent = true })
  end

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

    -- Find the Git root directory from the current file's path
    local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
      print 'Not a git repository. Searching on current working directory'
      return cwd
    end
    return git_root
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
      vim.fn.system 'git rev-parse --is-inside-work-tree'
      return vim.v.shell_error == 0
    end
    local function get_git_root()
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

  require('neodev').setup()
  -- document existing key chains

  require('which-key').register {
    ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
    ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
    ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
    ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
    ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
    ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
    ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
    ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
  }
  -- register which-key VISUAL mode
  -- required for visual <leader>hs (hunk stage) to work
  require('which-key').register({
    ['<leader>'] = { name = 'VISUAL <leader>' },
    ['<leader>h'] = { 'Git [H]unk' },
  }, { mode = 'v' })

  require('which-key').register {
    ['<leader>'] = { name = 'VISUAL <leader>' },
    ['<leader>h'] = { 'Git [H]unk' },
  }

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --
  --  Add any additional override configuration in the following tables. They will be passed to
  --  the `settings` field of the server config. You must look up that documentation yourself.
  --
  --  If you want to override the default filetypes that your language server will attach to you can
  --  define the property 'filetypes' to the map in question.
  local servers = {
    clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    tsserver = {},
    pylsp = {},
    -- html = { filetypes = { 'html', 'twig', 'hbs'} },
    -- csharp_ls = {
    --   root_dir = function(fname)
    --     return require('lspconfig').util.root_pattern('.godot','.git')(fname) or vim.fn.getcwd()
    --   end,
    -- },
    omnisharp = {
      -- root_dir = function(fname)
      --   return require('lspconfig').util.root_pattern('.godot', '.git')(fname) or vim.fn.getcwd()
      -- end,
    },
    tailwindcss = {},
    astro = {},
    svelte = {},
    lua_ls = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        diagnostics = { disable = { 'missing-fields' } },
      },
    },
  }

  -- mason-lspconfig requires that these setup functions are called in this order
  -- before setting up the servers.
  require('mason').setup()
  require('mason-lspconfig').setup()

  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  -- Ensure the servers above are installed
  local mason_lspconfig = require 'mason-lspconfig'

  mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
  }

  -- Install non-lsps with mason.
  -- require('mason-tool-installer').setup {
  --   ensure_installed = {
  --     'stylua',
  --     'prettier',
  --   },
  -- }

  mason_lspconfig.setup_handlers {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name],
        filetypes = (servers[server_name] or {}).filetypes,
        -- root_dir = (servers[server_name] or {}).root_dir,
      }
    end,
  }

  require('lspconfig').gdscript.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    -- NOTE: for whatever reason, vim.lsp.rpc.connect() doesn't work with gdscript
    cmd = { 'netcat', 'localhost', '6005' },
    filetypes = { 'gd', 'gdscript', 'gdscript3' },
    keys = {
      {
        '<leader>lspr',
        '<cmd>LspRestart<cr>',
        desc = '[LSP R]estart',
      },
    },
    root_dir = function(fname)
      return require('lspconfig').util.root_pattern('project.godot', '.git')(fname) or vim.fn.getcwd()
    end,
  }
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

local treesitter_opts = {
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,
  ignore_install = {},
  sync_install = false,
  modules = {},

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<leader>v',
      node_incremental = '<leader>v',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

local configure_cmp = function()
  -- [[ Configure nvim-cmp ]]
  -- See `:help cmp`
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  require('luasnip.loaders.from_vscode').lazy_load()
  luasnip.config.setup {}

  local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
      return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match '^%s*$' == nil
  end

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    completion = {
      completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete {},
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() and has_words_before() then
          -- if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = {
      { name = 'copilot' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
    },
  }

  -- Custom snippets in luasnip here
  add_statemachine_snippet()
end

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
  },

  {
    'tpope/vim-rhubarb',
    event = 'VeryLazy',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },

  -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-sleuth',
    event = 'VeryLazy',
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
      'folke/neodev.nvim',
    },
    config = configure_lsp,
    event = { 'VeryLazy' },
  },

  {
    'folke/zen-mode.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>z',
        function()
          require('zen-mode').toggle {}
        end,
        desc = 'Toggle [z]en-mode',
      },
    },
  },
  {
    'ahmedkhalf/project.nvim',
    dependencies = 'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    opts = {
      manual_mode = false, -- automactically add
    },
    keys = {
      {
        '<leader>sp',
        function()
          require('telescope').extensions.projects.projects {}
        end,
        desc = '[S]earch [P]rojects',
      },
    },
    config = function(_, opts)
      opts.detection_methods = { 'lsp', 'pattern' }
      opts.patterns = {
        '.git',
        '.hg',
        '.svn',
      }
      require('project_nvim').setup(opts)
      require('telescope').load_extension 'projects'
    end,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter', -- TODO: nvim-cmp lazy loading
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    config = configure_cmp,
  },

  {
    'mattn/emmet-vim',
    event = 'VeryLazy',
    ft = { 'typescriptreact', 'html' },
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
    event = 'VeryLazy',
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
      vim.cmd 'SetFont CaskaydiaCove Nerd Font:h10'
    end,
  },

  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        config = {
          week_header = {
            enable = true,
          },
          project = { enable = true, limit = 5, action = 'Telescope find_files' },
          mru = { limit = 5 },
          shortcut = {
            { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
            -- { desc = '⚡Restore Session', group = '@property', action = 'lua require("persistence").load({ last = true})', key = 'r' },
            { desc = '⚡Restore Session', group = '@property', action = 'SessionLoadLast', key = 'r' },
            {
              icon = ' ',
              icon_hl = '@variable',
              desc = 'Files',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f',
            },
            {
              desc = '📚 Notes',
              group = 'DiagnosticHint',
              action = 'Neorg journal today',
              key = 'n',
            },
            {
              desc = ' Apps',
              group = 'DiagnosticHint',
              action = 'Telescope app',
              key = 'a',
            },
            {
              desc = ' dotfiles',
              group = 'Number',
              action = 'Telescope file_browser path=' .. vim.fn.stdpath 'config',
              key = 'd',
            },
          },
        },
      }

      vim.keymap.set('n', '<leader>H', '<cmd>Dashboard<cr>', { desc = '[H]ome' }) --
    end,
    enabled = false, -- use alpha-nvim instead
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
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
    event = 'VimEnter',
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
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>lg', '<cmd>LazyGitCurrentFile<cr>', desc = '[L]azy[g]it' }, --
    },
  },

  {
    'stevearc/dressing.nvim',
    event = 'UIEnter',
    opts = {},
  },

  -- session management
  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    opts = {
      -- add any custom options here
    },
    keys = {
      { '<leader>tp', [[<cmd>lua require("persistence").stop()<cr>]], desc = 'Sto[p] Session Management' },
      { '<leader>ts', [[<cmd>lua require("persistence").start()<cr>]], desc = '[S]tart Session Management' },
    },
    enabled = false,
  },
  -- Chosen in favor of persistence.nvim
  {
    'olimorris/persisted.nvim',
    event = { 'VeryLazy' },
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
    'folke/edgy.nvim',
    event = 'VeryLazy',
    opts = {},
    config = function()
      -- views can only be fully collapsed with the global statusline
      vim.opt.laststatus = 3
      -- Default splitting will cause your main splits to jump when opening an edgebar.
      -- To prevent this, set `splitkeep` to either `screen` or `topline`.
      vim.opt.splitkeep = 'screen'
    end,
    enabled = false, -- disabled until I properly configure this
  },

  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    -- init = function()
    --   vim.g.barbar_auto_setup = false
    --   local map = vim.api.nvim_set_keymap
    --   local opts = { noremap = true, silent = true }
    --   -- Move to previous/next
    --   map('n', 'gT', '<Cmd>BufferPrevious<CR>', opts)
    --   map('n', 'gt', '<Cmd>BufferNext<CR>', opts)
    --   map('n', '<C-q>', '<Cmd>BufferClose<CR>', opts)
    -- end,
    opts = {
      sidebar_filetypes = {
        ['neo-tree'] = { text = 'Files' },
      },
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    keys = {
      { 'gT', '<Cmd>BufferPrevious<CR>' },
      { 'gt', '<Cmd>BufferNext<CR>' },
      { '<C-q>', '<Cmd>BufferClose<CR>' },
    },
    enabled = false,
  },

  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      filetypes = {},
    },
    config = function()
      -- vim.g.copilot_filetypes = {markdown = false, norg = false}
    end,
  },

  {
    'zbirenbaum/copilot-cmp',
    event = 'InsertEnter',
    dependencies = {
      'zbirenbaum/copilot.lua',
    },
    config = function()
      require('copilot_cmp').setup {
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
        },
      }
    end,
  },

  {
    'nanozuki/tabby.nvim',

    event = 'VimEnter',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {},
    enabled = true,
  },

  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
      options = {
        mode = 'tabs',
      },
    },
    enabled = false,
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
    event = 'VeryLazy',
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
    -- Theme inspired by Atom
    'olimorris/onedarkpro.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
    enabled = false,
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
    opts = {
      options = {
        component_separators = '|',
        section_separators = { left = '', right = '' },
        icons_enabled = true,
        theme = 'tokyonight',
        -- theme = 'onedark',
        -- component_separators = '|',
        -- section_separators = '',
      },
      extensions = {
        'neo-tree',
        'nvim-dap-ui',
        'mason',
        'lazy',
        'fugitive',
      },
    },
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
    event = { 'UIEnter', 'VeryLazy' },
    branch = '0.1.x',
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
        event = 'VeryLazy',
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
    event = { 'VeryLazy', 'VimEnter' },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall', 'TSBufEnable', 'TSBufDisable' },
    version = false, -- last release is way too old and doesn't work on Windows
    event = { 'VeryLazy' },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require('lazy.core.loader').add_to_rtp(plugin)
      require 'nvim-treesitter.query_predicates'
    end,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
    },
    build = ':TSUpdate',
    opts = treesitter_opts,
    ---@param opts TSConfig
    config = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  {
    'ggandor/leap.nvim',
    --event = 'VeryLazy', STOP, leap.nvim handle lazy loading already
    dependencies = {
      'tpope/vim-repeat',
    },
    priority = 51, -- set to 51 for the 'S' mapping to work
    config = function()
      require('leap').create_default_mappings()
    end,
  },

  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    opts = {
      keymaps = {
        visual = 'gz',
        visual_line = 'gZ',
      },
    },
  },

  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
  },
  {
    'vhyrro/luarocks.nvim',
    priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    config = true,
  },

  {
    'nvim-neorg/neorg',
    ft = 'norg',
    dependencies = { 'vhyrro/luarocks.nvim' },
    cmd = { 'Neorg', 'NeorgOpen', 'NeorgNew' },
    lazy = false,
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
    event = 'VeryLazy',
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
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
  },
}, {})

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
-- disabled because it messes up plugins, like git write, neotree
vim.o.autochdir = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.guifont = 'CaskaydiaCove Nerd Font:h14'

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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
