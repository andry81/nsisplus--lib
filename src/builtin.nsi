; implementation based only on runtime builtin functionality and does not dependent on not builtin runtime functionality, but may depend on init variables.

!ifndef _NSIS_SETUP_LIB_BUILTIN_NSI
!define _NSIS_SETUP_LIB_BUILTIN_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\preprocessor.nsi"

Var /GLOBAL ERRORS
Var /GLOBAL ERRORS_STACK ; to save/load the errors flag to/from variable

!define SetErrors "!insertmacro SetErrors"
!macro SetErrors var
IntCmp ${var} 0 0 +3 +3
ClearErrors
Goto +2
SetErrors
!macroend

!define GetErrors "!insertmacro GetErrors"
!macro GetErrors var
IfErrors 0 +4
StrCpy ${var} 1
SetErrors ; restore errors flag
Goto +2
StrCpy ${var} 0
!macroend

!define PushErrors "!insertmacro PushErrors"
!macro PushErrors
IfErrors 0 +4
StrCpy $ERRORS_STACK "$ERRORS_STACK1"
SetErrors ; restore errors flag
Goto +2
StrCpy $ERRORS_STACK "$ERRORS_STACK0"
!macroend

!define PopErrors "!insertmacro PopErrors"
!macro PopErrors
StrCmp $ERRORS_STACK "" +7
StrCpy $ERRORS $ERRORS_STACK "" -1
StrCpy $ERRORS_STACK $ERRORS_STACK -1
IntCmp $ERRORS 0 0 +3 +3 ; DO NOT replace by SetErrors macro!
ClearErrors
Goto +2
SetErrors
!macroend

!define PopAndSetErrors "!insertmacro PopAndSetErrors"
!macro PopAndSetErrors
${Pop} $ERRORS
${SetErrors} $ERRORS
!macroend

!define !AbortOrQuit "!insertmacro !AbortOrQuit"
!macro !AbortOrQuit
; CAUTION:
;   Abort function call from a page control window procedure handler does NOT initiate installer to quit!
;   To workaround this issue we have at least to call the installer process to exit directly from the Win32 API
;   instead of call to Quit if Abort or even Quit has been called already.
;

IntCmp $QUITCALLED 0 0 +2 +2
Goto +5
IfSilent +2
SendMessage $HWNDPARENT ${WM_CLOSE} 0 0 ; send gui messages only in non silent mode if already tried to quit in gui
Quit ; try last quit call again
Goto +6 ; skip everything after just in case
StrCpy $QUITCALLED 1
StrCmp $QUIT_CMD "Quit" 0 +2
Quit
StrCmp $QUIT_CMD "Abort" 0 +2
Abort
; nothing more can do here
!macroend

!endif
