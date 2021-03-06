"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_callbackitem') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_callbackitem = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#callbackitem#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#callbackitem#renewCache()
endfunction

"
function fuf#callbackitem#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#callbackitem#onInit()
endfunction

"
function fuf#callbackitem#launch(initialPattern, partialMatching, listener, items, forPath)
  let s:listener = a:listener
  let s:forPath = a:forPath
  if s:forPath
    let s:items = map(copy(a:items), 'fuf#makePathItem(v:val, 1)')
    call fuf#mapToSetSerialIndex(s:items, 1)
    call fuf#mapToSetAbbrWithSnippedWordAsPath(s:items)
  else
    let s:items = map(copy(a:items), '{ "word" : v:val }')
    let s:items = map(s:items, 'fuf#setBoundariesWithWord(v:val)')
    call fuf#mapToSetSerialIndex(s:items, 1)
    let s:items = map(s:items, 'fuf#setAbbrWithFormattedWord(v:val)')
  endif
  call fuf#launch(s:MODE_NAME, a:initialPattern, a:partialMatching)
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

" }}}1
"=============================================================================
" s:handler {{{1

let s:handler = {}

"
function s:handler.getModeName()
  return s:MODE_NAME
endfunction

"
function s:handler.getPrompt()
  return g:fuf_callbackitem_prompt
endfunction

"
function s:handler.getPromptHighlight()
  return g:fuf_callbackitem_promptHighlight
endfunction

"
function s:handler.targetsPath()
  return s:forPath
endfunction

"
function s:handler.onComplete(patternSet)
  if s:forPath
    return fuf#filterMatchesAndMapToSetRanks(
          \ s:items, a:patternSet,
          \ self.getFilteredStats(a:patternSet.raw), self.targetsPath())
  else
    return fuf#filterMatchesAndMapToSetRanks(
          \ s:items, a:patternSet,
          \ self.getFilteredStats(a:patternSet.raw), self.targetsPath())
  endif
endfunction

"
function s:handler.onOpen(expr, mode)
  call s:listener.onComplete(a:expr, a:mode)
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
endfunction

"
function s:handler.onModeLeavePost(opened)
  if !a:opened
    call s:listener.onAbort()
  endif
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
