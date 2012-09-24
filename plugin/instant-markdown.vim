function! UpdateMarkdown()
python << EOF
import base64, vim, os, sys
doc_markdown = '\n'.join(vim.current.buffer)
doc_encoded = base64.standard_b64encode(doc_markdown)
vim.command("let doc_encoded='%s'" % doc_encoded)
EOF
  if (b:im_needs_init)
    let b:im_needs_init = 0
    silent! exec "silent! !echo " . doc_encoded . " | instant-markdown-d &>/dev/null &"
  endif
  if (b:last_number_of_changes == "" || b:last_number_of_changes != b:changedtick)
    let b:last_number_of_changes = b:changedtick
    silent! exec "silent! !echo " . doc_encoded . " | curl -X PUT -T - http://localhost:8090/ &>/dev/null &"
  endif
endfunction
function! OpenMarkdown()
  let b:last_number_of_changes = ""
  let b:im_needs_init = 1
endfunction
function! CloseMarkdown()
  silent! exec "silent! !curl -s -X DELETE http://localhost:8090/ &>/dev/null &"
endfunction

" Only README.md is recognized by vim as type markdown. Do this to make ALL .md files markdown
autocmd BufWinEnter *.{md,mkd,mkdn,mdown,mark*} silent setf markdown

autocmd CursorMoved,CursorMovedI,CursorHold,CursorHoldI *.{md,mkd,mkdn,mdown,mark*} silent call UpdateMarkdown()
autocmd BufWinLeave *.{md,mkd,mkdn,mdown,mark*} silent call CloseMarkdown()
autocmd BufWinEnter *.{md,mkd,mkdn,mdown,mark*} silent call OpenMarkdown()
