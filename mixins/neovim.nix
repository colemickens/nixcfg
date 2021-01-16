{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;

        package = inputs.neovim-nightly."${pkgs.system}".defaultPackage;

        # TODO: how can I inherit `system` here?
        plugins = with pkgs.vimPlugins; [
          #nvim-treesitter        # neovim 0.5
          #nvim-lspconfig         # neovim 0.5
          #completion-nvim        # neovim 0.5
          #completion-treesitter  # neovim 0.5
          #lsp-status-nvim        # neovim 0.5
          #lsp_extensions-nvim    # neovim 0.5

          #tabular  # format selection into tables?
          gv-vim
          lightline-vim
          vim-better-whitespace
          vim-commentary         # (un)comment things
          vim-crates
          vim-fugitive
          neovim-fuzzy  # fzf replacement
          #skim # ???
          #skim-vim      # fzf replacement
          vim-multiple-cursors
          vim-nix
          vim-signify
          vim-sleuth   # auto-detect ident settings from file
          vim-smoothie # smooth scroll
          vim-sneak    # fast nav within files
          vim-surround # quickly change what a block of text is surrounded by
          vim-vinegar  # netrw enhanced

          # themes
          gruvbox
        ];

        # TODO: why are only some things 'packadd'ed below?

        extraConfig = ''
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

          set number
          set rnu
          set foldmethod=indent
          set foldnestmax=5
          set foldlevelstart=99
          set foldcolumn=0
          set mouse=a

          set wildmenu
          set wildmode=longest:full,full

          set list
          set listchars=tab:>-

          "let mapleader=' '

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
        '';
      };
    };
  };
}
