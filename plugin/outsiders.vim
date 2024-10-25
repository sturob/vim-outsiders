" vim-outsiders.vim
" Move files between vim instances in tmux panes spatially

if exists('g:loaded_tmux_vim_mover') || !exists('$TMUX')
    finish
endif
let g:loaded_tmux_vim_mover = 1

" Key mappings using mwasd
if !exists('g:outsiders_no_mappings') || !g:outsiders_no_mappings
    nnoremap <silent> <Leader>mw :call outsiders#move_file('up')<CR>
    nnoremap <silent> <Leader>ma :call outsiders#move_file('left')<CR>
    nnoremap <silent> <Leader>ms :call outsiders#move_file('down')<CR>
    nnoremap <silent> <Leader>md :call outsiders#move_file('right')<CR>
endif
