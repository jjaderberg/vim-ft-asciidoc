" Vim autoload file
" vim-ft-asciidoc/autoload/base.vim

function! asciidoc#base#follow_cursor_link(...) abort " {{{
    let [type, link] = asciidoc#base#get_cursor_link()
    if link =~ '{[^}]*}'
        let link = asciidoc#base#expand_attributes(link)
    endif
    if type == 'link'
        let link = strpart(link, matchend(link, 'link::\?'), len(link))
        if link =~ '\[[^\]]*\]$'
            let link = strpart(link, 0, match(link, '\[[^\]]*\]$'))
        endif
    elseif type == 'xref'
        let link = link[2:-2]
        if link =~ ','
            let [link, title] = split(link, ',')
        endif
    endif
    " echo type . ": " . link
    if a:0
        return asciidoc#base#follow_link(link, type, a:1)
    else
        return asciidoc#base#follow_link(link, type)
    endif
endfunc " }}}

function! asciidoc#base#get_attribute(name) " {{{
" Get a single attribute value by name.
" Returns attribute name if no value was found.
    let res = get(asciidoc#base#parse_attributes(1), a:name, a:name)
    return res
endfunc " }}}

function! asciidoc#base#sentence_per_line(mode) abort " {{{
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

function! asciidoc#base#format_text(fchar) abort " {{{
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

function! asciidoc#base#parse_attributes(refresh) " {{{
" Parse document attributes from current buffer.
    " Todo: use `search` instead
    if (exists('b:document_attributes') && !a:refresh)
        return b:document_attributes
    endif
    let b:document_attributes = {}
    let lines = getline(1, '$')
    let line_count = 0
    for line in lines
        let line_count = line_count + 1
        let m = matchlist(line, '^:\(\w\+\): \(.*\)$')
        if len(m) > 2
            let b:document_attributes[m[1]] = m[2]
        endif
    endfor
    let b:document_attributes['b'] = line_count
    return b:document_attributes
endfunc " }}}

function! asciidoc#base#expand_attributes(s) " {{{
" Expand attributes in a string.
    let res = substitute(a:s, '{\([^}]*\)}', '\=asciidoc#base#get_attribute(submatch(1))', 'g')
    return res
endfunc " }}}

function! asciidoc#base#get_cursor_link() abort "{{{
    let patterns = {
                \ 'xref': '<<[^>]*\%#[^>]*>>',
                \ 'link': 'link:[^| \t]\{-}\%#[^| \t]\{-}\[[^\]]*\]'
    \ }
    let save_cursor = getcurpos()
    let link = ""
    for [type, pattern] in items(patterns)
        if search(pattern, 'cn')
            let save_search = @/
            let save_reg = @"
            let @/ = pattern
            normal! ygn
            let link = @"
            let @" = save_reg
            let @/ = save_search
            call setpos('.', save_cursor)
            break
        endif
    endfor
    return [type, link]
endfunc " }}}

function! asciidoc#base#follow_link(link, kind, ...) " {{{
    let link = a:link
    let kind = a:kind
    let cmd = "echo 'what?' "
    if kind ==# 'link'
        let cmd = "!open " . link . " -a " . g:asciidoc_browser
    elseif kind ==# 'xref'
        if a:0
            for split_instr in ["edit", "split", "vsplit", "tabedit"]
                if a:1 == split_instr
                    let cmd = a:1 . " "
                endif
            endfor
        endif
        let file = ""
        if link =~ '#'
            let [file, anchor] = split(link, '#')
            if file !~ '/'
                let file = expand("%:p:h") . "/" . file
            endif
            if filereadable(file)
                let cmd .= file . '| /\[\[' . anchor . ']]'
            else
                let yn = input("File " . file . " does not exist. Edit it anyway? (y/n) ")
                if yn == 'y'
                    let cmd .= file . '| normal! i[[' . anchor . ']]0'
                else
                    let cmd = ''
                endif
            endif
        else
            call search(link, 'w')
        endif
    endif
    exe cmd
    return cmd
endfunc " }}}

function! asciidoc#base#insert_macro_attribs(mode, type, name) abort " {{{
    " This first part (..else) is kind of dumb. It's a convenience, but is it really
    " worth it to make the function harder to read?
    let inline = ['i', 'in', 'inl', 'inli', 'inlin', 'inline'] " {{{
    let block  = ['b', 'bl', 'blo', 'bloc', 'block']
    if a:type == inline[(len(a:type)-1)]
        let type = 'inline'
    elseif a:type == block[(len(a:type)-1)]
        let type = 'block'
    else
        echoerr "invalid macro type (" . a:type . ")"
        return -1
    endif " }}}
    let name = a:name
    let target = ""
    let save_reg = getreg('a', 1, 1)
    let save_reg_type = getregtype('a')
    let save_search = @/
    let viz_eol = col("'>") < (col("$") - 1)
    if a:mode == 'n'
        let @/ = get(g:asciidoc_patterns, a:name, '\w*\%#\w*')
        execute 'normal! gn"ad'
    elseif a:mode == 'v'
        execute 'normal! gv"ad'
    else
        echoerr "invalid mode (" . a:mode . ")"
    endif
    call setreg('a', '', 'ac')
    let quoted_attribs = split(@a, ', \?')
    let attribs = []
    for attrib in quoted_attribs
        call add(attribs, substitute(attrib, "^'\|'$", '', ''))
    endfor
    let @a = <SID>insert_macro(type, name, target, attribs)
    if viz_eol
        normal! "aP
    else
        normal! "ap
    endif
    call setreg('a', save_reg, save_reg_type)
    let @/ = save_search
endfunc " }}}

function! asciidoc#base#insert_macro_target(mode, type, name) abort " {{{
    " This first part (..else) is kind of dumb. It's a convenience, but is it really
    " worth it to make the function harder to read?
    let inline = ['i', 'in', 'inl', 'inli', 'inlin', 'inline'] " {{{
    let block  = ['b', 'bl', 'blo', 'bloc', 'block']
    if a:type == inline[(len(a:type)-1)]
        let type = 'inline'
    elseif a:type == block[(len(a:type)-1)]
        let type = 'block'
    else
        echoerr "invalid macro type (" . a:type . ")"
        return -1
    endif " }}}
    let name = a:name
    let attribs = []
    let save_reg = getreg('a', 1, 1)
    let save_reg_type = getregtype('a')
    let save_search = @/
    let viz_eol = col("'>") < (col("$") - 1)
    if a:mode == 'n'
        let @/ = get(g:asciidoc_patterns, a:name, '\w*\%#\w*')
        execute 'normal! gn"ad'
    elseif a:mode == 'v'
        execute 'normal! gv"ad'
    else
        echoerr "invalid mode (" . a:mode . ")"
    endif
    call setreg('a', '', 'ac')
    let target = @a
    let @a = <SID>insert_macro(type, name, @a, attribs)
    if viz_eol
        normal! "aP
    else
        normal! "ap
    endif
    call setreg('a', save_reg, save_reg_type)
    let @/ = save_search
endfunc " }}}

function! asciidoc#base#create_xref(mode) abort " {{{
" The function uses a normal mode command to wrap text in <<,>>.
" It operates either on the word under the cursor or on a visual selection.
    if a:mode == 'v'
        let mode = visualmode()
        if mode == 'v'
            execute "normal gvy"
            let sub = <SID>escape_linkname(@")
            execute "normal `>a>>`<i<<" . sub . ", "
        elseif mode == 'V'
            execute "normal gvy"
            let sub = <SID>escape_linkname(@")
            execute "normal A>>I<<" . sub . ", "
        endif
    elseif a:mode == 'n'
        execute "normal viwy"
        let sub = <SID>escape_linkname(@")
        execute "normal `>a>>`<i<<" . sub . ", "
    endif
endfunc " }}}

function! asciidoc#base#insert_paragraph(mode, delim, ...) abort " {{{
    let delim = a:delim
    let line = line('.')
    if a:mode == 'i'
        execute "normal! i".delim."\<CR>\<CR>".delim."\<CR>\<Esc>2k"
    elseif a:mode == 'n'
        execute "normal! O".delim."\<Down>\<C-O>o".delim."\<Esc>k0"
    elseif a:mode == 'v'
        execute "normal! \<Esc>`>o".delim."\<Esc>`<O".delim."\<Esc>j0"
    endif
    if a:0
        let cmd = "normal! 2ko["
        for ix in range(0, len(a:000) - 1)
            let cmd .= a:000[ix]
            if ix < (len(a:000) - 1)
                let cmd .= ", "
            endif
        endfor
        let cmd .= "]\<Esc>"
        if len(a:000) > 1
            let cmd .= "0Wvt]"
        else
            let cmd .= "2j0"
        endif
        execute cmd
    endif
endfunc " }}}

function! asciidoc#base#insert_table(mode) abort " {{{
    if a:mode == 'i'
        execute "normal! i|===\<CR>|\<CR>|===\<Up>"
    elseif a:mode == 'n'
        execute "normal! O|===\<Esc>"
        if getline(line('.') - 1) !~ '^$'
            execute "normal! O\<Esc>j"
        endif
        execute "normal! j0i| \<Esc>o|===\<Esc>"
        if getline(line('.') + 1) !~ '^$'
            execute "normal! o\<Esc>k"
        endif
        execute "normal! 2k02l"
    elseif a:mode == 'v'
        execute "normal! \<Esc>`>o|===\<Esc>"
        if getline(line('.') + 1) !~ '^$'
            execute "normal! o\<Esc>k"
        endif
        execute "normal! `<O|===\<Esc>"
        if getline(line('.') - 1) !~ '^$'
            execute "normal! O\<Esc>j"
        endif
        execute "'<,'>s/.*/| \\0/"
        execute "nohlsearch"
    else
        echoerr "invalid mode (" . a:mode . ")"
    endif
endfunc " }}}

function! s:insert_macro(type, name, target, attribs) abort " {{{
    let name = a:name
    if a:type == "block"
        let colon = "::"
    elseif a:type == "inline"
        let colon = ":"
    else
        echoerr "invalid macro type (" . a:type . ")"
        return -1
    endif
    if !<SID>validate_macro_name(name)
        echoerr "invalid macro name (" . name . ")"
        return -1
    endif
    let attribs = <SID>validate_macro_attribs(a:attribs)
    if type(attribs) != type([])
        echoerr "attributes may not contain unescaped ']' (" . string(a:attribs) . ")"
        return -1
    endif
    let target = <SID>escape_macro_target(a:target)
    let macro = name . colon . target . '[' . join(attribs, ', ') . ']'
    " echo macro
    return macro
endfunc " }}}

function! s:validate_macro_name(name) abort " {{{
    " may not start with a dash
    " may not include any char other than letters, digits and dashes
    return a:name !~ '^-' && a:name !~ '[^-[:alnum:]]'
endfunc " }}}

function! s:validate_macro_attribs(attribs) abort " {{{
    " Attribute may not contain an unescaped `]`.
    for attrib in a:attribs
        if string(attrib) =~ '[^\\]\]'
            return -1
        endif
    endfor
    return a:attribs
endfunc " }}}

function! s:escape_linkname(unsub) abort " {{{
    let sub = a:unsub
    let sub = substitute(sub, '\n', '', 'g')
    let sub = substitute(sub, '^[ \t\\.,!?;:/]\+', '', 'g')
    let sub = substitute(sub, '[ \t\\.,!?;:/]\+$', '', 'g')
    let sub = substitute(sub, '[ \t\\.,!?;:/]\+', '-', 'g')
    return sub
endfunc " }}}

function! asciidoc#base#soft_linebreak() "{{{
    let syntax_name = synIDattr(synID(line('.'), col('.'), 1), "name")
    " let syntax_name = synIDattr(synID(line('.'), col('.'), 0), "name")
    let apa = syntax_name =~? "table"
    echo syntax_name
    echo apa
    let save_reg = @"
    let save_search = @/
    if syntax_name =~? "table"
        normal! o| 
    elseif syntax_name =~? "list"
        let line = getline('.')
        let list_prefix = matchstr(line, "[1-9*.]\{,6}")
        let @" = list_prefix
        execute "normal! o\<Esc>p$a"
    endif
    let @/ = save_search
    let @" = save_reg
    startinsert!
endfunc "}}}

function! s:escape_macro_target(target) abort " {{{
    return substitute(a:target, ' ', '%20', 'g')
endfunc " }}}

function! asciidoc#base#custom_jump(motion) range " {{{
    let cnt = v:count1
    let save_search = @/
    mark '
    while cnt > 0
        silent! execute a:motion
        let cnt = cnt - 1
    endwhile
    call histdel('/', -1)
    let @/ = save_search
endfunction "}}}
