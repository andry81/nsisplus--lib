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

RequestExecutionLevel admin ; for all users

Page Custom Show Leave

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

; include for install only
${Include_RegAddPathToVar} ""
${Include_RegRemovePathFromVar} ""

Function Show
  nsDialogs::Create 1018
  Pop $DialogID

  ${NSD_CreateLabel} 0 3u 12% 8u "Path:"
  Pop $NULL

  ${NSD_CreateText} 12% 0 68% 14u "C:\NewInstall\bin"
  Pop $AddPath_EditID
  ${NSD_OnChange} $AddPath_EditID WndProc

  ${NSD_CreateButton} 80% 0 20% 14u "Append"
  Pop $AddPath_ButtonID
  ${NSD_OnClick} $AddPath_ButtonID WndProc


  ${NSD_CreateLabel} 0 43u 12% 8u "Includes:"
  Pop $NULL

  ${NSD_CreateText} 12% 40u 88% 14u "c:\NotExistedInstall\bin|c:\IncludedInstall\bin"
  Pop $IncludePathListToRemovePath_EditID
  ${NSD_OnChange} $IncludePathListToRemovePath_EditID WndProc

  ${NSD_CreateLabel} 0 58u 12% 8u "Excludes:"
  Pop $NULL

  ${NSD_CreateText} 12% 55u 88% 14u "%SystemRoot%|c:\ExcludedInstall"
  Pop $ExcludePathListToRemovePath_EditID
  ${NSD_OnChange} $ExcludePathListToRemovePath_EditID WndProc

  ${NSD_CreateLabel} 0 73u 12% 8u "Files:"
  Pop $NULL

  ${NSD_CreateText} 12% 70u 68% 14u "nonexisted.bin|test.bin"
  Pop $FileListToRemovePath_EditID
  ${NSD_OnChange} $FileListToRemovePath_EditID WndProc

  ${NSD_CreateButton} 80% 70u 20% 14u "Remove"
  Pop $RemovePath_ButtonID
  ${NSD_OnClick} $RemovePath_ButtonID WndProc

  StrCpy $R0 -1
  Call Update

  nsDialogs::Show
FunctionEnd

Function Leave
FunctionEnd

Function WndProc
  System::Store SR0
  Call Update
  System::Store L
FunctionEnd

Function Update
  ; read values
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

  ${If} $R0 = $AddPath_ButtonID
    ${If} $AddPath_Edit != ""
      #${RegAddPathToVar} "$AddPath_Edit" HKCU "Environment" PATH ; for current user
      ${RegAddPathToVar} "$AddPath_Edit" HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" PATH ; for all users
    ${EndIf}
  ${EndIf}

  ${If} $R0 = $RemovePath_ButtonID
    ${RegRemovePathFromVar} "$FileListToRemovePath_Edit" HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" PATH "$IncludePathListToRemovePath_Edit" "$ExcludePathListToRemovePath_Edit"
  ${EndIf}
FunctionEnd

Section -Hidden
SectionEnd
