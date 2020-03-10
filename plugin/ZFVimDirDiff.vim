" ============================================================
" options
" ============================================================

" dir diff buffer filetype
if !exists('g:ZFDirDiffUI_filetypeLeft')
    let g:ZFDirDiffUI_filetypeLeft = 'ZFDirDiffLeft'
endif
if !exists('g:ZFDirDiffUI_filetypeRight')
    let g:ZFDirDiffUI_filetypeRight = 'ZFDirDiffRight'
endif

" tabstop of the diff buffer
if !exists('g:ZFDirDiffUI_tabstop')
    let g:ZFDirDiffUI_tabstop = 2
endif

" autocmd
augroup ZF_DirDiff_augroup
    autocmd!
    autocmd User ZFDirDiff_DirDiffEnter silent
    autocmd User ZFDirDiff_FileDiffEnter silent
augroup END

" function name to get the header text
"     YourFunc(isLeft, fileLeft, fileRight)
" return a list of string
if !exists('g:ZFDirDiffUI_headerTextFunc')
    let g:ZFDirDiffUI_headerTextFunc = 'ZF_DirDiff_headerText'
endif
function! ZF_DirDiff_headerText()
    let text = []
    if b:ZFDirDiff_isLeft
        call add(text, '[LEFT]: ' . ZF_DirDiffPathFormat(t:ZFDirDiff_fileLeft, ':~') . '/')
        call add(text, '[LEFT]: ' . ZF_DirDiffPathFormat(t:ZFDirDiff_fileLeft, ':.') . '/')
    else
        call add(text, '[RIGHT]: ' . ZF_DirDiffPathFormat(t:ZFDirDiff_fileRight, ':~') . '/')
        call add(text, '[RIGHT]: ' . ZF_DirDiffPathFormat(t:ZFDirDiff_fileRight, ':.') . '/')
    endif
    call add(text, '------------------------------------------------------------')
    return text
endfunction

" whether need to sync same file
if !exists('g:ZFDirDiffUI_syncSameFile')
    let g:ZFDirDiffUI_syncSameFile = 0
endif

" overwrite confirm
if !exists('g:ZFDirDiffConfirmSyncDir')
    let g:ZFDirDiffConfirmSyncDir = 1
endif
if !exists('g:ZFDirDiffConfirmSyncFile')
    let g:ZFDirDiffConfirmSyncFile = 1
endif
if !exists('g:ZFDirDiffConfirmSyncConflict')
    let g:ZFDirDiffConfirmSyncConflict = 1
endif
if !exists('g:ZFDirDiffConfirmCopyDir')
    let g:ZFDirDiffConfirmCopyDir = 1
endif
if !exists('g:ZFDirDiffConfirmCopyFile')
    let g:ZFDirDiffConfirmCopyFile = 0
endif
if !exists('g:ZFDirDiffConfirmRemoveDir')
    let g:ZFDirDiffConfirmRemoveDir = 1
endif
if !exists('g:ZFDirDiffConfirmRemoveFile')
    let g:ZFDirDiffConfirmRemoveFile = 1
endif

" keymaps
if !exists('g:ZFDirDiffKeymap_update')
    let g:ZFDirDiffKeymap_update = ['DD']
endif
if !exists('g:ZFDirDiffKeymap_open')
    let g:ZFDirDiffKeymap_open = ['<cr>', 'o']
endif
if !exists('g:ZFDirDiffKeymap_goParent')
    let g:ZFDirDiffKeymap_goParent = ['U']
endif
if !exists('g:ZFDirDiffKeymap_diffThisDir')
    let g:ZFDirDiffKeymap_diffThisDir = ['cd']
endif
if !exists('g:ZFDirDiffKeymap_diffParentDir')
    let g:ZFDirDiffKeymap_diffParentDir = ['u']
endif
if !exists('g:ZFDirDiffKeymap_markToDiff')
    let g:ZFDirDiffKeymap_markToDiff = ['DM']
endif
if !exists('g:ZFDirDiffKeymap_quit')
    let g:ZFDirDiffKeymap_quit = ['q']
endif
if !exists('g:ZFDirDiffKeymap_quitFileDiff')
    let g:ZFDirDiffKeymap_quitFileDiff = g:ZFDirDiffKeymap_quit
endif
if !exists('g:ZFDirDiffKeymap_nextDiff')
    let g:ZFDirDiffKeymap_nextDiff = [']c', 'DJ']
endif
if !exists('g:ZFDirDiffKeymap_prevDiff')
    let g:ZFDirDiffKeymap_prevDiff = ['[c', 'DK']
endif
if !exists('g:ZFDirDiffKeymap_syncToHere')
    let g:ZFDirDiffKeymap_syncToHere = ['do', 'DH']
endif
if !exists('g:ZFDirDiffKeymap_syncToThere')
    let g:ZFDirDiffKeymap_syncToThere = ['dp', 'DL']
endif
if !exists('g:ZFDirDiffKeymap_deleteFile')
    let g:ZFDirDiffKeymap_deleteFile = ['dd']
endif
if !exists('g:ZFDirDiffKeymap_getPath')
    let g:ZFDirDiffKeymap_getPath = ['p']
endif
if !exists('g:ZFDirDiffKeymap_getFullPath')
    let g:ZFDirDiffKeymap_getFullPath = ['P']
endif

" highlight
" {Title,Dir,Same,Diff,DirOnlyHere,DirOnlyThere,FileOnlyHere,FileOnlyThere,ConflictDir,ConflictFile}
highlight link ZFDirDiffHL_Title Title
highlight link ZFDirDiffHL_Dir Directory
highlight link ZFDirDiffHL_Same Folded
highlight link ZFDirDiffHL_Diff DiffText
highlight link ZFDirDiffHL_DirOnlyHere DiffAdd
highlight link ZFDirDiffHL_DirOnlyThere Normal
highlight link ZFDirDiffHL_FileOnlyHere DiffAdd
highlight link ZFDirDiffHL_FileOnlyThere Normal
highlight link ZFDirDiffHL_ConflictDir ErrorMsg
highlight link ZFDirDiffHL_ConflictFile WarningMsg
highlight link ZFDirDiffHL_MarkToDiff Cursor

" custom highlight function
if !exists('g:ZFDirDiffHLFunc_resetHL')
    let g:ZFDirDiffHLFunc_resetHL='ZF_DirDiffHL_resetHL_default'
endif
if !exists('g:ZFDirDiffHLFunc_addHL')
    let g:ZFDirDiffHLFunc_addHL='ZF_DirDiffHL_addHL_default'
endif

" ============================================================
command! -nargs=+ -complete=file ZFDirDiff :call ZF_DirDiff(<f-args>)

" ============================================================
function! ZF_DirDiff(fileLeft, fileRight)
    let data = ZF_DirDiffCore(a:fileLeft, a:fileRight)
    if len(data) == 1 && data[0].type == 'T_DIFF'
        call s:diffByFile(a:fileLeft, a:fileRight)
    else
        call s:ZF_DirDiff_UI(a:fileLeft, a:fileRight, data)
        if empty(data)
            redraw! | echo '[ZFDirDiff] no diff found'
        endif
    endif
    return data
endfunction

function! ZF_DirDiffUpdate()
    if !exists('t:ZFDirDiff_dataUI')
        redraw!
        echo '[ZFDirDiff] no previous diff found'
        return
    endif

    let fileLeft = t:ZFDirDiff_fileLeftOrig
    let fileRight = t:ZFDirDiff_fileRightOrig
    let isLeft = b:ZFDirDiff_isLeft
    let cursorPos = getpos('.')

    call ZF_DirDiffQuit()
    call ZF_DirDiff(fileLeft, fileRight)

    if isLeft
        execute "normal! \<c-w>h"
    endif
    call setpos('.', cursorPos)
endfunction

function! ZF_DirDiffOpen()
    let item = s:getItem()
    if empty(item)
        redraw
        return
    endif
    if item.type == 'T_DIR'
        let fileLeft = t:ZFDirDiff_fileLeftOrig . '/' . item.path
        let fileRight = t:ZFDirDiff_fileRightOrig . '/' . item.path
        call ZF_DirDiffQuit()
        call ZF_DirDiff(fileLeft, fileRight)
        return
    endif
    if item.type != 'T_SAME' && item.type != 'T_DIFF'
        redraw!
        echo '[ZFDirDiff] can not be compared: ' . item.path
        return
    endif

    let fileLeft = t:ZFDirDiff_fileLeftOrig . '/' . item.path
    let fileRight = t:ZFDirDiff_fileRightOrig . '/' . item.path

    call s:diffByFile(fileLeft, fileRight)
endfunction

function! ZF_DirDiffGoParent()
    let fileLeft = fnamemodify(t:ZFDirDiff_fileLeftOrig, ':h')
    let fileRight = fnamemodify(t:ZFDirDiff_fileRightOrig, ':h')
    call ZF_DirDiffQuit()
    call ZF_DirDiff(fileLeft, fileRight)
endfunction

function! ZF_DirDiffDiffThisDir()
    let item = s:getItem()
    if empty(item)
        redraw!
        return
    endif
    if b:ZFDirDiff_isLeft
        if index(['T_DIR', 'T_DIR_LEFT', 'T_CONFLICT_DIR_LEFT'], item.type) >= 0
            let itemPath = fnamemodify(t:ZFDirDiff_fileLeftOrig . '/' . item.path, ':p')
        else
            let itemPath = fnamemodify(t:ZFDirDiff_fileLeftOrig . '/' . item.path, ':p:h')
        endif
    else
        if index(['T_DIR', 'T_DIR_RIGHT', 'T_CONFLICT_DIR_RIGHT'], item.type) >= 0
            let itemPath = fnamemodify(t:ZFDirDiff_fileRightOrig . '/' . item.path, ':p')
        else
            let itemPath = fnamemodify(t:ZFDirDiff_fileRightOrig . '/' . item.path, ':p:h')
        endif
    endif

    let fileLeft = b:ZFDirDiff_isLeft ? itemPath : t:ZFDirDiff_fileLeftOrig
    let fileRight = !b:ZFDirDiff_isLeft ? itemPath : t:ZFDirDiff_fileRightOrig
    call ZF_DirDiffQuit()
    call ZF_DirDiff(fileLeft, fileRight)
endfunction

function! ZF_DirDiffDiffParentDir()
    let fileLeft = b:ZFDirDiff_isLeft ? fnamemodify(t:ZFDirDiff_fileLeftOrig, ':h') : t:ZFDirDiff_fileLeftOrig
    let fileRight = !b:ZFDirDiff_isLeft ? fnamemodify(t:ZFDirDiff_fileRightOrig, ':h') : t:ZFDirDiff_fileRightOrig
    call ZF_DirDiffQuit()
    call ZF_DirDiff(fileLeft, fileRight)
endfunction

function! ZF_DirDiffMarkToDiff()
    let index = getpos('.')[1] - b:ZFDirDiff_iLineOffset - 1
    if index < 0
                \ || index >= len(t:ZFDirDiff_dataUI)
                \ || (b:ZFDirDiff_isLeft && index(['T_DIR_RIGHT', 'T_FILE_RIGHT'], t:ZFDirDiff_dataUI[index].data.type) >= 0)
                \ || (!b:ZFDirDiff_isLeft && index(['T_DIR_LEFT', 'T_FILE_LEFT'], t:ZFDirDiff_dataUI[index].data.type) >= 0)
        echo '[ZFDirDiff] no file under cursor'
        return
    endif

    let parent = b:ZFDirDiff_isLeft ? t:ZFDirDiff_fileLeftOrig : t:ZFDirDiff_fileRightOrig

    if !exists('t:ZFDirDiff_markToDiff')
        let t:ZFDirDiff_markToDiff = {
                    \   'isLeft' : b:ZFDirDiff_isLeft,
                    \   'index' : index,
                    \ }
        call s:ZF_DirDiff_redraw()
        redraw | echo '[ZFDirDiff] mark again to diff with: '
                    \ . parent . '/' . t:ZFDirDiff_dataUI[index].data.path
        return
    endif

    if t:ZFDirDiff_markToDiff.isLeft == b:ZFDirDiff_isLeft && t:ZFDirDiff_markToDiff.index == index
        unlet t:ZFDirDiff_markToDiff
        call s:ZF_DirDiff_redraw()
        return
    endif

    let fileLeft = (t:ZFDirDiff_markToDiff.isLeft ? t:ZFDirDiff_fileLeftOrig : t:ZFDirDiff_fileRightOrig)
                \ . '/' . t:ZFDirDiff_dataUI[t:ZFDirDiff_markToDiff.index].data.path
    let fileRight = parent . '/' . t:ZFDirDiff_dataUI[index].data.path
    unlet t:ZFDirDiff_markToDiff
    call s:ZF_DirDiff_redraw()
    call ZF_DirDiff(fileLeft, fileRight)
endfunction

function! ZF_DirDiffQuit()
    let Fn_resetHL=function(g:ZFDirDiffHLFunc_resetHL)
    let ownerTab = t:ZFDirDiff_ownerTab

    " note winnr('$') always equal to 1 for last window
    while winnr('$') > 1
        call Fn_resetHL()
        set nocursorbind
        set noscrollbind
        bd!
    endwhile
    " delete again to delete last window
    call Fn_resetHL()
    set nocursorbind
    set noscrollbind
    bd!

    execute 'normal! ' . ownerTab . 'gt'
endfunction

function! ZF_DirDiffQuitFileDiff()
    let ownerDiffTab = t:ZFDirDiff_ownerDiffTab

    execute "normal! \<c-w>k"
    execute "normal! \<c-w>h"
    call s:askWrite()

    execute "normal! \<c-w>k"
    execute "normal! \<c-w>l"
    call s:askWrite()

    let tabnr = tabpagenr('$')
    while exists('t:ZFDirDiff_ownerDiffTab') && tabnr == tabpagenr('$')
        bd!
    endwhile

    execute 'normal! ' . ownerDiffTab . 'gt'
    call ZF_DirDiffUpdate()
endfunction

function! ZF_DirDiffNextDiff()
    call s:jumpDiff('next')
endfunction
function! ZF_DirDiffPrevDiff()
    call s:jumpDiff('prev')
endfunction
function! s:jumpDiff(nextOrPrev)
    redraw

    if a:nextOrPrev == 'next'
        let iOffset = 1
        let iEnd = len(t:ZFDirDiff_dataUI)
    else
        let iOffset = -1
        let iEnd = -1
    endif

    let curPos = getpos('.')
    let iLine = curPos[1] - b:ZFDirDiff_iLineOffset - 1
    if iLine < 0
        let iLine = 0
    elseif iLine >= len(t:ZFDirDiff_dataUI)
        let iLine = len(t:ZFDirDiff_dataUI) - 1
    else
        let iLine += iOffset
    endif

    while iLine != iEnd
        let data = t:ZFDirDiff_dataUI[iLine].data
        if data.type != 'T_DIR' && data.type != 'T_SAME'
            let curPos[1] = iLine + b:ZFDirDiff_iLineOffset + 1
            call setpos('.', curPos)
            normal! zz
            return
        endif
        let iLine += iOffset
    endwhile
endfunction

function! ZF_DirDiffSyncToHere()
    let item = s:getItem()
    if empty(item)
        redraw
        return
    endif
    call ZF_DirDiffSync(t:ZFDirDiff_fileLeft, t:ZFDirDiff_fileRight, item.path, item.data, b:ZFDirDiff_isLeft ? 'r2l' : 'l2r', 0)
    call ZF_DirDiffUpdate()
endfunction
function! ZF_DirDiffSyncToThere()
    let item = s:getItem()
    if empty(item)
        redraw
        return
    endif
    call ZF_DirDiffSync(t:ZFDirDiff_fileLeft, t:ZFDirDiff_fileRight, item.path, item.data, b:ZFDirDiff_isLeft ? 'l2r' : 'r2l', 0)
    call ZF_DirDiffUpdate()
endfunction

function! ZF_DirDiffDeleteFile()
    let item = s:getItem()
    if empty(item)
        redraw
        return
    endif
    call ZF_DirDiffSync(t:ZFDirDiff_fileLeft, t:ZFDirDiff_fileRight, item.path, item.data, b:ZFDirDiff_isLeft ? 'dl' : 'dr', 0)
    call ZF_DirDiffUpdate()
endfunction

function! ZF_DirDiffGetPath()
    let item = s:getItem()
    if empty(item)
        redraw
        return
    endif

    let path = fnamemodify(b:ZFDirDiff_isLeft ? t:ZFDirDiff_fileLeftOrig : t:ZFDirDiff_fileRightOrig, ':.') . item.path
    if has('clipboard')
        let @*=path
    else
        let @"=path
    endif

    redraw
    echo '[ZFDirDiff] copied path: ' . path
endfunction
function! ZF_DirDiffGetFullPath()
    let item = s:getItem()
    if empty(item)
        redraw
        return
    endif

    let path = (b:ZFDirDiff_isLeft ? t:ZFDirDiff_fileLeft : t:ZFDirDiff_fileRight) . item.path
    if has('clipboard')
        let @*=path
    else
        let @"=path
    endif

    redraw
    echo '[ZFDirDiff] copied full path: ' . path
endfunction

" ============================================================
function! s:diffByFile(fileLeft, fileRight)
    let ownerDiffTab = tabpagenr()

    execute 'tabedit ' . a:fileLeft
    diffthis
    call s:diffByFile_setup(ownerDiffTab)

    vsplit

    execute "normal! \<c-w>l"
    execute 'edit ' . a:fileRight
    diffthis
    call s:diffByFile_setup(ownerDiffTab)

    execute "normal! \<c-w>="
endfunction
function! s:diffByFile_setup(ownerDiffTab)
    let t:ZFDirDiff_ownerDiffTab = a:ownerDiffTab

    for k in g:ZFDirDiffKeymap_quitFileDiff
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffQuitFileDiff()<cr>'
    endfor

    doautocmd User ZFDirDiff_FileDiffEnter
endfunction

function! s:getItem()
    let iLine = getpos('.')[1] - b:ZFDirDiff_iLineOffset - 1
    if iLine >= 0 && iLine < len(t:ZFDirDiff_dataUI)
        return t:ZFDirDiff_dataUI[iLine].data
    else
        return ''
    endif
endfunction

function! s:askWrite()
    if !&modified
        return
    endif
    redraw!
    let input = confirm("[ZFDirDiff] File " . expand("%:p") . " modified, save?", "&Yes\n&No", 1)
    if (input == 1)
        w!
    endif
endfunction

function! s:ZF_DirDiff_UI(fileLeft, fileRight, data)
    let ownerTab = tabpagenr()

    tabnew

    let t:ZFDirDiff_ownerTab = ownerTab
    let t:ZFDirDiff_fileLeft = ZF_DirDiffPathFormat(a:fileLeft)
    let t:ZFDirDiff_fileRight = ZF_DirDiffPathFormat(a:fileRight)
    let t:ZFDirDiff_fileLeftOrig = substitute(substitute(a:fileLeft, '\\', '/', 'g'), '/\+$', '', 'g')
    let t:ZFDirDiff_fileRightOrig = substitute(substitute(a:fileRight, '\\', '/', 'g'), '/\+$', '', 'g')
    let t:ZFDirDiff_data = a:data

    call s:setupDiffData()

    vsplit
    call s:setupDiffUI(1)

    execute "normal! \<c-w>l"
    enew
    call s:setupDiffUI(0)

    execute 'normal! gg0'
    if b:ZFDirDiff_iLineOffset > 0
        execute 'normal! ' . b:ZFDirDiff_iLineOffset . 'j'
    endif
endfunction

function! s:ZF_DirDiff_redraw()
    if !exists('t:ZFDirDiff_ownerTab')
        return
    endif
    let oldState = winsaveview()

    execute "normal! \<c-w>h"
    call s:setupDiffUI(1)
    execute "normal! \<c-w>l"
    call s:setupDiffUI(0)

    call winrestview(oldState)
endfunction

function! s:setupDiffData()
    " [
    "   {
    "     'data' : {
    "       // original data of t:ZFDirDiff_data
    "       ...
    "     },
    "   },
    "   ...
    " ]
    let t:ZFDirDiff_dataUI = []
    call s:setupDiffData_recursive(t:ZFDirDiff_data)
endfunction
function! s:setupDiffData_recursive(data)
    for item in a:data
        call add(t:ZFDirDiff_dataUI, {
                    \   'data' : item,
                    \ })
        call s:setupDiffData_recursive(item.children)
    endfor
endfunction

function! s:setupDiffUI(isLeft)
    let b:ZFDirDiff_isLeft = a:isLeft
    let b:ZFDirDiff_iLineOffset = 0

    if b:ZFDirDiff_isLeft
        execute 'setlocal filetype=' . g:ZFDirDiffUI_filetypeLeft
    else
        execute 'setlocal filetype=' . g:ZFDirDiffUI_filetypeRight
    endif

    setlocal modifiable
    normal! gg"_dG

    " header
    let Fn_headerText = function(g:ZFDirDiffUI_headerTextFunc)
    let headerText = Fn_headerText()
    let b:ZFDirDiff_iLineOffset = len(headerText)
    for i in range(b:ZFDirDiff_iLineOffset)
        call setline(i + 1, headerText[i])
    endfor

    " contents
    call s:setupDiffItemList()

    " other buffer setting
    call s:setupDiffBuffer()
endfunction

function! s:setupDiffItemList()
    let indentText = ''
    for i in range(g:ZFDirDiffUI_tabstop)
        let indentText .= ' '
    endfor

    let iLine = b:ZFDirDiff_iLineOffset + 1
    for item in t:ZFDirDiff_dataUI
        let data = item.data
        let line = ''
        let visible = 0
                    \ || (b:ZFDirDiff_isLeft && (data.type == 'T_DIR_RIGHT' || data.type == 'T_FILE_RIGHT'))
                    \ || (!b:ZFDirDiff_isLeft && (data.type == 'T_DIR_LEFT' || data.type == 'T_FILE_LEFT'))
                    \ ? 0 : 1

        if visible
            for i in range(data.level + 1)
                let line .= indentText
            endfor
            let line .= data.name
            if data.type == 'T_DIR'
                        \ || (b:ZFDirDiff_isLeft && (data.type == 'T_DIR_LEFT' || data.type == 'T_CONFLICT_DIR_LEFT'))
                        \ || (!b:ZFDirDiff_isLeft && (data.type == 'T_DIR_RIGHT' || data.type == 'T_CONFLICT_DIR_RIGHT'))
                let line .= '/'
            endif
        endif
        let line = substitute(line, ' \+$', '', 'g')
        call setline(iLine, line)
        let iLine += 1
    endfor

    call setline(b:ZFDirDiff_iLineOffset + len(t:ZFDirDiff_dataUI) + 1, '')
endfunction

function! s:setupDiffBuffer()
    call s:setupDiffBuffer_keymap()
    call s:setupDiffBuffer_statusline()
    call s:setupDiffBuffer_highlight()

    execute 'set tabstop=' . g:ZFDirDiffUI_tabstop
    setlocal buftype=nowrite
    setlocal bufhidden=hide
    setlocal nowrap
    setlocal nomodified
    setlocal nomodifiable
    set scrollbind
    set cursorbind

    doautocmd User ZFDirDiff_DirDiffEnter
endfunction

function! s:setupDiffBuffer_keymap()
    for k in g:ZFDirDiffKeymap_update
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffUpdate()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_open
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffOpen()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_goParent
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffGoParent()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_diffThisDir
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffDiffThisDir()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_diffParentDir
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffDiffParentDir()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_markToDiff
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffMarkToDiff()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_quit
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffQuit()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_nextDiff
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffNextDiff()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_prevDiff
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffPrevDiff()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_syncToHere
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffSyncToHere()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_syncToThere
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffSyncToThere()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_deleteFile
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffDeleteFile()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_getPath
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffGetPath()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_getFullPath
        execute 'nnoremap <buffer> ' . k . ' :call ZF_DirDiffGetFullPath()<cr>'
    endfor
endfunction

function! s:setupDiffBuffer_statusline()
    if b:ZFDirDiff_isLeft
        let hint = 'LEFT'
        let path = t:ZFDirDiff_fileLeftOrig
    else
        let hint = 'RIGHT'
        let path = t:ZFDirDiff_fileRightOrig
    endif
    let path = path . '/'
    let path = substitute(path, ' ', '\\ ', 'g')
    execute 'setlocal statusline=[' . hint . ']:\ ' . path
    setlocal statusline+=%=%k
    setlocal statusline+=\ %3p%%
endfunction

function! s:setupDiffBuffer_highlight()
    let Fn_resetHL=function(g:ZFDirDiffHLFunc_resetHL)
    let Fn_addHL=function(g:ZFDirDiffHLFunc_addHL)

    call Fn_resetHL()

    if len(t:ZFDirDiff_dataUI) > get(g:, 'ZFDirDiffHLMaxLine', 200)
        return
    endif

    for i in range(1, b:ZFDirDiff_iLineOffset)
        call Fn_addHL('ZFDirDiffHL_Title', i)
    endfor

    for index in range(len(t:ZFDirDiff_dataUI))
        let item = t:ZFDirDiff_dataUI[index].data
        let line = b:ZFDirDiff_iLineOffset + index + 1

        if exists('t:ZFDirDiff_markToDiff')
                    \ && b:ZFDirDiff_isLeft == t:ZFDirDiff_markToDiff.isLeft
                    \ && index == t:ZFDirDiff_markToDiff.index
            call Fn_addHL('ZFDirDiffHL_MarkToDiff', line)
            continue
        endif

        if 0
        elseif item.type == 'T_DIR'
            call Fn_addHL('ZFDirDiffHL_Dir', line)
        elseif item.type == 'T_SAME'
            call Fn_addHL('ZFDirDiffHL_Same', line)
        elseif item.type == 'T_DIFF'
            call Fn_addHL('ZFDirDiffHL_Diff', line)
        elseif item.type == 'T_DIR_LEFT'
            if b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_DirOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_DirOnlyThere', line)
            endif
        elseif item.type == 'T_DIR_RIGHT'
            if !b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_DirOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_DirOnlyThere', line)
            endif
        elseif item.type == 'T_FILE_LEFT'
            if b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_FileOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_FileOnlyThere', line)
            endif
        elseif item.type == 'T_FILE_RIGHT'
            if !b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_FileOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_FileOnlyThere', line)
            endif
        elseif item.type == 'T_CONFLICT_DIR_LEFT'
            if b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_ConflictDir', line)
            else
                call Fn_addHL('ZFDirDiffHL_ConflictFile', line)
            endif
        elseif item.type == 'T_CONFLICT_DIR_RIGHT'
            if !b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_ConflictDir', line)
            else
                call Fn_addHL('ZFDirDiffHL_ConflictFile', line)
            endif
        endif
    endfor
endfunction

