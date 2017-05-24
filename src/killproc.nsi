!ifndef _NSIS_SETUP_LIB_KILLPROC_NSI
!define _NSIS_SETUP_LIB_KILLPROC_NSI

!include "LogicLib.nsh"

Var /GLOBAL Missed_call_to_KillProc_lib_functions
Var /GLOBAL CURRENT_PROC_PATH
Var /GLOBAL CURRENT_SCRIPT_PATH
Var /GLOBAL FINDPROC_ERR
Var /GLOBAL KILLPROC_ERR
Var /GLOBAL KILLPROC_RETRY_NUM

!define KillProc "!insertmacro KillProc"
!macro KillProc proc_path
${DebugStackEnterFrame} KillProc 0 1
${Push} `${proc_path}`
!ifdef __UNINSTALL__
  Call un.KillProc
!else
  Call KillProc
!endif
${DebugStackExitFrame} KillProc 0 1
!macroend

!macro KillProcDef un
Function ${un}KillProc
  StrCpy $Missed_call_to_KillProc_lib_functions "" ; dummy to suppress "Variable ... not referenced ..." warnings

  ${ExchStack1} $CURRENT_PROC_PATH
  ;CURRENT_PROC_PATH - proc_path
  ${PushStack1} $R0

  ${DebugStackEnterFrame} ${un}KillProc 1 0

  StrCpy $KILLPROC_RETRY_NUM 0

  ${DetailPrint} "$(MSG_KILLPROC_PROC_IS_SEARCHING)"

  Retry:
  ${If} 16 < $KILLPROC_RETRY_NUM
    MessageBox MB_OKCANCEL "$(MSG_KILLPROC_PLEASE_CLOSE_PROC)" /SD IDCANCEL IDYES CheckProc IDCANCEL 0
    ${DetailPrint} "$(MSG_KILLPROC_PROC_IS_IGNORED)"
    Goto Continue
  ${EndIf}

  FindProc:
  FindProcDLL::FindProc "$CURRENT_PROC_PATH"
  StrCpy $FINDPROC_ERR $R0
  ${If} $FINDPROC_ERR == 1
    ${DetailPrint} "$(MSG_KILLPROC_PROC_IS_CLOSING)"
    FindProcDLL::KillProc "$CURRENT_PROC_PATH"
    StrCpy $KILLPROC_ERR $R0
    ${If} $KILLPROC_ERR = 1
      ${DetailPrint} "$(MSG_KILLPROC_PROC_IS_CLOSED)"
      IntOp $KILLPROC_RETRY_NUM $KILLPROC_RETRY_NUM + 1
      Goto Retry
    ${ElseIf} $KILLPROC_ERR <> 0
      ${DetailPrint} "$(MSG_KILLPROC_PROC_CLOSE_ERROR)"
      IntOp $KILLPROC_RETRY_NUM $KILLPROC_RETRY_NUM + 1
      Goto Retry
    ${Else}
      ${DetailPrint} "$(MSG_KILLPROC_PROC_NOT_FOUND)"
      IntOp $KILLPROC_RETRY_NUM $KILLPROC_RETRY_NUM + 1
      Goto Retry
    ${EndIf}
  ${Else}
    ${DetailPrint} "$(MSG_FINDPROC_PROC_ERROR_CODE)"
  ${EndIf}
  Goto Continue

  CheckProc:
  StrCpy $KILLPROC_RETRY_NUM 0
  Goto FindProc

  Continue:
  ${DebugStackExitFrame} ${un}KillProc 1 0

  ${PopStack2} $NULL $R0
FunctionEnd
!macroend

!insertmacro KillProcDef ""
!insertmacro KillProcDef "un."

!endif
