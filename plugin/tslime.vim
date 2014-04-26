" File: tslime.vim
" Code by: C. Coutinho <kikijump [at] gmail [dot] com>,
"          C. Brauner <christianvanbrauner [at] gmail [dot] com>,
"          K. Borges <kassioborges [at] gmail [dot] com>
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Last edited: 2014-04-26T11:56+01:00

if exists("g:loaded_tslime") && g:loaded_tslime
    finish
endif

let g:loaded_tslime = 1

" Send keys to tmux.
function! ExecuteKeys(keys)
    call system("tmux send-keys -t " . s:TmuxTarget() . " " . a:keys)
endfunction

function! SendKeysToTmux(keys)
    if !exists("g:tslime")
        call <SID>TmuxVars()
    end
    for k in split(a:keys, '\s')
        call <SID>ExecuteKeys(k)
    endfor
endfunction

" Main function.
function! SendToTmux(text)
    if !exists("b:tslime")
        if exists("g:tslime")
            " This bit sets the target on buffer basis so every tab can have its
            " own target.
            let b:tslime = g:tslime
        else
            call <SID>TmuxVars()
        end
    end

    let oldbuffer = system(shellescape("tmux show-buffer"))
    call <SID>SetTmuxBuffer(a:text)
    call system("tmux paste-buffer -t " . s:TmuxTarget())
    call <SID>SetTmuxBuffer(oldbuffer)
endfunction

function! s:TmuxTarget()
    return '"' . b:tslime['session'] . '":' . b:tslime['window'] . "." . b:tslime['pane']
endfunction

function! s:SetTmuxBuffer(text)
    let buf = substitute(a:text, "'", "\\'", 'g')
    call system("tmux load-buffer -", buf)
endfunction

function! SendTmux(text)
    call SendToTmux(a:text)
endfunction

" Session completion.
function! TmuxSessionNames(A,L,P)
    return <SID>TmuxSessions()
endfunction

" Window completion.
function! TmuxWindowNames(A,L,P)
    return <SID>TmuxWindows()
endfunction

" Pane completion.
function! TmuxPaneNumbers(A,L,P)
    return <SID>TmuxPanes()
endfunction

function! s:TmuxSessions()
    let sessions = system("tmux list-sessions | sed -e 's/:.*$//'")
    return sessions
endfunction

" To set the TmuxTarget globally rather than locally substitute 'g:' for all
" instances of 'b:' below and delete the 'if exists("g:tslime") let b:tslime =
" g:tslime' condition in the definition of the 'SendToTmux(text)' function
" above.
function! s:TmuxWindows()
    return system('tmux list-windows -t "' . b:tslime['session'] . '" | grep -e "^\w:" | sed -e "s/\s*([0-9].*//g"')
endfunction

function! s:TmuxPanes()
    return system('tmux list-panes -t "' . b:tslime['session'] . '":' . b:tslime['window'] . " | sed -e 's/:.*$//'")
endfunction

" Set variables for TmuxTarget().
function! s:TmuxVars()
    let names = split(s:TmuxSessions(), "\n")
    let b:tslime = {}
    if len(names) == 1
        let b:tslime['session'] = names[0]
    else
        let b:tslime['session'] = ''
    endif
    while b:tslime['session'] == ''
        let b:tslime['session'] = input("session name: ", "", "custom,TmuxSessionNames")
    endwhile

    let windows = split(s:TmuxWindows(), "\n")
    if len(windows) == 1
        let window = windows[0]
    else
        let window = input("window name: ", "", "custom,TmuxWindowNames")
        if window == ''
            let window = windows[0]
        endif
    endif

    let b:tslime['window'] =  substitute(window, ":.*$" , '', 'g')

    let panes = split(s:TmuxPanes(), "\n")
    if len(panes) == 1
        let b:tslime['pane'] = panes[0]
    else
        let b:tslime['pane'] = input("pane number: ", "", "custom,TmuxPaneNumbers")
        if b:tslime['pane'] == ''
            let b:tslime['pane'] = panes[0]
        endif
    endif
endfunction

vmap <unique> <Plug>SendSelectionToTmux y :call SendToTmux(@")<CR>
nmap <unique> <Plug>NormalModeSendToTmux V <Plug>SendSelectionToTmux

nmap <unique> <Plug>SetTmuxVars :call <SID>TmuxVars()<CR>

nmap <unique> <Plug>ExecuteKeysCc :call ExecuteKeys("C-c")<CR>
nmap <unique> <Plug>ExecuteKeysCl :call ExecuteKeys("C-l")<CR>

command! -nargs=* Tmux call SendToTmux('<Args><CR>')

" One possible way to map keys.
"vmap <Space><Space> <Plug>SendSelectionToTmux
"nmap <Space><Space> <Plug>NormalModeSendToTmux
"nmap <Space>r <Plug>SetTmuxVars
"
"nmap <C-c> <Plug>ExecuteKeysCc
"nmap <C-l> <Plug>ExecuteKeysCl

