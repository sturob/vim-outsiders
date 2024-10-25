" vim-outsiders.vim
" Move files between vim instances in tmux panes spatially

if exists('g:loaded_tmux_vim_mover') || !exists('$TMUX')
    finish
endif
let g:loaded_tmux_vim_mover = 1

function! s:GetPanePosition(pane_id)
    return system("tmux display-message -p -t " . a:pane_id . " '#{pane_left} #{pane_top}'")
endfunction

function! s:GetTmuxPane(direction)
    let l:cmd = "tmux display-message -p '#{pane_id}'"
    let l:current_pane = system(l:cmd)[:-2]
    let l:current_pos = s:GetPanePosition(l:current_pane)
    
    let l:direction_flag = {
        \ 'up': 'U',
        \ 'down': 'D',
        \ 'left': 'L',
        \ 'right': 'R'
        \ }[a:direction]
    
    let l:cmd = "tmux select-pane -" . l:direction_flag . " 2>/dev/null"
    call system(l:cmd)
    
    let l:target_pane = system("tmux display-message -p '#{pane_id}'")[:-2]
    let l:target_pos = s:GetPanePosition(l:target_pane)
    
    " Return to original pane
    call system("tmux select-pane -t " . l:current_pane)
    
    " Check if we've wrapped around by comparing positions
    if l:target_pane !=# l:current_pane
        let [l:curr_x, l:curr_y] = split(l:current_pos)
        let [l:target_x, l:target_y] = split(l:target_pos)
        
        " Detect wraparound based on direction and position
        if (a:direction ==# 'right' && l:target_x < l:curr_x) ||
         \ (a:direction ==# 'left' && l:target_x > l:curr_x) ||
         \ (a:direction ==# 'down' && l:target_y < l:curr_y) ||
         \ (a:direction ==# 'up' && l:target_y > l:curr_y)
            return ''
        endif
        
        return l:target_pane
    endif
    
    return ''
endfunction

function! s:CreateNewPane(direction, file, line_number)
    let l:split_cmd = {
        \ 'up': '-b',
        \ 'down': '',
        \ 'left': '-h -b',
        \ 'right': '-h'
        \ }[a:direction]
    
    " Create new pane and immediately launch vim with the file
    let l:vim_cmd = "'vim +" . a:line_number . " " . a:file . "'"
    call system("tmux split-window " . l:split_cmd . " " . l:vim_cmd)
    
    return s:GetTmuxPane(a:direction)
endfunction

function! s:GetPaneCommand(pane_id)
    let l:pane_info = system("tmux list-panes -F '#{pane_id} #{pane_current_command}' | grep " . a:pane_id)
    return split(l:pane_info)[-1]
endfunction

function! s:IsVimRunningInPane(pane_id)
    let l:cmd = s:GetPaneCommand(a:pane_id)
    return l:cmd =~# '\<vim\|\<nvim\>'
endfunction

function! s:IsShellRunningInPane(pane_id)
    let l:cmd = s:GetPaneCommand(a:pane_id)
    return l:cmd =~# '\<bash\|\<zsh\|\<sh\>'
endfunction

function! s:SendToVim(pane_id, file, line_number)
    if s:IsVimRunningInPane(a:pane_id)
        " If Vim is running, escape to normal mode, open file, and go to line
        let l:cmd = "tmux send-keys -t " . a:pane_id . " Escape ';e " . a:file . "' C-m '" . a:line_number . "G'"
        call system(l:cmd)
        call system("tmux select-pane -t " . a:pane_id)
    elseif s:IsShellRunningInPane(a:pane_id)
        " If shell is running, start new vim instance at line
        let l:cmd = "tmux send-keys -t " . a:pane_id . " 'vim +" . a:line_number . " " . a:file . "' C-m"
        call system(l:cmd)
        call system("tmux select-pane -t " . a:pane_id)
    else
        echo "Target pane must be running vim or a shell"
        return
    endif
endfunction

function! s:CountListedBuffers()
    " return len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
	return len(filter(range(1, bufnr('$')), 'buflisted(v:val) && bufname(v:val) != ""'))
endfunction

function! s:MoveFile(direction)
    let l:current_file = expand('%:p')
    if empty(l:current_file)
        echo "No file to move"
        return
    endif
    
    let l:line_number = line('.')
    
    let l:target_pane = s:GetTmuxPane(a:direction)
    if empty(l:target_pane)
        " Create new pane and launch vim immediately
        let l:target_pane = s:CreateNewPane(a:direction, l:current_file, l:line_number)
    else
        " Use existing pane
        call s:SendToVim(l:target_pane, l:current_file, l:line_number)
    endif
    
	bd
    
    " Quit if no buffers remain
    if s:CountListedBuffers() == 0
        q
    endif
endfunction

" Key mappings using mwasd
nnoremap <silent> <Leader>mw :call <SID>MoveFile('up')<CR>
nnoremap <silent> <Leader>ma :call <SID>MoveFile('left')<CR>
nnoremap <silent> <Leader>ms :call <SID>MoveFile('down')<CR>
nnoremap <silent> <Leader>md :call <SID>MoveFile('right')<CR>
