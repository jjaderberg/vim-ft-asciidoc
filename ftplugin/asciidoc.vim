" Vim filetype plugin
" Language:     AsciiDoc
" Maintainer:   Jonatan Jäderberg <jonatan.jaderberg@jberg.info>
" Last Changed: 4 January 2016
"               16 September 2015
"               28 November 2014
" URL:          http://github.com/jjaderberg/vim-ft-asciidoc/

if exists("b:did_plugin")
    finish
endif
let b:did_plugin = 1

" Options ==================================================          {{{

let g:asciidoc_browser = "Firefox"
let g:asciidoc_preview_app = "Firefox"

let g:asciidoc_patterns = {
            \ 'include': '\f*\%#\f*',
            \ 'image': '\f*\%#\f*',
            \ 'kbd': '\S*\%#\S*',
            \ 'menu': '\S*\%#\S*',
            \ 'btn': '\S*\%#\S*',
            \ }

setlocal foldexpr=Foldexpr_asciidoc(v:lnum)
setlocal foldmethod=expr

setlocal commentstring=//\ %s
setlocal comments=fl:////,://
setlocal spell
setlocal spelllang=en

" END Options }}}

" Folding ==================================================          {{{

" Foldexpr function {{{
" From https://github.com/mjakl/vim-asciidoc/
" Removed conditional fold options.
" Fixed so that it doesn't interpret every line starting with `=` as a section title
" Still can't distinguish between a section title and an identical string
" within, e.g., a literal block. Time to implement syntax folding?
function! Foldexpr_asciidoc(lnum)
    let l0 = getline(a:lnum)
    if l0 =~ '^=\{1,5}\s\+\S.*$'
        return '>'.matchend(l0, '^=\+')
    else
        return '='
    endif
endfunc
" }}}

" Debug foldexpr {{{
" nnoremap <buffer> ,fe :echo Foldexpr_asciidoc(line('.'))<CR>
" nnoremap <buffer> ,fl :echo foldlevel('.')<CR>
" nnoremap <buffer> ,fm :echo match(getline('.'), '=')<CR>
" }}}

" End.Folding }}}

" Make =====================================================          {{{

" Makeprg --------------------------------------------------          {{{
let &l:makeprg="asciidoctor"
if exists("b:adoc_out_dir") | let &l:makeprg .= " -D " . b:adoc_out_dir | endif
if exists("b:adoc_styles_dir") | let &l:makeprg .= ' -a stylesdir="' . b:adoc_styles_dir . '"' | endif
if exists("b:adoc_stylesheet") | let &l:makeprg .= ' -a stylesheet="' . b:adoc_stylesheet . '"' | endif
" End.Makeprg }}}

" Quick iteration (compile on save) ------------------------          {{{

function! AdocToggleQuickIter() " {{{
    if exists("g:asciidoc_quick_iter") && g:asciidoc_quick_iter == 1
        autocmd! BufWritePost <buffer>
        let g:asciidoc_quick_iter = 0
    else
        autocmd BufWritePost <buffer> silent make %
        let g:asciidoc_quick_iter = 1
    endif
endfunc " }}}
command! AdocToggleQuickIter call AdocToggleQuickIter()

" Toggle quick iteration mode
nnoremap <buffer> <localleader>qi :AdocToggleQuickIter<CR>

" End.Quick iteration }}}

" End.Make }}}

" Control ==================================================          {{{

" Preview asciidoc file with `g:asciidoc_preview_app` application
nnoremap <buffer> <localleader>of :execute "!open file://" . expand('%:p') . " -a " . g:asciidoc_preview_app<CR>

" Follow link under cursor
nnoremap <buffer> ,gf :AdocFollowLinkUnderCursor edit<CR>
nnoremap <buffer> ,<C-W>f :AdocFollowLinkUnderCursor split<CR>
nnoremap <buffer> ,<C-W><C-F> :AdocFollowLinkUnderCursor vsplit<CR>
nnoremap <buffer> ,<C-W>gf :AdocFollowLinkUnderCursor tabedit<CR>

" End.Control }}}

" Editing ==================================================          {{{

" Formatting -----------------------------------------------          {{{

" Symmetric ................................................          {{{

" strong
vnoremap <buffer> <localleader>ts <Esc>:AdocFormatText *<CR>
nnoremap <buffer> <localleader>ts viw<Esc>:AdocFormatText *<CR>

" emphasis
vnoremap <buffer> <localleader>te <Esc>:AdocFormatText _<CR>
nnoremap <buffer> <localleader>te viw<Esc>:AdocFormatText _<CR>

" code
vnoremap <buffer> <localleader>tc <Esc>:AdocFormatText `<CR>
nnoremap <buffer> <localleader>tc viw<Esc>:AdocFormatText `<CR>

" superscript
vnoremap <buffer> <localleader>tk <Esc>:AdocFormatText ^<CR>
nnoremap <buffer> <localleader>tk viw<Esc>:AdocFormatText ^<CR>

" subscript
vnoremap <buffer> <localleader>tj <Esc>:AdocFormatText ^<CR>
nnoremap <buffer> <localleader>tj viw<Esc>:AdocFormatText ^<CR>

" passthrough
vnoremap <buffer> <localleader>tp <Esc>:AdocFormatText +<CR>
nnoremap <buffer> <localleader>tp viw<Esc>:AdocFormatText +<CR>

" END.Symmetric }}}

" Asymmetric ...............................................          {{{

" line through
vnoremap <buffer> <localleader>t- <Esc>`>a#<Esc>`<i[line-through]#<Esc>
nnoremap <buffer> <localleader>t- viw<Esc>`>a#<Esc>`<i[line-through]#<Esc>

" attribute
vnoremap <buffer> <localleader>ta <Esc>`>a#<Esc>`<i[]#<Esc>hi
nnoremap <buffer> <localleader>ta viw<Esc>`>a#<Esc>`<i[]#<Esc>hi

" End.Asymmetric }}}

" END.Formatting }}}

" Macros ---------------------------------------------------          {{{

" Image ....................................................          {{{
inoremap <buffer> <localleader>img image:[]<Left>
nnoremap <buffer> <localleader>img :AdocInsertMacroVisualTarget n inline image<CR>
vnoremap <buffer> <localleader>img :<C-U>AdocInsertMacroVisualTarget v inline image<CR>
" }}}

" Asciidoctor experimental .................................          {{{
" kbd
inoremap <buffer> <localleader>kbd kbd:[]<Left>
nnoremap <buffer> <localleader>kbd :AdocInsertMacroVisualAttribs n inline kbd<CR>
vnoremap <buffer> <localleader>kbd :<C-U>AdocInsertMacroVisualAttribs v inline kbd<CR>

" menu
inoremap <buffer> <localleader>menu menu:[]<Left>
nnoremap <buffer> <localleader>menu :AdocInsertMacroVisualAttribs n inline menu<CR>
vnoremap <buffer> <localleader>menu :<C-U>AdocInsertMacroVisualAttribs v inline menu<CR>

" button
inoremap <buffer> <localleader>btn btn:[]<Left>
nnoremap <buffer> <localleader>btn :AdocInsertMacroVisualAttribs n inline btn<CR>
vnoremap <buffer> <localleader>btn :<C-U>AdocInsertMacroVisualAttribs v inline btn<CR>
" END.Asciidoctor experimental }}}

" Create include ...........................................          {{{
nnoremap <buffer> <LocalLeader>inc :AdocInsertMacroVisualTarget n block include<CR>
vnoremap <buffer> <LocalLeader>inc :<C-U>AdocInsertMacroVisualTarget v block include<CR>
" End.Create include}}}

" END.Macros }}}

" Block ----------------------------------------------------          {{{

" code block
inoremap <buffer> <localleader>code <Esc>:AdocInsertParagraph i ---- source<CR>
nnoremap <buffer> <localleader>code :AdocInsertParagraph n ---- source<CR>
vnoremap <buffer> <localleader>code :<C-U>AdocInsertParagraph v ---- source<CR>

" example block
inoremap <buffer> <localleader>example <Esc>:AdocInsertParagraph i ====<CR>
nnoremap <buffer> <localleader>example :AdocInsertParagraph n ====<CR>
vnoremap <buffer> <localleader>example :<C-U>AdocInsertParagraph v ====<CR>

" literal block
inoremap <buffer> <localleader>literal <Esc>:AdocInsertParagraph i ....<CR>
nnoremap <buffer> <localleader>literal :AdocInsertParagraph n ....<CR>
vnoremap <buffer> <localleader>literal :<C-U>AdocInsertParagraph v ....<CR>

" open block
inoremap <buffer> <localleader>open <Esc>:AdocInsertParagraph i --<CR>
nnoremap <buffer> <localleader>open :AdocInsertParagraph n --<CR>
vnoremap <buffer> <localleader>open :<C-U>AdocInsertParagraph v --<CR>

" passthrough block
inoremap <buffer> <localleader>passthrough <Esc>:AdocInsertParagraph i ++++<CR>
nnoremap <buffer> <localleader>passthrough :AdocInsertParagraph n ++++<CR>
vnoremap <buffer> <localleader>passthrough :<C-U>AdocInsertParagraph v ++++<CR>

" quote block
inoremap <buffer> <localleader>quote <Esc>:AdocInsertParagraph i ____ quote author source<CR>
nnoremap <buffer> <localleader>quote :AdocInsertParagraph n ____ quote author source<CR>
vnoremap <buffer> <localleader>quote :<C-U>AdocInsertParagraph v ____ quote author source<CR>

" sidebar block
inoremap <buffer> <localleader>sidebar <Esc>:AdocInsertParagraph i ****<CR>
nnoremap <buffer> <localleader>sidebar :AdocInsertParagraph n ****<CR>
vnoremap <buffer> <localleader>sidebar :<C-U>AdocInsertParagraph v ****<CR>

" verse block
inoremap <buffer> <localleader>verse <Esc>:AdocInsertParagraph i ____ verse author source<CR>
nnoremap <buffer> <localleader>verse :AdocInsertParagraph n ____ verse author source<CR>
vnoremap <buffer> <localleader>verse :<C-U>AdocInsertParagraph v ____ verse author source<CR>

" Admonition ----------------------------------------          {{{

" caution
inoremap <buffer> <localleader>caution <Esc>:AdocInsertParagraph i -- CAUTION<CR>
nnoremap <buffer> <localleader>caution :AdocInsertParagraph n -- CAUTION<CR>
vnoremap <buffer> <localleader>caution :<C-U>AdocInsertParagraph v -- CAUTION<CR>

" important
inoremap <buffer> <localleader>important <Esc>:AdocInsertParagraph i -- IMPORTANT<CR>
nnoremap <buffer> <localleader>important :AdocInsertParagraph n -- IMPORTANT<CR>
vnoremap <buffer> <localleader>important :<C-U>AdocInsertParagraph v -- IMPORTANT<CR>

" note
inoremap <buffer> <localleader>note <Esc>:AdocInsertParagraph i -- NOTE<CR>
nnoremap <buffer> <localleader>note :AdocInsertParagraph n -- NOTE<CR>
vnoremap <buffer> <localleader>note :<C-U>AdocInsertParagraph v -- NOTE<CR>

" tip
inoremap <buffer> <localleader>tip <Esc>:AdocInsertParagraph i -- TIP<CR>
nnoremap <buffer> <localleader>tip :AdocInsertParagraph n -- TIP<CR>
vnoremap <buffer> <localleader>tip :<C-U>AdocInsertParagraph v -- TIP<CR>

" warning
inoremap <buffer> <localleader>warning <Esc>:AdocInsertParagraph i -- WARNING<CR>
nnoremap <buffer> <localleader>warning :AdocInsertParagraph n -- WARNING<CR>
vnoremap <buffer> <localleader>warning :<C-U>AdocInsertParagraph v -- WARNING<CR>

" End.Admonition }}}

" The built-in paragraph styles are:
" Handled:
" CAUTION, IMPORTANT, NOTE, TIP, WARNING, example,
" listing, literal, normal, quote, sidebar, source, verse,
" Review:
" abstract, comment, graphviz, latex, music, partintro

" End.Block }}}

" Other ----------------------------------------------------          {{{

" Create xref ..............................................          {{{
vnoremap <buffer> <LocalLeader>xr :<C-U>AdocInsertXref v<CR>
nnoremap <buffer> <LocalLeader>xr :AdocInsertXref n<CR>
" End.Create xref }}}

" One sentence per line .................................... {{{
nnoremap <buffer> <localleader>spl :call asciidoc#base#sentence_per_line()<CR>
" End.One sentence per line }}}

" End.Other }}}

" End.Editing }}}

command! -buffer AdocSentencePerLine call asciidoc#base#sentence_per_line()
command! -buffer -nargs=+ AdocInsertParagraph call asciidoc#base#insert_paragraph(<f-args>)
command! -buffer -nargs=1 AdocFormatText call asciidoc#base#format_text(<f-args>)
command! -buffer -nargs=+ AdocInsertMacroVisualTarget call asciidoc#base#insert_macro_target(<f-args>)
command! -buffer -nargs=+ AdocInsertMacroVisualAttribs call asciidoc#base#insert_macro_attribs(<f-args>)
command! -buffer -nargs=? AdocFollowLinkUnderCursor call asciidoc#base#follow_cursor_link(<f-args>)
command! -buffer -nargs=1 AdocInsertXref call asciidoc#base#create_xref(<f-args>)

" vim: set fdm=marker:
