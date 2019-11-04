" Vim filetype plugin
" Language:     AsciiDoc
" Maintainer:   Jonatan Jäderberg <jonatan.jaderberg@jberg.info>
" Last Changed: 4 January 2016
"               16 September 2015
"               28 November 2014
" URL:          http://github.com/jjaderberg/vim-ft-asciidoc/

" if exists("b:did_plugin")
"     finish
" endif
" let b:did_plugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Dicts {{{
if !exists('g:asciidoc_use_defaults')
    let g:asciidoc_use_defaults = [
                \ 'folding',
                \ 'editing',
                \ 'navigating',
                \ 'compiling',
                \ 'options',
                \ ]
endif

let g:asciidoc_patterns = {
            \ 'include': '\f*\%#\f*',
            \ 'image': '\f*\%#\f*',
            \ 'kbd': '\S*\%#\S*',
            \ 'menu': '\S*\%#\S*',
            \ 'btn': '\S*\%#\S*',
            \ 'title': '^=\{1,6} \w',
            \ }

let g:asciidoc_blocks = {
            \ '/': '////',
            \ '=': '====',
            \ '-': '----',
            \ '.': '....',
            \ '+': '++++',
            \ '*': '****',
            \ 'o': '--',
            \ 'q': '____',
            \ 'v': '____',
            \ }

let g:setext_to_atx = {
            \ '=': '=',
            \ '-': '==',
            \ '~': '===',
            \ '^': '====',
            \ '+': '=====',
            \ }

let g:atx_to_setext = {
            \ '='    : '=',
            \ '=='   : '-',
            \ '==='  : '~',
            \ '====' : '^',
            \ '=====': '+',
            \ }

"}}}

" Options ==================================================          {{{
if -1 < match(g:asciidoc_use_defaults, 'options')
    let g:asciidoc_browser = "Firefox"
    let g:asciidoc_preview_app = "Firefox"
    if !exists('g:asciidoc_debug_level')
        let g:asciidoc_debug_level = 0
    endif

    setlocal commentstring=//\ %s
    setlocal comments=fl:////,://,fn:*,fn:.
    setlocal formatoptions=tcqjnro
    let &formatlistpat="^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*"
    setlocal spell
    setlocal include=^include::
endif
" END Options }}}

" Folding ==================================================          {{{
if -1 < match(g:asciidoc_use_defaults, 'folding')
    setlocal foldexpr=asciidoc#folding#foldexpr(v:lnum)
    setlocal foldmethod=expr
    setlocal foldlevel=1

    " Debug foldexpr {{{
    " nnoremap <buffer> ,fe :echo asciidoc#folding#foldexpr(line('.'))<CR>
    " nnoremap <buffer> ,fl :echo foldlevel('.')<CR>
    " nnoremap <buffer> ,fm :echo match(getline('.'), '=')<CR>
    " }}}
endif
" End.Folding }}}

" Compiling ================================================          {{{
if -1 < match(g:asciidoc_use_defaults, 'compiling')
    " Makeprg
    let &l:makeprg="asciidoctor"
    if exists("b:adoc_out_dir") | let &l:makeprg .= " -D " . b:adoc_out_dir | endif
    if exists("b:adoc_styles_dir") | let &l:makeprg .= ' -a stylesdir="' . b:adoc_styles_dir . '"' | endif
    if exists("b:adoc_stylesheet") | let &l:makeprg .= ' -a stylesheet="' . b:adoc_stylesheet . '"' | endif

    " Toggle quick iteration mode
    nnoremap <buffer> <LocalLeader>qi :AdocToggleQuickIter<CR>
endif
" End.Compiling }}}

" Navigating ===============================================          {{{
if -1 < match(g:asciidoc_use_defaults, 'navigating')
    " Preview asciidoc file with `g:asciidoc_preview_app` application
    nnoremap <buffer> <LocalLeader>of :execute "!open file://" . shellescape(expand('%:p')) . " -a " . g:asciidoc_preview_app<CR>

    " Follow link under cursor
    nnoremap <buffer> ,gf :AdocFollowLinkUnderCursor edit<CR>
    nnoremap <buffer> ,<C-W>f :AdocFollowLinkUnderCursor split<CR>
    nnoremap <buffer> ,<C-W><C-F> :AdocFollowLinkUnderCursor vsplit<CR>
    nnoremap <buffer> ,<C-W>gf :AdocFollowLinkUnderCursor tabedit<CR>

    " Section motions
    nnoremap <buffer> <silent> ]] :call asciidoc#base#custom_jump('/^=\{1,6} \w', 0)<CR>
    vnoremap <buffer> <silent> ]] :<C-U>call asciidoc#base#custom_jump('/^=\{1,6} \w', 1)<CR>
    onoremap <buffer> <silent> ]] :call asciidoc#base#custom_jump('/^=\{1,6} \w', 0)<CR>
    nnoremap <buffer> <silent> [[ :call asciidoc#base#custom_jump('?^=\{1,6} \w', 0)<CR>
    vnoremap <buffer> <silent> [[ :<C-U>call asciidoc#base#custom_jump('?^=\{1,6} \w', 1)<CR>
    onoremap <buffer> <silent> [[ :<call asciidoc#base#custom_jump('?^=\{1,6} \w', 0)<CR>
    nnoremap <buffer> <silent> ][ :call asciidoc#base#custom_jump('/\n=\{1,6} \w', 0)<CR>
    vnoremap <buffer> <silent> ][ :<C-U>call asciidoc#base#custom_jump('/\n=\{1,6} \w', 1)<CR>
    onoremap <buffer> <silent> ][ :call asciidoc#base#custom_jump('/\n=\{1,6} \w', 0)<CR>
    nnoremap <buffer> <silent> [] :call asciidoc#base#custom_jump('?\n=\{1,6} \w', 0)<CR>
    vnoremap <buffer> <silent> [] :<C-U>call asciidoc#base#custom_jump('?\n=\{1,6} \w', 1)<CR>
    onoremap <buffer> <silent> [] :call asciidoc#base#custom_jump('?\n=\{1,6} \w', 0)<CR>
endif
" End.Navigating }}}

" Editing ==================================================          {{{

if -1 < match(g:asciidoc_use_defaults, 'editing')

    " Formatting -------------------------------------------          {{{

    " Symmetric ............................................          {{{

    " strong
    vnoremap <buffer> <LocalLeader>ts <Esc>:AdocFormatText *<CR>
    nnoremap <buffer> <LocalLeader>ts viw<Esc>:AdocFormatText *<CR>

    " emphasis
    vnoremap <buffer> <LocalLeader>te <Esc>:AdocFormatText _<CR>
    nnoremap <buffer> <LocalLeader>te viw<Esc>:AdocFormatText _<CR>

    " code
    vnoremap <buffer> <LocalLeader>tc <Esc>:AdocFormatText `<CR>
    nnoremap <buffer> <LocalLeader>tc viw<Esc>:AdocFormatText `<CR>

    " superscript
    vnoremap <buffer> <LocalLeader>tk <Esc>:AdocFormatText ^<CR>
    nnoremap <buffer> <LocalLeader>tk viw<Esc>:AdocFormatText ^<CR>

    " subscript
    vnoremap <buffer> <LocalLeader>tj <Esc>:AdocFormatText ~<CR>
    nnoremap <buffer> <LocalLeader>tj viw<Esc>:AdocFormatText ~<CR>

    " passthrough
    vnoremap <buffer> <LocalLeader>tp <Esc>:AdocFormatText +<CR>
    nnoremap <buffer> <LocalLeader>tp viw<Esc>:AdocFormatText +<CR>

    " End.Symmetric }}}

    " Asymmetric ...........................................          {{{

    " line through
    vnoremap <buffer> <LocalLeader>t- <Esc>`>a#<Esc>`<i[line-through]#<Esc>
    nnoremap <buffer> <LocalLeader>t- viw<Esc>`>a#<Esc>`<i[line-through]#<Esc>

    " attribute
    vnoremap <buffer> <LocalLeader>ta <Esc>`>a#<Esc>`<i[]#<Esc>hi
    nnoremap <buffer> <LocalLeader>ta viw<Esc>`>a#<Esc>`<i[]#<Esc>hi

    " End.Asymmetric }}}

    " End.Formatting }}}

    " Macros ---------------------------------------------------          {{{

    " Image ....................................................          {{{
    inoremap <buffer> <LocalLeader>img image:[]<Left>
    nnoremap <buffer> <LocalLeader>img :AdocInsertMacroVisualTarget n inline image<CR>
    vnoremap <buffer> <LocalLeader>img :<C-U>AdocInsertMacroVisualTarget v inline image<CR>
    " }}}

    " Asciidoctor experimental .................................          {{{
    " kbd
    inoremap <buffer> <LocalLeader>kbd kbd:[]<Left>
    nnoremap <buffer> <LocalLeader>kbd :AdocInsertMacroVisualAttribs n inline kbd<CR>
    vnoremap <buffer> <LocalLeader>kbd :<C-U>AdocInsertMacroVisualAttribs v inline kbd<CR>

    " menu
    inoremap <buffer> <LocalLeader>menu menu:[]<Left>
    nnoremap <buffer> <LocalLeader>menu :AdocInsertMacroVisualAttribs n inline menu<CR>
    vnoremap <buffer> <LocalLeader>menu :<C-U>AdocInsertMacroVisualAttribs v inline menu<CR>

    " button
    inoremap <buffer> <LocalLeader>btn btn:[]<Left>
    nnoremap <buffer> <LocalLeader>btn :AdocInsertMacroVisualAttribs n inline btn<CR>
    vnoremap <buffer> <LocalLeader>btn :<C-U>AdocInsertMacroVisualAttribs v inline btn<CR>
    " End.Asciidoctor experimental }}}

    " Include ...........................................          {{{
    nnoremap <buffer> <LocalLeader>inc :AdocInsertMacroVisualTarget n block include<CR>
    vnoremap <buffer> <LocalLeader>inc :<C-U>AdocInsertMacroVisualTarget v block include<CR>
    " End.Include}}}

    " Link .................................................          {{{
    nnoremap <buffer> <LocalLeader>link :AdocInsertMacroVisualTarget n inline link<CR>
    vnoremap <buffer> <LocalLeader>link :<C-U>AdocInsertMacroVisualTarget v inline link<CR>
    " End.Link }}}

    " End.Macros }}}

    " Block ------------------------------------------------          {{{

    " code block
    inoremap <buffer> <LocalLeader>code <Esc>:AdocInsertParagraph i ---- source<CR>
    nnoremap <buffer> <LocalLeader>code :AdocInsertParagraph n ---- source<CR>
    vnoremap <buffer> <LocalLeader>code :<C-U>AdocInsertParagraph v ---- source<CR>

    " comment block
    inoremap <buffer> <LocalLeader>comment <Esc>:AdocInsertParagraph i //// <CR>
    nnoremap <buffer> <LocalLeader>comment :AdocInsertParagraph n //// <CR>
    vnoremap <buffer> <LocalLeader>comment :<C-U>AdocInsertParagraph v //// <CR>

    " example block
    inoremap <buffer> <LocalLeader>example <Esc>:AdocInsertParagraph i ====<CR>
    nnoremap <buffer> <LocalLeader>example :AdocInsertParagraph n ====<CR>
    vnoremap <buffer> <LocalLeader>example :<C-U>AdocInsertParagraph v ====<CR>

    " literal block
    inoremap <buffer> <LocalLeader>literal <Esc>:AdocInsertParagraph i ....<CR>
    nnoremap <buffer> <LocalLeader>literal :AdocInsertParagraph n ....<CR>
    vnoremap <buffer> <LocalLeader>literal :<C-U>AdocInsertParagraph v ....<CR>

    " open block
    inoremap <buffer> <LocalLeader>open <Esc>:AdocInsertParagraph i --<CR>
    nnoremap <buffer> <LocalLeader>open :AdocInsertParagraph n --<CR>
    vnoremap <buffer> <LocalLeader>open :<C-U>AdocInsertParagraph v --<CR>

    " passthrough block
    inoremap <buffer> <LocalLeader>passthrough <Esc>:AdocInsertParagraph i ++++<CR>
    nnoremap <buffer> <LocalLeader>passthrough :AdocInsertParagraph n ++++<CR>
    vnoremap <buffer> <LocalLeader>passthrough :<C-U>AdocInsertParagraph v ++++<CR>

    " quote block
    inoremap <buffer> <LocalLeader>quote <Esc>:AdocInsertParagraph i ____ quote author source<CR>
    nnoremap <buffer> <LocalLeader>quote :AdocInsertParagraph n ____ quote author source<CR>
    vnoremap <buffer> <LocalLeader>quote :<C-U>AdocInsertParagraph v ____ quote author source<CR>

    " sidebar block
    inoremap <buffer> <LocalLeader>sidebar <Esc>:AdocInsertParagraph i ****<CR>
    nnoremap <buffer> <LocalLeader>sidebar :AdocInsertParagraph n ****<CR>
    vnoremap <buffer> <LocalLeader>sidebar :<C-U>AdocInsertParagraph v ****<CR>

    " verse block
    inoremap <buffer> <LocalLeader>verse <Esc>:AdocInsertParagraph i ____ verse author source<CR>
    nnoremap <buffer> <LocalLeader>verse :AdocInsertParagraph n ____ verse author source<CR>
    vnoremap <buffer> <LocalLeader>verse :<C-U>AdocInsertParagraph v ____ verse author source<CR>

    " Admonition -------------------------------------------          {{{

    " caution
    inoremap <buffer> <LocalLeader>caution <Esc>:AdocInsertParagraph i -- CAUTION<CR>
    nnoremap <buffer> <LocalLeader>caution :AdocInsertParagraph n -- CAUTION<CR>
    vnoremap <buffer> <LocalLeader>caution :<C-U>AdocInsertParagraph v -- CAUTION<CR>

    " important
    inoremap <buffer> <LocalLeader>important <Esc>:AdocInsertParagraph i -- IMPORTANT<CR>
    nnoremap <buffer> <LocalLeader>important :AdocInsertParagraph n -- IMPORTANT<CR>
    vnoremap <buffer> <LocalLeader>important :<C-U>AdocInsertParagraph v -- IMPORTANT<CR>

    " note
    inoremap <buffer> <LocalLeader>note <Esc>:AdocInsertParagraph i -- NOTE<CR>
    nnoremap <buffer> <LocalLeader>note :AdocInsertParagraph n -- NOTE<CR>
    vnoremap <buffer> <LocalLeader>note :<C-U>AdocInsertParagraph v -- NOTE<CR>

    " tip
    inoremap <buffer> <LocalLeader>tip <Esc>:AdocInsertParagraph i -- TIP<CR>
    nnoremap <buffer> <LocalLeader>tip :AdocInsertParagraph n -- TIP<CR>
    vnoremap <buffer> <LocalLeader>tip :<C-U>AdocInsertParagraph v -- TIP<CR>

    " warning
    inoremap <buffer> <LocalLeader>warning <Esc>:AdocInsertParagraph i -- WARNING<CR>
    nnoremap <buffer> <LocalLeader>warning :AdocInsertParagraph n -- WARNING<CR>
    vnoremap <buffer> <LocalLeader>warning :<C-U>AdocInsertParagraph v -- WARNING<CR>

    " End.Admonition }}}

    " TODO: abstract, graphviz, latex, music, partintro

    " End.Block }}}

    " Table ------------------------------------------------          {{{
    inoremap <buffer> <LocalLeader>table <Esc>:AdocInsertTable i<CR>
    nnoremap <buffer> <LocalLeader>table :AdocInsertTable n<CR>
    vnoremap <buffer> <LocalLeader>table :<C-U>AdocInsertTable v<CR>
    " Table text objects
    vnoremap <buffer> <silent> <LocalLeader>it :<C-U>call asciidoc#table#text_object(1, 1)<CR>
    onoremap <buffer> <silent> <LocalLeader>it :<C-U>call asciidoc#table#text_object(1, 0)<CR>
    vnoremap <buffer> <silent> <LocalLeader>at :<C-U>call asciidoc#table#text_object(0, 1)<CR>
    onoremap <buffer> <silent> <LocalLeader>at :<C-U>call asciidoc#table#text_object(0, 0)<CR>
    " Table attributes
    nnoremap <buffer> <silent> <LocalLeader>cols :call asciidoc#table#insert_attributes('cols')<CR>
    nnoremap <buffer> <silent> <LocalLeader>opts :call asciidoc#table#insert_attributes('options')<CR>
    " End.Table }}}

    " Other ------------------------------------------------          {{{

    " Create xref ..........................................          {{{
    vnoremap <buffer> <LocalLeader>xr :<C-U>AdocInsertXref v<CR>
    nnoremap <buffer> <LocalLeader>xr :AdocInsertXref n<CR>
    " End.Create xref }}}

    " One sentence per line ................................          {{{
    nnoremap <buffer> <LocalLeader>spl :AdocSentencePerLine n<CR>
    vnoremap <buffer> <LocalLeader>spl :<C-U>AdocSentencePerLine v<CR>
    " End.One sentence per line }}}

    " Toggle Title .........................................          {{{
    nnoremap <buffer> <LocalLeader>tt :call asciidoc#editing#toggle_title()<CR>
    " End.Toggle Title }}}

    " Context sensitive line break {{{
    inoremap <buffer> <S-CR> <Esc>:call asciidoc#base#soft_linebreak()<CR>
    " End.Context sensitive line break }}}

    " End.Other }}}

endif

" End.Editing }}}

" Commands =================================================          {{{
command! -buffer AdocToggleQuickIter call asciidoc#compiler#quick_iter()
command! -buffer -nargs=1 AdocSentencePerLine call asciidoc#editing#sentence_per_line(<f-args>)
command! -buffer -nargs=+ AdocInsertParagraph call asciidoc#base#insert_paragraph(<f-args>)
command! -buffer -nargs=1 AdocFormatText call asciidoc#editing#format_text(<f-args>)
command! -buffer -nargs=+ AdocInsertMacroVisualTarget call asciidoc#base#insert_macro_target(<f-args>)
command! -buffer -nargs=+ AdocInsertMacroVisualAttribs call asciidoc#base#insert_macro_attribs(<f-args>)
command! -buffer -nargs=? AdocFollowLinkUnderCursor call asciidoc#base#follow_cursor_link(<f-args>)
command! -buffer -nargs=1 AdocInsertXref call asciidoc#base#create_xref(<f-args>)
command! -buffer -nargs=1 AdocInsertTable call asciidoc#base#insert_table(<f-args>)
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" Experimental =============================================          {{{

nnoremap <buffer> <LocalLeader>bl :set opfunc=asciidoc#experimental#block_operator<CR>g@

xnoremap <buffer> <silent> <LocalLeader>ib :<C-U>call asciidoc#experimental#text_object_block(1, 1)<CR>
onoremap <buffer> <silent> <LocalLeader>ib :call asciidoc#experimental#text_object_block(1, 0)<CR>
xnoremap <buffer> <silent> <LocalLeader>ab :<C-U>call asciidoc#experimental#text_object_block(0, 1)<CR>
onoremap <buffer> <silent> <LocalLeader>ab :call asciidoc#experimental#text_object_block(0, 0)<CR>

xnoremap <buffer> <silent> <LocalLeader>il :<C-U>call asciidoc#experimental#text_object_list_item(1, 1)<CR>
onoremap <buffer> <silent> <LocalLeader>il :call asciidoc#experimental#text_object_list_item(1, 0)<CR>
xnoremap <buffer> <silent> <LocalLeader>al :<C-U>call asciidoc#experimental#text_object_list_item(0, 1)<CR>
onoremap <buffer> <silent> <LocalLeader>al :call asciidoc#experimental#text_object_list_item(0, 0)<CR>

nnoremap <buffer> <silent> <LocalLeader>csb :call asciidoc#experimental#change_surround_block()<CR>
nnoremap <buffer> <silent> <LocalLeader>dsb :call asciidoc#experimental#delete_surround_block(1)<CR>

" }}}

" vim: set fdm=marker:
