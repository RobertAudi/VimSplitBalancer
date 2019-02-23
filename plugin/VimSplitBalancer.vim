" VimSplitBalancer.vim:
" Maintainer:   jordwalke <github.com/jordwalke>
" License:      MIT
"
" =============================VimSplitBalancer.vim==============================
" Distributes available space among vertical splits, but plays nice with
" NERDTree.
"
" The currently focused vertical split will always automatically be resized
" according to the max amount of characters horizontally in that text file.
" The remaining space will be evenly distributed across all of the other
" vertical splits.
" ===============================================================================

"  Load Once:
if exists('g:loaded_vim_split_balancer')
  finish
endif
let g:loaded_vim_split_balancer = 1

" For some reason, NERDTree doesn't actually respect its width setting.
let g:VimSplitBalancerMaxSideBar = get(g:, 'VimSplitBalancerMaxSideBar',  50)
let g:VimSplitBalancerMaxWidth   = get(g:, 'VimSplitBalancerMaxWidth',   110)
let g:VimSplitBalancerMinWidth   = get(g:, 'VimSplitBalancerMinWidth',    70)
let g:VimSplitBalancerIgnoreFiletypes = get(g:, 'VimSplitBalancerIgnoreFiletypes', [])

let s:VimSplitBalancerIgnoreFiletypes = uniq(extend([
      \   'nerdtree',
      \   'tagbar',
      \ ], g:VimSplitBalancerIgnoreFiletypes))

" - winwidth setting is the *minimum* window width for the focused window at
"   the time of invoking `wincmd =`, or just focusing a window. All others get
"   space distributed, unless they have set winfixwidth/winfixheight.
"   `winwidth` is a global setting.  If this were a per-window setting, it
"   would make this plugin a lot simpler.
" - winfixwidth/winfixheight make a window immune to being resized when
"   another window is focused or does `wincmd =`.
" - winwidth(0) function is (confusingly) the actual width of the current
"   window. Not the minimum width when `wincmd =` is called .
" - NERDTree should have winfixwidth set.
function! s:BalanceSplits()
  if get(g:, 'VimSplitBalancerSupress', 0)
    return
  endif

  " If the window (such as NERDTree) is marked as immune to being resized
  " due to winwidth when other windows are focused (or when `wincmd =` is
  " invoked) that doesn't make it immune to resizing when that window does
  " `wincmd =` itself, or is focused itself. To simulate that, we
  " temporarily set that global `winwidth` to the current width.
  if &winfixwidth || index(s:VimSplitBalancerIgnoreFiletypes, &filetype) >= 0
    let &winwidth = min([winwidth(0), g:VimSplitBalancerMaxSideBar])
    if winwidth(0) != &winwidth
      execute 'vertical resize ' . &winwidth
    endif
  else
    let longest = max(map(range(1, line('$')), "virtcol([v:val, '$'])"))

    " We set the global setting when entering any window to make it seem
    " as if winwidth was a perf-window setting.
    let &winwidth = max([g:VimSplitBalancerMinWidth, min([longest, g:VimSplitBalancerMaxWidth])])
  endif

  wincmd =

  " Now, set it back to 1, so that it effectively disables resizing when
  " focusing/jumping around windows. Think of this plugin as a way to
  " always have winwidth = 1, but then selectively set it to the "right"
  " width only when g:VimSplitBalancerSupress is 0, and when not focusing
  " on the NERDTree etc.
  let &winwidth = 1
endfunction

augroup VimSplitBalancer
  autocmd!

  " Restore it.
  autocmd VimResized * call <SID>BalanceSplits()

  " Not sure why we needed this `WinEnter` hook, and it messed up
  " the special "HUD" style location list layers in VimBox.
  autocmd WinEnter * call <SID>BalanceSplits()
  autocmd TabEnter * call <SID>BalanceSplits()
augroup END
