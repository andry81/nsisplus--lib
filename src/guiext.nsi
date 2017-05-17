; base GUI extension w/o behaviour change

!ifndef _NSIS_SETUP_LIB_GUI_EXT_NSI
!define _NSIS_SETUP_LIB_GUI_EXT_NSI

!ifndef LOGICLIB
!include "LogicLib.nsh"
!endif

!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"

!define NSD_GetTextAlloc "!insertmacro __NSD_GetTextAlloc"
!macro __NSD_GetTextAlloc ctrl byte_size_var addr_var
  !define __NSD_GetTextAlloc__LABELID_EXIT __NSD_GetTextAlloc__LABELID_EXIT_L${__LINE__}

  ${PushStack2} $R0 $R9

  StrCpy $R0 0 ; size
  StrCpy $R9 0 ; address

  System::Call "user32::GetWindowTextLength(p ${ctrl}) i.R0"
  ${If} $R0 = 0
    Goto ${__NSD_GetTextAlloc__LABELID_EXIT}
  ${EndIf}

  ; convertion from characters into bytes
  IntOp $R0 $R0 * ${NSIS_CHAR_SIZE}
  IntOp $R0 $R0 + ${NSIS_CHAR_SIZE}

  System::Alloc $R0
  Pop $R9
  ${If} $R9 = 0
    StrCpy $R0 0
    Goto ${__NSD_GetTextAlloc__LABELID_EXIT}
  ${EndIf}

  System::Call "user32::GetWindowText(p ${ctrl}, p R9, i R0) i"

  ${__NSD_GetTextAlloc__LABELID_EXIT}:

  ${MacroPopStack2} "${byte_size_var} ${addr_var}" "$R0 $R9" $R0 $R9

  !undef __NSD_GetTextAlloc__LABELID_EXIT
!macroend

!define NSD_SetTextAddr `!insertmacro __NSD_SetTextAddr`
!macro __NSD_SetTextAddr ctrl addr
  SendMessage ${ctrl} ${WM_SETTEXT} 0 ${addr}
!macroend

!endif
