if exists('g:loaded_searchx_nvim')
  finish
endif
let g:loaded_searchx_nvim = 1

command! Searchx lua require('searchx.command').run()
