!include "nsDialogs.nsh"
!include "WinCore.nsh"
!include "LogicLib.nsh"

!include "${TEST_LIB_ROOT}\common.nsi"
!include "${TEST_LIB_ROOT}\config.nsi"

!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\Stack.nsh"
#!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\CommCtrl.nsh"
#!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\WndSubclass.nsh"
#!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\Locate.nsh"
#!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\Registry.nsh"

!include "${_NSIS_SETUP_LIB_ROOT}\src\preprocessor.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\init.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\utils.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\guiext.nsi"

RequestExecutionLevel admin ; for all users

Page Custom Show Leave

; all
!define REG_HIVE HKLM
!define REG_KEY "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
#; current user
#!define REG_HIVE HKCU
#!define REG_KEY "Environment"

Var /GLOBAL VariableName_EditID
Var /GLOBAL VariableName_Edit

Var /GLOBAL VariableValue_EditID
Var /GLOBAL VariableValue_Edit ; TODO: replace by MessageBox macro with memory allocated strings support

Var /GLOBAL VariableRead_ButtonID
Var /GLOBAL VariableRead_ValueLen
Var /GLOBAL VariableRead_ValueTypeStr
Var /GLOBAL VariableRead_ValueSize
Var /GLOBAL VariableRead_ValueAddr
Var /GLOBAL VariableRead_ValueType

Var /GLOBAL VariableSet_ButtonID

Var /GLOBAL VariableInfo_LabelID
Var /GLOBAL VariableInfo_ButtonID

Var /GLOBAL AddPath_EditID
Var /GLOBAL AddPath_Edit
Var /GLOBAL AddPath_ButtonID

Var /GLOBAL IncludePathListToRemovePath_EditID
Var /GLOBAL IncludePathListToRemovePath_Edit
Var /GLOBAL ExcludePathListToRemovePath_EditID
Var /GLOBAL ExcludePathListToRemovePath_Edit
Var /GLOBAL FileListToRemovePath_EditID
Var /GLOBAL FileListToRemovePath_Edit
Var /GLOBAL RemovePath_ButtonID

Var /GLOBAL Update_IgnoreUpdate

; include for install only
${Include_RegAddPathToVar} ""
${Include_RegRemovePathFromVar} ""
${Include_RegReadToAllocValue} ""
${Include_RegSetAllocValue} ""

Function Show
  StrCpy $VariableRead_ValueAddr 0
  StrCpy $Update_IgnoreUpdate 0
  StrCpy $VariableRead_ValueLen 0
  StrCpy $VariableRead_ValueTypeStr "<undefined>"

  nsDialogs::Create 1018
  Pop $DialogID

  ${NSD_CreateLabel} 0 3u 12% 8u "Variable:"
  Pop $NULL

  ${NSD_CreateText} 12% 0u 68% 14u "PATH"
  Pop $VariableName_EditID
  ${NSD_OnChange} $VariableName_EditID WndProc

  ${NSD_CreateButton} 80% 0u 20% 14u "Read"
  Pop $VariableRead_ButtonID
  ${NSD_OnClick} $VariableRead_ButtonID WndProc

  ${NSD_CreateLabel} 0 18u 12% 8u "Value:"
  Pop $NULL

  ${NSD_CreateText} 12% 15u 68% 14u ""
  Pop $VariableValue_EditID
  ${NSD_OnChange} $VariableValue_EditID WndProc

  ${NSD_CreateButton} 80% 15u 20% 14u "Info"
  Pop $VariableInfo_ButtonID
  ${NSD_OnClick} $VariableInfo_ButtonID WndProc

  ${NSD_CreateLabel} 12% 30u 78% 8u "Length: $VariableRead_ValueLen; Type: $VariableRead_ValueTypeStr"
  Pop $VariableInfo_LabelID

  ${NSD_CreateButton} 90% 30u 10% 14u "Set"
  Pop $VariableSet_ButtonID
  ${NSD_OnClick} $VariableSet_ButtonID WndProc


  ${NSD_CreateLabel} 0 53u 12% 8u "Path:"
  Pop $NULL

  ${NSD_CreateText} 12% 50u 68% 14u "C:\NewInstall\bin"
  Pop $AddPath_EditID
  ${NSD_OnChange} $AddPath_EditID WndProc

  ${NSD_CreateButton} 80% 50u 20% 14u "Append"
  Pop $AddPath_ButtonID
  ${NSD_OnClick} $AddPath_ButtonID WndProc


  ${NSD_CreateLabel} 0 73u 12% 8u "Includes:"
  Pop $NULL

  ${NSD_CreateText} 12% 70u 88% 14u "c:\NotExistedInstall\bin|c:\IncludedInstall\bin"
  Pop $IncludePathListToRemovePath_EditID
  ${NSD_OnChange} $IncludePathListToRemovePath_EditID WndProc

  ${NSD_CreateLabel} 0 88u 12% 8u "Excludes:"
  Pop $NULL

  ${NSD_CreateText} 12% 85u 88% 14u "%SystemRoot%|c:\ExcludedInstall"
  Pop $ExcludePathListToRemovePath_EditID
  ${NSD_OnChange} $ExcludePathListToRemovePath_EditID WndProc

  ${NSD_CreateLabel} 0 103u 12% 8u "Files:"
  Pop $NULL

  ${NSD_CreateText} 12% 100u 68% 14u "nonexisted.bin|test.bin"
  Pop $FileListToRemovePath_EditID
  ${NSD_OnChange} $FileListToRemovePath_EditID WndProc

  ${NSD_CreateButton} 80% 100u 20% 14u "Remove"
  Pop $RemovePath_ButtonID
  ${NSD_OnClick} $RemovePath_ButtonID WndProc


  StrCpy $R0 -1
  Call Update

  nsDialogs::Show
FunctionEnd

Function Leave
  ${If} $VariableRead_ValueAddr <> 0 ; deallocate buffer on page leave
    ${SystemFree} $VariableRead_ValueAddr
    StrCpy $VariableRead_ValueSize 0
    StrCpy $VariableRead_ValueType 0
  ${EndIf}
FunctionEnd

Function WndProc
  System::Store SR0
  Call Update
  System::Store L
FunctionEnd

Function UpdateInfo
  StrCpy $VariableRead_ValueLen 0
  ${If} $VariableRead_ValueSize > ${NSIS_CHAR_SIZE}
    IntOp $VariableRead_ValueLen $VariableRead_ValueSize - ${NSIS_CHAR_SIZE}
  ${EndIf}
  IntOp $VariableRead_ValueLen $VariableRead_ValueLen / ${NSIS_CHAR_SIZE}

  ${RegGetValueTypeMap} $VariableRead_ValueTypeStr $VariableRead_ValueType
  ${If} $VariableRead_ValueTypeStr == ""
    StrCpy $VariableRead_ValueTypeStr "<undefined>"
  ${EndIf}
FunctionEnd

Function UpdateInfoGUI
  ShowWindow $VariableInfo_LabelID ${SW_HIDE}
  ${NSD_SetText} $VariableInfo_LabelID "Length: $VariableRead_ValueLen; Type: ($VariableRead_ValueType) $VariableRead_ValueTypeStr"
  ShowWindow $VariableInfo_LabelID ${SW_SHOW} ; to force label update
FunctionEnd

Function Update
  ${If} $Update_IgnoreUpdate <> 0
    Return
  ${EndIf}

  ; read values
  ${If} $R0 = $VariableName_EditID
  ${OrIf} $R0 = -1
    ${NSD_GetText} $VariableName_EditID $VariableName_Edit
  ${EndIf}

  ${If} $R0 = $VariableValue_EditID
  ${OrIf} $R0 = -1
    ${If} $VariableRead_ValueAddr <> 0
      ${SystemFree} $VariableRead_ValueAddr ; deallocate previous buffer
      StrCpy $VariableRead_ValueSize 0
    ${EndIf}

    ${If} $VariableRead_ValueType == ""
      StrCpy $VariableRead_ValueType 0
    ${EndIf}

    ${NSD_GetTextAlloc} $VariableValue_EditID $VariableRead_ValueSize $VariableRead_ValueAddr

    ; update info
    ${If} $VariableRead_ValueAddr <> 0
    ${AndIf} $VariableRead_ValueType = ${REG_NONE}
      StrCpy $VariableRead_ValueType ${REG_EXPAND_SZ} ; use on first input if not set before
    ${EndIf}
    Call UpdateInfo
    StrCpy $Update_IgnoreUpdate 1 ; ignore any recursion
    Call UpdateInfoGUI
    StrCpy $Update_IgnoreUpdate 0
  ${EndIf}

  ${If} $R0 = $AddPath_EditID
  ${OrIf} $R0 = -1
    ${NSD_GetText} $AddPath_EditID $AddPath_Edit
  ${EndIf}

  ${If} $R0 = $IncludePathListToRemovePath_EditID
  ${OrIf} $R0 = -1
    ${NSD_GetText} $IncludePathListToRemovePath_EditID $IncludePathListToRemovePath_Edit
  ${EndIf}

  ${If} $R0 = $ExcludePathListToRemovePath_EditID
  ${OrIf} $R0 = -1
    ${NSD_GetText} $ExcludePathListToRemovePath_EditID $ExcludePathListToRemovePath_Edit
  ${EndIf}

  ${If} $R0 = $FileListToRemovePath_EditID
  ${OrIf} $R0 = -1
    ${NSD_GetText} $FileListToRemovePath_EditID $FileListToRemovePath_Edit
  ${EndIf}

  ${If} $R0 = $VariableRead_ButtonID
  ${AndIf} $VariableName_Edit != ""
    ${If} $VariableRead_ValueAddr <> 0 ; deallocate previous buffer
      ${SystemFree} $VariableRead_ValueAddr
      StrCpy $VariableRead_ValueSize 0
      StrCpy $VariableRead_ValueType 0
    ${EndIf}

    ${RegReadToAllocValue} ${REG_HIVE} "${REG_KEY}" $VariableName_Edit $VariableRead_ValueSize $VariableRead_ValueAddr $VariableRead_ValueType

    Call UpdateInfo
    
    StrCpy $Update_IgnoreUpdate 1 ; ignore any recursion
    Call UpdateInfoGUI

    ${If} $VariableRead_ValueAddr <> 0
      ${NSD_SetTextAddr} $VariableValue_EditID $VariableRead_ValueAddr
    ${Else}
      ${NSD_SetText} $VariableValue_EditID "<null>"
    ${EndIf}
    StrCpy $Update_IgnoreUpdate 0

    ${NSD_GetText} $VariableValue_EditID $VariableValue_Edit
  ${EndIf}

  ${If} $R0 = $VariableInfo_ButtonID
    MessageBox MB_OK "Variable$\t: $VariableName_Edit$\nType$\t: ($VariableRead_ValueType) $VariableRead_ValueTypeStr$\nLength$\t: $VariableRead_ValueLen$\nValue$\t: $\"$VariableValue_Edit$\""
  ${EndIf}

  ${If} $R0 = $VariableSet_ButtonID
  ${AndIf} $VariableSet_Edit != ""
    ${If} $VariableRead_ValueAddr <> 0 ; ignore invalid buffer
      ${RegSetAllocValue} ${REG_HIVE} "${REG_KEY}" $VariableName_Edit $VariableRead_ValueSize $VariableRead_ValueAddr $VariableRead_ValueType
    ${Else}
      ${RegSetAllocValue} ${REG_HIVE} "${REG_KEY}" $VariableName_Edit 1 0 $VariableRead_ValueType ; to clear the key in case of null address the size must be 1
    ${EndIf}
  ${EndIf}

  ${If} $R0 = $AddPath_ButtonID
  ${AndIf} $VariableName_Edit != ""
    ${If} $AddPath_Edit != ""
      ${RegAddPathToVar} "$AddPath_Edit" ${REG_HIVE} "${REG_KEY}" $VariableName_Edit
    ${EndIf}
  ${EndIf}

  ${If} $R0 = $RemovePath_ButtonID
  ${AndIf} $VariableName_Edit != ""
    ${RegRemovePathFromVar} "$FileListToRemovePath_Edit" ${REG_HIVE} "${REG_KEY}" $VariableName_Edit "$IncludePathListToRemovePath_Edit" "$ExcludePathListToRemovePath_Edit"
  ${EndIf}
FunctionEnd

Section -Hidden
SectionEnd
