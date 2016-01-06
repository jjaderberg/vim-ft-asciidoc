" Vim autoload file
" vim-ft-asciidoc/autoload/asciidoc.vim

" Quick iteration (compile on save) -----------------------          {{{
function! asciidoc#compiler#quick_iter()
    if exists("g:asciidoc_quick_iter") && g:asciidoc_quick_iter == 1
        autocmd! BufWritePost <buffer>
        let g:asciidoc_quick_iter = 0
    else
        autocmd BufWritePost <buffer> silent make %
        let g:asciidoc_quick_iter = 1
    endif
endfunc " }}}
