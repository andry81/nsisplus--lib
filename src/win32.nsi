; functions uses win32 API as a dependency or rely on win32 API as a base

!ifndef _NSIS_SETUP_LIB_WIN32_NSI
!define _NSIS_SETUP_LIB_WIN32_NSI

!ifndef __WIN_WINDOWS__INC
!include "WinCore.nsh"
!endif
!ifndef WINMESSAGES_INCLUDED
!include "WinMessages.nsh"
!endif
!ifndef LOGICLIB
!include "LogicLib.nsh"
!endif

!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\UAC.nsh"
!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\CommCtrl.nsh"

!include "${_NSIS_SETUP_LIB_ROOT}\src\preprocessor.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\debug.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\winbase.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\winuser.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\wingdi.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\winctrl.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\win32util.nsi"

; -1 - UAC_RunElevation is not called
;  0 - UAC_RunElevation is not created new forked setup process
;  1 - UAC_RunElevation has created new forked setup process
Var /GLOBAL UAC_PROCESS_ELEVATION_STATUS_FLAGS
Var /GLOBAL PROCESS_ID

Var /GLOBAL APPDATA_CURRENT
Var /GLOBAL APPDATA_LOCAL_CURRENT
Var /GLOBAL APPDATA_ALL

Var /GLOBAL DESKTOP_CURRENT
Var /GLOBAL DESKTOP_ALL

Var /GLOBAL SMPROGRAMS_CURRENT
Var /GLOBAL SMPROGRAMS_ALL

; user32::InvalidateRect flags
!define RDW_INVALIDATE 0x0001
!define RDW_INTERNALPAINT 0x0002
!define RDW_ERASE 0x0004

!define RDW_VALIDATE 0x0008
!define RDW_NOINTERNALPAINT 0x0010
!define RDW_NOERASE 0x0020

!define RDW_NOCHILDREN 0x0040
!define RDW_ALLCHILDREN 0x0080

!define RDW_UPDATENOW 0x0100
!define RDW_ERASENOW 0x0200

!define RDW_FRAME 0x0400
!define RDW_NOFRAME 0x0800

!define SystemFree "!insertmacro SystemFree"
!macro SystemFree buf_var
${If} "${buf_var}" != ""
${AndIf} ${buf_var} <> 0
  System::Free ${buf_var}
  StrCpy ${buf_var} 0
${EndIf}
!macroend

!define Func_PreInitUserWin32 "!insertmacro Func_PreInitUserWin32"
!macro Func_PreInitUserWin32 un
Function ${un}PreInitUserWin32
  ${PushStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
  ; R0 - calling process id

  ${DebugStackEnterFrame} `${un}PreInitUserWin32` 1 0

  ${If} $R0 <> $PROCESS_ID
    ; calling process is forked setup process
    StrCpy $UAC_PROCESS_ELEVATION_STATUS_FLAGS 1
  ${EndIf}

  ; return process id
  StrCpy $R0 $PROCESS_ID
  ; return UAC_PROCESS_ELEVATION_STATUS_FLAGS
  StrCpy $R1 $UAC_PROCESS_ELEVATION_STATUS_FLAGS

  ${DebugStackExitFrame} `${un}PreInitUserWin32` 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Func_PostInitUserWin32 "!insertmacro Func_PostInitUserWin32"
!macro Func_PostInitUserWin32 un
Function ${un}PostInitUserWin32
  ${PushStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} `${un}PostInitUserWin32` 1 0

  ; update process elevation status flags

  #${PushShellVarContext} current

  ; not all, see ${NSIS_ROOT}/include/WinCore.nsh for complete list
  System::Call "shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .R1, i ${CSIDL_APPDATA}, i 0) i.R9"
  StrCpy $APPDATA_CURRENT $R1
  System::Call "shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .R1, i ${CSIDL_LOCAL_APPDATA}, i 0) i.R9"
  StrCpy $APPDATA_LOCAL_CURRENT $R1
  System::Call "shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .R1, i ${CSIDL_DESKTOPDIRECTORY}, i 0) i.R9"
  StrCpy $DESKTOP_CURRENT $R1
  System::Call "shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .R1, i ${CSIDL_PROGRAMS}, i 0) i.R9"
  StrCpy $SMPROGRAMS_CURRENT $R1
  
  #${PopShellVarContext}
  
  #${PushShellVarContext} all
  
  ; not all, see ${NSIS_ROOT}/include/WinCore.nsh for complete list
  System::Call "shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .R1, i ${CSIDL_COMMON_APPDATA}, i 0) i.R9"
  StrCpy $APPDATA_ALL $R1
  System::Call "shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .R1, i ${CSIDL_COMMON_DESKTOPDIRECTORY}, i 0) i.R9"
  StrCpy $DESKTOP_ALL $R1
  System::Call "shell32::SHGetSpecialFolderPath(i $HWNDPARENT, t .R1, i ${CSIDL_COMMON_PROGRAMS}, i 0) i.R9"
  StrCpy $SMPROGRAMS_ALL $R1

  #${PopShellVarContext}

  ${DebugStackExitFrame} `${un}PostInitUserWin32` 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

#!define UAC_PreInit "!insertmacro Call_UAC_PreInit ''"
#!define un.UAC_PreInit "!insertmacro Call_UAC_PreInit 'un.'"
!define UAC_PostInitAndReadShellGlobals "!insertmacro Call_UAC_PostInitAndReadShellGlobals ''"
!define un.UAC_PostInitAndReadShellGlobals "!insertmacro Call_UAC_PostInitAndReadShellGlobals 'un.'"

!define Call_UAC_PreInit "!insertmacro Call_UAC_PreInit"
!macro Call_UAC_PreInit prefix
${DebugStackEnterFrame} Call_UAC_PreInit 0 1

Call ${prefix}UAC_PreInit

${DebugStackExitFrame} Call_UAC_PreInit 0 1
!macroend

!define Call_UAC_PostInitAndReadShellGlobals "!insertmacro Call_UAC_PostInitAndReadShellGlobals"
!macro Call_UAC_PostInitAndReadShellGlobals prefix
${DebugStackEnterFrame} ${prefix}UAC_PostInitAndReadShellGlobals 0 1

Call ${prefix}UAC_PostInitAndReadShellGlobals

${DebugStackExitFrame} ${prefix}UAC_PostInitAndReadShellGlobals 0 1
!macroend

!define Func_UAC_PreInit "!insertmacro Func_UAC_PreInit"
!macro Func_UAC_PreInit un
Function ${un}UAC_PreInit
  ${PushStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9

  ${DebugStackEnterFrame} `${un}UAC_PreInit` 1 0

  ; input: calling process id, output: called process id
  StrCpy $R0 $PROCESS_ID
  ; output: called process UAC_PROCESS_ELEVATION_STATUS_FLAGS value
  StrCpy $R1 -1

  !insertmacro UAC_AsUser_Call Function ${un}PreInitUserWin32 ${UAC_SYNCREGISTERS}

  ${If} $R0 <> $PROCESS_ID
    ; setup process has forked from parent process, do copy process elevation status flags
    StrCpy $UAC_PROCESS_ELEVATION_STATUS_FLAGS $R1
  ${EndIf}

  ${DebugStackExitFrame} `${un}UAC_PreInit` 1 0

  ${PopStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
FunctionEnd
!macroend

!define Func_UAC_PostInitAndReadShellGlobals "!insertmacro Func_UAC_PostInitAndReadShellGlobals"
!macro Func_UAC_PostInitAndReadShellGlobals un
Function ${un}UAC_PostInitAndReadShellGlobals
  ${PushStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9

  ${DebugStackEnterFrame} `${un}UAC_PostInitAndReadShellGlobals` 1 0

  !insertmacro UAC_AsUser_Call Function ${un}PostInitUserWin32 0

  !insertmacro UAC_AsUser_GetGlobalVar $APPDATA_CURRENT
  !insertmacro UAC_AsUser_GetGlobalVar $APPDATA_ALL
  !insertmacro UAC_AsUser_GetGlobalVar $APPDATA_LOCAL_CURRENT

  !insertmacro UAC_AsUser_GetGlobalVar $DESKTOP_CURRENT
  !insertmacro UAC_AsUser_GetGlobalVar $DESKTOP_ALL

  !insertmacro UAC_AsUser_GetGlobalVar $SMPROGRAMS_CURRENT
  !insertmacro UAC_AsUser_GetGlobalVar $SMPROGRAMS_ALL

  ${DebugStackExitFrame} `${un}UAC_PostInitAndReadShellGlobals` 1 0

  ${PopStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
FunctionEnd
!macroend

!define Include_UAC "!insertmacro Include_UAC"
!macro Include_UAC prefix
${Func_UAC_RunElevation} "${prefix}"
${Func_PreInitUserWin32} "${prefix}"
${Func_UAC_PreInit} "${prefix}"
${Func_PostInitUserWin32} "${prefix}"
${Func_UAC_PostInitAndReadShellGlobals} "${prefix}"
${Include_Win32Registry} "${prefix}"
!macroend

!define UAC_RunElevation "!insertmacro Call_UAC_RunElevation ''"
!define un.UAC_RunElevation "!insertmacro Call_UAC_RunElevation 'un.'"

!define Call_UAC_RunElevation "!insertmacro Call_UAC_RunElevation"
!macro Call_UAC_RunElevation prefix
${DebugStackEnterFrame} Call_UAC_RunElevation 0 1

Call ${prefix}UAC_RunElevation

${DebugStackExitFrame} Call_UAC_RunElevation 0 1
!macroend

!define Func_UAC_RunElevation "!insertmacro Func_UAC_RunElevation"
!macro Func_UAC_RunElevation un
Function ${un}UAC_RunElevation
  ${PushStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9

  ${DebugStackEnterFrame} `${un}UAC_RunElevation` 1 0

  StrCpy $UAC_PROCESS_ELEVATION_STATUS_FLAGS 0

  uac_tryagain:
  !insertmacro UAC_RunElevated
  ${Switch} $0
  ${Case} 0
    ${If} $1 = 1 ; we are the outer process, the inner process has done its work, we are done
      SetErrorLevel $2 ; set forked process exit code for outer process
      ${!Exit}
      ${Break} ; just in case
    ${EndIf}
    ${If} $3 <> 0 ; we are admin, let the show go on
      SetErrorLevel 0 ; set success exit code for outer process
      ${Break}
    ${EndIf}
    ${If} $1 = 3 ; RunAs completed successfully, but with a non-admin user
      MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "This installer requires admin privileges, try again" /SD IDNO IDYES uac_tryagain IDNO 0
    ${EndIf}
    ;fall-through and die
  ${Case} 1223
    MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "This installer requires admin privileges, aborting!" /SD IDOK
    SetErrorLevel 1223
    ${!Abort}
    ${Break} ; just in case
  ${Case} 1062
    MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "Logon service is not running, aborting!" /SD IDOK
    SetErrorLevel 1062
    ${!Abort}
    ${Break} ; just in case
  ${Default}
    MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "Unable to elevate setup process, error $0" /SD IDOK
    SetErrorLevel $0
    ${!Abort}
    ${Break} ; just in case
  ${EndSwitch}

  ${Call_UAC_PreInit} "${un}"

  ${DebugStackExitFrame} `${un}UAC_RunElevation` 1 0

  ${PopStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
FunctionEnd
!macroend

; *before* the SendMessage call
!define GUIWindowProcBeginMarkerFrame "!insertmacro GUIWindowProcBeginMarkerFrame"
!macro GUIWindowProcBeginMarkerFrame code_id frame_id
${DebugStackPushMarkerFrame} ${code_id} ${frame_id} ${WNDPROCID_STR_PREFIX} ; Push to main stack
!macroend

; *after* the SendMessage call
!define GUIWindowProcEndMarkerFrame "!insertmacro GUIWindowProcEndMarkerFrame"
!macro GUIWindowProcEndMarkerFrame code_id frame_id
${If} $PLUGINS_UNLOADED = 0 ; plugins not unloaded yet, can request debug check
  ${DebugStackRestoreMainStackByMarkerFrame} ${code_id} ${frame_id} $WNDPROC_STACK_HANDLE 4 "" ${WNDPROCID_STR_PREFIX} ; maximum 4 pushes to main stack for a window procedure handler
${EndIf}
!macroend

; *before* the nsDialog::Show call
!define GUIDialogsShowBeginMarkerFrame "!insertmacro GUIDialogsShowBeginMarkerFrame"
!macro GUIDialogsShowBeginMarkerFrame code_id frame_id
${DebugStackPushMarkerFrame} ${code_id} ${frame_id} ${DLGSHOWID_STR_PREFIX} ; Push to main stack
!macroend

; *after* the nsDialog::Show call
!define GUIDialogsShowEndMarkerFrame "!insertmacro GUIDialogsShowEndMarkerFrame"
!macro GUIDialogsShowEndMarkerFrame code_id frame_id
${If} $PLUGINS_UNLOADED = 0 ; plugins not unloaded yet, can request debug check
  ${DebugStackRestoreMainStackByMarkerFrame} ${code_id} ${frame_id} $WNDPROC_STACK_HANDLE 4 "" ${DLGSHOWID_STR_PREFIX} ; maximum 4 pushes to main stack for the nsDialogs::Show builtin window procedure handler
${EndIf}
!macroend

; inside Window Procedure *before* handling code
!define GUIWindowProcEnterMarkerFrame "!insertmacro GUIWindowProcEnterMarkerFrame"
!macro GUIWindowProcEnterMarkerFrame code_id
System::Store Ss ; save all registers in the system stack

StrCpy $R0 0 ; window handle
StrCpy $R1 0 ; window message id
StrCpy $R2 "" ; wparam
StrCpy $R3 "" ; lparam
; always try to extract maximum of 4 elements before the marker, otherwise restore all of them back to the stack
${DebugStackRestoreMainStackByMarkerFrame} ${code_id} 0 $WNDPROC_STACK_HANDLE 4 "$R0|$R1|$R2|$R3" ${WNDPROCID_STR_PREFIX}
${DebugStackEnterFunction} ${code_id}
!macroend

; inside Window Procedure *after* handling code
!define GUIWindowProcExitMarkerFrame "!insertmacro GUIWindowProcExitMarkerFrame"
!macro GUIWindowProcExitMarkerFrame code_id
${DebugStackExitFunction} ${code_id}

System::Store lL ; restore all registers from the system stack
!macroend

!define GUISendMessage "!insertmacro GUISendMessage"
!macro GUISendMessage hwnd msg wparam lparam
${GUIWindowProcBeginMarkerFrame} GUISendMessage 0

SendMessage ${hwnd} ${msg} "${wparam}" "${lparam}"

${GUIWindowProcEndMarkerFrame} GUISendMessage 0
!macroend

!define GUISendMessageVar "!insertmacro GUISendMessageVar"
!macro GUISendMessageVar hwnd msg wparam lparam var
${GUIWindowProcBeginMarkerFrame} GUISendMessageVar 0

SendMessage ${hwnd} ${msg} "${wparam}" "${lparam}" ${var}

${GUIWindowProcEndMarkerFrame} GUISendMessageVar 0
!macroend

!define SelectListViewRow "!insertmacro SelectListViewRow"
!macro SelectListViewRow handle row_index
${DebugStackEnterFrame} SelectListViewRow 0 1

${Push} ${handle}
${Push} ${row_index}
Call SelectListViewRow

${DebugStackExitFrame} SelectListViewRow 0 1
!macroend

Function SelectListViewRow
  ${ExchStack2} $R1 $R0
  ; $R0 - handle
  ; $R1 - row_index
  ${PushStack2} $R2 $R3

  ${DebugStackEnterFrame} SelectListViewRow 1 0

  ;typedef struct {
  ;  UINT   mask;
  ;  int    iItem;
  ;  int    iSubItem;
  ;  UINT   state;
  ;  UINT   stateMask;
  ;  LPTSTR pszText;
  ;  int    cchTextMax;
  ;  int    iImage;
  ;  LPARAM lParam;
  ;#if (_WIN32_IE >= 0x0300)
  ;  int    iIndent;
  ;#endif 
  ;#if (_WIN32_WINNT >= 0x0501)
  ;  int    iGroupId;
  ;  UINT   cColumns;
  ;  PUINT  puColumns;
  ;#endif 
  ;#if (_WIN32_WINNT >= 0x0600)
  ;  int    *piColFmt;
  ;  int    iGroup;
  ;#endif 
  ;} LVITEM, *LPLVITEM;

  ; select first row
  System::Alloc 64
  ${Pop} $R2
  IntOp $R3 ${LVIS_FOCUSED} + 0
  IntOp $R3 $R3 | ${LVIS_SELECTED}
  System::Call "*$R2(i,i,i,i,i) (${LVIF_STATE}, $R1, 0, $R3, $R3)"
  ${GUISendMessage} $R0 ${LVM_SETITEMSTATE} $R1 $R2
  ${SystemFree} $R2
  #System::Call user32::InvalidateRect(p,p,i)i ($R0, 0, 1)"
  
  ${DebugStackExitFrame} SelectListViewRow 1 0

  ${PopStack4} $R0 $R1 $R2 $R3
FunctionEnd

!define RegGetKeyMap "!insertmacro RegGetKeyMap"
!macro RegGetKeyMap var value
  ${Switch} ${value}
    ${Case} "HKCR"
      StrCpy ${var} ${HKEY_CLASSES_ROOT}
    ${Break}
    ${Case} "HKCU"
      StrCpy ${var} ${HKEY_CURRENT_USER}
    ${Break}
    ${Case} "HKLM"
      StrCpy ${var} ${HKEY_LOCAL_MACHINE}
    ${Break}
    ${Case} "HKU"
      StrCpy ${var} ${HKEY_USERS}
    ${Break}
    ${Case} "HKPD"
      StrCpy ${var} ${HKEY_PERFORMANCE_DATA}
    ${Break}
    ${Case} "HKDD"
      StrCpy ${var} ${HKEY_DYN_DATA}
    ${Break}
    ${Case} "HKCC"
      StrCpy ${var} ${HKEY_CURRENT_CONFIG}
    ${Break}
    ${Case} "HKEY_CLASSES_ROOT"
      StrCpy ${var} ${HKEY_CLASSES_ROOT}
    ${Break}
    ${Case} "HKEY_CURRENT_USER"
      StrCpy ${var} ${HKEY_CURRENT_USER}
    ${Break}
    ${Case} "HKEY_LOCAL_MACHINE"
      StrCpy ${var} ${HKEY_LOCAL_MACHINE}
    ${Break}
    ${Case} "HKEY_USERS"
      StrCpy ${var} ${HKEY_USERS}
    ${Break}
    ${Case} "HKEY_PERFORMANCE_DATA"
      StrCpy ${var} ${HKEY_PERFORMANCE_DATA}
    ${Break}
    ${Case} "HKEY_DYN_DATA"
      StrCpy ${var} ${HKEY_DYN_DATA}
    ${Break}
    ${Case} "HKEY_CURRENT_CONFIG"
      StrCpy ${var} ${HKEY_CURRENT_CONFIG}
    ${Break}
    ${Default}
      StrCpy ${var} ${HKEY_CURRENT_USER}
    ${Break}
  ${EndSwitch}
!macroend

!define RegGetValueTypeMap "!insertmacro RegGetValueTypeMap"
!macro RegGetValueTypeMap var type
  ${Switch} ${type}
    ${Case} "${REG_NONE}"
      StrCpy ${var} "REG_NONE"
    ${Break}
    ${Case} "${REG_SZ}"
      StrCpy ${var} "REG_SZ"
    ${Break}
    ${Case} "${REG_EXPAND_SZ}"
      StrCpy ${var} "REG_EXPAND_SZ"
    ${Break}
    ${Case} "${REG_BINARY}"
      StrCpy ${var} "REG_BINARY"
    ${Break}
    ${Case} "${REG_DWORD}"
      StrCpy ${var} "REG_DWORD"
    ${Break}
    ${Case} "${REG_DWORD_LITTLE_ENDIAN}"
      StrCpy ${var} "REG_DWORD_LITTLE_ENDIAN"
    ${Break}
    ${Case} "${REG_DWORD_BIG_ENDIAN}"
      StrCpy ${var} "REG_DWORD_BIG_ENDIAN"
    ${Break}
    ${Case} "${REG_LINK}"
      StrCpy ${var} "REG_LINK"
    ${Break}
    ${Case} "${REG_MULTI_SZ}"
      StrCpy ${var} "REG_MULTI_SZ"
    ${Break}
    ${Default}
      StrCpy ${var} ""
    ${Break}
  ${EndSwitch}
!macroend

!define RegCallSysFuncPred "!insertmacro RegCallSysFuncPred"
!macro RegCallSysFuncPred hive_name func_name func_arg_0 func_args_N
  ${DebugStackEnterFrame} RegCallSysFuncPred 0 0

  ClearErrors ; drop errors flag

  ${Switch} "${hive_name}"
    ${Case} "HKCR"
      ${func_name} ${func_arg_0} HKCR ${func_args_N}
    ${Break}
    ${Case} "HKLM"
      ${func_name} ${func_arg_0} HKLM ${func_args_N}
    ${Break}
    ${Case} "HKCU"
      ${func_name} ${func_arg_0} HKCU ${func_args_N}
    ${Break}
    ${Case} "HKU"
      ${func_name} ${func_arg_0} HKU ${func_args_N}
    ${Break}
    ${Case} "HKCC"
      ${func_name} ${func_arg_0} HKCC ${func_args_N}
    ${Break}
    ${Case} "HKDD"
      ${func_name} ${func_arg_0} HKDD ${func_args_N}
    ${Break}
    ${Case} "HKPD"
      ${func_name} ${func_arg_0} HKPD ${func_args_N}
    ${Break}
    ${Case} "SHCTX"
      ${func_name} ${func_arg_0} SHCTX ${func_args_N}
    ${Break}
    ; Default must always exist, because func_name may return variables!
    ${Default}
      ${func_name} ${func_arg_0} HKCU ${func_args_N}
    ${Break}
  ${EndSwitch}

  ${DebugStackExitFrame} RegCallSysFuncPred 0 0
!macroend

!define IfRegHiveIsUserProfiled "!insertmacro IfRegHiveIsUserProfiled"
!macro IfRegHiveIsUserProfiled hive_name
!define __IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__ ${__LINE__}
${If} "${hive_name}" != "HKCU"
#${AndIf} "${hive_name}" != "..."
  Goto __IfRegHiveIsUserProfiled_FALSE_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}
${EndIf}
!macroend

!define ElseIfRegHiveIsUserProfiled "!insertmacro ElseIfRegHiveIsUserProfiled"
!macro ElseIfRegHiveIsUserProfiled
!define __IfRegHiveIsUserProfiled_ELSE_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}
Goto __IfRegHiveIsUserProfiled_END_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}
__IfRegHiveIsUserProfiled_FALSE_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}:
!macroend

!define EndIfRegHiveIsUserProfiled "!insertmacro EndIfRegHiveIsUserProfiled"
!macro EndIfRegHiveIsUserProfiled
!ifdef __IfRegHiveIsUserProfiled_ELSE_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}
!undef __IfRegHiveIsUserProfiled_ELSE_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}
__IfRegHiveIsUserProfiled_END_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}:
!else
__IfRegHiveIsUserProfiled_FALSE_${__IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__}:
!endif
!undef __IfRegHiveIsUserProfiled_CURRENT_MACRO_LINE__
!macroend

!define IfRegHiveIsNotUserProfiled "!insertmacro IfRegHiveIsNotUserProfiled"
!macro IfRegHiveIsNotUserProfiled hive_name
!define __IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__ ${__LINE__}
${If} "${hive_name}" == "HKCU"
#${OrIf} "${hive_name}" == "..."
  Goto __IfRegHiveIsUserProfiled_TRUE_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}
${EndIf}
!macroend

!define ElseIfRegHiveIsNotUserProfiled "!insertmacro ElseIfRegHiveIsNotUserProfiled"
!macro ElseIfRegHiveIsNotUserProfiled
!define __IfRegHiveIsNotUserProfiled_ELSE_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}
Goto __IfRegHiveIsNotUserProfiled_END_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}
__IfRegHiveIsUserProfiled_TRUE_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}:
!macroend

!define EndIfRegHiveIsNotUserProfiled "!insertmacro EndIfRegHiveIsNotUserProfiled"
!macro EndIfRegHiveIsNotUserProfiled
!ifdef __IfRegHiveIsNotUserProfiled_ELSE_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}
!undef __IfRegHiveIsNotUserProfiled_ELSE_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}
__IfRegHiveIsNotUserProfiled_END_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}:
!else
__IfRegHiveIsUserProfiled_TRUE_${__IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__}:
!endif
!undef __IfRegHiveIsNotUserProfiled_CURRENT_MACRO_LINE__
!macroend

; Usage:
; All users:
;   ${Push} "HKLM"
;   ${Push} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
;   ${Push} "<var_name>"
;   Call RegReadToAllocValue
;   ${Pop} "<value_type>"
;   ${Pop} "<value_addr>"
;   ${Pop} "<value_size>"
; Current user only:
;   ${Push} "HKCU"
;   ${Push} "Environment"
;   ${Push} "<var_name>"
;   Call RegReadToAllocValue
;   ${Pop} "<value_type>"
;   ${Pop} "<value_addr>"
;   ${Pop} "<value_size>"
!macro Func_RegReadToAllocValue un
Function ${un}RegReadToAllocValue
  ${ExchStack3} $R0 $R1 $R2

  ${PushStack7} $R3 $R4 $R5 $R6 $R7 $R8 $0

  ; handles and pointers init
  StrCpy $R5 0
  StrCpy $R7 0
  StrCpy $0 0

  ; keys map
  ${RegGetKeyMap} $R3 $R0

  System::Call "advapi32::RegOpenKey(i R3, t R1, *i.R6) i.R4"
  ${If} $R4 <> 0
    DetailPrint "RegReadToAllocValue: advapi32::RegOpenKey error: code=$R4 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\""
    MessageBox MB_OK "RegReadToAllocValue: advapi32::RegOpenKey error: code=$R4 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\"" /SD IDOK
    Goto exit
  ${EndIf}

  System::Call "advapi32::RegQueryValueEx(i R6, t R2, i 0, *i .R5, p 0, *i 0 R7) i.R4"
  ${If} $R4 <> 0
    DetailPrint "RegReadToAllocValue: advapi32::RegQueryValueEx (1) error: code=$R4 size=$R7 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\""
    MessageBox MB_OK "RegReadToAllocValue: advapi32::RegQueryValueEx (1) error: code=$R4 size=$R7 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\"" /SD IDOK
    Goto exit
  ${EndIf}

  StrCpy $R8 $R7

  ; allocate dynamic buffer
  System::Alloc $R8
  Pop $0
  ${If} $0 = 0
    DetailPrint "RegReadToAllocValue: System::Alloc (1) error: size=$R8 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\""
    MessageBox MB_OK "RegReadToAllocValue: System::Alloc (1) error: size=$R8 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\"" /SD IDOK
    Goto exit
  ${EndIf}

  System::Call "advapi32::RegQueryValueEx(i R6, t R2, i 0, i 0, p r0, *i R8 R7) i.R4"
  ${If} $R4 <> 0
    DetailPrint "RegReadToAllocValue: advapi32::RegQueryValueEx (2) error: code=$R4 size=$R7 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\""
    MessageBox MB_OK "RegReadToAllocValue: advapi32::RegQueryValueEx (2) error: code=$R4 size=$R7 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\"" /SD IDOK
    Goto exit
  ${EndIf}

exit:
  System::Call "advapi32::RegCloseKey(i $R6)"

  ${PushStack3} $R5 $0 $R7
  ${ExchStackStack3} 7

  ${PopStack10} $R3 $R4 $R5 $R6 $R7 $R8 $0 $R0 $R1 $R2
FunctionEnd
!macroend

!define RegReadToAllocValue "!insertmacro RegReadToAllocValue"
!macro RegReadToAllocValue hkey hkey_path var_name value_size_var value_addr_var value_type_var
${PushStack3} `${hkey}` `${hkey_path}` `${var_name}`
!ifndef __UNINSTALL__
Call RegReadToAllocValue
!else
Call un.RegReadToAllocValue
!endif
${PopStack3} `${value_type_var}` `${value_addr_var}` `${value_size_var}`
!macroend

!define Include_RegReadToAllocValue "!insertmacro Include_RegReadToAllocValue"
!macro Include_RegReadToAllocValue un
!ifndef ${un}RegReadToAllocValue_INCLUDED
!define ${un}RegReadToAllocValue_INCLUDED
!insertmacro Func_RegReadToAllocValue "${un}"
!endif
!macroend

; Usage:
; All users:
;   ${Push} "HKLM"
;   ${Push} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
;   ${Push} "<var_name>"
;   ${Push} "<value_size>"
;   ${Push} "<value_addr>"
;   ${Push} "<value_type>"
;   Call RegSetAllocValue
; Current user only:
;   ${Push} "HKCU"
;   ${Push} "Environment"
;   ${Push} "<var_name>"
;   ${Push} "<value_size>"
;   ${Push} "<value_addr>"
;   ${Push} "<value_type>"
;   Call RegSetAllocValue
!macro Func_RegSetAllocValue un
Function ${un}RegSetAllocValue
  ${ExchStack6} $R0 $R1 $R2 $R3 $R4 $R5

  ${PushStack3} $R6 $R8 $R9

  ; keys map
  ${RegGetKeyMap} $R8 $R0

  System::Call "advapi32::RegOpenKey(i R8, t R1, *i.R6) i.R9"
  ${If} $R9 <> 0
    DetailPrint "RegSetAllocValue: advapi32::RegOpenKey error: code=$R9 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\""
    MessageBox MB_OK "RegSetAllocValue: advapi32::RegOpenKey error: code=$R9 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ${If} $R4 <> 0
    System::Call "advapi32::RegSetValueEx(i R6, t R2, i 0, i R5, p R4, i R3) i.R9"
  ${ElseIf} $R3 = 1 ; to clear the key in case of null address the size must be 1
    System::Call "advapi32::RegSetValueEx(i R6, t R2, i 0, i R5, t '', i ${NSIS_CHAR_SIZE}) i.R9"
  ${EndIf}
  ${If} $R9 <> 0
    DetailPrint "RegSetAllocValue: advapi32::RegSetValueEx error: code=$R9 size=$R3 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\""
    MessageBox MB_OK "RegSetAllocValue: advapi32::RegSetValueEx error: code=$R9 size=$R3 var=$\"$R2$\" hive=$\"$R0$\" key=$\"$R1$\"" /SD IDOK
    Goto exit
  ${EndIf}

exit:
  System::Call "advapi32::RegCloseKey(i $R6)"

  ${PopStack9} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R8 $R9
FunctionEnd
!macroend

!define RegSetAllocValue "!insertmacro RegSetAllocValue"
!macro RegSetAllocValue hkey hkey_path var_name value_size value_addr value_type
${PushStack6} `${hkey}` `${hkey_path}` `${var_name}` `${value_size}` `${value_addr}` `${value_type}`
!ifndef __UNINSTALL__
Call RegSetAllocValue
!else
Call un.RegSetAllocValue
!endif
!macroend

!define Include_RegSetAllocValue "!insertmacro Include_RegSetAllocValue"
!macro Include_RegSetAllocValue un
!ifndef ${un}RegSetAllocValue_INCLUDED
!define ${un}RegSetAllocValue_INCLUDED
!insertmacro Func_RegSetAllocValue "${un}"
!endif
!macroend

; Usage:
; All users:
;   ${Push} "<path>"
;   ${Push} "HKLM"
;   ${Push} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
;   ${Push} "<env_var>"
;   Call RegAddPathToVar
; Current user only:
;   ${Push} "<path>"
;   ${Push} "HKCU"
;   ${Push} "Environment"
;   ${Push} "<env_var>"
;   Call RegAddPathToVar
!macro Func_RegAddPathToVar un
Function ${un}RegAddPathToVar
  ${ExchStack4} $R0 $R1 $R2 $R3

  ${PushStack11} $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $8 $9

  ; WARNING:
  ;   NSIS ReadRegStr returns empty string on string overflow, so native calls are used here:
  ;   1. To check actual length of <env_var>.
  ;   2. To process the PATH variable of any length long.

  ; The IDEAL algorithm for any length long PATH variable, where each subpath and function paramaters is not longer than ${NSIS_MAX_STRLEN}-${NSIS_CHAR_SIZE} bytes:
  ;   1. Init current string list if does not have any before or take as current has created after the previous algorithm run.
  ;   2. Read string of ${NSIS_MAX_STRLEN}-${NSIS_CHAR_SIZE} bytes length into the array of ${NSIS_MAX_STRLEN} bytes length from the input address, add NSIS_CHAR_SIZE null at the end.
  ;   3. Go to 20 if empty or nothing else except the ; characters in the array.
  ;   4. Truncate all in the array after the last ; character, where the ; character has found not under " character quoted string (see description in the 6).
  ;   5. Split strings in the array by the ; character if it has found not under " character quoted string into the list.
  ;   6. Move the last string from the list into the next repeat cycle list if it begins by the " character but not ends by the same character (not completely fitted into the limited to ${NSIS_MAX_STRLEN} bytes window).
  ;   7. Unquote all strings in the list and create the second list with flags marked where the quotes has removed.
  ;   8. Search for "$R0" or "$R0\" in the list, if found then raise a flag and leave the algorithm.
  ;   9. Move ${NSIS_MAX_STRLEN} byte window by the array current string length long multiple to NSIS_CHAR_SIZE value along the input address.
  ;  10. Repeat the algorithm.
  ;  20. Append path to the list.
  ;  21. Restore quotes for those strings in the first list what been quoted before by the second list.
  ;  22. Join first list by the separator into one string.

  ; The REAL algorithm for any length long PATH variable, where each subpath and function paramaters is not longer than ${NSIS_MAX_STRLEN}-${NSIS_CHAR_SIZE} bytes:
  ;   1. Read string from registry into dynamic buffer enough to store more characters: length of being searched string + length of separator + length of string to search + length of null character.
  ;   2. Copy string from the buffer to the second dynamic buffer enough to store more characters: length of separator + length of being searched string + length of separator + length of null character.
  ;   3. Prepend and append separator character to second buffer.
  ;   4. Try to find multiple instances of the string to search in the second buffer through the shlwapi::StrStrI, where search instances are:
  ;      `<Separator><StringToSearch><Separator>'
  ;      `<Separator><StringToSearch>\<Separator>'
  ;   5. If found any instance then leave the algorithm.
  ;   6. Append separator character to the first buffer if it does not ending by it.
  ;   7. Append the string to search to the first buffer.

  ; handles and pointers init
  StrCpy $R7 0
  StrCpy $R9 0
  StrCpy $0 0
  StrCpy $1 0
  StrCpy $2 0

  ; keys map
  ${RegGetKeyMap} $R8 $R1

  System::Call "advapi32::RegOpenKey(i R8, t R2, *i.R6) i.R4"
  ${If} $R4 <> 0
    DetailPrint "RegAddPathToVar: advapi32::RegOpenKey error: code=$R4 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: advapi32::RegOpenKey error: code=$R4 hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  System::Call "advapi32::RegQueryValueEx(i R6, t R3, i 0, *i .r9, p 0, *i 0 R7) i.R4"
  ${If} $R4 <> 0
    DetailPrint "RegAddPathToVar: advapi32::RegQueryValueEx (1) error: code=$R4 size=$R7 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: advapi32::RegQueryValueEx (1) error: code=$R4 size=$R7 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ; trim trailing "\" character from the string to search
  ${TrimTrailingChars} $R0 $R0 "\"

  StrLen $R8 $R0
  ; first buffer: length of being searched string + length of separator + length of string to search + length of null character
  IntOp $R5 $R8 + 1 ; ";"
  IntOp $R5 $R5 * ${NSIS_CHAR_SIZE}
  IntOp $R5 $R5 + $R7 ; already in bytes including null character

  ; allocate first dynamic buffer
  System::Alloc $R5
  Pop $0
  ${If} $0 = 0
    DetailPrint "RegAddPathToVar: System::Alloc (1) error: size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: System::Alloc (1) error: size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  System::Call "advapi32::RegQueryValueEx(i R6, t R3, i 0, i 0, p r0, *i R5 R7) i.R4"
  ${If} $R4 <> 0
    DetailPrint "RegAddPathToVar: advapi32::RegQueryValueEx (2) error: code=$R4 size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: advapi32::RegQueryValueEx (2) error: code=$R4 size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ; strip separator characters from the first buffer end
  ${If} $R7 > ${NSIS_CHAR_SIZE}
    ; excluding null character
    IntOp $R5 $R7 - ${NSIS_CHAR_SIZE}
    IntOp $R5 $R5 - ${NSIS_CHAR_SIZE}
    IntOp $R9 $0 + $R5
strip_loop1:
    System::Call "*$R9(&t1 .r8)"
    ${If} $8 == ";"
      System::Call "*$R9(&t1 '')" ; null character
      IntOp $R7 $R7 - ${NSIS_CHAR_SIZE}
      ${If} $R9 >= ${NSIS_CHAR_SIZE}
        IntOp $R9 $R9 - ${NSIS_CHAR_SIZE}
        Goto strip_loop1
      ${EndIf}
    ${EndIf}
  ${EndIf}

  ${If} $R7 <= ${NSIS_CHAR_SIZE}
    Goto empty
  ${EndIf}

  ; second buffer: length of separator + length of being searched string + length of separator + length of null character
  IntOp $R5 2 * ${NSIS_CHAR_SIZE} ; 2 x ";"
  IntOp $R5 $R5 + $R7 ; already in bytes including null character

  ; allocate second dynamic buffer
  System::Alloc $R5
  Pop $1
  ${If} $1 = 0
    DetailPrint "RegAddPathToVar: System::Alloc (2) error: size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: System::Alloc (2) error: size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  System::Call "*$1(&t1 ';')"

  IntOp $R9 $1 + ${NSIS_CHAR_SIZE}
  System::Call "kernel32::lstrcpyn(p R9, p r0, i R7) p.R4"
  ${If} $R4 = 0
    DetailPrint "RegAddPathToVar: kernel32::lstrcpyn (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: kernel32::lstrcpyn (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  IntOp $R9 $R9 + $R7
  IntOp $R9 $R9 - ${NSIS_CHAR_SIZE} ; exclude last null character
  System::Call "*$R9(&t1 ';')"
  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE}
  System::Call "*$R9(&t1 '')" ; null character

  ; buffer for the string to search
  IntOp $R5 0 + 4 ; 2 x ";" + "\" + length of null character
  IntOp $R5 $R5 + $R8 ; excluding null character
  IntOp $R5 $R5 * ${NSIS_CHAR_SIZE}

  System::Alloc $R5
  Pop $2
  ${If} $2 = 0
    DetailPrint "RegAddPathToVar: System::Alloc (3) error: size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: System::Alloc (3) error: size=$R5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ; convert R8 (length of R0) to bytes
  IntOp $R8 $R8 * ${NSIS_CHAR_SIZE}

  ; `<Separator><StringToSearch><Separator>'
  System::Call "*$2(&t1 ';')"

  IntOp $R9 $2 + ${NSIS_CHAR_SIZE}
  System::Call "kernel32::lstrcpy(p R9, t R0) p.R4"
  ${If} $R4 = 0
    DetailPrint "RegAddPathToVar: kernel32::lstrcpy (2) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: kernel32::lstrcpy (2) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  IntOp $R9 $R9 + $R8 ; length does not include the last null character
  System::Call "*$R9(&t1 ';')"
  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE}
  System::Call "*$R9(&t1 '')" ; null character

  System::Call "shlwapi::StrStrI(p r1, p r2) p.R4"
  ${GotoIf} exit "$R4 <> 0"

  ; `<Separator><StringToSearch>\<Separator>'
  System::Call "*$2(&t1 ';')"

  IntOp $R9 $2 + ${NSIS_CHAR_SIZE}
  IntOp $R9 $R9 + $R8
  System::Call "*$R9(&t1 '\')"
  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE}
  System::Call "*$R9(&t1 ';')"
  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE}
  System::Call "*$R9(&t1 '')" ; null character

  System::Call "shlwapi::StrStrI(p r1, p r2) p.R4"
  ${GotoIf} exit "$R4 <> 0"

empty:
  ; append to the first buffer
  IntOp $R9 0 + $0
  ${If} $R7 > ${NSIS_CHAR_SIZE}
    IntOp $R9 $R9 + $R7
    IntOp $R9 $R9 - ${NSIS_CHAR_SIZE} ; exclude last null character
    System::Call "*$R9(&t1 ';')"
    IntOp $R9 $R9 + ${NSIS_CHAR_SIZE}
  ${EndIf}

  System::Call "kernel32::lstrcpy(p R9, t R0) p.R4"
  ${If} $R4 = 0
    DetailPrint "RegAddPathToVar: kernel32::lstrcpy (3) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: kernel32::lstrcpy (3) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  IntOp $R9 $R9 + $R8 ; length does not include the last null character
  System::Call "*$R9(&t1 '')" ; null character

  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE}
  IntOp $R5 $R9 - $0

  System::Call "advapi32::RegSetValueEx(i R6, t R3, i 0, i r9, p r0, i R5) i.R4"
  ${If} $R4 <> 0
    DetailPrint "RegAddPathToVar: advapi32::RegSetValueEx (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegAddPathToVar: advapi32::RegSetValueEx (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ; broadcast global event
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

exit:
  System::Call "advapi32::RegCloseKey(i $R6)"

  ${SystemFree} $0
  ${SystemFree} $1
  ${SystemFree} $2

  ${PopStack15} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $8 $9
FunctionEnd
!macroend

!define RegAddPathToVar "!insertmacro RegAddPathToVar"
!macro RegAddPathToVar path hkey hkey_path env_var
Push `${path}`
Push `${hkey}`
Push `${hkey_path}`
Push `${env_var}`
!ifndef __UNINSTALL__
Call RegAddPathToVar
!else
Call un.RegAddPathToVar
!endif
!macroend

!define Include_RegAddPathToVar "!insertmacro Include_RegAddPathToVar"
!macro Include_RegAddPathToVar un
!ifndef ${un}RegAddPathToVar_INCLUDED
!define ${un}RegAddPathToVar_INCLUDED
!insertmacro Func_RegAddPathToVar "${un}"
!endif
!macroend

; Usage:
; All users:
;   ${Push} "<file1> [ | <file2> [... | <fileN>]]"
;   ${Push} "HKLM"
;   ${Push} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
;   ${Push} "<env_var>"
;   ${Push} "<IncludePath1> [ | <IncludePath2> [... | <IncludePathN>]]"
;   ${Push} "<ExcludePath1> [ | <ExcludePath2> [... | <ExcludePathN>]]"
;   Call RegRemovePathFromVar
; Current user only:
;   ${Push} "<file1> [ | <file2> [... | <fileN>]]"
;   ${Push} "HKCU"
;   ${Push} "Environment"
;   ${Push} "<env_var>"
;   ${Push} "<IncludePath1> [ | <IncludePath2> [... | <IncludePathN>]]"
;   ${Push} "<ExcludePath1> [ | <ExcludePath2> [... | <ExcludePathN>]]"
;   Call RegRemovePathFromVar
!macro Func_RegRemovePathFromVar un
Var /GLOBAL RegRemovePathFromVar_Locate_OnFound_Var

Function ${un}RegRemovePathFromVar
  ${ExchStack6} $R0 $R1 $R2 $R3 $R4 $R5

  ${PushStack14} $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9

  ; WARNING:
  ;   NSIS ReadRegStr returns empty string on string overflow, so native calls are used here:
  ;   1. To check actual length of <env_var>.
  ;   2. To process the PATH variable of any length long.

  ; The algorithm for any length long PATH variable, where each subpath and function paramaters is not longer than ${NSIS_MAX_STRLEN}-${NSIS_CHAR_SIZE} bytes:
  ;   1. Read string from registry into dynamic buffer enough to store more characters: length of separator + length of being searched string + length of separator + length of null character.
  ;   2. Allocate second buffer of the same size to store half of the string from the first buffer to emulate string move in the first buffer through the kernel32::lstrcpy (does not support strings overlap) and double copy.
  ;   3. Prepend and append separator character to the buffer.
  ;   4. Try to find include paths (paths for unconditional remove) in the buffer through the shlwapi::StrStrI, where search instances are:
  ;      `<Separator><AnIncludePath><Separator>'
  ;      `<Separator><AnIncludePath>\<Separator>'
  ;   5. If found any instance then cut it from the string in the buffer excluding the last separator.
  ;   6. Repeat 3 until end of path list in the buffer.
  ;   7. Search the buffer again for files from the list where the variable paths does not begin by exclude paths.
  ;   8. If found any of file from the list then cut entire directory path from the string in the buffer.
  ;   9. Repeat 6 until end of path list in the buffer.

  ; handles and pointers init
  StrCpy $R7 0
  StrCpy $R9 0
  StrCpy $0 0
  StrCpy $1 0

  ; keys map
  ${RegGetKeyMap} $R8 $R1

  System::Call "advapi32::RegOpenKey(i R8, t R2, *i.R6) i.R9"
  ${If} $R9 <> 0
    DetailPrint "RegRemovePathFromVar: advapi32::RegOpenKey error: code=$R9 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegRemovePathFromVar: advapi32::RegOpenKey error: code=$R9 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  System::Call "advapi32::RegQueryValueEx(i R6, t R3, i 0, *i .r9, p 0, *i 0 R7) i.R9"
  ${If} $R9 <> 0
    DetailPrint "RegRemovePathFromVar: advapi32::RegQueryValueEx (1) error: code=$R9 size=$R7 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegRemovePathFromVar: advapi32::RegQueryValueEx (1) error: code=$R9 size=$R7 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ${If} $R7 <= ${NSIS_CHAR_SIZE}
    Goto exit ; nothing to remove
  ${EndIf}

  ; first buffer: length of separator + length of being searched string + length of separator + length of null character
  IntOp $5 0 + 2 ; 2 x ";"
  IntOp $5 $5 * ${NSIS_CHAR_SIZE}
  IntOp $5 $5 + $R7 ; already in bytes including null character

  ; allocate first dynamic buffer
  System::Alloc $5
  Pop $0
  ${If} $0 = 0
    DetailPrint "RegRemovePathFromVar: System::Alloc (1) error: size=$5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegRemovePathFromVar: System::Alloc (1) error: size=$5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ; allocate second dynamic buffer
  System::Alloc $5
  Pop $1
  ${If} $1 = 0
    DetailPrint "RegRemovePathFromVar: System::Alloc (2) error: size=$5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegRemovePathFromVar: System::Alloc (2) error: size=$5 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ; initialize first buffer
  System::Call "*$0(&t1 ';')"
  IntOp $R9 $0 + ${NSIS_CHAR_SIZE}

  System::Call "advapi32::RegQueryValueEx(i R6, t R3, i 0, i 0, p R9, *i r5 R7) i.r4"
  ${If} $4 <> 0
    DetailPrint "RegRemovePathFromVar: advapi32::RegQueryValueEx (2) error: code=$4 size=$R7 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegRemovePathFromVar: advapi32::RegQueryValueEx (2) error: code=$4 size=$R7 var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  IntOp $R9 $R9 + $R7
  IntOp $R9 $R9 - ${NSIS_CHAR_SIZE} ; exclude last null character
  System::Call "*$R9(&t1 ';')"
  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE}
  System::Call "*$R9(&t1 '')" ; null character

  ; include paths list length
  ${WordFind} "$R4|" | "#" $2
  ${If} ${Errors}
  ${OrIf} $R4 == ""
    StrCpy $2 0
  ${EndIf}

  StrCpy $R8 0 ; the buffer has no changes

  ; process include paths list
  ${If} $2 <= 0
    Goto includes_check_end
  ${EndIf}

  ${For} $6 1 $2
    StrCpy $R9 $0

    ${WordFind} "$R4|" | +$6 $7
    ${TrimLeadingChars} $7 $7 " "
    ${TrimTrailingChars} $7 $7 " "
    ${TrimTrailingChars} $7 $7 "\"

    ${If} $7 == ""
      ${Continue}
    ${EndIf}

    StrCpy $8 ";$7;"
    System::Call "shlwapi::StrStrI(p R9, t r8) p.R9"
    ${If} $R9 <> 0
      ; cut found string excluding last separator
      StrLen $4 $8
      IntOp $4 $4 - 1

      IntOp $8 $R9 + $4

      ; string move through the double copy
      System::Call "kernel32::lstrcpy(p r1, p r8) p.r4"
      ${If} $4 = 0
        DetailPrint "RegRemovePathFromVar: kernel32::lstrcpy (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
        MessageBox MB_OK "RegRemovePathFromVar: kernel32::lstrcpy (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
        Goto exit
      ${EndIf}

      System::Call "kernel32::lstrcpy(p R9, p r1) p.r4"
      ${If} $4 = 0
        DetailPrint "RegRemovePathFromVar: kernel32::lstrcpy (2) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
        MessageBox MB_OK "RegRemovePathFromVar: kernel32::lstrcpy (2) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
        Goto exit
      ${EndIf}

      StrCpy $R8 1

      ${Continue}
    ${EndIf}

    StrCpy $8 ";$7\;"
    System::Call "shlwapi::StrStrI(p r0, t r8) p.R9"
    ${If} $R9 <> 0
      ; cut found string excluding last separator
      StrLen $4 $8
      IntOp $4 $4 - 1

      IntOp $8 $R9 + $4

      ; string move through the double copy
      System::Call "kernel32::lstrcpy(p r1, p r8) p.r4"
      ${If} $4 = 0
        DetailPrint "RegRemovePathFromVar: kernel32::lstrcpy (3) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
        MessageBox MB_OK "RegRemovePathFromVar: kernel32::lstrcpy (3) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
        Goto exit
      ${EndIf}

      System::Call "kernel32::lstrcpy(p R9, p r1) p.r4"
      ${If} $4 = 0
        DetailPrint "RegRemovePathFromVar: kernel32::lstrcpy (4) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
        MessageBox MB_OK "RegRemovePathFromVar: kernel32::lstrcpy (4) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
        Goto exit
      ${EndIf}

      StrCpy $R8 1

      ${Continue}
    ${EndIf}
  ${Next}

includes_check_end:
  ; files list length
  ${WordFind} "$R0|" | "#" $3
  ${If} ${Errors}
  ${OrIf} $R0 == ""
    StrCpy $3 0
  ${EndIf}

  IntOp $4 $2 + $3

  ${If} $4 = 0
    Goto exit ; nothing to remove
  ${EndIf}

  ${If} $3 <= 0
    Goto ready_to_update
  ${EndIf}

  ; move to free register
  StrCpy $2 $3

  ; exclude paths list length
  ${WordFind} "$R5|" | "#" $3
  ${If} ${Errors}
  ${OrIf} $R5 == ""
    StrCpy $3 0
  ${EndIf}

  ; process the variable paths list
  StrCpy $R9 $0 ; set string beginning

repeat_path_search:
  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE} ; w/o first separator character
  System::Call "shlwapi::StrStrI(p R9, t ';') p.R7" ; ignore the last separator character
  ${If} $R7 = 0
    Goto ready_to_update
  ${EndIf}
  ${If} $R9 = $R7
    Goto repeat_path_search
  ${EndIf}

  IntOp $R9 $R9 - ${NSIS_CHAR_SIZE} ; roll back

  ${If} $3 <= 0
    Goto excludes_check_end
  ${EndIf}

  ; temporary replace next separator character by the null character to enable the shlwapi::StrStrI to search the current path only
  System::Call "*$R7(&t1 '')" ; null character

  ; check current path on excludes filter
  ${For} $6 1 $3
    ${WordFind} "$R5|" | +$6 $7
    ${TrimTrailingChars} $7 $7 "\"
    ${If} $7 == ""
      ${Continue}
    ${EndIf}

    ; check if the exclude path is equal path
    StrCpy $8 ";$7"
!ifdef NSIS_UNICODE
    System::Call "shlwapi::StrCmpI(p R9, t r8) i.r5"
!else
    System::Call "shlwapi::StrCmpIC(p R9, t r8) i.r5"
!endif
    ${If} $5 = 0
      System::Call "*$R7(&t1 ';')" ; restore next separator character
      Goto next_path ; ignore search path
    ${EndIf}

    ; check if the exclude path is a prefix path
    StrCpy $8 ";$7\"
    System::Call "shlwapi::StrStrI(p R9, t r8) p.r5"
    ${If} $5 <> 0
      System::Call "*$R7(&t1 ';')" ; restore next separator character
      Goto next_path ; ignore search path
    ${EndIf}
  ${Next}

  System::Call "*$R7(&t1 ';')" ; restore next separator character

excludes_check_end:
  ${If} $2 <= 0
    Goto next_path
  ${EndIf}

  ${For} $4 1 $2
    ; search files from the list in search paths list
    ${WordFind} "$R0|" | +$4 $5
    ${If} $5 == ""
      ${Continue}
    ${EndIf}

    IntOp $R9 $R9 + ${NSIS_CHAR_SIZE} ; w/o first separator character

    IntOp $6 $R7 - $R9 ; length of the path to search in
    ${If} $6 > ${NSIS_MAX_STRLEN} ; truncation to the max
      StrCpy $6 ${NSIS_MAX_STRLEN}
    ${EndIf}
    System::Call "*$R9(&t$6 .r7)" ; read the path by pointer

    IntOp $R9 $R9 - ${NSIS_CHAR_SIZE} ; roll back

    ${TrimTrailingChars} $7 $7 "\"
    ${If} $9 = ${REG_EXPAND_SZ} ; REG_EXPAND_SZ
      ExpandEnvStrings $7 $7 ; expand %-variables in the path
    ${EndIf}

    StrCpy $RegRemovePathFromVar_Locate_OnFound_Var 0 ; not found
    ${Locate} $7 "/L=F /G=1 /M=$5" "RegRemovePathFromVar_Locate_OnFound"
    ${If} $RegRemovePathFromVar_Locate_OnFound_Var <> 0
      ; string move through the double copy
      System::Call "kernel32::lstrcpy(p r1, p R7) p.r6"
      ${If} $6 = 0
        DetailPrint "RegRemovePathFromVar: kernel32::lstrcpy (5) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
        MessageBox MB_OK "RegRemovePathFromVar: kernel32::lstrcpy (5) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
        Goto exit
      ${EndIf}

      System::Call "kernel32::lstrcpy(p R9, p r1) p.r6"
      ${If} $6 = 0
        DetailPrint "RegRemovePathFromVar: kernel32::lstrcpy (6) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
        MessageBox MB_OK "RegRemovePathFromVar: kernel32::lstrcpy (6) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
        Goto exit
      ${EndIf}

      StrCpy $R8 1
    ${EndIf}
  ${Next}

next_path:
  IntOp $R9 $R9 + ${NSIS_CHAR_SIZE} ; w/o first separator character
  System::Call "shlwapi::StrStrI(p R9, t ';') p.R7"
  ${If} $R7 <> 0
    ; ignore empty paths
    ${If} $R9 = $R7
      Goto next_path
    ${EndIf}
    StrCpy $R9 $R7
    Goto repeat_path_search
  ${EndIf}

ready_to_update:
  ${GotoIf} exit "$R8 = 0"

  IntOp $R9 $0 + ${NSIS_CHAR_SIZE} ; ignore first separator

  ; calculate length of the new path list
  System::Call "kernel32::lstrlen(p R9) i.r4"
  ${If} $4 > ${NSIS_CHAR_SIZE}
    IntOp $5 $4 - ${NSIS_CHAR_SIZE}
    IntOp $6 $R9 + $5
    System::Call "*$6(&t1 '')" ; remove the last separator
    StrCpy $4 $5
  ${EndIf}
  IntOp $4 $4 + ${NSIS_CHAR_SIZE} ; including null character

  System::Call "advapi32::RegSetValueEx(i R6, t R3, i 0, i r9, p R9, i r4) i.r6"
  ${If} $6 <> 0
    DetailPrint "RegRemovePathFromVar: advapi32::RegSetValueEx (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\""
    MessageBox MB_OK "RegRemovePathFromVar: advapi32::RegSetValueEx (1) error: var=$\"$R3$\" hive=$\"$R1$\" key=$\"$R2$\"" /SD IDOK
    Goto exit
  ${EndIf}

  ; broadcast global event
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

exit:
  System::Call "advapi32::RegCloseKey(i $R6)"

  ${SystemFree} $0
  ${SystemFree} $1

  ${PopStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
FunctionEnd

Function RegRemovePathFromVar_Locate_OnFound
  StrCpy $RegRemovePathFromVar_Locate_OnFound_Var 1
  ${Push} "StopLocate"
FunctionEnd
!macroend

!define RegRemovePathFromVar "!insertmacro RegRemovePathFromVar"
!macro RegRemovePathFromVar files_list hkey hkey_path env_var include_paths_list exclude_paths_list
Push `${files_list}`
Push `${hkey}`
Push `${hkey_path}`
Push `${env_var}`
Push `${include_paths_list}`
Push `${exclude_paths_list}`
!ifndef __UNINSTALL__
Call RegRemovePathFromVar
!else
Call un.RegRemovePathFromVar
!endif
!macroend

!define Include_RegRemovePathFromVar "!insertmacro Include_RegRemovePathFromVar"
!macro Include_RegRemovePathFromVar un
!ifndef WORDFUNC_INCLUDED
!include "WordFunc.nsh"
!insertmacro WordFind
!endif

!ifndef FILEFUNC_INCLUDED
!include "FileFunc.nsh"
!insertmacro Locate
!endif

!ifndef ${un}RegRemovePathFromVar_INCLUDED
!define ${un}RegRemovePathFromVar_INCLUDED
${Include_TrimLeadingChars} "${un}"
${Include_TrimTrailingChars} "${un}"
${Include_ExpandEnvironmentString} "${un}"
!insertmacro Func_RegRemovePathFromVar "${un}"
!endif
!macroend

; RegAddWindowsFirewallRule - Adds Windows Firewall rule directly to the registry
;   WARNING: You must restart firewall to make them applied for the firewall!
;
; Usage:
;   ${Push} "<key_name>"     ; registry key name
;   ${Push} "<version>"      ; default=v2.10
;   ${Push} "<action>"       ; Allow, Block
;   ${Push} "<active>"       ; TRUE, FALSE
;   ${Push} "<direction>"    ; In, Out
;   ${Push} "<protocol>"     ; 6=TCP, 17=UDP
;   ${Push} "<profile>"      ; 1-Domain, 2-Private, 4-Public
;   ${Push} "<app>"          ; application path
;   ${Push} "<svc>"          ; service name
;   ${Push} "<name>"         ; friendly name
;   ${Push} "<desc>"         ; description
;   ${Push} "<embed_ctx>"    ; context of call
;   Call RegAddWindowsFirewallRule
!macro Func_RegAddWindowsFirewallRule un
!ifndef ${un}RegAddWindowsFirewallRule_INCLUDED
!define ${un}RegAddWindowsFirewallRule_INCLUDED
Function ${un}RegAddWindowsFirewallRule
  ${ExchStack12} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1

  ${PushStack8} $2 $3 $4 $5 $6 $7 $8 $9

  ${DebugStackEnterFrame} `${un}RegAddWindowsFirewallRule` 1 0

  ${ReadRegStr} $5 HKLM "${WIN_FIREWALL_RULES_REGKEY}" $R0
  ; ignore if already added
  ${If} $5 != ""
    Goto Done
  ${EndIf}

  StrCpy $9 "$R1|Action=$R2|Active=$R3|Dir=$R4|Protocol=$R5|"

  ; profiles substring construction
  StrCpy $8 ""
  IntOp $7 $R6 & 0x01
  ${If} $7 <> 0
    StrCpy $8 "$8Profile=Domain|"
  ${EndIf}
  IntOp $7 $R6 & 0x02
  ${If} $7 <> 0
    StrCpy $8 "$8Profile=Private|"
  ${EndIf}
  IntOp $7 $R6 & 0x04
  ${If} $7 <> 0
    StrCpy $8 "$8Profile=Public|"
  ${EndIf}

  StrCpy $9 "$9$8"

  ${If} $R7 != ""
    StrCpy $9 "$9App=$R7|"
  ${EndIf}

  ${If} $R8 != ""
    StrCpy $9 "$9Svc=$R8|"
  ${EndIf}

  ${If} $R9 != ""
    StrCpy $9 "$9Name=$R9|"
  ${EndIf}

  ${If} $0 != ""
    StrCpy $9 "$9Desc=$0|"
  ${EndIf}

  ${If} $1 != ""
    StrCpy $9 "$9EmbedCtx=$1|"
  ${EndIf}

  ${WriteRegStr} HKLM "${WIN_FIREWALL_RULES_REGKEY}" $R0 $9

Done:
  ${DebugStackExitFrame} `${un}RegAddWindowsFirewallRule` 1 0

  ${PopStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
FunctionEnd
!endif
!macroend

!define Call_RegAddWindowsFirewallRule "!insertmacro Call_RegAddWindowsFirewallRule"
!macro Call_RegAddWindowsFirewallRule prefix key_name version action active direction protocol profile app svc name desc embed_ctx
${DebugStackEnterFrame} Call_RegAddWindowsFirewallRule 0 1

${Push} `${key_name}`
${Push} `${version}`
${Push} `${action}`
${Push} `${active}`
${Push} `${direction}`
${Push} `${protocol}`
${Push} `${profile}`
${Push} `${app}`
${Push} `${svc}`
${Push} `${name}`
${Push} `${desc}`
${Push} `${embed_ctx}`
Call ${prefix}RegAddWindowsFirewallRule

${DebugStackExitFrame} Call_RegAddWindowsFirewallRule 0 1
!macroend

!define Include_RegAddWindowsFirewallRule "!insertmacro Include_RegAddWindowsFirewallRule"
!macro Include_RegAddWindowsFirewallRule prefix
!if "${prefix}" == ""
!ifndef StrRep_INCLUDED
${StrRep}
!endif
!else
!if "${prefix}" == "un."
!ifndef UnStrRep_INCLUDED
${UnStrRep}
!endif
!endif
!endif
!insertmacro Func_RegAddWindowsFirewallRule "${prefix}"
!macroend

!define RegAddWindowsFirewallRule "${Call_RegAddWindowsFirewallRule} ''"
!define un.RegAddWindowsFirewallRule "${Call_RegAddWindowsFirewallRule} 'un.'"

; RegRemoveWindowsFirewallRule
!define Include_RegRemoveWindowsFirewallRule "!insertmacro Include_RegRemoveWindowsFirewallRule"
!macro Include_RegRemoveWindowsFirewallRule prefix
${Include_BeginMacroBodyFunction} "${prefix}"
${Include_EndMacroBodyFunction} "${prefix}"
!macroend

!define Call_RegRemoveWindowsFirewallRule "!insertmacro Call_RegRemoveWindowsFirewallRule"
!macro Call_RegRemoveWindowsFirewallRule prefix key_name
${DebugStackEnterFrame} Call_RegRemoveWindowsFirewallRule 0 1

${Call_BeginMacroBodyFunction} "${prefix}"
${DeleteRegValue} HKLM "${WIN_FIREWALL_RULES_REGKEY}" "${key_name}"
${Call_EndMacroBodyFunction} "${prefix}"

${DebugStackExitFrame} Call_RegRemoveWindowsFirewallRule 0 1
!macroend

!define RegRemoveWindowsFirewallRule "${Call_RegRemoveWindowsFirewallRule} ''"
!define un.RegRemoveWindowsFirewallRule "${Call_RegRemoveWindowsFirewallRule} 'un.'"

; RegEnableWindowsFirewallRule - Enables existing Windows Firewall rule directly from the registry
;   WARNING: You must restart firewall to make changes applied for the firewall!
;
; Usage:
;   ${Push} "<key_name>"     ; registry key name
;   ${Push} "<value>"        ; 0 or 1
;   Call RegEnableWindowsFirewallRule
!macro Func_RegEnableWindowsFirewallRule un
!ifndef ${un}RegEnableWindowsFirewallRule_INCLUDED
!define ${un}RegEnableWindowsFirewallRule_INCLUDED
Function ${un}RegEnableWindowsFirewallRule
  ${ExchStack2} $R0 $R1
  ;R0 - key_name
  ;R1 - value
  ${PushStack1} $R3

  ${DebugStackEnterFrame} `${un}RegEnableWindowsFirewallRule` 1 0

  ${ReadRegStr} $R3 HKLM "${WIN_FIREWALL_RULES_REGKEY}" $R0
  ${If} $R1 <> 0
    ${StrRep} $R3 $R3 '|Active=FALSE|' '|Active=TRUE|'
  ${Else}
    ${StrRep} $R3 $R3 '|Active=TRUE|' '|Active=FALSE|'
  ${EndIf}
  ${WriteRegStr} HKLM "${WIN_FIREWALL_RULES_REGKEY}" $R0 $R3

Done:
  ${DebugStackExitFrame} `${un}RegEnableWindowsFirewallRule` 1 0

  ${PopStack3} $R0 $R1 $R3
FunctionEnd
!endif
!macroend

!define Call_RegEnableWindowsFirewallRule "!insertmacro Call_RegEnableWindowsFirewallRule"
!macro Call_RegEnableWindowsFirewallRule prefix key_name value
${DebugStackEnterFrame} Call_RegEnableWindowsFirewallRule 0 1

${Push} `${key_name}`
${Push} `${value}`
Call ${prefix}RegEnableWindowsFirewallRule

${DebugStackExitFrame} Call_RegEnableWindowsFirewallRule 0 1
!macroend

!define Include_RegEnableWindowsFirewallRule "!insertmacro Include_RegEnableWindowsFirewallRule"
!macro Include_RegEnableWindowsFirewallRule prefix
!if "${prefix}" == ""
!ifndef StrRep_INCLUDED
${StrRep}
!endif
!else
!if "${prefix}" == "un."
!ifndef UnStrRep_INCLUDED
${UnStrRep}
!endif
!endif
!endif
!insertmacro Func_RegEnableWindowsFirewallRule "${prefix}"
!macroend

!define RegEnableWindowsFirewallRule "${Call_RegEnableWindowsFirewallRule} ''"
!define un.RegEnableWindowsFirewallRule "${Call_RegEnableWindowsFirewallRule} 'un.'"

; RegReplaceWindowsFirewallRuleByStrFromAppPath - Replaces all existing
;   Windows Firewall rules directly from the registry by a pattern string.
;   WARNING: You must restart firewall to make changes applied for the firewall!
;
; Usage:
;   ${Push} "<app>"              ; application path
;   ${Push} "<name>"             ; rule name
;   ${Push} "<str_to_replace>"   ; string to replace
;   ${Push} "<str_for_replace>"  ; string for replace
;   Call RegReplaceWindowsFirewallRuleByStrFromAppPath
!macro Func_RegReplaceWindowsFirewallRuleByStrFromAppPath un
!ifndef ${un}RegReplaceWindowsFirewallRuleByStrFromAppPath_INCLUDED
!define ${un}RegReplaceWindowsFirewallRuleByStrFromAppPath_INCLUDED
Function ${un}RegReplaceWindowsFirewallRuleByStrFromAppPath
  ${ExchStack4} $R0 $R1 $R2 $R3
  ;R0 - app
  ;R1 - name
  ;R2 - str_to_replace
  ;R3 - str_for_replace
  ${PushStack4} $R4 $R5 $R6 $R7

  ${DebugStackEnterFrame} `${un}RegReplaceWindowsFirewallRuleByStrFromAppPath` 1 0

  StrCpy $R5 0
Loop:
  ClearErrors
  EnumRegValue $R4 HKLM "${WIN_FIREWALL_RULES_REGKEY}" $R5
  IfErrors Done
  IntOp $R5 $R5 + 1
  ReadRegStr $R6 HKLM "${WIN_FIREWALL_RULES_REGKEY}" $R4
  ${StrStr} $R7 $R6 '|App=$R0|'
  ${If} $R7 == ""
    Goto Loop
  ${EndIf}
  ${StrStr} $R7 $R6 '|Name=$R1|'
  ${If} $R7 == ""
    Goto Loop
  ${EndIf}
  ${StrRep} $R6 $R6 $R2 $R3
  WriteRegStr HKLM "${WIN_FIREWALL_RULES_REGKEY}" $R4 $R6
  Goto Loop

Done:
  ${DebugStackExitFrame} `${un}RegReplaceWindowsFirewallRuleByStrFromAppPath` 1 0

  ${PopStack8} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7
FunctionEnd
!endif
!macroend

!define Call_RegReplaceWindowsFirewallRuleByStrFromAppPath "!insertmacro Call_RegReplaceWindowsFirewallRuleByStrFromAppPath"
!macro Call_RegReplaceWindowsFirewallRuleByStrFromAppPath prefix app name str_to_replace str_for_replace
${DebugStackEnterFrame} Call_RegReplaceWindowsFirewallRuleByStrFromAppPath 0 1

${Push} `${app}`
${Push} `${name}`
${Push} `${str_to_replace}`
${Push} `${str_for_replace}`
Call ${prefix}RegReplaceWindowsFirewallRuleByStrFromAppPath

${DebugStackExitFrame} Call_RegReplaceWindowsFirewallRuleByStrFromAppPath 0 1
!macroend

!define Include_RegReplaceWindowsFirewallRuleByStrFromAppPath "!insertmacro Include_RegReplaceWindowsFirewallRuleByStrFromAppPath"
!macro Include_RegReplaceWindowsFirewallRuleByStrFromAppPath prefix
!if "${prefix}" == ""
!ifndef StrStr_INCLUDED
${StrStr}
!endif
!ifndef StrRep_INCLUDED
${StrRep}
!endif
!else
!if "${prefix}" == "un."
!ifndef UnStrStr_INCLUDED
${UnStrStr}
!endif
!ifndef UnStrRep_INCLUDED
${UnStrRep}
!endif
!endif
!endif
!insertmacro Func_RegReplaceWindowsFirewallRuleByStrFromAppPath "${prefix}"
!macroend

!define RegReplaceWindowsFirewallRuleByStrFromAppPath "${Call_RegReplaceWindowsFirewallRuleByStrFromAppPath} ''"
!define un.RegReplaceWindowsFirewallRuleByStrFromAppPath "${Call_RegReplaceWindowsFirewallRuleByStrFromAppPath} 'un.'"

!define AddWindowsFirewallRuleOnceFromAppPath "!insertmacro AddWindowsFirewallRuleOnceFromAppPath"
!macro AddWindowsFirewallRuleOnceFromAppPath app name profile
${DebugStackEnterFrame} AddWindowsFirewallRuleOnceFromAppPath 0 1

${PushStack1} $R0

${DebugStackEnterFrame} AddWindowsFirewallRuleOnceFromAppPath 1 0

DetailPrint "liteFirewall::RemoveRule $\"${app}$\" $\"${name}$\""
liteFirewall::RemoveRule "${app}" "${name}"
${Pop} $R0
DetailPrint "Last error code: $R0"

DetailPrint "liteFirewall::AddRule $\"${app}$\" $\"${name}$\""
; Default registry value: #v2.10|Action=Allow|Active=TRUE|Dir=In|Profile=Private|App=${app}|Name=${name}|
liteFirewall::AddRule "${app}" "${name}"
${Pop} $R0
DetailPrint "Last error code: $R0"

${If} "${profile}" != ""
  ${RegReplaceWindowsFirewallRuleByStrFromAppPath} "${app}" "${name}" "|Profile=Private|" "|${profile}|"
${EndIf}

${DebugStackExitFrame} AddWindowsFirewallRuleOnceFromAppPath 1 0

${PopStack1} $R0

${DebugStackExitFrame} AddWindowsFirewallRuleOnceFromAppPath 0 1
!macroend

!define AddWindowsFirewallRuleOnceFromAppPathAndPorts "!insertmacro AddWindowsFirewallRuleOnceFromAppPathAndPorts"
!macro AddWindowsFirewallRuleOnceFromAppPathAndPorts app name profile tcp_in_port
${DebugStackEnterFrame} AddWindowsFirewallRuleOnceFromAppPathAndPorts 0 1

${PushStack1} $R0

${DebugStackEnterFrame} AddWindowsFirewallRuleOnceFromAppPathAndPorts 1 0

DetailPrint "liteFirewall::RemoveRule $\"${app}$\" $\"${name}$\""
liteFirewall::RemoveRule "${app}" "${name}"
${Pop} $R0
DetailPrint "Last error code: $R0"

DetailPrint "liteFirewall::AddRule $\"${app}$\" $\"${name}$\""
; Default registry value: #v2.10|Action=Allow|Active=TRUE|Dir=In|Profile=Private|App=${app}|Name=${name}|
liteFirewall::AddRule "${app}" "${name}"
${Pop} $R0
DetailPrint "Last error code: $R0"

${If} "${profile}" != ""
  ${RegReplaceWindowsFirewallRuleByStrFromAppPath} "${app}" "${name}" "|Dir=In|Profile=Private|App=" "|Dir=In|${profile}|App="
${EndIf}
${If} "${tcp_in_port}" != ""
  ${RegReplaceWindowsFirewallRuleByStrFromAppPath} "${app}" "${name}" "|Dir=In|Profile=" "|Dir=In|Protocol=6|Profile="
  ${RegReplaceWindowsFirewallRuleByStrFromAppPath} "${app}" "${name}" "|App=" "|LPort=${tcp_in_port}|App="
${EndIf}

${DebugStackExitFrame} AddWindowsFirewallRuleOnceFromAppPathAndPorts 1 0

${PopStack1} $R0

${DebugStackExitFrame} AddWindowsFirewallRuleOnceFromAppPathAndPorts 0 1
!macroend

!define CreateShortcutDirectory "!insertmacro CreateShortcutDirectory"
!macro CreateShortcutDirectory shell_ctx path
${DebugStackEnterFrame} CreateShortcutDirectory 0 1

${PushShellVarContext} "${shell_ctx}"

CreateDirectory "${path}"

${PopShellVarContext}

${DebugStackExitFrame} CreateShortcutDirectory 0 1
!macroend

!define Func_CreateShortCutImplBegin "!insertmacro Func_CreateShortCutImplBegin"
!macro Func_CreateShortCutImplBegin un
Function ${un}CreateShortCutImplBegin
  ${ExchStack7} $R0 $R1 $R2 $R3 $R4 $R5 $R6
  ; R0 - type
  ; R1 - product_regkey
  ; R2 - base_path
  ; R3 - rel_path
  ; R4 - exec_file
  ; R5 - args
  ; R6 - icon_file
  ${PushStack3} $R7 $R8 $R9

  ${DebugStackEnterFrame} `${un}CreateShortCutImplBegin` 1 0

  ; shortcuts that has not related to user account must be registered in the HKLM
  ${Switch} $R0
  ${Case} "StartMenu"
  ${Case} "Desktop"
    ; depends on shell_ctx ($SHELL_VAR_CTX)
    ${Switch} $SHELL_VAR_CTX
      ${Case} current
        StrCpy $R7 0 ; HKCU
      ${Break}
      ${Case} all
        StrCpy $R7 1 ; HKLM
      ${Break}
      ${Default}
        StrCpy $R7 0 ; HKCU by default
    ${EndSwitch}
  ${Break}
  ${Case} "Instdir"
    StrCpy $R7 1 ; HKLM
  ${Break}
  ${Default}
    StrCpy $R7 1 ; HKLM by default
  ${EndSwitch}
  
  ${If} $R7 = 0
    ${ReadRegDWORD} $R9 HKCU "$R1\Shortcuts\$R0" "NumItems"
  ${Else}
    ${ReadRegDWORD} $R9 HKLM "$R1\Shortcuts\$R0" "NumItems"
  ${EndIf}
  ${If} "$R9" == ""
    StrCpy $R9 0
  ${EndIf}

  ${If} $R7 = 0
    ${WriteRegStr} HKCU "$R1\Shortcuts\$R0\Item.$R9" "File" "$R3"
    ${WriteRegStr} HKCU "$R1\Shortcuts\$R0\Item.$R9" "Target" "$R4"
    ${WriteRegStr} HKCU "$R1\Shortcuts\$R0\Item.$R9" "Args" "$R5"
    IntOp $R8 $R9 + 1
    ${WriteRegDWORD} HKCU "$R1\Shortcuts\$R0" "NumItems" $R8
  ${Else}
    ${WriteRegStr} HKLM "$R1\Shortcuts\$R0\Item.$R9" "File" "$R3"
    ${WriteRegStr} HKLM "$R1\Shortcuts\$R0\Item.$R9" "Target" "$R4"
    ${WriteRegStr} HKLM "$R1\Shortcuts\$R0\Item.$R9" "Args" "$R5"
    IntOp $R8 $R9 + 1
    ${WriteRegDWORD} HKLM "$R1\Shortcuts\$R0" "NumItems" $R8
  ${EndIf}

  ${DebugStackExitFrame} `${un}CreateShortCutImplBegin` 1 0
FunctionEnd
!macroend

!define Func_CreateShortCutImplEnd "!insertmacro Func_CreateShortCutImplEnd"
!macro Func_CreateShortCutImplEnd un
Function ${un}CreateShortCutImplEnd
  ${DebugStackEnterFrame} `${un}CreateShortCutImplEnd` 1 0

  ${If} ${NoErrors}
    ShellLink::GetShortCutTarget "$R2\$R3"
    ${Pop} $R4

    ${DebugStackCheckFrame} `${un}CreateShortCutImplEnd` 1 0

    ShellLink::GetShortCutArgs "$R2\$R3"
    ${Pop} $R5

    ${DebugStackCheckFrame} `${un}CreateShortCutImplEnd` 1 0

    ${If} $R7 = 0
      ${WriteRegStr} HKCU "$R1\Shortcuts\$R0\Item.$R9" "Target" $R4
      ${WriteRegStr} HKCU "$R1\Shortcuts\$R0\Item.$R9" "Args" $R5
    ${Else}
      ${WriteRegStr} HKLM "$R1\Shortcuts\$R0\Item.$R9" "Target" $R4
      ${WriteRegStr} HKLM "$R1\Shortcuts\$R0\Item.$R9" "Args" $R5
    ${EndIf}
  ${EndIf}

  ${DebugStackExitFrame} `${un}CreateShortCutImplEnd` 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Call_CreateShortCut "!insertmacro Call_CreateShortCut"
!macro Call_CreateShortCut prefix type product_regkey shell_ctx base_path rel_path exec_file args icon_file icon_index
${DebugStackEnterFrame} Call_CreateShortCut 0 1

${PushShellVarContext} "${shell_ctx}"

${Push} `${type}`
${Push} `${product_regkey}`
${Push} `${base_path}`
${Push} `${rel_path}`
${Push} `${exec_file}`
${Push} `${args}`
${Push} `${icon_file}`
; must be called as a Function to force parameters evaluation before the use
Call ${prefix}CreateShortCutImplBegin
ClearErrors
; WARNING: Have to call CreateShortCut in a macro because ${icon_index} argument is not evaluatable from a Function
;         (error message: "cannot interpret icon index")
CreateShortCut "$R2\$R3" "$R4" "$R5" "$R6" ${icon_index}
Call ${prefix}CreateShortCutImplEnd

${PopShellVarContext}

${DebugStackExitFrame} Call_CreateShortCut 0 1
!macroend

!define Include_CreateShortCut "!insertmacro Include_CreateShortCut"
!macro Include_CreateShortCut prefix
${Func_CreateShortCutImplBegin} "${prefix}"
${Func_CreateShortCutImplEnd} "${prefix}"
!macroend

!define CreateShortCut "${Call_CreateShortCut} ''"
!define un.CreateShortCut "${Call_CreateShortCut} 'un.'"

!define Func_DeleteAllShortcuts "!insertmacro Func_DeleteAllShortcuts"
!macro Func_DeleteAllShortcuts un
Function ${un}DeleteAllShortcuts
  ${ExchStack3} $R0 $R1 $R2
  ; R0 - type
  ; R1 - product_regkey
  ; R2 - base_path
  #; R3 - base_path_current
  ${PushStack7} $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} `${un}DeleteAllShortcuts` 1 0

  ; shortcuts that has not related to user account must be unregistered from the HKLM
  ${Switch} $R0
  ${Case} "StartMenu"
  ${Case} "Desktop"
    ; depends on shell_ctx ($SHELL_VAR_CTX)
    ${Switch} $SHELL_VAR_CTX
      ${Case} current
        StrCpy $R3 0 ; HKCU
      ${Break}
      ${Case} all
        StrCpy $R3 1 ; HKLM
      ${Break}
      ${Default}
        StrCpy $R3 0 ; HKCU by default
    ${EndSwitch}
  ${Break}
  ${Case} "Instdir"
    StrCpy $R3 1 ; HKLM
  ${Break}
  ${Default}
    StrCpy $R3 1 ; HKLM by default
  ${EndSwitch}

  ${If} $R3 = 0
    ${WriteRegDWORD} HKCU "$R1\Shortcuts\$R0" "NumItems" 0
  ${Else}
    ${WriteRegDWORD} HKLM "$R1\Shortcuts\$R0" "NumItems" 0
  ${EndIf}

  StrCpy $R9 0

  ${Do}
    ${If} $R3 = 0
      ${ReadRegStr} $R4 HKCU "$R1\Shortcuts\$R0\Item.$R9" "File"
    ${Else}
      ${ReadRegStr} $R4 HKLM "$R1\Shortcuts\$R0\Item.$R9" "File"
    ${EndIf}
    ${If} "$R4" == ""
      ${Break}
    ${EndIf}

    ${If} ${FileExists} "$R2\$R4"
      ${If} $R3 = 0
        ${ReadRegStr} $R5 HKCU "$R1\Shortcuts\$R0\Item.$R9" "Target"
        ${ReadRegStr} $R6 HKCU "$R1\Shortcuts\$R0\Item.$R9" "Args"
      ${Else}
        ${ReadRegStr} $R5 HKLM "$R1\Shortcuts\$R0\Item.$R9" "Target"
        ${ReadRegStr} $R6 HKLM "$R1\Shortcuts\$R0\Item.$R9" "Args"
      ${EndIf}

      ShellLink::GetShortCutTarget "$R2\$R4"
      ${Pop} $R7

      ${DebugStackCheckFrame} `${un}DeleteAllShortcuts` 1 0

      ShellLink::GetShortCutArgs "$R2\$R4"
      ${Pop} $R8

      ${DebugStackCheckFrame} `${un}DeleteAllShortcuts` 1 0

      ; shortcut validation by Target and Args
      ${If} $R5 == $R7
      ${AndIf} $R6 == $R8
        Delete "$R2\$R4"
        ; try to remove shortcut directory after remove a shortcut file
        ${Call_RemoveEmptyDirectoryPathImpl} "${un}" $R2 $R4
        #; current user shortcuts basically override public shortcuts (for all users),
        #; so we have to remove them too to avoid shortcuts obscuring and cleanup current user
        #; shortcut folders.
        #${If} $SHELL_VAR_CTX == "all"
        #  Delete "$R3\$R4"
        #  ${Call_RemoveEmptyDirectoryPathImpl} "${un}" $R3 $R4
        #${EndIf}
      ${Else}
        DetailPrint "DeleteAllShortcuts: warning: shortcut has been changed, deletion ignored: $\"$R2\$R4$\""
      ${EndIf}
    ${Else}
      DetailPrint "DeleteAllShortcuts: error: shortcut is not found: $\"$R2\$R4$\""
    ${EndIf}

    ${If} $R3 = 0
      ${DeleteRegValue} HKCU "$R1\Shortcuts\$R0\Item.$R9" "File"
      ${DeleteRegValue} HKCU "$R1\Shortcuts\$R0\Item.$R9" "Target"
      ${DeleteRegValue} HKCU "$R1\Shortcuts\$R0\Item.$R9" "Args"

      ${DeleteRegKeyIfEmpty} HKCU "$R1\Shortcuts\$R0\Item.$R9"
    ${Else}
      ${DeleteRegValue} HKLM "$R1\Shortcuts\$R0\Item.$R9" "File"
      ${DeleteRegValue} HKLM "$R1\Shortcuts\$R0\Item.$R9" "Target"
      ${DeleteRegValue} HKLM "$R1\Shortcuts\$R0\Item.$R9" "Args"

      ${DeleteRegKeyIfEmpty} HKLM "$R1\Shortcuts\$R0\Item.$R9"
    ${EndIf}

    IntOp $R9 $R9 + 1
  ${Loop}

  ${If} $R3 = 0
    ${DeleteRegValue} HKCU "$R1\Shortcuts\$R0" "NumItems"

    ${DeleteRegKeyIfEmpty} HKCU "$R1\Shortcuts\$R0"
    ${DeleteRegKeyIfEmpty} HKCU "$R1\Shortcuts"
  ${Else}
    ${DeleteRegValue} HKLM "$R1\Shortcuts\$R0" "NumItems"

    ${DeleteRegKeyIfEmpty} HKLM "$R1\Shortcuts\$R0"
    ${DeleteRegKeyIfEmpty} HKLM "$R1\Shortcuts"
  ${EndIf}

  ${DebugStackExitFrame} `${un}DeleteAllShortcuts` 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Call_DeleteAllShortcuts "!insertmacro Call_DeleteAllShortcuts"
!macro Call_DeleteAllShortcuts prefix type product_regkey shell_ctx base_path
${DebugStackEnterFrame} Call_DeleteAllShortcuts 0 1

${PushShellVarContext} "${shell_ctx}"

${Push} `${type}`
${Push} `${product_regkey}`
${Push} `${base_path}`
#${If} "${shell_ctx}" != "current"
#  ${PushShellVarContext} current
#
#  ${Push} `${base_path}`
#  ${Exch} 1
#
#  ${PopShellVarContext}
#${Else}
#  ${Push} `${base_path}`
#${EndIf}
Call ${prefix}DeleteAllShortcuts

${PopShellVarContext}

${DebugStackExitFrame} Call_DeleteAllShortcuts 0 1
!macroend

!define Include_DeleteAllShortcuts "!insertmacro Include_DeleteAllShortcuts"
!macro Include_DeleteAllShortcuts prefix
${Include_RemoveEmptyDirectoryPath} "${prefix}"
${Func_DeleteAllShortcuts} "${prefix}"
!macroend

!define DeleteAllShortcuts "${Call_DeleteAllShortcuts} ''"
!define un.DeleteAllShortcuts "${Call_DeleteAllShortcuts} 'un.'"

!define Func_PinShortcut "!insertmacro Func_PinShortcut"
!macro Func_PinShortcut un
Function ${un}PinShortcut
  ${ExchStack5} $R0 $R1 $R2 $R3 $R4
  ; R0 - type
  ; R1 - product_regkey
  ; R2 - base_path
  ; R3 - shortcut_file_ansi
  ; R4 - shortcut_file_utf_8
  ${PushStack5} $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} `${un}PinShortcut` 1 0

  ; pin new shortcuts
  ${ReadRegDWORD} $R9 HKCU "$R1\PinList\$R0" "NumItems"
  ${If} "$R9" == ""
    StrCpy $R9 0
  ${EndIf}

  ${WriteRegStr} HKCU "$R1\PinList\$R0\Item.$R9" "Path" "$R2"
  ${WriteRegStr} HKCU "$R1\PinList\$R0\Item.$R9" "File" "$R3"
  ${WriteRegStr} HKCU "$R1\PinList\$R0\Item.$R9" "File.utf" "$R4"
  IntOp $R9 $R9 + 1
  ${WriteRegDWORD} HKCU "$R1\PinList\$R0" "NumItems" $R9

  ${StdUtils.InvokeShellVerb} $R8 "$R2" "$R4" ${StdUtils.Const.ShellVerb.PinToStart}

  ${DebugStackCheckFrame} `${un}PinShortcut` 1 0

  DetailPrint "Pinned shortcut $\"$R2\$R3$\" to start menu: $R8"
  ${UpdateSilentSetupNotify}

  ${DebugStackExitFrame} `${un}PinShortcut` 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Call_PinShortcut "!insertmacro Call_PinShortcut"
!macro Call_PinShortcut prefix type product_regkey shell_ctx base_path shortcut_file_ansi shortcut_file_utf_8
${DebugStackEnterFrame} Call_PinShortcut 0 1

${PushShellVarContext} "${shell_ctx}"

${Push} `${type}`
${Push} `${product_regkey}`
${Push} `${base_path}`
${Push} `${shortcut_file_ansi}`
${Push} `${shortcut_file_utf_8}`
Call ${prefix}PinShortcut

${PopShellVarContext}

${DebugStackExitFrame} Call_PinShortcut 0 1
!macroend

!define Include_PinShortcut "!insertmacro Include_PinShortcut"
!macro Include_PinShortcut prefix
${Func_PinShortcut} "${prefix}"
!macroend

!define PinShortcut "${Call_PinShortcut} ''"
!define un.PinShortcut "${Call_PinShortcut} 'un.'"

!define Func_UnpinAllShortcuts "!insertmacro Func_UnpinAllShortcuts"
!macro Func_UnpinAllShortcuts un
Function ${un}UnpinAllShortcuts
  ${ExchStack2} $R0 $R1
  ; R0 - type
  ; R1 - product_regkey
  ${PushStack8} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} `${un}UnpinAllShortcuts` 1 0

  ; new implementation
  ${WriteRegDWORD} HKCU "$R1\PinList\$R0" "NumItems" 0

  ; old implementation, unpin shortcuts from previous installation
  StrCpy $R9 0
  ${Do}
    ${ReadRegStr} $R4 HKCU "$R1\$R0PinList\Item.$R9" "Path"
    ${ReadRegStr} $R5 HKCU "$R1\$R0PinList\Item.$R9" "File"
    ${ReadRegStr} $R6 HKCU "$R1\$R0PinList\Item.$R9" "File.utf"
    ${If} "$R4" == ""
    ${OrIf} "$R5" == ""
      ${Break}
    ${EndIf}

    ${StdUtils.InvokeShellVerb} $R8 "$R4" "$R6" ${StdUtils.Const.ShellVerb.UnpinFromStart}

    ${DebugStackCheckFrame} `${un}UnpinAllShortcuts` 1 0

    DetailPrint "Unpinned shortcut $\"$R4\$R5$\" from start menu: $R8"

    ; Previous unpin may fail if FolderItemVerb with `Изъять из меню "Пуск"` won't be found on the list of items.
    ; So to workaround shortcut duplication bug in next call to pin: try additionally to unpin from current user AppData directory.
    #${PushShellVarContext} current

    StrCpy $R4 "$APPDATA_CURRENT\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu"
    ${StdUtils.InvokeShellVerb} $R8 "$R4" "$R6" ${StdUtils.Const.ShellVerb.UnpinFromStart}

    ${DebugStackCheckFrame} `${un}UnpinAllShortcuts` 1 0

    DetailPrint "Unpinned shortcut $\"$R4\$R5$\" from start menu: $R8"

    #${PopShellVarContext}

    ${DeleteRegValue} HKCU "$R1\$R0PinList\Item.$R9" "Path"
    ${DeleteRegValue} HKCU "$R1\$R0PinList\Item.$R9" "File"
    ${DeleteRegValue} HKCU "$R1\$R0PinList\Item.$R9" "File.utf"

    ${DeleteRegKeyIfEmpty} HKCU "$R1\$R0PinList\Item.$R9"

    ${UpdateSilentSetupNotify}

    IntOp $R9 $R9 + 1
  ${Loop}

  ${DeleteRegKeyIfEmpty} HKCU "$R1\$R0PinList"

  ; new implementation, unpin shortcuts from previous installation
  StrCpy $R9 0
  ${Do}
    ${ReadRegStr} $R4 HKCU "$R1\PinList\$R0\Item.$R9" "Path"
    ${ReadRegStr} $R5 HKCU "$R1\PinList\$R0\Item.$R9" "File"
    ${ReadRegStr} $R6 HKCU "$R1\PinList\$R0\Item.$R9" "File.utf"
    ${If} "$R4" == ""
    ${OrIf} "$R5" == ""
      ${Break}
    ${EndIf}

    ${StdUtils.InvokeShellVerb} $R8 "$R4" "$R6" ${StdUtils.Const.ShellVerb.UnpinFromStart}

    ${DebugStackCheckFrame} `${un}UnpinAllShortcuts` 1 0

    DetailPrint "Unpinned shortcut $\"$R4\$R5$\" from start menu: $R8"

    ; Previous unpin may fail if FolderItemVerb with `Изъять из меню "Пуск"` won't be found on the list of items.
    ; So to workaround shortcut duplication bug in next call to pin: try additionally to unpin from AppData directory.
    #${PushShellVarContext} current

    StrCpy $R4 "$APPDATA_CURRENT\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu"
    ${StdUtils.InvokeShellVerb} $R8 "$R4" "$R6" ${StdUtils.Const.ShellVerb.UnpinFromStart}

    ${DebugStackCheckFrame} `${un}UnpinAllShortcuts` 1 0

    DetailPrint "Unpinned shortcut $\"$R4\$R5$\" from start menu: $R8"

    #${PopShellVarContext}

    ${DeleteRegValue} HKCU "$R1\PinList\$R0\Item.$R9" "Path"
    ${DeleteRegValue} HKCU "$R1\PinList\$R0\Item.$R9" "File"
    ${DeleteRegValue} HKCU "$R1\PinList\$R0\Item.$R9" "File.utf"

    ${DeleteRegKeyIfEmpty} HKCU "$R1\PinList\$R0\Item.$R9"

    ${UpdateSilentSetupNotify}

    IntOp $R9 $R9 + 1
  ${Loop}

  ${DeleteRegValue} HKCU "$R1\PinList\$R0" "NumItems"

  ${DeleteRegKeyIfEmpty} HKCU "$R1\PinList\$R0"
  ${DeleteRegKeyIfEmpty} HKCU "$R1\PinList"

  ${DebugStackExitFrame} `${un}UnpinAllShortcuts` 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Call_UnpinAllShortcuts "!insertmacro Call_UnpinAllShortcuts"
!macro Call_UnpinAllShortcuts prefix type product_regkey shell_ctx
${DebugStackEnterFrame} Call_UnpinAllShortcuts 0 1

${PushShellVarContext} "${shell_ctx}"

${Push} `${type}`
${Push} `${product_regkey}`
Call ${prefix}UnpinAllShortcuts

${PopShellVarContext}

${DebugStackExitFrame} Call_UnpinAllShortcuts 0 1
!macroend

!define Include_UnpinAllShortcuts "!insertmacro Include_UnpinAllShortcuts"
!macro Include_UnpinAllShortcuts prefix
${Func_UnpinAllShortcuts} "${prefix}"
!macroend

!define UnpinAllShortcuts "${Call_UnpinAllShortcuts} ''"
!define un.UnpinAllShortcuts "${Call_UnpinAllShortcuts} 'un.'"

; Register installation file copy
!define Func_RegInstallFileCopy "!insertmacro Func_RegInstallFileCopy"
!macro Func_RegInstallFileCopy un
Function ${un}RegInstallFileCopy
  ${ExchStack3} $R0 $R1 $R2
  ; R0 - product_regkey
  ; R1 - dir_path
  ; R2 - path_to
  ${PushStack3} $R3 $R8 $R9

  ${DebugStackEnterFrame} `${un}RegInstallFileCopy` 1 0

  StrCpy $R8 $R1 1 -1 ; last character
  ${If} $R1 != ""
  ${AndIf} $R8 != "\"
    StrCpy $R1 "$R1\"
  ${EndIf}

  ${If} ${FileExists} "$R1$R2"
    ${ReadRegDWORD} $R9 HKLM "$R0\InstallFilesCopy" "NumItems"
    ${If} "$R9" == ""
      StrCpy $R9 0
    ${EndIf}

    ${WriteRegStr} HKLM "$R0\InstallFilesCopy\Item.$R9" "File" "$R2"
    ${If} $R1 != ""
      ${WriteRegStr} HKLM "$R0\InstallFilesCopy\Item.$R9" "Dir" "$R1"
    ${EndIf}
    IntOp $R9 $R9 + 1
    ${WriteRegDWORD} HKLM "$R0\InstallFilesCopy" "NumItems" "$R9"

    StrCpy $R3 0
  ${Else}
    StrCpy $R3 -1
  ${EndIf}

  ${DebugStackExitFrame} `${un}RegInstallFileCopy` 1 0

  ${Push} $R3
  ${Exch} 6

  ${PopStack6} $R1 $R2 $R3 $R8 $R9 $R0
FunctionEnd
!macroend

!define Call_RegInstallFileCopy "!insertmacro Call_RegInstallFileCopy"
!macro Call_RegInstallFileCopy prefix res_var product_regkey shell_ctx dir_path path_to
${DebugStackEnterFrame} Call_RegInstallFileCopy 0 1

${PushShellVarContext} "${shell_ctx}"

${Push} `${product_regkey}`
${Push} `${dir_path}`
${Push} `${path_to}`
Call ${prefix}RegInstallFileCopy
${Pop} $DEBUG_RET0

${PopShellVarContext}

${DebugStackExitFrame} Call_RegInstallFileCopy 0 1

StrCpy `${res_var}` $DEBUG_RET0
!macroend

!define Include_RegInstallFileCopy "!insertmacro Include_RegInstallFileCopy"
!macro Include_RegInstallFileCopy prefix
${Func_RegInstallFileCopy} "${prefix}"
!macroend

!define RegInstallFileCopy "${Call_RegInstallFileCopy} ''"
!define un.RegInstallFileCopy "${Call_RegInstallFileCopy} 'un.'"

; Installation files copy with registration
!define Func_CopyInstallFiles "!insertmacro Func_CopyInstallFiles"
!macro Func_CopyInstallFiles un
Function ${un}CopyInstallFiles
  ${ExchStack4} $R0 $R1 $R2 $R3
  ; R0 - product_regkey
  ; R1 - dir_path
  ; R2 - path_from
  ; R3 - path_to
  ${PushStack3} $R4 $R8 $R9

  ${DebugStackEnterFrame} `${un}CopyInstallFiles` 1 0

  StrCpy $R8 $R1 1 -1 ; last character
  ${If} $R1 != ""
  ${AndIf} $R8 != "\"
    StrCpy $R1 "$R1\"
  ${EndIf}

  ; convert path_from to absolute path
  ${If} $R2 != ""
    StrCpy $R4 $R2 1 1
    ${If} $R4 != ":"
      StrCpy $R2 "$R1$R2"
    ${EndIf}
  ${EndIf}

  ${If} ${FileExists} "$R2"
    ${ReadRegDWORD} $R9 HKLM "$R0\InstallFilesCopy" "NumItems"
    ${If} "$R9" == ""
      StrCpy $R9 0
    ${EndIf}

    ${WriteRegStr} HKLM "$R0\InstallFilesCopy\Item.$R9" "File" "$R3"
    ${If} $R1 != ""
      ${WriteRegStr} HKLM "$R0\InstallFilesCopy\Item.$R9" "Dir" "$R1"
    ${EndIf}
    IntOp $R9 $R9 + 1
    ${WriteRegDWORD} HKLM "$R0\InstallFilesCopy" "NumItems" "$R9"

    ClearErrors
    CopyFiles "$R2" "$R1$R3"
    ${If} ${NoErrors}
      StrCpy $R4 0
    ${Else}
      StrCpy $R4 1
    ${EndIf}
  ${Else}
    StrCpy $R4 -1
  ${EndIf}

  ${DebugStackExitFrame} `${un}CopyInstallFiles` 1 0

  ${Push} $R4
  ${Exch} 7

  ${PopStack7} $R1 $R2 $R3 $R4 $R8 $R9 $R0
FunctionEnd
!macroend

!define Call_CopyInstallFiles "!insertmacro Call_CopyInstallFiles"
!macro Call_CopyInstallFiles prefix res_var product_regkey shell_ctx dir_path path_from path_to
${DebugStackEnterFrame} Call_CopyInstallFiles 0 1

${PushShellVarContext} "${shell_ctx}"

${Push} `${product_regkey}`
${Push} `${dir_path}`
${Push} `${path_from}`
${Push} `${path_to}`
Call ${prefix}CopyInstallFiles
${Pop} $DEBUG_RET0

${PopShellVarContext}

${DebugStackExitFrame} Call_CopyInstallFiles 0 1

StrCpy `${res_var}` $DEBUG_RET0
!macroend

!define Include_CopyInstallFiles "!insertmacro Include_CopyInstallFiles"
!macro Include_CopyInstallFiles prefix
${Func_CopyInstallFiles} "${prefix}"
!macroend

!define CopyInstallFiles "${Call_CopyInstallFiles} ''"
!define un.CopyInstallFiles "${Call_CopyInstallFiles} 'un.'"

!define Func_DeleteInstallFilesCopy "!insertmacro Func_DeleteInstallFilesCopy"
!macro Func_DeleteInstallFilesCopy un
Function ${un}DeleteInstallFilesCopy
  ${ExchStack1} $R0
  ; R0 - product_regkey
  ${PushStack3} $R1 $R2 $R9

  ${DebugStackEnterFrame} `${un}DeleteInstallFilesCopy` 1 0

  ${WriteRegDWORD} HKLM "$R0\InstallFilesCopy" "NumItems" 0

  StrCpy $R9 0

  ${Do}
    ${ReadRegStr} $R1 HKLM "$R0\InstallFilesCopy\Item.$R9" "File"
    ${If} "$R1" == ""
      ${Break}
    ${EndIf}

    ${ReadRegStr} $R2 HKLM "$R0\InstallFilesCopy\Item.$R9" "Dir"

    ${If} $R2 != ""
      Delete "$R2$R1"

      ; Remove file not persistent parent directories if they having no files
      ${Call_RemoveEmptyDirectoryPathImpl} "${un}" $R2 $R1 ; no shell context because all variables already must be expanded here!
    ${Else}
      ; old implementation
      Delete "$R1"
    ${EndIf}

    ${DeleteRegValue} HKLM "$R0\InstallFilesCopy\Item.$R9" "File"
    ${DeleteRegValue} HKLM "$R0\InstallFilesCopy\Item.$R9" "Dir"
    ${DeleteRegKeyIfEmpty} HKLM "$R0\InstallFilesCopy\Item.$R9"

    IntOp $R9 $R9 + 1
  ${Loop}

  ${DeleteRegValue} HKLM "$R0\InstallFilesCopy" "NumItems"

  ${DeleteRegKeyIfEmpty} HKLM "$R0\InstallFilesCopy"

  ${DebugStackExitFrame} `${un}DeleteInstallFilesCopy` 1 0

  ${PopStack4} $R0 $R1 $R2 $R9
FunctionEnd
!macroend

!define DeleteInstallFilesCopy "!insertmacro DeleteInstallFilesCopy"
!macro DeleteInstallFilesCopy product_regkey
${DebugStackEnterFrame} DeleteInstallFilesCopy 0 1

${Push} `${product_regkey}`
!ifndef __UNINSTALL__
Call DeleteInstallFilesCopy
!else
Call un.DeleteInstallFilesCopy
!endif

${DebugStackExitFrame} DeleteInstallFilesCopy 0 1
!macroend

!define Include_DeleteInstallFilesCopy "!insertmacro Include_DeleteInstallFilesCopy"
!macro Include_DeleteInstallFilesCopy prefix
${Func_DeleteInstallFilesCopy} "${prefix}"
!macroend

!define IsRebootRequired "!insertmacro IsRebootRequired"
!macro IsRebootRequired var
${DebugStackEnterFrame} IsRebootRequired 0 1

!ifndef __UNINSTALL__
Call IsRebootRequired
!else
Call un.IsRebootRequired
!endif
${Pop} $DEBUG_RET0

${DebugStackExitFrame} IsRebootRequired 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

; with UAC elevation support
!define Func_IsRebootRequiredImpl_HKCU "!insertmacro Func_IsRebootRequiredImpl_HKCU"
!macro Func_IsRebootRequiredImpl_HKCU un
Function ${un}IsRebootRequiredImpl_HKCU
  ${DebugStackEnterFrame} `${un}IsRebootRequiredImpl_HKCU` 1 0

  ClearErrors
  EnumRegValue $R1 HKCU "Software\Microsoft\Windows\CurrentVersion\RunOnce" 0
  ${If} ${NoErrors} # if no properties but the key exists then no errors
    ${If} $R1 != "" # having properties?
      DetailPrint "IsRebootRequired (x86): HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"
      IntOp $R0 $R0 | 0x00000008
    ${EndIf}
  ${EndIf}
  ; check in WOW64 mode
  ${If} ${RunningX64}
    SetRegView 64
    ClearErrors
    EnumRegValue $R1 HKCU "Software\Microsoft\Windows\CurrentVersion\RunOnce" 0
    ${If} ${NoErrors} # if no properties but the key exists then no errors
      ${If} $R1 != "" # having properties?
        DetailPrint "IsRebootRequired (x64): HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        IntOp $R0 $R0 | 0x00000010
      ${EndIf}
    ${EndIf}
    SetRegView lastused
  ${EndIf}

  ${DebugStackExitFrame} `${un}IsRebootRequiredImpl_HKCU` 1 0
FunctionEnd
!macroend

; no need UAC elevation support
!define Func_IsRebootRequired "!insertmacro Func_IsRebootRequired"
!macro Func_IsRebootRequired un
Function ${un}IsRebootRequired
  ${PushStack4} $R0 $R1 $R2 $R9

  ${DebugStackEnterFrame} `${un}IsRebootRequired` 1 0

  StrCpy $R0 0

  ; Internal reboot flag state
  IfRebootFlag RebootFlag NoRebootFlag

  RebootFlag:
  DetailPrint "IsRebootRequired: NSIS IfRebootFlag"
  IntOp $R0 $R0 | 0x00000001

  NoRebootFlag:

  ; Check RunOnce registry records
  ClearErrors
  EnumRegValue $R1 HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnce" 0
  ${If} ${NoErrors} # if no properties but the key exists then no errors
    ${If} $R1 != "" # having properties?
      DetailPrint "IsRebootRequired (x86): HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"
      IntOp $R0 $R0 | 0x00000002
    ${Endif}
  ${EndIf}
  ; check in WOW64 mode
  ${If} ${RunningX64}
    SetRegView 64
    EnumRegValue $R1 HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnce" 0
    ${If} ${NoErrors} # if no properties but the key exists then no errors
      ${If} $R1 != "" # having properties?
        DetailPrint "IsRebootRequired (x64): HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        IntOp $R0 $R0 | 0x00000004
      ${Endif}
    ${EndIf}
    SetRegView lastused
  ${EndIf}

  ${DebugStackCheckFrame} `${un}IsRebootRequired` 1 0

  Call ${un}IsRebootRequiredImpl_HKCU

  ${DebugStackCheckFrame} `${un}IsRebootRequired` 1 0

  ; the same call but for UAC promoted setup process
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackExitFrame} `${un}IsRebootRequired` 1 0

    ; $R0 will be synced back, so we must save the previous value
    ${PushStack20} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9

    ${DebugStackEnterFrame} `${un}IsRebootRequired` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}IsRebootRequiredImpl_HKCU ${UAC_SYNCREGISTERS}

    ${DebugStackExitFrame} `${un}IsRebootRequired` 1 0

    ${Push} $R0
    ${Exch} 20

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0

    ${Pop} $R9

    ; merge the return value
    IntOp $R0 $R0 | $R9

    ${DebugStackEnterFrame} `${un}IsRebootRequired` 1 0
  ${EndIf}

  ; More complex search for reboot requiest from 3d party installers.
  ; (fore details: http://blogs.technet.com/b/heyscriptingguy/archive/2013/06/10/determine-pending-reboot-status-powershell-style-part-1.aspx)
  ; Short legend, several places where to search for reboot requiests:
  ;  * Registry: PendingFileRenameOperations
  ;  * Registry: WindowsUpdate\Auto Update
  ;  * Registry: Component-Based Servicing
  ;  * WMI: CCM_ClientUtilities (System Center Configuration Manager clients only)

  ClearErrors
  EnumRegValue $R1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" 0
  ${If} ${NoErrors}
    DetailPrint "IsRebootRequired (x86): HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    IntOp $R0 $R0 | 0x00000020
  ${EndIf}
  ; check in WOW64 mode
  ${If} ${RunningX64}
    SetRegView 64
    ClearErrors
    EnumRegValue $R1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" 0
    ${If} ${NoErrors}
      DetailPrint "IsRebootRequired (x64): HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
      IntOp $R0 $R0 | 0x00000040
    ${EndIf}
    SetRegView lastused
  ${EndIf}

  ${DebugStackCheckFrame} `${un}IsRebootRequired` 1 0

  ${registry::Read} "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" "PendingFileRenameOperations" $R1 $R2
  #${ReadRegStr} $R1 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager" "PendingFileRenameOperations"
  ${If} $R1 != ""
    DetailPrint "IsRebootRequired (x86): HKLM\SYSTEM\CurrentControlSet\Control\Session Manager: PendingFileRenameOperations"
    IntOp $R0 $R0 | 0x00000080
  ${EndIf}
  ; check in WOW64 mode
  ${If} ${RunningX64}
    SetRegView 64
    ${registry::Read} "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" "PendingFileRenameOperations" $R1 $R2
    #${ReadRegStr} $R1 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager" "PendingFileRenameOperations"
    ${If} $R1 != ""
      DetailPrint "IsRebootRequired (x64): HKLM\SYSTEM\CurrentControlSet\Control\Session Manager: PendingFileRenameOperations"
      IntOp $R0 $R0 | 0x00000100
    ${EndIf}
    SetRegView lastused
  ${EndIf}

  ${DebugStackCheckFrame} `${un}IsRebootRequired` 1 0

  ClearErrors
  EnumRegValue $R1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" 0
  ${If} ${NoErrors}
    DetailPrint "IsRebootRequired (x86): HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    IntOp $R0 $R0 | 0x00000200
  ${EndIf}
  ; check in WOW64 mode
  ${If} ${RunningX64}
    SetRegView 64
    ClearErrors
    EnumRegValue $R1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" 0
    ${If} ${NoErrors}
      DetailPrint "IsRebootRequired (x64): HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
      IntOp $R0 $R0 | 0x00000400
    ${EndIf}
    SetRegView lastused
  ${EndIf}

  ${DebugStackCheckFrame} `${un}IsRebootRequired` 1 0

  ; update globals
  IntOp $R0 $R0 & 0x0000FFFF
  IntOp $REBOOT_STATUS_FLAGS_INT $REBOOT_STATUS_FLAGS_INT | $R0 ; as internal reboot status

  ; set reboot status in the setup output ini as merge of internal and external statuses
  ${If} $R0 <> 0
    ${If} $SETUP_INI_OUT != ""
      ${If} ${FileExists} $SETUP_INI_OUT
        StrCpy $R1 $REBOOT_STATUS_FLAGS_EXT
        ; Shift lower part of external reboot status to the left on 16 bits to
        ; save internal reboot status in lower 16 bits.
        IntOp $R2 $R1 << 16
        IntOp $R1 $R1 & 0xFFFF0000
        IntOp $R1 $R1 | $R2
        ; Merge of external and internal reboot statuses, where lower 16 bits part is
        ; always clean internal reboot status and higher 16 bits is merge of higher and lower 16 bits of
        ; external reboot status.
        IntOp $R2 $REBOOT_STATUS_FLAGS_INT & 0x0000FFFF ; just in case
        IntOp $R2 $R1 | $R2
        WriteINIStr "$SETUP_INI_OUT" setup REBOOT_STATUS_FLAGS $R2
      ${EndIf}
    ${EndIf}
  ${EndIf}

  ${DebugStackExitFrame} `${un}IsRebootRequired` 1 0

  ${Push} $R0
  ${Exch} 4

  ${PopStack4} $R1 $R2 $R9 $R0
FunctionEnd
!macroend

!define Include_IsRebootRequired "!insertmacro Include_IsRebootRequired"
!macro Include_IsRebootRequired prefix
${Func_IsRebootRequiredImpl_HKCU} "${prefix}"
${Func_IsRebootRequired} "${prefix}"
!macroend

!define UpdateRebootStatus "!insertmacro UpdateRebootStatus"
!macro UpdateRebootStatus reboot_status_flags_int
${DebugStackEnterFrame} UpdateRebootStatus 0 1

${Push} `${reboot_status_flags_int}`
!ifndef __UNINSTALL__
Call UpdateRebootStatus
!else
Call un.UpdateRebootStatus
!endif

${DebugStackExitFrame} UpdateRebootStatus 0 1
!macroend

!define Func_UpdateRebootStatus "!insertmacro Func_UpdateRebootStatus"
!macro Func_UpdateRebootStatus un
Function ${un}UpdateRebootStatus
  ${ExchStack1} $R0
  ;R0 - reboot_status_flags_int

  ${DebugStackEnterFrame} `${un}UpdateRebootStatus` 1 0

  ${If} $PARENT_CONTROL_SETUP = 0
    ${If} $R0 <> 0
      SetRebootFlag true ; set Reboot Finish Page to show
    ${EndIf}
  ${Else}
    ${If} $R0 <> 0
      ; Reboot Finish Page must be shown only in the root setup process
      SetRebootFlag false ; avoid Reboot Finish Page in the current setup process
    ${EndIf}
  ${EndIf}

  ${DebugStackExitFrame} `${un}UpdateRebootStatus` 1 0

  ${PopStack1} $R0
FunctionEnd
!macroend

!define Include_UpdateRebootStatus "!insertmacro Include_UpdateRebootStatus"
!macro Include_UpdateRebootStatus prefix
${Func_UpdateRebootStatus} "${prefix}"
!macroend

!define PostProcessRebootStatus "!insertmacro PostProcessRebootStatus"
!macro PostProcessRebootStatus
${DebugStackEnterFrame} PostProcessRebootStatus 0 1

!ifndef __UNINSTALL__
Call PostProcessRebootStatus
!else
Call un.PostProcessRebootStatus
!endif

${DebugStackExitFrame} PostProcessRebootStatus 0 1
!macroend

!define Func_PostProcessRebootStatus "!insertmacro Func_PostProcessRebootStatus"
!macro Func_PostProcessRebootStatus un
Function ${un}PostProcessRebootStatus
  ${PushStack1} $R0

  ${DebugStackEnterFrame} `${un}PostProcessRebootStatus` 1 0

  ${IsRebootRequired} $R0
  ${UpdateRebootStatus} $R0

  ${DebugStackExitFrame} `${un}PostProcessRebootStatus` 1 0

  ${PopStack1} $R0
FunctionEnd
!macroend

!define Include_RebootStatus "!insertmacro Include_RebootStatus"
!macro Include_RebootStatus prefix
${Include_IsRebootRequired} "${prefix}"
${Include_UpdateRebootStatus} "${prefix}"
${Func_PostProcessRebootStatus} "${prefix}"
!macroend

!define GetAbsolutePath "!insertmacro GetAbsolutePath"
!macro GetAbsolutePath var path
!ifndef __UNINSTALL__
${Call_GetAbsolutePath} "" `${var}` `${path}`
!else
${Call_GetAbsolutePath} "un." `${var}` `${path}`
!endif
!macroend

!define GetAbsolutePathIfEmpty "!insertmacro GetAbsolutePathIfEmpty"
!macro GetAbsolutePathIfEmpty var path
!define __CURRENT_MACRO_LABELID_GetAbsolutePathIfEmpty_END __CURRENT_MACRO_LABELID_GetAbsolutePathIfEmpty_END_L${__LINE__}

StrCmp "${var}" "" 0 ${__CURRENT_MACRO_LABELID_GetAbsolutePathIfEmpty_END}

!ifndef __UNINSTALL__
${Call_GetAbsolutePath} "" `${var}` `${path}`
!else
${Call_GetAbsolutePath} "un." `${var}` `${path}`
!endif

${__CURRENT_MACRO_LABELID_GetAbsolutePathIfEmpty_END}:
!undef __CURRENT_MACRO_LABELID_GetAbsolutePathIfEmpty_END
!macroend

!define Call_GetAbsolutePath "!insertmacro Call_GetAbsolutePath"
!macro Call_GetAbsolutePath prefix var path
${DebugStackEnterFrame} Call_GetAbsolutePath 0 1

${Push} `${path}`
Call ${prefix}GetAbsolutePath
${Pop} $DEBUG_RET0

${DebugStackExitFrame} Call_GetAbsolutePath 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

!define Func_GetAbsolutePath "!insertmacro Func_GetAbsolutePath"
!macro Func_GetAbsolutePath un
Function ${un}GetAbsolutePath
  ${ExchStack1} $R0
  ;R0 - path
  ${PushStack3} $R1 $R2 $R9

  ${DebugStackEnterFrame} `${un}GetAbsolutePath` 1 0

  StrCpy $R9 ""

  ${If} $R0 == ""
    Goto end ; ignore empty paths
  ${EndIf}

  StrCpy $R1 $R0 1 -1 ; last character
  ${If} $R1 != "\"
    ; add '\' to the path end to avoid check on file path existence
    StrCpy $R0 "$R0\"
  ${EndIf}
  GetFullPathName $R9 $R0
  StrCpy $R2 $R9 1 -1 ; reread last character
  ${If} $R1 != "\"
    ${If} $R2 == "\"
      ; back slash has added to the end, remove it
      StrCpy $R9 $R9 -1
    ${EndIf}
  ${ElseIf} $R2 != "\"
    ; back slash has removed from the end, add it
    StrCpy $R9 "$R9\"
  ${EndIf}

  end:
  ${DebugStackExitFrame} `${un}GetAbsolutePath` 1 0

  ${Push} $R9
  ${Exch} 4

  ${PopStack4} $R1 $R2 $R9 $R0
FunctionEnd
!macroend

!define Include_GetAbsolutePath "!insertmacro Include_GetAbsolutePath"
!macro Include_GetAbsolutePath prefix
${Func_GetAbsolutePath} "${prefix}"
!macroend

!define GetLongPathName "!insertmacro GetLongPathName"
!macro GetLongPathName var path
!ifndef __UNINSTALL__
${Call_GetLongPathName} "" `${var}` `${path}`
!else
${Call_GetLongPathName} "un." `${var}` `${path}`
!endif
!macroend

!define Call_GetLongPathName "!insertmacro Call_GetLongPathName"
!macro Call_GetLongPathName prefix var path
${DebugStackEnterFrame} Call_GetLongPathName 0 1

${Push} `${path}`
Call ${prefix}GetLongPathName
${Pop} $DEBUG_RET0

${DebugStackExitFrame} Call_GetLongPathName 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

!define Func_GetLongPathName "!insertmacro Func_GetLongPathName"
!macro Func_GetLongPathName un
Function ${un}GetLongPathName
  ${ExchStack1} $R0
  ;R0 - path
  ${PushStack3} $R1 $R2 $R9

  ${DebugStackEnterFrame} `${un}GetLongPathName` 1 0

  StrCpy $R9 ""

  ${If} $R0 == ""
    Goto end ; ignore empty paths
  ${EndIf}

  System::Call "kernel32::GetLongPathName(t R0, t .R9, i ${NSIS_MAX_STRLEN}, p 0) i"

  end:
  ${DebugStackExitFrame} `${un}GetLongPathName` 1 0

  ${Push} $R9
  ${Exch} 4

  ${PopStack4} $R1 $R2 $R9 $R0
FunctionEnd
!macroend

!define Include_GetLongPathName "!insertmacro Include_GetLongPathName"
!macro Include_GetLongPathName prefix
${Func_GetLongPathName} "${prefix}"
!macroend

; ReadRegStr

!define ReadRegStr "!insertmacro ReadRegStr"
!macro ReadRegStr var hive_name key_path key
!ifndef __UNINSTALL__
${Call_ReadRegStr} "" `${var}` `${hive_name}` `${key_path}` `${key}`
!else
${Call_ReadRegStr} "un." `${var}` `${hive_name}` `${key_path}` `${key}`
!endif
!macroend

!define ReadRegStrIfEmpty "!insertmacro ReadRegStrIfEmpty"
!macro ReadRegStrIfEmpty var have_name key_path key
!define __CURRENT_MACRO_LABELID_ReadRegStrIfEmpty_END __CURRENT_MACRO_LABELID_ReadRegStrIfEmpty_END_L${__LINE__}

StrCmp "${var}" "" 0 ${__CURRENT_MACRO_LABELID_ReadRegStrIfEmpty_END}

!ifndef __UNINSTALL__
${Call_ReadRegStr} "" `${var}` `${have_name}` `${key_path}` `${key}`
!else
${Call_ReadRegStr} "un." `${var}` `${have_name}` `${key_path}` `${key}`
!endif

${__CURRENT_MACRO_LABELID_ReadRegStrIfEmpty_END}:
!undef __CURRENT_MACRO_LABELID_ReadRegStrIfEmpty_END
!macroend

!define Call_ReadRegStr "!insertmacro Call_ReadRegStr"
!macro Call_ReadRegStr prefix var hive_name key_path key
${DebugStackEnterFrame} Call_ReadRegStr 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
${Push} `${key}`
Call ${prefix}ReadRegStr

${PopAndSetErrors}
${Pop} $DEBUG_RET0

${DebugStackExitFrame} Call_ReadRegStr 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_ReadRegStr "!insertmacro Func_ReadRegStr"
!macro Func_ReadRegStr un
Function ${un}ReadRegStr
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack3} $R0 $R1 $R2
    ;R0 - hive_name
    ;R1 - key_path
    ;R2 - key
    ${PushStack17} $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag
    ;R9 - return value

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}ReadRegStr` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}ReadRegStr ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}ReadRegStr` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 ReadRegStr $R9 '$R1 $R2'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack2} $R9 $R8
    ${ExchStackStack2} 18

    ${PopStack20} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0 $R1
  ${EndIf}
FunctionEnd
!macroend

; ReadRegDWORD

!define ReadRegDWORD "!insertmacro ReadRegDWORD"
!macro ReadRegDWORD var hive_name key_path key
!ifndef __UNINSTALL__
${Call_ReadRegDWORD} "" `${var}` `${hive_name}` `${key_path}` `${key}`
!else
${Call_ReadRegDWORD} "un." `${var}` `${hive_name}` `${key_path}` `${key}`
!endif
!macroend

!define ReadRegDWORDIfEmpty "!insertmacro ReadRegDWORDIfEmpty"
!macro ReadRegDWORDIfEmpty var have_name key_path key
!define __CURRENT_MACRO_LABELID_ReadRegDWORDIfEmpty_END __CURRENT_MACRO_LABELID_ReadRegDWORDIfEmpty_END_L${__LINE__}

StrCmp "${var}" "" 0 ${__CURRENT_MACRO_LABELID_ReadRegDWORDIfEmpty_END}

!ifndef __UNINSTALL__
${Call_ReadRegDWORD} "" `${var}` `${have_name}` `${key_path}` `${key}`
!else
${Call_ReadRegDWORD} "un." `${var}` `${have_name}` `${key_path}` `${key}`
!endif

${__CURRENT_MACRO_LABELID_ReadRegDWORDIfEmpty_END}:
!undef __CURRENT_MACRO_LABELID_ReadRegDWORDIfEmpty_END
!macroend

!define Call_ReadRegDWORD "!insertmacro Call_ReadRegDWORD"
!macro Call_ReadRegDWORD prefix var hive_name key_path key
${DebugStackEnterFrame} Call_ReadRegDWORD 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
${Push} `${key}`
Call ${prefix}ReadRegDWORD

${PopAndSetErrors}
${Pop} $DEBUG_RET0

${DebugStackExitFrame} Call_ReadRegDWORD 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_ReadRegDWORD "!insertmacro Func_ReadRegDWORD"
!macro Func_ReadRegDWORD un
Function ${un}ReadRegDWORD
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack3} $R0 $R1 $R2
    ;R0 - hive_name
    ;R1 - key_path
    ;R2 - key
    ${PushStack17} $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag
    ;R9 - return value

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}ReadRegDWORD` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}ReadRegDWORD ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}ReadRegDWORD` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 ReadRegDWORD $R9 '$R1 $R2'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack2} $R9 $R8
    ${ExchStackStack2} 18

    ${PopStack20} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0 $R1
  ${EndIf}
FunctionEnd
!macroend

; WriteRegStr

!define WriteRegStr "!insertmacro WriteRegStr"
!macro WriteRegStr hive_name key_path key value
!ifndef __UNINSTALL__
${Call_WriteRegStr} "" `${hive_name}` `${key_path}` `${key}` `${value}`
!else
${Call_WriteRegStr} "un." `${hive_name}` `${key_path}` `${key}` `${value}`
!endif
!macroend

!define Call_WriteRegStr "!insertmacro Call_WriteRegStr"
!macro Call_WriteRegStr prefix hive_name key_path key value
${DebugStackEnterFrame} Call_WriteRegStr 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
${Push} `${key}`
${Push} `${value}`
Call ${prefix}WriteRegStr

${PopAndSetErrors}

${DebugStackExitFrame} Call_WriteRegStr 0 1
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_WriteRegStr "!insertmacro Func_WriteRegStr"
!macro Func_WriteRegStr un
Function ${un}WriteRegStr
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack4} $R0 $R1 $R2 $R3
    ;R0 - hive_name
    ;R1 - key_path
    ;R2 - key
    ;R3 - value
    ${PushStack16} $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}WriteRegStr` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}WriteRegStr ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}WriteRegStr` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 WriteRegStr "" '$R1 $R2 $R3'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack1} $R8
    ${ExchStackStack1} 19

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0
  ${EndIf}
FunctionEnd
!macroend

; WriteRegExpandStr

!define WriteRegExpandStr "!insertmacro WriteRegExpandStr"
!macro WriteRegExpandStr hive_name key_path key value
!ifndef __UNINSTALL__
${Call_WriteRegExpandStr} "" `${hive_name}` `${key_path}` `${key}` `${value}`
!else
${Call_WriteRegExpandStr} "un." `${hive_name}` `${key_path}` `${key}` `${value}`
!endif
!macroend

!define Call_WriteRegExpandStr "!insertmacro Call_WriteRegExpandStr"
!macro Call_WriteRegExpandStr prefix hive_name key_path key value
${DebugStackEnterFrame} Call_WriteRegExpandStr 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
${Push} `${key}`
${Push} `${value}`
Call ${prefix}WriteRegExpandStr

${PopAndSetErrors}

${DebugStackExitFrame} Call_WriteRegExpandStr 0 1
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_WriteRegExpandStr "!insertmacro Func_WriteRegExpandStr"
!macro Func_WriteRegExpandStr un
Function ${un}WriteRegExpandStr
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack4} $R0 $R1 $R2 $R3
    ;R0 - hive_name
    ;R1 - key_path
    ;R2 - key
    ;R3 - value
    ${PushStack16} $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}WriteRegExpandStr` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}WriteRegExpandStr ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}WriteRegExpandStr` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 WriteRegExpandStr "" '$R1 $R2 $R3'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack1} $R8
    ${ExchStackStack1} 19

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0
  ${EndIf}
FunctionEnd
!macroend

; WriteRegDWORD

!define WriteRegDWORD "!insertmacro WriteRegDWORD"
!macro WriteRegDWORD hive_name key_path key value
!ifndef __UNINSTALL__
${Call_WriteRegDWORD} "" `${hive_name}` `${key_path}` `${key}` `${value}`
!else
${Call_WriteRegDWORD} "un." `${hive_name}` `${key_path}` `${key}` `${value}`
!endif
!macroend

!define Call_WriteRegDWORD "!insertmacro Call_WriteRegDWORD"
!macro Call_WriteRegDWORD prefix hive_name key_path key value
${DebugStackEnterFrame} Call_WriteRegDWORD 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
${Push} `${key}`
${Push} `${value}`
Call ${prefix}WriteRegDWORD

${PopAndSetErrors}

${DebugStackExitFrame} Call_WriteRegDWORD 0 1
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_WriteRegDWORD "!insertmacro Func_WriteRegDWORD"
!macro Func_WriteRegDWORD un
Function ${un}WriteRegDWORD
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack4} $R0 $R1 $R2 $R3
    ;R0 - hive_name
    ;R1 - key_path
    ;R2 - key
    ;R3 - value
    ${PushStack16} $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}WriteRegDWORD` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}WriteRegDWORD ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}WriteRegDWORD` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 WriteRegDWORD "" '$R1 $R2 $R3'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack1} $R8
    ${ExchStackStack1} 19

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0
  ${EndIf}
FunctionEnd
!macroend

; WriteRegBin

; WARNING: WriteRegBin is not runtime applicable because ${valuedata} argument is not evaluatable from a Function
;         (error message: "Usage: WriteRegBin rootkey subkey entry_name hex_string_like_12848412AB")
#!define WriteRegBin "!insertmacro WriteRegBin"

; DeleteRegKey

!define DeleteRegKey "!insertmacro DeleteRegKey"
!macro DeleteRegKey hive_name key_path
!ifndef __UNINSTALL__
${Call_DeleteRegKey} "" `${hive_name}` `${key_path}`
!else
${Call_DeleteRegKey} "un." `${hive_name}` `${key_path}`
!endif
!macroend

!define Call_DeleteRegKey "!insertmacro Call_DeleteRegKey"
!macro Call_DeleteRegKey prefix hive_name key_path
${DebugStackEnterFrame} Call_DeleteRegKey 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
Call ${prefix}DeleteRegKey

${PopAndSetErrors}

${DebugStackExitFrame} Call_DeleteRegKey 0 1
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_DeleteRegKey "!insertmacro Func_DeleteRegKey"
!macro Func_DeleteRegKey un
Function ${un}DeleteRegKey
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack2} $R0 $R1
    ;R0 - hive_name
    ;R1 - key_path
    ${PushStack18} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}DeleteRegKey` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}DeleteRegKey ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}DeleteRegKey` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 DeleteRegKey "" '$R1'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack1} $R8
    ${ExchStackStack1} 19

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0
  ${EndIf}
FunctionEnd
!macroend

; DeleteRegKeyIfEmpty

!define DeleteRegKeyIfEmpty "!insertmacro DeleteRegKeyIfEmpty"
!macro DeleteRegKeyIfEmpty hive_name key_path
!ifndef __UNINSTALL__
${Call_DeleteRegKeyIfEmpty} "" `${hive_name}` `${key_path}`
!else
${Call_DeleteRegKeyIfEmpty} "un." `${hive_name}` `${key_path}`
!endif
!macroend

!define Call_DeleteRegKeyIfEmpty "!insertmacro Call_DeleteRegKeyIfEmpty"
!macro Call_DeleteRegKeyIfEmpty prefix hive_name key_path
${DebugStackEnterFrame} Call_DeleteRegKeyIfEmpty 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
Call ${prefix}DeleteRegKeyIfEmpty

${PopAndSetErrors}

${DebugStackExitFrame} Call_DeleteRegKeyIfEmpty 0 1
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_DeleteRegKeyIfEmpty "!insertmacro Func_DeleteRegKeyIfEmpty"
!macro Func_DeleteRegKeyIfEmpty un
Function ${un}DeleteRegKeyIfEmpty
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack2} $R0 $R1
    ;R0 - hive_name
    ;R1 - key_path
    ${PushStack18} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}DeleteRegKeyIfEmpty` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}DeleteRegKeyIfEmpty ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}DeleteRegKeyIfEmpty` 1 0
  ${Else}
    DirectCall:
    ${DebugStackEnterFrame} `${un}DeleteRegKeyIfEmpty` 2 0

    ${RegCallSysFuncPred} $R0 EnumRegValue "$R2" '$R1 0'
    ${If} ${Errors}
      ${RegCallSysFuncPred} $R0 DeleteRegKey /ifempty '$R1'
    ${Else}
      ${If} $R2 == ""
        ${RegCallSysFuncPred} $R0 DeleteRegKey /ifempty '$R1'
      ${EndIf}
    ${EndIf}
    ${GetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}DeleteRegKeyIfEmpty` 2 0
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack1} $R8
    ${ExchStackStack1} 19

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0
  ${EndIf}
FunctionEnd
!macroend

; DeleteRegValue

!define DeleteRegValue "!insertmacro DeleteRegValue"
!macro DeleteRegValue hive_name key_path key
!ifndef __UNINSTALL__
${Call_DeleteRegValue} "" `${hive_name}` `${key_path}` `${key}`
!else
${Call_DeleteRegValue} "un." `${hive_name}` `${key_path}` `${key}`
!endif
!macroend

!define Call_DeleteRegValue "!insertmacro Call_DeleteRegValue"
!macro Call_DeleteRegValue prefix hive_name key_path key
${DebugStackEnterFrame} Call_DeleteRegValue 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
${Push} `${key}`
Call ${prefix}DeleteRegValue

${PopAndSetErrors}

${DebugStackExitFrame} Call_DeleteRegValue 0 1
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_DeleteRegValue "!insertmacro Func_DeleteRegValue"
!macro Func_DeleteRegValue un
Function ${un}DeleteRegValue
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack3} $R0 $R1 $R2
    ;R0 - hive_name
    ;R1 - key_path
    ;R2 - key
    ${PushStack17} $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}DeleteRegValue` 1 0

    !insertmacro UAC_AsUser_Call Function ${un}DeleteRegValue ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}DeleteRegValue` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 DeleteRegValue "" '$R1 $R2'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack1} $R8
    ${ExchStackStack1} 19

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0
  ${EndIf}
FunctionEnd
!macroend

; DeleteUninstallRegKey

!define DeleteUninstallRegKey "!insertmacro DeleteUninstallRegKey"
!macro DeleteUninstallRegKey hive_name key_path
!ifndef __UNINSTALL__
${Call_DeleteUninstallRegKey} "" `${hive_name}` `${key_path}`
!else
${Call_DeleteUninstallRegKey} "un." `${hive_name}` `${key_path}`
!endif
!macroend

!define Call_DeleteUninstallRegKey "!insertmacro Call_DeleteUninstallRegKey"
!macro Call_DeleteUninstallRegKey prefix hive_name key_path
${DebugStackEnterFrame} Call_DeleteUninstallRegKey 0 1

${Push} `${hive_name}`
${Push} `${key_path}`
Call ${prefix}DeleteUninstallRegKey

${PopAndSetErrors}

${DebugStackExitFrame} Call_DeleteUninstallRegKey 0 1
!macroend

; CAUTION: Function internally must be called through the UAC plugin!
!define Func_DeleteUninstallRegKey "!insertmacro Func_DeleteUninstallRegKey"
!macro Func_DeleteUninstallRegKey un
Function ${un}DeleteUninstallRegKey
  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${ExchStack2} $R0 $R1
    ;R0 - hive_name
    ;R1 - key_path
    ${PushStack18} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9
    ;R8 - errors flag

    ${IfRegHiveIsNotUserProfiled} $R0
      Goto DirectCall
    ${EndIfRegHiveIsNotUserProfiled}
  ${Else}
    Goto DirectCall
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS >= 1
  ${AndIf} ${UAC_IsInnerInstance}
    ${DebugStackEnterFrame} `${un}DeleteUninstallRegKey` 1 0
   
    !insertmacro UAC_AsUser_Call Function ${un}DeleteUninstallRegKey ${UAC_SYNCREGISTERS}
    ${SetErrors} $R8 ; pass errors flag back to caller

    ${DebugStackExitFrame} `${un}DeleteUninstallRegKey` 1 0
  ${Else}
    DirectCall:
    ${RegCallSysFuncPred} $R0 DeleteRegValue "" '$R1 "NSIS:Language"'
    ${RegCallSysFuncPred} $R0 DeleteRegValue "" '$R1 "NSIS:StartMenuDir"'
    ${RegCallSysFuncPred} $R0 DeleteRegKey "" '$R1'
    ${GetErrors} $R8 ; pass errors flag back to caller
  ${EndIf}

  ${If} $UAC_PROCESS_ELEVATION_STATUS_FLAGS < 1
  ${OrIf} ${UAC_IsInnerInstance}
    ${PushStack1} $R8
    ${ExchStackStack1} 19

    ${PopStack20} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $R0
  ${EndIf}
FunctionEnd
!macroend

!define Include_Win32Registry "!insertmacro Include_Win32Registry"
!macro Include_Win32Registry prefix
${Func_ReadRegStr} "${prefix}"
${Func_ReadRegDWORD} "${prefix}"
${Func_WriteRegStr} "${prefix}"
${Func_WriteRegExpandStr} "${prefix}"
${Func_WriteRegDWORD} "${prefix}"
${Func_DeleteRegKey} "${prefix}"
${Func_DeleteRegKeyIfEmpty} "${prefix}"
${Func_DeleteRegValue} "${prefix}"
${Func_DeleteUninstallRegKey} "${prefix}"
!macroend

!define IsServiceRunning "${Call_IsServiceRunning} ''"
!define un.IsServiceRunning "${Call_IsServiceRunning} 'un.'"

!define Call_IsServiceRunning "!insertmacro Call_IsServiceRunning"
!macro Call_IsServiceRunning prefix var service_name
${DebugStackEnterFrame} Call_IsServiceRunning 0 1

${Push} `${service_name}`
Call ${prefix}IsServiceRunning
${Pop} $DEBUG_RET0

${DebugStackExitFrame} Call_IsServiceRunning 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

!define Func_IsServiceRunning "!insertmacro Func_IsServiceRunning"
!macro Func_IsServiceRunning un
Function ${un}IsServiceRunning
  ${ExchStack1} $R0
  ;R0 - service_name
  ${PushStack2} $R1 $R9

  ${DebugStackEnterFrame} `${un}IsServiceRunning` 1 0

  SimpleSC::ServiceIsRunning $R0
  ${Pop} $LAST_ERROR ; returns an errorcode (<>0) otherwise success (0)
  ${Pop} $R1 ; returns 1 (service is running) - returns 0 (service is not running)

  ${DebugStackCheckFrame} `${un}IsServiceRunning` 1 0

  DetailPrint "SimpleSC::ServiceIsRunning $\"$R0$\": $LAST_ERROR $R1"

  ${If} $LAST_ERROR = 0
  ${AndIf} $R1 <> 0
    StrCpy $R9 1 ; Running
  ${Else}
    StrCpy $R9 0 ; Stopped
  ${EndIf}

  ${DebugStackExitFrame} `${un}IsServiceRunning` 1 0

  ${Push} $R9
  ${Exch} 3

  ${PopStack3} $R1 $R9 $R0
FunctionEnd
!macroend

!define Include_IsServiceRunning "!insertmacro Include_IsServiceRunning"
!macro Include_IsServiceRunning prefix
${Func_IsServiceRunning} "${prefix}"
!macroend

!define IsServiceEnabled "${Call_IsServiceEnabled} ''"
!define un.IsServiceEnabled "${Call_IsServiceEnabled} 'un.'"

!define Call_IsServiceEnabled "!insertmacro Call_IsServiceEnabled"
!macro Call_IsServiceEnabled prefix var service_name
${DebugStackEnterFrame} Call_IsServiceEnabled 0 1

${Push} `${service_name}`
Call ${prefix}IsServiceEnabled
${Pop} $DEBUG_RET0

${DebugStackExitFrame} Call_IsServiceEnabled 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

!define Func_IsServiceEnabled "!insertmacro Func_IsServiceEnabled"
!macro Func_IsServiceEnabled un
Function ${un}IsServiceEnabled
  ${ExchStack1} $R0
  ;R0 - service_name
  ${PushStack2} $R1 $R9

  ${DebugStackEnterFrame} `${un}IsServiceEnabled` 1 0

  SimpleSC::GetServiceStartType $R0
  ${Pop} $LAST_ERROR ; returns an errorcode (<>0) otherwise success (0)
  ${Pop} $R1 ; returns the start type of the service (see "start_type" in the parameters)

  ${DebugStackCheckFrame} `${un}IsServiceEnabled` 1 0

  DetailPrint "SimpleSC::GetServiceStartType $\"$R0$\": $LAST_ERROR $R1"

  ${If} $LAST_ERROR <> 0
  ${OrIf} $R1 = 4 ; SERVICE_DISABLED
    StrCpy $R9 0 ; Disabled (Treated as disabled)
  ${Else}
    StrCpy $R9 1 ; Enabled
  ${EndIf}

  ${DebugStackExitFrame} `${un}IsServiceEnabled` 1 0

  ${Push} $R9
  ${Exch} 3

  ${PopStack3} $R1 $R9 $R0
FunctionEnd
!macroend

!define Include_IsServiceEnabled "!insertmacro Include_IsServiceEnabled"
!macro Include_IsServiceEnabled prefix
${Func_IsServiceEnabled} "${prefix}"
!macroend

!define EnableServiceStartOnDemand "${Call_EnableServiceStartOnDemand} ''"
!define un.EnableServiceStartOnDemand "${Call_EnableServiceStartOnDemand} 'un.'"

!define Call_EnableServiceStartOnDemand "!insertmacro Call_EnableServiceStartOnDemand"
!macro Call_EnableServiceStartOnDemand prefix service_name
${DebugStackEnterFrame} Call_EnableServiceStartOnDemand 0 1

${Push} `${service_name}`
Call ${prefix}EnableServiceStartOnDemand

${DebugStackExitFrame} Call_EnableServiceStartOnDemand 0 1
!macroend

!define Func_EnableServiceStartOnDemand "!insertmacro Func_EnableServiceStartOnDemand"
!macro Func_EnableServiceStartOnDemand un
Function ${un}EnableServiceStartOnDemand
  ${ExchStack1} $R0
  ;R0 - service_name

  ${DebugStackEnterFrame} `${un}EnableServiceStartOnDemand` 1 0

  ; Temporary enable service to install Windows Updates
  SimpleSC::SetServiceStartType "wuauserv" 3 ; SERVICE_DEMAND_START
  ${Pop} $LAST_ERROR ; returns an errorcode (<>0) otherwise success (0)

  ${DebugStackCheckFrame} `${un}EnableServiceStartOnDemand` 1 0

  DetailPrint "SimpleSC::SetServiceStartType $\"$R0$\" 3: $LAST_ERROR"

  ${DebugStackExitFrame} `${un}EnableServiceStartOnDemand` 1 0

  ${PopStack1} $R0
FunctionEnd
!macroend

!define Include_EnableServiceStartOnDemand "!insertmacro Include_EnableServiceStartOnDemand"
!macro Include_EnableServiceStartOnDemand prefix
${Func_EnableServiceStartOnDemand} "${prefix}"
!macroend

!define StartService "${Call_StartService} ''"
!define un.StartService "${Call_StartService} 'un.'"

!define Call_StartService "!insertmacro Call_StartService"
!macro Call_StartService prefix service_name wait_timeout
${DebugStackEnterFrame} Call_StartService 0 1

${Push} `${service_name}`
${Push} `${wait_timeout}`
Call ${prefix}StartService

${DebugStackExitFrame} Call_StartService 0 1
!macroend

!define Func_StartService "!insertmacro Func_StartService"
!macro Func_StartService un
Function ${un}StartService
  ${ExchStack2} $R0 $R1
  ;R0 - service_name
  ;R1 - wait_timeout

  ${DebugStackEnterFrame} `${un}StartService` 1 0

  SimpleSC::StartService "wuauserv" "" $R1 ; timeout to unlock
  ${Pop} $LAST_ERROR

  ${DebugStackCheckFrame} `${un}StartService` 1 0

  DetailPrint "SimpleSC::StartService $\"$R0$\" $\"$\" $R1: $LAST_ERROR"

  ${DebugStackExitFrame} `${un}StartService` 1 0

  ${PopStack2} $R0 $R1
FunctionEnd
!macroend

!define Include_StartService "!insertmacro Include_StartService"
!macro Include_StartService prefix
${Func_StartService} "${prefix}"
!macroend

!define DisableService "${Call_DisableService} ''"
!define un.DisableService "${Call_DisableService} 'un.'"

!define Call_DisableService "!insertmacro Call_DisableService"
!macro Call_DisableService prefix service_name
${DebugStackEnterFrame} Call_DisableService 0 1

${Push} `${service_name}`
Call ${prefix}DisableService

${DebugStackExitFrame} Call_DisableService 0 1
!macroend

!define Func_DisableService "!insertmacro Func_DisableService"
!macro Func_DisableService un
Function ${un}DisableService
  ${ExchStack1} $R0
  ;R0 - service_name

  ${DebugStackEnterFrame} `${un}DisableService` 1 0

  SimpleSC::SetServiceStartType "$R0" 4 ; SERVICE_DISABLED
  ${Pop} $LAST_ERROR ; returns an errorcode (<>0) otherwise success (0)

  ${DebugStackCheckFrame} `${un}DisableService` 1 0

  DetailPrint "SimpleSC::SetServiceStartType $\"$R0$\" 4: $LAST_ERROR"

  ${DebugStackExitFrame} `${un}DisableService` 1 0

  ${PopStack1} $R0
FunctionEnd
!macroend

!define Include_DisableService "!insertmacro Include_DisableService"
!macro Include_DisableService prefix
${Func_DisableService} "${prefix}"
!macroend

!define StopService "${Call_StopService} ''"
!define un.StopService "${Call_StopService} 'un.'"

!define Call_StopService "!insertmacro Call_StopService"
!macro Call_StopService prefix service_name wait_timeout
${DebugStackEnterFrame} Call_StopService 0 1

${Push} `${service_name}`
${Push} `${wait_timeout}`
Call ${prefix}StopService

${DebugStackExitFrame} Call_StopService 0 1
!macroend

!define Func_StopService "!insertmacro Func_StopService"
!macro Func_StopService un
Function ${un}StopService
  ${ExchStack2} $R0 $R1
  ;R0 - service_name
  ;R1 - wait_timeout

  ${DebugStackEnterFrame} `${un}StopService` 1 0
 
  SimpleSC::StopService "$R0" 1 $R1 ; timeout to unlock
  ${Pop} $LAST_ERROR ; returns an errorcode (<>0) otherwise success (0)

  ${DebugStackCheckFrame} `${un}StopService` 1 0

  DetailPrint "SimpleSC::StopService $\"$R0$\" 1 $R1: $LAST_ERROR"

  ${DebugStackExitFrame} `${un}StopService` 1 0

  ${PopStack2} $R0 $R1
FunctionEnd
!macroend

!define Include_StopService "!insertmacro Include_StopService"
!macro Include_StopService prefix
${Func_StopService} "${prefix}"
!macroend

!define EnterWindowsUpdateSection "!insertmacro EnterWindowsUpdateSection"
!macro EnterWindowsUpdateSection var_is_running var_is_enabled section wait_timeout
  ${DebugStackEnterFrame} EnterWindowsUpdateSection 0 1

  ; Windows Update service is required to install updates
  ${IsServiceRunning} `${var_is_running}` `${section}`

  ; Check Windows Update service disability state
  ${IsServiceEnabled} `${var_is_enabled}` `${section}`

  ${If} `${var_is_enabled}` = 0
    ; Temporary enable service to install Windows Updates
    DetailPrint "Enabling Windows Update service..."
    ${EnableServiceStartOnDemand} `${section}`
  ${EndIf}
  ${If} `${var_is_running}` = 0
    DetailPrint "Starting Windows Update service..."
    ${StartService} `${section}` `${wait_timeout}` ; timeout to unlock
  ${EndIf}

  ${DebugStackExitFrame} EnterWindowsUpdateSection 0 1
!macroend

!define LeaveWindowsUpdateSection "!insertmacro LeaveWindowsUpdateSection"
!macro LeaveWindowsUpdateSection var_is_running var_is_enabled section wait_timeout
  ${DebugStackEnterFrame} LeaveWindowsUpdateSection 0 1

  ; Restore Windows Update service states
  ${If} `${var_is_enabled}` = 0
    DetailPrint "Disabling Windows Update service..."
    ${DisableService} `${section}`
  ${EndIf}
  ${If} `${var_is_running}` = 0
    DetailPrint "Stopping Windows Update service..."
    ${StopService} `${section}` `${wait_timeout}` ; timeout to unlock
  ${EndIf}

  ${DebugStackExitFrame} LeaveWindowsUpdateSection 0 1
!macroend

!define SetWindowClassUserData "!insertmacro SetWindowClassUserData"
!macro SetWindowClassUserData id userdata_var old_userdata_var
!if "${old_userdata_var}" != ""
${Push} $R9

System::Call "user32::SetWindowLong(p,i,l)l (${id}, ${GWL_USERDATA}, ${userdata_var}) .R9"

!if "${old_userdata_var}" != "$R9"
${Pop} ${old_userdata_var}
!else
${Pop} $NULL
!endif
!else
; reset
System::Call "user32::SetWindowLong(p,i,l)l (${id}, ${GWL_USERDATA}, ${userdata_var})"
StrCpy ${userdata_var} 0
!endif
!macroend

!define GetWin32ErrorMesssage "!insertmacro GetWin32ErrorMesssage"
!macro GetWin32ErrorMesssage id var
${PushStack4} $R0 $R1 $R3 $R9

#System::Call "kernel32::GetSystemDefaultLangID(v) i .R1"
StrCpy $R1 $LANGUAGE

StrCpy $R9 ${FORMAT_MESSAGE_FROM_SYSTEM}
#IntOp $R9 $R9 + ${FORMAT_MESSAGE_ALLOCATE_BUFFER}
IntOp $R9 $R9 + ${FORMAT_MESSAGE_IGNORE_INSERTS}
IntOp $R9 $R9 + ${FORMAT_MESSAGE_MAX_WIDTH_MASK}

System::Call "kernel32::FormatMessage(i,p,i,i,t,i,p) i .R3 (R9, 0, ${id}, R1, .R0, ${NSIS_MAX_STRLEN}, 0)"

${MacroPopStack4} "${var}" "$R0" $R0 $R1 $R3 $R9
!macroend

!define GetTickCount "!insertmacro GetTickCount"
!macro GetTickCount var
${PushStack1} $R0

System::Call "kernel32::GetTickCount() i.R0"

${MacroPopStack1} "${var}" "$R0" $R0
!macroend

!define BeginFrameWait "!insertmacro BeginFrameWait"
!macro BeginFrameWait frames_var first_frame_ticks_var
!if "${frames_var}" == "${first_frame_ticks_var}"
!error "BeginFrameWait: frames_var and first_frame_ticks_var must be different: frames_var=$\"${frames_var}$\" first_frame_ticks_var=$\"${first_frame_ticks_var}$\""
!endif
StrCpy ${frames_var} 0
${GetTickCount} ${first_frame_ticks_var}
!macroend

; CAUTION:
;   frame_time_span should be the same in frame-to-frame calls.
!define GetNextFrameWaitTime "!insertmacro GetNextFrameWaitTime"
!macro GetNextFrameWaitTime next_frame_wait_time_var frames first_frame_ticks frame_time_span
${If} ${frames} >= 0
  ${PushStack2} $R0 $R9

  ; calculate sleep timeout
  IntOp $R9 ${frames} * ${frame_time_span}
  IntOp $R9 $R9 + ${first_frame_ticks}

  ${GetTickCount} $R0 ; last frame ticks
  IntOp $R9 $R9 - $R0

  ${MacroPopStack2} "${next_frame_wait_time_var}" "$R9" $R0 $R9
${Else}
  StrCpy ${next_frame_wait_time_var} 0
${EndIf}
!macroend

!define Include_WindowsUpdateSection "!insertmacro Include_WindowsUpdateSection"
!macro Include_WindowsUpdateSection prefix
${Include_IsServiceRunning} "${prefix}"
${Include_IsServiceEnabled} "${prefix}"
${Include_EnableServiceStartOnDemand} "${prefix}"
${Include_DisableService} "${prefix}"
${Include_StartService} "${prefix}"
${Include_StopService} "${prefix}"
!macroend

!endif
