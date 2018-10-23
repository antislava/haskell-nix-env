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
    " let err2 = system('cabal2nix . > `basename $(pwd)`.nix')
    " let err2 = system('cabal2nix $(pwd %) > `basename $(pwd)`.nix')
    " let err2 = system('p=`pwd %` && touch $p/`basename $p`.nix')
    " let err2 = system('p=`dirname % '.expand('%').'` && touch $p/asdf.asdf')
    " let err2 = system('p=`dirname % '.expand('%').'` && cabal2nix $p > `basename $p`.nix')
    let err2 = system('p=`dirname '.expand('%').'` && n=`basename $p` && cabal2nix $p > ./$n.nix')
    " let err2 = system('p=`dirname '.expand('%').'` && n=$(basename $p) && echo $p $n > ./asdf.nix')

    " If there is a nix folder put the nix file there, otherwise in root
    " NOooo! - it is too tricky (the nix will need to point sources in the parent) - going back to same dir
    " let err2 = system('cabal2nix . > `find . -maxdepth 1 -type d -name nix -exec echo {}/ \;``basename $(pwd)`.nix')
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

