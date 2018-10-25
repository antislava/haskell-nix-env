" """""""""""""""""""""""""""""""""""""""""""""""""""""
" Additional tmux/slime shortcuts. HASKELL-specific
"
" """""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <silent> <leader>rr <ESC>:call Send_to_Tmux(":l ". expand('%') . "\n")<CR>


" """""""""""""""""""""""""""""""""""""""""""""""""""""
" HPACK INTEGRATION
" https://github.com/sol/hpack
" """""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd! BufWritePost package.yaml call Hpack()

function! Hpack()
  let err = system('hpack ' . expand('%'))
  if v:shell_error
    echo err
  else
    " If 'name: ' field in package.yaml is absent, use dirname!
    " Stripping the trailing newline is a bit tricky:
    let pname = system('echo -n `sed -rn "s|^name: (.*)$|\1|p;" '.expand('%').' | xargs`')
    " echom pname
    " let dname = system('basename `dirname '.expand('%:p').'`')
    let dname = expand('%:p:h:t')
    if pname ==? ""
    " if 1
      let name = dname
    else
      let name = pname
    endif
    let err2 = system('p=`dirname '.expand('%').'` && n=`basename $p` && touch '.shellescape(name).'.nix')

    if v:shell_error
      echo err2
    endif
  endif
endfunction

" " Copy the full path of the current file to ssytem clipboard
" " command! -nargs=0 Readlink !readlink -f % | xclip -selection clipboard
" function! Readlink()
"   system('readlink -f ' . expand(%) . ' | xclip -selection clipboard')
" endfunction
" nmap <silent> <leader>rl <ESC>:Readlink<CR><CR>
