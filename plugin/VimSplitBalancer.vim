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

augroup VimSplitBalancer
  autocmd!

  " Restore it.
  autocmd VimResized * call VimSplitBalancer#BalanceSplits()

  " Not sure why we needed this `WinEnter` hook, and it messed up
  " the special "HUD" style location list layers in VimBox.
  autocmd WinEnter * call VimSplitBalancer#BalanceSplits()
  autocmd TabEnter * call VimSplitBalancer#BalanceSplits()
augroup END
