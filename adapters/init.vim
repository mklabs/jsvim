
" if exists("g:loaded_jsvim_init") || v:version < 700 || &cp
"   finish
" endif
" let g:loaded_jsvim_init = 1

"
" The init script is init'd on VimEnter
"

" mapping filename, script to execute

if !exists("g:jsvim_filename")
  finish
endif

let s:filename = g:jsvim_filename
function! s:init()
  let output = system('node ' . s:filename)
  call jsvim#eval(output)
endfunction

autocmd VimEnter * call s:init()

call s:init()
