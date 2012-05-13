" jsvim.vim -  Experimental framework to extend Vim with plain JavaScript
" Maintainer:       mklabs
"
" " if exists("g:loaded_jsvim") || v:version < 700 || &cp
" "   finish
" " endif
" " let g:loaded_jsvim = 1

" borrowed to vim-rhubarb

let s:basedir = expand('<sfile>:h:h')

function! s:error(string) abort
  let errmsg = '... jsvim: '.a:string . ' ...'
  echo errmsg
endfunction


function! jsvim#json_parse(string) abort
  let [null, false, true] = ['', 0, 1]
  let stripped = substitute(a:string,'\C"\(\\.\|[^"\\]\)*"','','g')
  if stripped !~# "[^,:{}\\[\\]0-9.\\-+Eaeflnr-u \n\r\t]"
    try
      return eval(substitute(a:string,"[\r\n]"," ",'g'))
    catch
    endtry
  endif
  call s:error("invalid JSON: ".stripped)
endfunction

function! jsvim#json_generate(object) abort
  if type(a:object) == type('')
    return '"' . substitute(a:object, "[\001-\031\"\\\\]", '\=printf("\\u%04x", char2nr(submatch(0)))', 'g') . '"'
  elseif type(a:object) == type([])
    return '['.join(map(copy(a:object), 'jsvim#json_generate(v:val)'),', ').']'
  elseif type(a:object) == type({})
    let pairs = []
    for key in keys(a:object)
      call add(pairs, jsvim#json_generate(key) . ': ' . jsvim#json_generate(a:object[key]))
    endfor
    return '{' . join(pairs, ', ') . '}'
  else
    return string(a:object)
  endif
endfunction

" Point of entry for basic default usage.  Give a directory name to invoke
" jsvim#start() (defaults to "jsbundle"), at init time.
function! jsvim#register(...)
  let directory = a:0 ? a:1 : 'jsbundle'
  call jsvim#appendBundle(directory)
endfunction

let s:bundles = []
function! jsvim#appendBundle(directory)
  call add(s:bundles, a:directory)
endfunction

function! jsvim#start()
  for bundle in s:bundles
    let dir = fnamemodify(bundle, ':p')
    if !isdirectory(dir)
      call s:error("not a directory, abort")
      return
    endif
    " for each js file in the bundle, try to source the according adapater
    " from plugin/adapters
    let scripts = split(globpath(dir, '*.js'), "\n")
    for filename in scripts
      let basename = fnamemodify(filename, ':t:r')
      " see if we have a mapping autoload bridge for this filename
      let adapter = join([s:basedir, 'adapters', basename . '.vim'], '/')
      if filereadable(adapter)
        let g:jsvim_filename = filename
        " all is good, source the file
        exe 'source ' . adapter
        let g:jsvim_filename = 0
      else
        call s:error(filename . ' not implemented or invalid name')
      endif
    endfor
  endfor
endfunction

function! jsvim#initCommands()
  command! -nargs=* JSVim       call jsvim#init(<q-args>)
endfunction

function! jsvim#init(...)
  call jsvim#start()
  call jsvim#initCommands()
endfunction

function! jsvim#eval(output)
  let directives = jsvim#json_parse(a:output)
  for directive in directives
    let cmd = directive.cmd
    let data = directive.data
    if exists('g:jsvim_debug') && g:jsvim_debug == 1
      echo cmd
      echo data
    endif
    if exists('s:commander.' . cmd)
      call s:commander[cmd](data)
    endif
  endfor
endfunction

augroup jsvim
  autocmd!
  autocmd VimEnter * call jsvim#init()
augroup END


let s:commander = {}
function! s:commander.set(data)
  " XXX validate data provided
  " XXX some basic filetype conversion
  exe 'let ' . a:data.scope . ':' . a:data.name . ' = ' a:data.value
endfunction

function! s:commander.echo(data)
  echo a:data.message
endfunction

function! s:commander.command(data)
  exe 'command! -bang -nargs=' . a:data.nargs . ' ' . a:data.name . ' ' . a:data.trigger
endfunction

function! s:commander.nmap(data)
  " XXX deal with options, <buffer> <silent>, etc.
  " deal with function invoke, needs a way to register func from node
  " land

  " echo "nmap " a:data.key a:data.trigger
  exe "nnoremap " a:data.key a:data.trigger "<C-R>"
endfunction

function! s:commander.imap(data)
  exe "inoremap " a:data.key a:data.trigger
endfunction

" XXX debug
call jsvim#register('~/src/vim/bundle/jsvim/test')


" vim:set sw=2 sts=2:
"

