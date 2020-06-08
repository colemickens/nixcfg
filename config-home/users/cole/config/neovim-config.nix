{ pkgs, ... }:

# credit to jonringer, the origin of this particular file
{
  enable = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    fzf-vim
    fzfWrapper
    #LanguageClient-neovim
    lightline-vim
    #nerdtree
    supertab
    tabular
    vim-better-whitespace
    vim-multiple-cursors
    vim-surround
    #vimproc
    #vimproc-vim
    vim-vinegar

    # themes
    wombat256
    gruvbox

    vim-nix
  ];

  extraConfig = ''
    colorscheme wombat256mod
    colorscheme gruvbox

    set number
    set rnu
    set expandtab
    set foldmethod=indent
    set foldnestmax=5
    set foldlevelstart=99
    set foldcolumn=0
    set mouse=a

    set list
    set listchars=tab:>-

    let g:better_whitespace_enabled=1
    let g:strip_whitespace_on_save=1
    
    "let mapleader=' '

    autocmd FileType markdown setlocal conceallevel=0

    " TODO: Tabular? fzf?
    " TODO: super-tab?
    " something to mirror vs code as easily as possible
  '';
}

