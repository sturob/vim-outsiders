" Autoloaded functions for vim-outsiders

function! outsiders#get_pane_position(pane_id)
    return system("tmux display-message -p -t " . a:pane_id . " '#{pane_left} #{pane_top}'")
endfunction

function! outsiders#get_tmux_pane(direction)
    let l:cmd = "tmux display-message -p '#{pane_id}'"
    let l:current_pane = system(l:cmd)[:-2]
    let l:current_pos = outsiders#get_pane_position(l:current_pane)
    
    let l:direction_flag = {
        \ 'up': 'U',
        \ 'down': 'D',
        \ 'left': 'L',
        \ 'right': 'R'
        \ }[a:direction]
    
    let l:cmd = "tmux select-pane -" . l:direction_flag . " 2>/dev/null"
    call system(l:cmd)
    
    let l:target_pane = system("tmux display-message -p '#{pane_id}'")[:-2]
    let l:target_pos = outsiders#get_pane_position(l:target_pane)
    
    " Return to original pane
    call system("tmux select-pane -t " . l:current_pane)
    
    " Check if we've wrapped around by comparing positions
    if l:target_pane !=# l:current_pane
        let [l:curr_x, l:curr_y] = split(l:current_pos)
        let [l:target_x, l:target_y] = split(l:target_pos)
        
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

function! outsiders#create_new_pane(direction, file, line_number)
    let l:split_cmd = {
        \ 'up': '-b',
        \ 'down': '',
        \ 'left': '-h -b',
        \ 'right': '-h'
        \ }[a:direction]
    
    let l:vim_cmd = "'vim +" . a:line_number . " " . a:file . "'"
    call system("tmux split-window " . l:split_cmd . " " . l:vim_cmd)
    
    return outsiders#get_tmux_pane(a:direction)
endfunction

function! outsiders#get_pane_command(pane_id)
    let l:pane_info = system("tmux list-panes -F '#{pane_id} #{pane_current_command}' | grep " . a:pane_id)
    return split(l:pane_info)[-1]
endfunction

function! outsiders#is_vim_running_in_pane(pane_id)
    let l:cmd = outsiders#get_pane_command(a:pane_id)
    return l:cmd =~# '\<vim\|\<nvim\>'
endfunction

function! outsiders#is_shell_running_in_pane(pane_id)
    let l:cmd = outsiders#get_pane_command(a:pane_id)
    return l:cmd =~# '\<bash\|\<zsh\|\<sh\>'
endfunction

function! outsiders#send_to_vim(pane_id, file, line_number)
    if outsiders#is_vim_running_in_pane(a:pane_id)
        let l:cmd = "tmux send-keys -t " . a:pane_id . " Escape ';e " . a:file . "' C-m '" . a:line_number . "G'"
        call system(l:cmd)
        call system("tmux select-pane -t " . a:pane_id)
    elseif outsiders#is_shell_running_in_pane(a:pane_id)
        let l:cmd = "tmux send-keys -t " . a:pane_id . " 'vim +" . a:line_number . " " . a:file . "' C-m"
        call system(l:cmd)
        call system("tmux select-pane -t " . a:pane_id)
    else
        echo "Target pane must be running vim or a shell"
        return
    endif
endfunction

function! outsiders#count_listed_buffers()
    return len(filter(range(1, bufnr('$')), 'buflisted(v:val) && bufname(v:val) != ""'))
endfunction

function! outsiders#move_file(direction)
    let l:current_file = expand('%:p')
    if empty(l:current_file)
        echo "No file to move"
        return
    endif
    
    let l:line_number = line('.')
    
    let l:target_pane = outsiders#get_tmux_pane(a:direction)
    if empty(l:target_pane)
        let l:target_pane = outsiders#create_new_pane(a:direction, l:current_file, l:line_number)
    else
        call outsiders#send_to_vim(l:target_pane, l:current_file, l:line_number)
    endif
    
    bd
    
    if outsiders#count_listed_buffers() == 0
        q
    endif
endfunction
