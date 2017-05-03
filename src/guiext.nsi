; base GUI extension w/o behaviour change

!ifndef _NSIS_SETUP_LIB_GUI_EXT_NSI
!define _NSIS_SETUP_LIB_GUI_EXT_NSI

!ifndef LOGICLIB
!include "LogicLib.nsh"
!endif

!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"

!define NSD_GetAllocText `!insertmacro __NSD_GetAllocText`
!macro __NSD_GetAllocText ctrl var_size var_addr
  !define __NSD_GetAllocText__LABELID_EXIT __NSD_GetAllocText__LABELID_EXIT_L${__LINE__}

  ${PushStack2} $R0 $R9

  StrCpy $R0 0 ; size
  StrCpy $R9 0 ; address

  System::Call user32::GetWindowTextLength(p ${ctrl}) i.R0
  ${If} $R0 = 0
    Goto ${__NSD_GetAllocText__LABELID_EXIT}
  ${EndIf}

  System::Alloc $R0
  Pop $R9
  ${If} $R9 = 0
    StrCpy $R0 0 ; just in case
    Goto ${__NSD_GetAllocText__LABELID_EXIT}
  ${EndIf}

  System::Call user32::GetWindowText(p ${ctrl}, p R9, i R0) i.R0

  ${__NSD_GetAllocText__LABELID_EXIT}:

  ${MacroPopStack2} "${var_size} ${var_addr}" "$R0 $R9" $R0 $R9

  !undef __NSD_GetAllocText__LABELID_EXIT
!macroend

!define NSD_SetTextAddr `!insertmacro __NSD_SetTextAddr`
!macro __NSD_SetTextAddr ctrl addr
  SendMessage ${ctrl} ${WM_SETTEXT} 0 ${addr}
!macroend

!endif
