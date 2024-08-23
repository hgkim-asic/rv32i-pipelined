function! ConvertToSpaces()
    set tabstop=4
    set shiftwidth=4
    set expandtab
    retab
    wq
endfunction

function! ConvertToTabs()
    set tabstop=4
    set shiftwidth=4
    set noexpandtab
    retab!
    wq
endfunction 
