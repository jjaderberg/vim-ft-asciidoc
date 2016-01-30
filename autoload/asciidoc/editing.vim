" Vim autoload file
" vim-ft-asciidoc/autoload/editing.vim

function! asciidoc#editing#toggle_title() abort "{{{
    let save_pos = getcurpos()
    " Find the last title. (Should really check that we aren't on a title already).
    let setext = '^[^. +/].*[^.]\n[-=~^+]\{3,}$'
    let atx = g:asciidoc_patterns['title']
    let g:temps = '\(' . atx . '\|' . setext . '\)'
    " echo s
    call search('\(' . atx . '\|' . setext . '\)', 'bc')
    " Find out which kind of title it is. Make the search land on the _text_
    " for SETEXT and we can rely on a '=' at column one means it's ATX.
    let save_reg = @"
    if getline(line('.')) =~ '^='
        " Do the deed: ATX to SETEXT
        execute "normal! df\<Space>"
        let ix = split(@")[0]
        let char = g:atx_to_setext[ix]
        call append(line('.'), repeat(char, len(getline(line('.')))))
    else
        " Do the deed: SETEXT to ATX
        execute "normal! jdd"
        execute "normal! kI" . g:setext_to_atx[@"[0]] . " \<Esc>"
    endif
    let @" = save_reg
    call setpos('.', save_pos)
endfunc "}}}
