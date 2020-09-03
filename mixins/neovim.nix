{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;

        # TODO: how can I inherit `system` here?
        plugins = with pkgs.vimPlugins; [
          #nvim-treesitter        # neovim 0.5
          completion-nvim        # neovim 0.5
          #completion-treesitter  # neovim 0.5
          fzf-vim
          fzfWrapper
          lightline-vim
          #lsp-status-nvim        # neovim 0.5
          nvim-lsp               # neovim 0.5
          tabular
          vim-better-whitespace
          vim-crates
          vim-fugitive
          vim-multiple-cursors
          vim-nix
          vim-surround
          vim-vinegar

          # themes
          gruvbox
        ];

        # TODO: why are only some things 'packadd'ed below?

        extraConfig = ''
          set background=dark
          colorscheme gruvbox

          set number
          set rnu
          set expandtab
          set foldmethod=indent
          set foldnestmax=5
          set foldlevelstart=99
          set foldcolumn=0
          set mouse=a

          set wildmenu
          set wildmode=longest:full,full

          set list
          set listchars=tab:>-

          let g:better_whitespace_enabled=1
          let g:strip_whitespace_on_save=1

          "let mapleader=' '

          autocmd FileType markdown setlocal conceallevel=0

          packadd nvim-lsp
          "packadd lsp-status-nvim
          "packadd nvim-treesitter
          "packadd completion-treesitter
          packadd completion-nvim
          lua require'nvim_lsp'.rust_analyzer.setup({on_attach=require'completion'.on_attach})

          autocmd BufRead Cargo.toml call crates#toggle()
          autocmd BufEnter * lua require'completion'.on_attach()

          " Use <Tab> and <S-Tab> to navigate through popup menu
          inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
          inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

          " Set completeopt to have a better completion experience
          set completeopt=menuone,noinsert,noselect

          " Avoid showing message extra message when using completion
          set shortmess+=c

          " TODO: Tabular? fzf?
          " TODO: super-tab?
          " something to mirror vs code as easily as possible

          " don't quit, muahah
          "cabbrev q <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>
        '';
      };
    };
  };
}
