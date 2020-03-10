" ============================================================
" options
" ============================================================

" whether to show files that are same
if !exists('g:ZFDirDiffShowSameFile')
    let g:ZFDirDiffShowSameFile = 1
endif

" file name exclude pattern, e.g. `*.class,*.o`
if !exists('g:ZFDirDiffFileExclude')
    if !get(g:, 'ZFDirDiffFileExcludeUseDefault', 0)
        let g:ZFDirDiffFileExclude = ''
    else
        let g:ZFDirDiffFileExclude = 'tags'
        let g:ZFDirDiffFileExclude .= ',*.swp'
        let g:ZFDirDiffFileExclude .= ',.DS_Store'
        let g:ZFDirDiffFileExclude .= ',*.d'
        let g:ZFDirDiffFileExclude .= ',*.depend*'
        let g:ZFDirDiffFileExclude .= ',*.a'
        let g:ZFDirDiffFileExclude .= ',*.o'
        let g:ZFDirDiffFileExclude .= ',*.so'
        let g:ZFDirDiffFileExclude .= ',*.dylib'
        let g:ZFDirDiffFileExclude .= ',*.jar'
        let g:ZFDirDiffFileExclude .= ',*.class'
        let g:ZFDirDiffFileExclude .= ',*.exe'
        let g:ZFDirDiffFileExclude .= ',*.dll'
        let g:ZFDirDiffFileExclude .= ',*.iml'
        let g:ZFDirDiffFileExclude .= ',local.properties'
        let g:ZFDirDiffFileExclude .= ',*.user'

        let g:ZFDirDiffFileExclude .= ',*/.svn/*'
        let g:ZFDirDiffFileExclude .= ',*/.git/*'
        let g:ZFDirDiffFileExclude .= ',*/.hg/*'
        let g:ZFDirDiffFileExclude .= ',*/.cache/*'
        let g:ZFDirDiffFileExclude .= ',*/_cache/*'
        let g:ZFDirDiffFileExclude .= ',*/.tmp/*'
        let g:ZFDirDiffFileExclude .= ',*/_tmp/*'
        let g:ZFDirDiffFileExclude .= ',*/.release/*'
        let g:ZFDirDiffFileExclude .= ',*/_release/*'
        let g:ZFDirDiffFileExclude .= ',*/.build/*'
        let g:ZFDirDiffFileExclude .= ',*/_build/*'
        let g:ZFDirDiffFileExclude .= ',*/build-*/*'
        let g:ZFDirDiffFileExclude .= ',*/bin-*/*'
        let g:ZFDirDiffFileExclude .= ',*/_repo/*'
        let g:ZFDirDiffFileExclude .= ',*/.wing/*'
        let g:ZFDirDiffFileExclude .= ',*/.idea/*'
        let g:ZFDirDiffFileExclude .= ',*/.gradle/*'
        let g:ZFDirDiffFileExclude .= ',*/build/*'
        let g:ZFDirDiffFileExclude .= ',*/.externalNativeBuild/*'
        let g:ZFDirDiffFileExclude .= ',*/Pods/*'
        let g:ZFDirDiffFileExclude .= ',*/vendor/*'
    endif
endif

" file content exclude pattern, e.g. `log:,id:`
if !exists('g:ZFDirDiffContentExclude')
    let g:ZFDirDiffContentExclude = ''
endif

" whether ignore file name case
if !exists('g:ZFDirDiffFileIgnoreCase')
    let g:ZFDirDiffFileIgnoreCase = 0
endif

" additional diff args passed to `diff`
if !exists('g:ZFDirDiffCustomDiffArg')
    let g:ZFDirDiffCustomDiffArg = ''
endif

" diff lang string
if !exists('g:ZFDirDiffLang')
    let g:ZFDirDiffLang = ''
endif
if !exists('g:ZFDirDiffLangString')
    if has('win32') && !has('win32unix')
        let g:ZFDirDiffLangString = 'SET LANG=' . g:ZFDirDiffLang . ' && '
    else
        let g:ZFDirDiffLangString = 'LANG=' . g:ZFDirDiffLang . ' '
    endif
endif
if !exists('*ZF_DirDiffTempname')
    function! ZF_DirDiffTempname()
        " cygwin's path may not work for some external command
        if has("win32unix") && executable('cygpath')
            return substitute(system('cygpath -m "' . tempname() . '"'), '[\r\n]', '', 'g')
        else
            return tempname()
        endif
    endfunction
endif
if !exists('*ZF_DirDiffShellEnv_pathFormat')
    function! ZF_DirDiffShellEnv_pathFormat(path)
        return fnamemodify(a:path, ':.')
    endfunction
endif

" sort function
if !exists('g:ZFDirDiffSortFunc')
    let g:ZFDirDiffSortFunc = 'ZF_DirDiffSortFunc'
endif
function! ZF_DirDiffSortFunc(item0, item1)
    let priority0 = s:ZF_DirDiffSortFunc_priority(a:item0.type)
    let priority1 = s:ZF_DirDiffSortFunc_priority(a:item1.type)
    if priority0 != priority1
        return (priority0 > priority1) ? -1 : 1
    endif

    return (a:item0.name < a:item1.name) ? -1 : 1
endfunction
function! s:ZF_DirDiffSortFunc_priority(type)
    if a:type == 'T_DIR' || a:type == 'T_DIR_LEFT' || a:type == 'T_DIR_RIGHT'
        return 2
    elseif a:type == 'T_CONFLICT_DIR_LEFT' || a:type == 'T_CONFLICT_DIR_RIGHT'
        return 1
    else
        return 0
    endif
endfunction

" ============================================================

" return:
"   [
"       {
"           'name' : 'file or dir name, empty if fileLeft and fileRight is file',
"           'type' : '',
"               // T_DIR: current node is dir and children has diff
"               // T_SAME: current node is file and has no diff
"               // T_DIFF: current node is file and has diff
"               // T_DIR_LEFT: only left exists and it is dir
"               // T_DIR_RIGHT: only right exists and it is dir
"               // T_FILE_LEFT: only left exists and it is dir
"               // T_FILE_RIGHT: only right exists and it is dir
"               // T_CONFLICT_DIR_LEFT: left is dir and right is file
"               // T_CONFLICT_DIR_RIGHT: left is file and right is dir
"           'children' : [
"               ...
"           ],
"       },
"       ...
"   ]
"
" all type: {T_DIR,T_SAME,T_DIFF,T_DIR_LEFT,T_DIR_RIGHT,T_FILE_LEFT,T_FILE_RIGHT,T_CONFLICT_DIR_LEFT,T_CONFLICT_DIR_RIGHT}
function! ZF_DirDiffCore(fileLeft, fileRight)
    let fileLeft = ZF_DirDiffShellEnv_pathFormat(ZF_DirDiffPathFormat(a:fileLeft))
    let fileRight = ZF_DirDiffShellEnv_pathFormat(ZF_DirDiffPathFormat(a:fileRight))

    " both file, always treat as diff
    if filereadable(fileLeft) && filereadable(fileRight)
        return [{
                    \   'name' : '',
                    \   'type' : 'T_DIFF',
                    \   'children' : [],
                    \ }]
    endif

    " use temp file to solve encoding issue
    let tmpFile = ZF_DirDiffTempname()
    let cmd = '!' . g:ZFDirDiffLangString . 'diff'
    let cmdarg = ' -r --brief'

    if g:ZFDirDiffShowSameFile
        let cmdarg .= ' -s'
    endif
    if g:ZFDirDiffFileIgnoreCase
        let cmdarg .= ' -i'
    endif
    if g:ZFDirDiffCustomDiffArg != ''
        let cmdarg .= ' ' . g:ZFDirDiffCustomDiffArg . ' '
    endif
    if g:ZFDirDiffFileExclude != ''
        let cmdarg .= ' -x"' . substitute(g:ZFDirDiffFileExclude, ',', '" -x"', 'g') . '"'
    endif
    if g:ZFDirDiffContentExclude != ''
        let cmdarg .= ' -I"' . substitute(g:ZFDirDiffContentExclude, ',', '" -I"', 'g') . '"'
    endif
    let cmd = cmd . cmdarg . ' "' . fileLeft . '" "' . fileRight . '"'
    let cmd = cmd . ' > "' . tmpFile . '" 2>&1'

    redraw!
    echo '[ZFDirDiff] running diff, it may take a while...'
    silent! execute cmd
    let error = v:shell_error
    if error == 0
        silent! call delete(tmpFile)
        redraw! | echo '[ZFDirDiff] no diff found'
        return []
    elseif error != 1
        redraw!
        echo '[ZFDirDiff] diff failed with exit code: ' . error
        for msg in readfile(tmpFile)
            echo '    ' . msg
        endfor
        silent! call delete(tmpFile)
        return []
    endif

    let content = readfile(tmpFile)
    let data = s:parse(fileLeft, fileRight, content)
    redraw!
    echo '[ZFDirDiff] sorting result, it may take a while...'
    call s:sortResult(data)
    redraw!
    echo '[ZFDirDiff] diff complete'
    silent! call delete(tmpFile)
    return data
endfunction

function! ZF_DirDiffPathFormat(path, ...)
    let path = a:path
    let path = fnamemodify(path, ':p')
    if !empty(get(a:, 1, ''))
        let path = fnamemodify(path, a:1)
    endif
    let path = substitute(path, '\\$\|/$', '', '')
    return substitute(path, '\\', '/', 'g')
endfunction

" ============================================================
" $ diff -rq left right
" Files left/p0/p1/a.txt and right/p0/p1/a.txt differ
" Only in right/p0/p1: b.txt
" Only in left/p0/p1: c.txt
" Only in left/p0/p1: 的.txt
" File left/p0/p1/conflict_left is a directory while file right/p0/p1/conflict_left is a regular file
" File left/p0/p1/conflict_right is a regular file while file right/p0/p1/conflict_right is a directory
" Only in left/p0/p1: dir
" Files test/left/p0/p1/dir_same/a.txt and test/right/p0/p1/dir_same/a.txt are identical
"
" types:
" * Files [A]/p0/p1/a.txt and [B]/p0/p1/a.txt differ
" * Files [A]/p0/p1/a.txt and [B]/p0/p1/a.txt are identical
" * Only in [B]/p0/p1: b.txt
" * File [A]/p0/p1/conflict_left is a directory while file [B]/p0/p1/conflict_left is a regular file
" * File [A]/p0/p1/conflict_right is a regular file while file [B]/p0/p1/conflict_right is a directory
" ============================================================
function! s:parse(fileLeft, fileRight, content)
    let pDiff = get(g:, 'ZFDirDiff_patternDiff',
                \ 'Files \(.*\) and \(.*\) differ')
    let pSame = get(g:, 'ZFDirDiff_patternSame',
                \ 'Files \(.*\) and \(.*\) are identical')
    let pOnly = get(g:, 'ZFDirDiff_patternOnly',
                \ 'Only in \(.*\): \(.*\)')
    let pConflictL = get(g:, 'ZFDirDiff_patternConflictL',
                \ 'File \(.*\) is a directory while file \(.*\) is a regular file')
    let pConflictR = get(g:, 'ZFDirDiff_patternConflictR',
                \ 'File \(.*\) is a regular file while file \(.*\) is a directory')

    let fileLeft = substitute(a:fileLeft, '\', '/', 'g')
    let fileRight = substitute(a:fileRight, '\', '/', 'g')

    let data = []
    for line in a:content
        let line = substitute(line, '\', '/', 'g')
        if 0
        elseif match(line, pSame) >= 0
            let left = substitute(line, pSame, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(data, path, 'T_SAME')
        elseif match(line, pDiff) >= 0
            let left = substitute(line, pDiff, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(data, path, 'T_DIFF')
        elseif match(line, pOnly) >= 0
            let path = substitute(line, pOnly, '\1', '')
            let file = substitute(line, pOnly, '\2', '')

            let matchLeft = (match(path, fileLeft) >= 0)
            let matchRight = (match(path, fileRight) >= 0)
            if matchLeft && matchRight
                if len(fileLeft) >= len(fileRight)
                    let matchRight = 0
                else
                    let matchLeft = 0
                endif
            endif

            let parent = matchLeft ? fileLeft : fileRight
            let path = substitute(path, parent, '', '')
            let path = path . '/' . file
            if matchLeft
                call s:addDiff(data, path, filereadable(parent . path) ? 'T_FILE_LEFT' : 'T_DIR_LEFT')
            else
                call s:addDiff(data, path, filereadable(parent . path) ? 'T_FILE_RIGHT' : 'T_DIR_RIGHT')
            endif
        elseif match(line, pConflictL) >= 0
            let left = substitute(line, pConflictL, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(data, path, 'T_CONFLICT_DIR_LEFT')
        elseif match(line, pConflictR) >= 0
            let left = substitute(line, pConflictR, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(data, path, 'T_CONFLICT_DIR_RIGHT')
        endif
    endfor
    return data
endfunction

function! s:addDiff(data, path, type)
    let item = a:data
    let nameList = split(a:path, '/')
    let nameIndex = 0

    while nameIndex < len(nameList)
        let nameExists = 0
        for itItem in item
            if itItem.name == nameList[nameIndex]
                call s:fixDirOnlyType(itItem, a:type)
                let nameExists = 1
                let item = itItem.children
                break
            endif
        endfor
        if !nameExists
            break
        endif
        let nameIndex += 1
    endwhile

    while nameIndex < len(nameList)
        let newItem = {
                    \   'name' : nameList[nameIndex],
                    \   'type' : 'T_DIR',
                    \   'children' : [],
                    \ }
        if nameIndex == len(nameList) - 1
            let newItem.type = a:type
        else
            if a:type == 'T_DIR_LEFT' || a:type == 'T_FILE_LEFT'
                let newItem.type = 'T_DIR_LEFT'
            elseif a:type == 'T_DIR_RIGHT' || a:type == 'T_FILE_RIGHT'
                let newItem.type = 'T_DIR_RIGHT'
            endif
        endif

        call add(item, newItem)
        let item = newItem.children
        let nameIndex += 1
    endwhile
endfunction

function! s:fixDirOnlyType(item, addType)
    if a:item.type == 'T_DIR_LEFT'
        if 0
                    \ || a:addType == 'T_SAME'
                    \ || a:addType == 'T_DIFF'
                    \ || a:addType == 'T_CONFLICT_DIR_LEFT'
                    \ || a:addType == 'T_CONFLICT_DIR_RIGHT'
                    \ || a:addType == 'T_DIR_RIGHT'
                    \ || a:addType == 'T_FILE_RIGHT'
            let a:item.type = 'T_DIR'
        endif
    elseif a:item.type == 'T_DIR_RIGHT'
        if 0
                    \ || a:addType == 'T_SAME'
                    \ || a:addType == 'T_DIFF'
                    \ || a:addType == 'T_CONFLICT_DIR_LEFT'
                    \ || a:addType == 'T_CONFLICT_DIR_RIGHT'
                    \ || a:addType == 'T_DIR_LEFT'
                    \ || a:addType == 'T_FILE_LEFT'
            let a:item.type = 'T_DIR'
        endif
    endif
endfunction

function! s:sortResult(data)
    call sort(a:data, g:ZFDirDiffSortFunc)
    for item in a:data
        call s:sortResult(item.children)
    endfor
endfunction

