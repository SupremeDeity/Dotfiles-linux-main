" Begin plugin section + specify plugin dir
call plug#begin('~/nvim/autoload/plugged')

" VimWiki
Plug 'vimwiki/vimwiki'
"Intellisense
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Better comments
Plug 'tpope/vim-commentary'
" Convert binary, hex, etc..
Plug 'glts/vim-radical'
" Better text navigation
Plug 'unblevable/quick-scope'
" Better react comments
Plug 'suy/vim-context-commentstring'
" Easymotion
Plug 'easymotion/vim-easymotion'
" Surround
Plug 'tpope/vim-surround'
" Syntax Support
Plug 'sheerun/vim-polyglot'
" Cool Icons
Plug 'ryanoasis/vim-devicons'
" Auto pairs for '(' '[' '{'
Plug 'jiangmiao/auto-pairs'
" Closetags
Plug 'alvan/vim-closetag'
" Themes
Plug 'rakr/vim-one'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
" Status Line
Plug 'kevinhwang91/rnvimr'
" FZF
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'yuki-ycino/fzf-preview.vim', { 'branch': 'release', 'do': ':UpdateRemotePlugins' }
Plug 'junegunn/fzf.vim'
" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'
Plug 'rhysd/git-messenger.vim'
" Terminal
Plug 'voldikss/vim-floaterm'
" Start Screen
Plug 'mhinz/vim-startify'
" Vista
Plug 'liuchengxu/vista.vim'
" See what keys do like in emacs
Plug 'liuchengxu/vim-which-key'
" Zen mode
Plug 'junegunn/goyo.vim'
" Snippets
Plug 'honza/vim-snippets'
Plug 'mattn/emmet-vim'
" Interactive code
Plug 'metakirby5/codi.vim'
" undo time travel
Plug 'mbbill/undotree'
" Find and replace
Plug 'ChristianChiarulli/far.vim'
" Auto change html tags
Plug 'AndrewRadev/tagalong.vim'
" live server
Plug 'turbio/bracey.vim'
" Smooth scroll
Plug 'psliwka/vim-smoothie'
" " async tasks
Plug 'skywind3000/asynctasks.vim'
Plug 'skywind3000/asyncrun.vim'
" Swap windows
Plug 'wesQ3/vim-windowswap'
" Markdown Preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & npm install'  }
" Easily Create Gists
Plug 'mattn/vim-gist'
Plug 'mattn/webapi-vim'
" Colorizer
Plug 'norcalli/nvim-colorizer.lua'
" Intuitive buffer closing
Plug 'moll/vim-bbye'
" Status/Tabline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Color Scheme
Plug 'dylanaraps/wal.vim'

" End of plugin section
call plug#end()

" Automatically installs plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

colorscheme one " Color Scheme
set number " Line numbers
"set background=dark " for the dark version
set termguicolors

" Airline Settings
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1 " Enable Airline Tab
let g:airline_theme = 'one' " Airline Theme
let g:airline#extensions#tabline#fnamemod = ':t'       " disable file paths in the tab

" Alias for sudo write
command! -nargs=0 Sw w !sudo tee % > /dev/null
nmap <Leader>ww <Plug>VimwikiIndex
" VimWiki markdown
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
