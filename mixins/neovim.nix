{ config, pkgs, inputs, ... }:

let
  neovimPkg = if (pkgs.system == "aarch64-linux" || pkgs.system == "x86_64-linux")
    then inputs.neovim-nightly.defaultPackage."${pkgs.system}"
    else pkgs.neovim;
in {
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;

        package = neovimPkg;

        # TODO: how can I inherit `system` here?
        plugins = with pkgs.vimPlugins; [
          #nvim-treesitter        # neovim 0.5
          #nvim-lspconfig         # neovim 0.5
          #completion-nvim        # neovim 0.5
          #completion-treesitter  # neovim 0.5
          #lsp-status-nvim        # neovim 0.5
          #lsp_extensions-nvim    # neovim 0.5

          #tabular  # format selection into tables?
          undotree
          telescope-nvim      # "highly-customizable" fuzzy finder
          gv-vim              # Git commit Viewer
          lightline-vim       # status line
          vim-better-whitespace # auto clean whitespace
          vim-commentary         # (un)comment things
          vim-crates
          vim-fugitive        # more git tools
          #neovim-fuzzy  # fzf replacement
          #skim # ???
          #skim-vim      # fzf replacement
          vim-multiple-cursors
          vim-nix
          vim-signify  # ?
          vim-sleuth   # auto-detect ident settings from file
          vim-smoothie # smooth scroll
          vim-sneak    # fast nav within files
          vim-surround # quickly change what a block of text is surrounded by
          vim-vinegar  # netrw enhanced


          # themes
          #gruvbox
          #gruvbox-community
          gruvbox-nvim
          #vim-gruvbox8
        ];

        # TODO: why are only some things 'packadd'ed below?

        extraConfig = ''
          set number
          set relativenumber
          set nohlsearch
          set hidden
          set noerrorbells
          set nowrap
          set smartcase
          set ignorecase
          set noswapfile
          set nobackup
          " use with plugin undo-tree
          set undodir=~/.cache/nvim/undo
          set undofile
          set incsearch
          set termguicolors
          set signcolumn=yes

          set foldmethod=indent
          set foldnestmax=5
          set foldlevelstart=99
          set foldcolumn=0
          set mouse=a

          set wildmenu
          set wildmode=longest:full,full

          set list
          set listchars=tab:>-


          set background=dark
          colorscheme gruvbox

          set scrolloff=5

          " vim-better-whitespace
          let g:better_whitespace_enabled=1
          let g:strip_whitespace_on_save=1

          " vim-signify
          set updatetime=100

          " vim-sneak
          "let g:sneak#streak = 1
          let g:sneak#label = 1
          let g:sneak#s_next = 0
          let g:sneak#prompt = 'sneak>'

          " vim-fuzzy
          nnoremap <C-p> :FuzzyOpen<CR>
          autocmd FileType fuzzy tnoremap <silent> <buffer> <C-T> <C-\><C-n>:FuzzyOpenFileInTab<CR>
          autocmd FileType fuzzy tnoremap <silent> <buffer> <C-S> <C-\><C-n>:FuzzyOpenFileInSplit<CR>
          autocmd FileType fuzzy tnoremap <silent> <buffer> <C-V> <C-\><C-n>:FuzzyOpenFileInVSplit<CR>

          " lightline-vim
          let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'FugitiveStatusline'
            \ },
            \ }

          let mapleader=' '

          autocmd FileType markdown setlocal conceallevel=0

          "packadd lsp-status-nvim
          "packadd nvim-lspconfig
          "packadd nvim-treesitter
          "packadd completion-treesitter
          "packadd completion-nvim
          "lua require'lspconfig'.rust_analyzer.setup({on_attach=require'completion'.on_attach})

          " vim-crates
          autocmd BufRead Cargo.toml call crates#toggle()
          "autocmd BufEnter * lua require'completion'.on_attach()

          " lsp + supertab?

          " cargo-culted::: not sure: ?

          " Use <Tab> and <S-Tab> to navigate through popup menu
          inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
          inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

          " Set completeopt to have a better completion experience
          set completeopt=menuone,noinsert,noselect

          " Avoid showing message extra message when using completion
          set shortmess+=c

          " Configure Telescope
          " Find files using Telescope command-line sugar.
          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          nnoremap <leader>fb <cmd>Telescope buffers<cr>
          nnoremap <leader>fh <cmd>Telescope help_tags<cr>

          " Using lua functions
          # nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
          # nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
          # nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
          # nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
        '';
      };
    };
  };
}
