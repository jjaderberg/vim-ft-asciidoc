" Vim autoload file
" vim-ft-asciidoc/autoload/editing.vim

function! asciidoc#editing#format_text(fchar) abort " {{{
    let mode = visualmode()
    let save_reg = getreg('a', 1, 1)
    let save_reg_type = getregtype('a')
    let char = a:fchar
    if mode == 'v'
        let p1 = '\w\%' . col("'<") . 'c'
        let p2 = '\%' . col("'>") . 'c.\w'
        let m1 = match(getline("'<"), p1)
        let m2 = match(getline("'>"), p2)
        if -1 != m1 || -1 != m2
            let char .= char
        endif
        " echo m1
        " echo m2
    endif
    execute 'normal! gv"ay'
    call setreg('a', '', 'ac')
    let text = @a
    let @a = char . text . char
    execute "normal! `>a=char`<i=char"
    call setreg('a', save_reg, save_reg_type)
endfunc " }}}

function! asciidoc#editing#sentence_per_line(mode) abort " {{{
    let save_cursor = getcurpos()
    if a:mode == 'n'
        let pat = '^$\|^[-_.*+=]\{2}'
        let bot = search(pat, 'n') - 1
        let top = search(pat, 'bn') + 1
        if top != bot
            execute ":" . top
            execute 'normal! V' . (bot - top) . 'jJ0'
        endif
    elseif a:mode == 'v'
        normal! VJ0
    endif
    while 1
        let l = line('.')
        normal! )
        if l == line('.')
            " `normal! b` will skip over some characters, better search back for
            " first non-whitespace
            " normal! blr
            call search('\S', 'b')
            normal! lr
        else
            break
        endif
    endwhile
    call setpos('.', save_cursor)
endfunc " }}}

function! asciidoc#editing#toggle_title() abort "{{{
    let save_pos = getcurpos()
    " Find the last title. (Should really check that we aren't on a title already).
    let setext = '^[^. +/].*[^.]\n[-=~^+]\{3,}$'
    let atx = g:asciidoc_patterns['title']
    call search('\(' . atx . '\|' . setext . '\)', 'bc')
    " Find out which kind of title it is. Make the search land on the _text_
    " for SETEXT and we can rely on a '=' at column one means it's ATX.
    let save_reg = @"
    if getline(line('.')) =~ '^='
        " Do the deed: ATX to SETEXT
        execute "normal! df\<Space>"
        " If title has trailing '=', remove them also
        let lead = asciidoc#base#strip(@")
        if getline(line('.')) =~ (lead . '$')
            execute "normal! $" . repeat('h', len(lead)) . "d$"
        endif
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
