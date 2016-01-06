" Vim autoload file
" vim-ft-asciidoc/autoload/asciidoc.vim

" Foldexpr function {{{
" From https://github.com/mjakl/vim-asciidoc/
" Removed conditional fold options.
" Fixed to avoid matching every line starting with `=`, and to skip title lines
" within literal et. al. blocks.
function! asciidoc#folding#foldexpr(lnum)
    let l0 = getline(a:lnum)
    if l0 =~ '^=\{1,5}\s\+\S.*$' && synIDattr(synID(a:lnum, 1, 1), "name") =~ "asciidoc.*Title"
        return '>'.matchend(l0, '^=\+')
    else
        return '='
    endif
endfunc " }}}

