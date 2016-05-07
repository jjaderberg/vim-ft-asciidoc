" Vim autoload file
" vim-ft-asciidoc/autoload/experimental.vim
"
function! asciidoc#experimental#block_operator(type, ...) abort "{{{
    " {{{
    let debug = []
    let in = <SID>block_selection_input()
    let delim = g:asciidoc_blocks[in]
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@
    if !a:0
        if a:type == 'line'
            execute "normal! '[V']\<Esc>"
        else
            execute "normal! `[v`]\<Esc>"
        endif
    endif " }}}

    " goto bot
    execute "normal! `>"
    call add(debug, "at col " . col('.'))

    "if cur col is not eol, beak line at cur
    if col('`>') < col('$') - 1
        call add(debug, "ins nl after")
        execute "normal! a\<CR>\<Esc>"
    endif

    " store bot cur col
    let bot = line('.') - 1
    call add(debug, "bot=" . bot)

    " goto top
    execute "normal! `<"
    call add(debug, "at col " . col('.'))

    " if cur col is not beginning of line, break line at cur
    if col('`<') > 1
        call add(debug, "ins nl before")
        execute "normal! i\<CR>\<Esc>"
    endif

    " store top cur col
    let top = line('.')
    call add(debug, "top=" . top)

    " add delimiter at bot
    call append(bot, delim)

    " if bot is not empty line
    if getline(bot + 2)
        call add(debug, "add nl bot")
        if g:asciidoc_debug_level | echo getline(bot + 2) | endif
        call append(bot + 1, "")
    endif

    " add delimiter at top
    call append(top - 1, delim)

    " if top is not empty line
    if getline(top - 2)
        call add(debug, "add nl top")
        call append(top - 2, "")
    endif
    if g:asciidoc_debug_level
        echo getline(top)
       echo string(debug)
    endif

endfunc "}}}

function! asciidoc#experimental#text_object_block(inner, visual) abort "{{{
    " let delim = '\(' . substitute(join(values(g:asciidoc_blocks), '\|'), '\*', '\\\0', 'g') . '\)'
    let in = <SID>block_selection_input()
    let delim = g:asciidoc_blocks[in]
    let delim = substitute(delim, '\.\|\*', '\\\0', 'g')
    let bot = search('^' . delim, 'W')
    if 0 > bot | return | endif
    if a:inner
        let bot = bot - 1
        normal! k
    elseif getline(bot + 1) =~ '^$'
        let bot = bot + 1
    endif
    let top = search('^' . delim, 'bW')
    if a:inner
        normal! j
    endif
    normal! V
    call cursor(bot, 0)
    normal $
    if g:asciidoc_debug_level | echo [top, bot] | endif
endfunc "}}}

function! asciidoc#experimental#delete_surround_block(withattrs) abort "{{{
    let in = <SID>block_selection_input()
    let delim = g:asciidoc_blocks[in]
    let delim = substitute(delim, '\.\|\*', '\\\0', 'g')
    echo "delim: " . delim
    let bot = search(delim, 'W')
    let top = search(delim, 'bW')

    " remove delimiter at bot
    execute bot . "delete"

    " remove delimiter from top
    execute top . "delete"

    " if block has attributes or an anchor, remove them
    if a:withattrs
        let top = top - 1
        if getline(top) =~ '\[[^]]*]\{1,2}'
            execute top . "delete"
        endif
    endif

    return [bot, top]
endfunc "}}}

function! asciidoc#experimental#change_surround_block() abort "{{{
    let [bot, top] = asciidoc#experimental#delete_surround_block(0)
    let in = <SID>block_selection_input()
    let delim = g:asciidoc_blocks[in]
    call append(bot - 2, delim)
    call append(top - 1, delim)
endfunc "}}}

function! s:block_selection_input() " {{{
    let m = {
                \ '/': 'comment',
                \ '=': 'example',
                \ '-': 'listing',
                \ '.': 'literal',
                \ '+': 'passthrough',
                \ '*': 'sidebar',
                \ 'o': 'open',
                \ 'q': 'quote',
                \ 'v': 'verse',
                \}
    let input_msg = ""
    for item in items(m)
        let input_msg .= substitute(string(item)[1:-2], ',', ':', '') . "\n"
    endfor
    return input(input_msg)
endfunc " }}}

function! asciidoc#experimental#text_object_list_item(inner, visual) abort "{{{
    let bot = search('^\*\|^$\|\%$', 'W') - 1
    let top = search('^\*', 'bW')
    execute "normal! V" . bot . 'G'
    echo [top, bot]
endfunc "}}}
