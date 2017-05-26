!ifndef _NSIS_SETUP_LIB_LOG_NSI
!define _NSIS_SETUP_LIB_LOG_NSI

!include "StrFunc.nsh"

!include "${_NSIS_SETUP_LIB_ROOT}\src\preprocessor.nsi"

; DetailPrint with workarounds
!define Func_DetailPrint "!insertmacro Func_DetailPrint"
!macro Func_DetailPrint un
Function ${un}DetailPrint
  Exch $R0
  !if "${un}" != "un."
    ${StrRep} $R0 $R0 "$\n" " " ; replace all line returns in the message to fix the DetailPrint tooltip cut off before a line return
  !else
    ${UnStrRep} $R0 $R0 "$\n" " " ; replace all line returns in the message to fix the DetailPrint tooltip cut off before a line return
  !endif
  DetailPrint $R0
  Pop $R0
FunctionEnd
!macroend

!define DetailPrint "!insertmacro DetailPrint"
!macro DetailPrint str
Push `${str}`
!ifndef __UNINSTALL__
Call DetailPrint
!else
Call un.DetailPrint
!endif
!macroend

!define Include_DetailPrint "!insertmacro Include_DetailPrint"
!macro Include_DetailPrint un
!ifndef ${un}DetailPrint_INCLUDED
  !define ${un}DetailPrint_INCLUDED
  !if "${un}" != "un."
    !ifndef StrRep_INCLUDED
      ${StrRep}
    !endif
  !else
    !ifndef UnStrRep_INCLUDED
      ${UnStrRep}
    !endif
  !endif
  ${Func_DetailPrint} "${un}"
!endif
!macroend

!endif
