tslime.vim
==========

This is a simple vim script to send portion of text from a vim buffer to a
running tmux session.

It is based on slime.vim http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/,
but use tmux instead of screen. However, compared to tmux, screen doesn't
have the notion of panes. So, the script was adapted to take panes into
account.

**Note:** If you use version of tmux ealier than 1.3, you should use the stable
branch. The version available in that branch isn't aware of panes so it
will paste to pane 0 of the window.


(1) This fork provides the ability to send multiple keys to a tmux target
at once.

(2) The tmux target is set on buffer basis. This means that every tab in
Vim can have its own tmux target. (E.g. you could have a tab in which you
edit a Python script and send text and keys to a Python repl and another
tab in which you edit an R script and send text and keys to an R repl.)

(3) This fork allows you to refer to panes either via their dynamic
identifier which is a simple number. Or via their unique identifier which
is a number prefixed with `%`.

a) Demonstrative Reference/Dynamic Reference: If you choose to refer to a
pane via its dynamic identifier the target of any given send function in
this script will change when you insert a new pane before the pane you
used.

b) Proper Name/Static Reference: If you choose to refer to a pane via its
unique identifier the target of any given send function in this script
will stay fixed.

Tip: You can find out the unique identifier of a pane by either passing
`tmux list-panes -t x` where `x` is the name of the session. Or (the
easier way) you let the unique identifier of every pane be shown in your
tmux status bar with the option `#D`; e.g.: `set -g status-left '#D'`.
(All possible options about what to display in the statusbar can be found
via `man tmux` or some internet searching.)

I suggest using something like this in your `.tmux.conf`:
\# Status bar.
set -g status-interval 2
set -g status-right '[#D|#P|#T] '
\# set-option -g status-left-length 30
set -g status-left '[#{session_id}|#S]'
set-option -g status-justify centre

\# Disable showing the default window list component and trim it to a more
\# specific format.
set-window-option -g window-status-current-format
'[#F|#{window_id}|#I|#W|#{window_panes}]' set-window-option -g
window-status-format '[#F|#{window_id}|#I|#W|#{window_panes}]'

which gives you: `#{session_id} := unique session ID`, `#S := session
title`, `#F := window flags` (Info about which windows is active etc.),
`#{window_id} := unique window ID`, `#I := window index`, #W := window
title`, `#{window_panes} := number of active panes in current window`, `#D
:= unique pane number`, `#P := dynamic pane number`, `#T := pane title`,
The characters `[`, `]` and `|` are just used to secure visibility and do
not have any further meaning.

A last hint: If you fancy it you can rename panes. Just issue `printf
'\033]2;%s\033\\' 'hello'` in any pane and observe how `#T` will change.

(For fun: Consider including `#D` and `#P` in your statusbar for a moment
in order to see how tmux changes the dynamic window number for every pane
that comes after the one you just opened and how `#D` stays fixed.)

(4) In this fork of tslime.vim, keybindings are not set automatically
for you. Instead, you can map whatever you'd like to one of the
plugin-specific bindings in your `.vimrc` file.


Setting Keybindings
-------------------

To get the old defaults, put the following in your `.vimrc`:

``` vim
vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars
```

To send a selection in visual mode to vim, set the following in your `.vimrc`:

``` vim
vmap <your_key_combo> <Plug>SendSelectionToTmux
```

To grab the current method that a cursor is in normal mode, set the following:

``` vim
nmap <your_key_combo> <Plug>NormalModeSendToTmux
```

Use the following to reset the session, window, and pane info:

``` vim
nmap <your_key_combo> <Plug>SetTmuxVars
```

Have a command you run frequently, use this:

``` vim
nmap <your_key_combo> :Tmux <your_command><CR>
```

More info about the `<Plug>` and other mapping syntax can be found
[here](http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_3) ).
