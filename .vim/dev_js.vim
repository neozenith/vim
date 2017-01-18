" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuration specific to javascript development 
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" Javascript Development: Syntax/Linting Checker
" ---------------------------
" Inspired by this Stackoverflow answer 
" http://stackoverflow.com/a/29819201/622276
function! JscsFix()
  "Save current cursor position"
  let l:winview = winsaveview()
  "Pipe the current buffer (%) through the jscs -x command"
  % ! jscs -x
  "Restore cursor position - this is needed as piping the file"
  "through jscs jumps the cursor to the top"
  call winrestview(l:winview)
endfunction
command! JscsFix :call JscsFix()