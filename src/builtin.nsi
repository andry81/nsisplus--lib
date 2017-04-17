; implementation based only on runtime builtin functionality and does not dependent on not builtin runtime functionality

!ifndef _NSIS_SETUP_LIB_BUILTIN_NSI
!define _NSIS_SETUP_LIB_BUILTIN_NSI

!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\preprocessor.nsi"

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

!endif
