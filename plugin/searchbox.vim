if exists('g:loaded_searchbox_nvim')
  finish
endif
let g:loaded_searchbox_nvim = 1

command! -range -nargs=* SearchBoxMatchAll lua require('searchbox.command').run('match_all', <line1>, <line2>, <count>, <q-args>)
