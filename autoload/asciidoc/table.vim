" Vim autoload file
" vim-ft-asciidoc/autoload/base.vim

function! asciidoc#table#insert_attributes(kind) abort " {{{
    call search("^|===", 'b')
    let line = getline(line('.') - 1)
    if line =~ '^\[[^\]]*]'
        if line =~ a:kind . '="'
            call search(a:kind . '="\zs.', 'b')
        else
            call search('^\[[^\]]*\zs]', 'b')
        endif
    else
        execute "normal! O[" . a:kind . "=\"\"]\<Esc>h"
        startinsert
    endif
endfunc " }}}

function! asciidoc#table#text_object(inner, visual) abort "{{{
    let bot = search('^|===', 'W')
    if 0 > bot
        return
    endif
    if a:inner
        let bot = bot - 1
        normal! k
    elseif getline(bot + 1) =~ '^$'
        let bot = bot + 1
    endif
    let top = search('^|===', 'bW')
    if a:inner
        normal! j
    endif
    normal! V
    call cursor(bot, 0)
    normal! $
    echo [top, bot]
endfunc "}}}
