!ifndef _NSIS_SETUP_LIB_UNINIT_NSI
!define _NSIS_SETUP_LIB_UNINIT_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\init.nsi"

; CAUTION:
;   * DO NOT unload/uninit plugins on non system event messages, overwise Access Violation may happen.
;   * DO unload/uninit plugins at system event messages after which nothing else could be called from user code.
;   * Experementally found the .onGUIEnd always calls after customUserAbort
;   * .onGUIEnd does not call in silent mode
;   * Abort does not quit immediately in some cases, for example, when Show/Section being called

!define UninitInstall "!insertmacro UninitInstall"
!macro UninitInstall event_msg
; CAUTION: We have to avoid UninitInstall recursive macro expansion here
!ifndef UNINITING
!define UNINITING 1

${DebugStackEnterFrame} UninitInstall 0 1

${Push} `${event_msg}`
Call Uninit

${If} $PLUGINS_UNLOADED = 0 ; plugins not unloaded yet, can request debug check
  ${DebugStackExitFrame} UninitInstall 0 1
${EndIf}

!undef UNINITING
!endif
!macroend

!define UninitUninstall "!insertmacro UninitUninstall"
!macro UninitUninstall event_msg
; CAUTION: We have to avoid UninitUninstal recursive macro expansion here
!ifndef UNINITING
!define UNINITING 1

${DebugStackEnterFrame} UninitUninstall 0 1

${Push} `${event_msg}`
Call un.Uninit

${If} $PLUGINS_UNLOADED = 0 ; plugins not unloaded yet, can request debug check
  ${DebugStackExitFrame} UninitUninstall 0 1
${EndIf}

!undef UNINITING
!endif
!macroend

!define UninitInstallGUI "!insertmacro UninitInstallGUI"
!macro UninitInstallGUI
Call UninitGUI
!macroend

!define !ExitCall "!insertmacro !ExitCall"
!macro !ExitCall msg
StrCpy $QUIT_CMD "Quit"

${If} $QUITTING = 0
  StrCpy $QUITTING 1

  DetailPrint "!ExitCall: exiting..."

  ; system won't call anything after Abort, so we must call UninitInstall/UninistUninstall at least with special exit code
  !if "${msg}" != ""
  DetailPrint "!ExitCall: ${msg}"
  StrCpy $MSG_ABORT "${msg}"
  !endif
  !ifdef Init_INCLUDED
  ${If} $INITED <> 0 ; ignore uninit if is not inited
    !ifndef __UNINSTALL__
    ${UninitInstall} "Exit"
    !else
    ${UninitUninstall} "Exit"
    !endif
  ${EndIf}
  !endif
${EndIf}

; ASSUMPTION:
;   Abort/Quit call from a page control window procedure handler does NOT initiate installer to quit!
;   To workaround this issue we have at least to call the installer process to exit directly from the Win32 API
;   instead of call to Abort/Quit again if Abort/Quit has been called already.
;

StrCpy $QUITCALLED 1 ; just in case
Quit
; nothing more can do here
!macroend

!define !AbortCall "!insertmacro !AbortCall"
!macro !AbortCall cmd event msg
StrCpy $QUIT_CMD "${cmd}"
IfSilent 0 +2
StrCpy $QUIT_CMD "Quit" ; in silent mode there is no .onGUIEnd call, can't postpone unload
IntCmp $SECTION_SCOPE_INDEX 0 0 +2 +2
StrCpy $QUIT_CMD "Quit" ; we are not in a section, quit immediately, otherwise a page can be just skipped w/o actual quit!

${If} $QUITTING = 0
  StrCpy $QUITTING 1

  DetailPrint "!AbortCall: cmd=$\"$QUIT_CMD$\" event=$\"${event}$\": aborting..."

  ; system won't call anything after Abort, so we must call UninitInstall/UninistUninstall at least with special exit code
  !if "${msg}" != ""
  DetailPrint "!AbortCall: ${msg}"
  MessageBox MB_OK|MB_TOPMOST|MB_SETFOREGROUND "${msg}" /SD IDOK
  StrCpy $MSG_ABORT "${msg}"
  !endif
  !ifdef Init_INCLUDED
  ${If} $INITED <> 0 ; ignore uninit if is not inited
    !ifndef __UNINSTALL__
    ${UninitInstall} "${event}"
    !else
    ${UninitUninstall} "${event}"
    !endif
  ${EndIf}
  !endif
${EndIf}

; ASSUMPTION:
;   Abort/Quit call from a page control window procedure handler does NOT initiate installer to quit!
;   To workaround this issue we have at least to call the installer process to exit directly from the Win32 API
;   instead of call to Abort/Quit again if Abort/Quit has been called already.
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

!define Func_Exit "!insertmacro Func_Exit"
!macro Func_Exit un
Function ${un}!Exit
  ${!ExitCall} ""
FunctionEnd
!macroend

!define Include_Exit "!insertmacro Include_Exit"
!macro Include_Exit prefix
${Func_Exit} "${prefix}"
!macroend

!define !Exit "!insertmacro !Exit"
!macro !Exit
!ifndef __UNINSTALL__
Call !Exit
!else
Call un.!Exit
!endif
!macroend

!define Func_Abort "!insertmacro Func_Abort"
!macro Func_Abort un
Function ${un}!Abort
  ${!AbortCall} Abort "Abort" ""
FunctionEnd
!macroend

!define Include_Abort "!insertmacro Include_Abort"
!macro Include_Abort prefix
${Func_Abort} "${prefix}"
!macroend

!define !Abort "!insertmacro !Abort"
!macro !Abort
!ifdef Init_INCLUDED
  !ifndef __UNINSTALL__
  Call !Abort
  !else
  Call un.!Abort
  !endif
!else
  Abort
  Quit ; if not aborted
!endif
!macroend

!define Func_Quit "!insertmacro Func_Quit"
!macro Func_Quit un
Function ${un}!Quit
  ${!AbortCall} Quit "Abort" ""
FunctionEnd
!macroend

!define Include_Quit "!insertmacro Include_Quit"
!macro Include_Quit prefix
${Func_Quit} "${prefix}"
!macroend

!define !Quit "!insertmacro !Quit"
!macro !Quit
!ifdef Init_INCLUDED
  !ifndef __UNINSTALL__
  Call !Quit
  !else
  Call un.!Quit
  !endif
!else
  Quit
!endif
!macroend

!define !AbortWithMsg "!insertmacro !AbortWithMsg"
!macro !AbortWithMsg msg
${!AbortCall} Abort "Abort" `${msg}`
!macroend

!define !QuitWithMsg "!insertmacro !QuitWithMsg"
!macro !QuitWithMsg msg
${!AbortCall} Quit "Abort" `${msg}`
!macroend

; Abort/Quit can't be executed, for example, from a page control window procedure handler, so call it again to accomplish already initiated abort through another way
!define !ExecutePostponedAbort "!insertmacro !ExecutePostponedAbort"
!macro !ExecutePostponedAbort
${If} $QUITCALLED <> 0
  ${!Abort}
${EndIf}
!macroend

!define CommonUnloadUninitCleanupImpl "!insertmacro CommonUnloadUninitCleanupImpl"
!macro CommonUnloadUninitCleanupImpl
${Push} $R9

; wait a bit to give a chance to show up popup tooltip in the system tray about install/uninstall/unpack completness
${IsSilentSetupNotify} $R9
${If} $R9 <> 0
  Sleep $SILENT_SETUP_NOTIFY_POPUP_SHOW_DELAY
${EndIf}

; remember last error level to restore it
GetErrorLevel $LAST_ERROR

; call pending plugins unload
${UnloadUninitPlugins}

Pop $R9 ; w/o debug check because all plugin already unloaded!
!macroend

!define UnloadUninitPlugins "!insertmacro UnloadUninitPlugins"
!macro UnloadUninitPlugins

; unload dll
SetPluginUnload manual

; force unload plugins
${locate::Unload}
${registry::Unload}

; force release plugins to unlock plugins folder for delete it on exit
System::Call "kernel32::GetModuleHandle(t 'NSISpcre.dll') p .R9"
System::Call "kernel32::FreeLibrary(p $R9) i"

; unload Stack plugin
${If} $WNDPROC_STACK_HANDLE <> 0
  ${stack::dll_destroy} $WNDPROC_STACK_HANDLE
${EndIf}
StrCpy $WNDPROC_STACK_HANDLE 0 ; just in case

${stack::Unload}

StrCpy $PLUGINS_UNLOADED 1

!ifndef __UNINSTALL__
RMDir "$SETUP_SESSION_DIR_PATH_LOCAL"
!endif

; in case of abortion we must cleanup PluginsDir recursively
RMDir /r "$PluginsDir"

; restore last error level again
SetErrorLevel $LAST_ERROR
!macroend

!define Func_UninitInstall "!insertmacro Func_UninitInstall"
!macro Func_UninitInstall
Function Uninit
  ${ExchStack1} $R0
  ;R0 - event_msg

  StrCpy $INITED 0
  StrCpy $UNINIT_EVENT $R0

  ${If} $UNINITING = 0
    StrCpy $UNINITING 1
  ${Else}
    ${PopStack1} $R0
    Return ; ignore double uninit
  ${EndIf}

  ${PushStack9} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} Uninit 1 0

  ; get last error level to save it
  GetErrorLevel $R9
  WriteINIStr "$SETUP_INI_OUT" setup EXIT_CODE "$R9"

  SetOverwrite off ; just in case
  SetOutPath "$SYSDIR" ; avoid working directory lock

  !if "${PARENT.PRODUCT_VERSION}" == ""
  !define NOTIFICATION_TITLE "$APP_NAME"
  !else
  !define NOTIFICATION_TITLE "$APP_NAME v${PARENT.PRODUCT_VERSION}${PARENT.BUILD_NUMBER_VERSION_SUFFIX}"
  !endif

  ${Switch} $UNINIT_EVENT
    ${Case} "onInstSuccess"
      WriteINIStr "$SETUP_INI_OUT" setup EXIT_STATUS_TYPE "onInstSuccess"
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_COMPLETED"
      ${Break}
    ${Case} "onInstFailed"
      WriteINIStr "$SETUP_INI_OUT" setup EXIT_STATUS_TYPE "onInstFailed"
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_CANCELED"
      ${Break}
    ${Case} "customUserAbort"
      StrCpy $CUSTOM_ABORT 1
      StrCpy $CUSTOM_USER_ABORT 1
      WriteINIStr "$SETUP_INI_OUT" setup EXIT_STATUS_TYPE "customUserAbort"
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_CANCELED"
      ${Break}
    ${Case} "Exit"
      StrCpy $CUSTOM_ABORT 1
      WriteINIStr "$SETUP_INI_OUT" setup EXIT_STATUS_TYPE "Exit"
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_COMPLETED"
      ${Break}
    ${Case} "Abort"
      StrCpy $CUSTOM_ABORT 1
      WriteINIStr "$SETUP_INI_OUT" setup EXIT_STATUS_TYPE "Abort"
      ${If} $MSG_ABORT != ""
        ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_ABORT$\n$\n$MSG_NOTIFY_PRODUCT_SETUP_ABORTED"
      ${Else}
        ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_ABORTED"
      ${EndIf}
      ${Break}
    ${Default}
      WriteINIStr "$SETUP_INI_OUT" setup EXIT_STATUS_TYPE "Unknown"
  ${EndSwitch}

  !undef NOTIFICATION_TITLE

  ${DebugStackCheckFrame} Uninit 1 0

  ${IfNot} ${Silent} ; in silent mode there is no .onGUIEnd call, can't postpone unload
    ${If} $QUIT_CMD == "Abort" ; postpone unload has meaninig for the Abort call ONLY, the Quit will quit immediately
      ${If} $CUSTOM_USER_ABORT = 0
        ; customUserAbort is not the last function to call, we should not unload here
        StrCpy $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP 1
      ${EndIf}

      ${If} $SECTION_SCOPE_INDEX = 0
      ${OrIf} $QUIT_CMD == "Abort"
        ; Abort in section won't initiate immediate quit, we should not unload here
        StrCpy $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP 1
      ${EndIf}
    ${EndIf}
  ${EndIf}

  ; exit frame early because CommonUnloadUninitCleanupImpl can unload all plugins including the stack check plugin!
  ${DebugStackExitFrame} Uninit 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ${If} $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP = 0
    ${CommonUnloadUninitCleanupImpl}
  ${EndIf}
FunctionEnd
!macroend

!define Include_UninitInstall "!insertmacro Include_UninitInstall"
!macro Include_UninitInstall
${Func_UninitInstall}
${Func_UninitInstallGUI}
!macroend

!define Func_UninitUninstall "!insertmacro Func_UninitUninstall"
!macro Func_UninitUninstall
Function un.Uninit
  ${ExchStack1} $R0
  ;R0 - event_msg

  StrCpy $INITED 0
  StrCpy $UNINIT_EVENT $R0

  ${If} $UNINITING = 0
    StrCpy $UNINITING 1
  ${Else}
    ${PopStack1} $R0
    Return ; ignore double uninit
  ${EndIf}

  ${PushStack9} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ; different stack frame ids to avoid compilation errors
  ${If} $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP = 0
    ${DebugStackEnterFrame} un.Uninit 1 0
  ${Else}
    ${DebugStackEnterFrame} un.Uninit 2 0
  ${EndIf}

  SetOverwrite off ; just in case
  SetOutPath "$SYSDIR" ; avoid working directory lock

  !if "${PARENT.PRODUCT_VERSION}" == ""
  !define NOTIFICATION_TITLE "$APP_NAME"
  !else
  !define NOTIFICATION_TITLE "$APP_NAME v${PARENT.PRODUCT_VERSION}${PARENT.BUILD_NUMBER_VERSION_SUFFIX}"
  !endif

  ${Switch} $UNINIT_EVENT
    ${Case} "onUninstSuccess"
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_COMPLETED"
      ${Break}
    ${Case} "onUninstFailed"
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_CANCELED"
      ${Break}
    ${Case} "customUserAbort"
      StrCpy $CUSTOM_ABORT 1
      StrCpy $CUSTOM_USER_ABORT 1
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_CANCELED"
      ${Break}
    ${Case} "Exit"
      StrCpy $CUSTOM_ABORT 1
      ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_COMPLETED"
      ${Break}
    ${Case} "Abort"
      StrCpy $CUSTOM_ABORT 1
      ${If} $MSG_ABORT != ""
        ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_ABORT$\n$\n$MSG_NOTIFY_PRODUCT_SETUP_CANCELED"
      ${Else}
        ${ShowSilentSetupNotify} "${NOTIFICATION_TITLE}" "$MSG_NOTIFY_PRODUCT_SETUP_CANCELED"
      ${EndIf}
      ${Break}
  ${EndSwitch}

  !undef NOTIFICATION_TITLE

  ${DebugStackCheckFrame} un.Uninit 1 0

  ; different stack frame ids to avoid compilation errors
  ${If} $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP <> 0
    ${DebugStackExitFrame} un.Uninit 2 0

    ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
  ${Else}
    ; exit frame early because CommonUnloadUninitCleanupImpl will unload all plugins including the stack check plugin!
    ${DebugStackExitFrame} un.Uninit 1 0

    ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

    ${CommonUnloadUninitCleanupImpl}
  ${EndIf}
FunctionEnd
!macroend

!define Include_UninitUninstall "!insertmacro Include_UninitUninstall"
!macro Include_UninitUninstall
${Func_UninitUninstall}
!macroend

!define Func_UninitInstallGUI "!insertmacro Func_UninitInstallGUI"
!macro Func_UninitInstallGUI
Function UninitGUI
  ; Reload variables from language tables (language variables initializes ONLY after .onInit call!)
  StrCpy $APP_NAME $(APP_NAME)

  ; last place to unload in some cases
  ${If} $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP <> 0
    ${CommonUnloadUninitCleanupImpl}
  ${EndIf}
FunctionEnd
!macroend

Function AskSetupInstallAbort
  ${DebugStackEnterFrame} AskSetupInstallAbort 1 0

  ${IfNot} ${Silent}
  ${OrIf} $COMPONENTS_SILENT_INSTALL = 0
    DetailPrint "$(MSG_SETUP_INSTALL_ABORT_LOG)"
    MessageBox MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "$(MSG_SETUP_INSTALL_ABORT_ASKING)" /SD IDNO IDYES abort
  ${EndIf}
  Goto end

  abort:
  ${!Abort}

  end:
  ${DebugStackExitFrame} AskSetupInstallAbort 1 0
FunctionEnd

!define ProcessLastNsisSetupExitStatus "!insertmacro ProcessLastNsisSetupExitStatus"
!macro ProcessLastNsisSetupExitStatus cmd args setup_ini_out return_code_inout_var
${Call_BeginMacroBodyFunction} "" ; macro currently available in installation section ONLY

${DebugStackEnterFrame} ProcessLastNsisSetupExitStatus 0 1

${PushStack4} `${cmd}` `${args}` `${setup_ini_out}` `${return_code_inout_var}`

!ifndef __UNINSTALL__
Call ProcessLastNsisSetupExitStatus
!else
Call un.ProcessLastNsisSetupExitStatus
!endif
${PopStack1} $DEBUG_RET0

${DebugStackExitFrame} ProcessLastNsisSetupExitStatus 0 1

StrCpy ${return_code_inout_var} $DEBUG_RET0
!macroend

!define Func_ProcessLastNsisSetupExitStatus "!insertmacro Func_ProcessLastNsisSetupExitStatus"
!macro Func_ProcessLastNsisSetupExitStatus un
Function ${un}ProcessLastNsisSetupExitStatus
  ${ExchStack4} $R0 $R1 $R2 $R3
  ; R0 - cmd
  ; R1 - args
  ; R2 - setup_ini_out
  ; R3 - return_code_inout_var
  ${PushStack2} $R8 $R9

  ${DebugStackEnterFrame} ProcessLastNsisSetupExitStatus 1 0

  DetailPrint "Last error code: $LAST_ERROR"
  ${UpdateSilentSetupNotify}

  ${If} $R2 != ""
    ${GetLastNsisSetupExitStatus} $R8 $R9 $R0 $R1 $R2

    ${Switch} $R8
    !ifndef __UNINSTALL__
      ${Case} "onInstSuccess"
    !else
      ${Case} "onUninstSuccess"
    !endif
      ${Case} "Exit"
        ${Break}
      ${Default}
        DetailPrint "$R9"
        ${IfNot} ${Silent}
        ${OrIf} $COMPONENTS_SILENT_INSTALL = 0
          ; set return_code as last error level
          SetErrorLevel $R3

          DetailPrint "$(MSG_SETUP_INSTALL_ABORT_LOG)"
          MessageBox MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "$R9$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)" /SD IDNO IDYES 0 IDNO continue

          ${!AbortCall} Abort $R8 ""
        ${EndIf}
      ${Break}
    ${EndSwitch}
  ${EndIf}

  ${DebugStackCheckFrame} ProcessLastNsisSetupExitStatus 1 0

  ${If} $R3 <> 0
    ${IfNot} ${Silent}
    ${OrIf} $COMPONENTS_SILENT_INSTALL = 0
      ; set return_code as last error level
      SetErrorLevel $R3

      DetailPrint "$(MSG_SETUP_INSTALL_ABORT_LOG)"
      MessageBox MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "$(MSG_SETUP_INSTALL_ABORT_ASKING)" /SD IDNO IDYES 0 IDNO continue

      ${!Abort}
    ${EndIf}
  ${EndIf}

  continue:
  ${DebugStackExitFrame} ProcessLastNsisSetupExitStatus 1 0

  ${PushStack1} $R3
  ${ExchStack1} 6

  ${PopStack6} $R1 $R2 $R3 $R8 $R9 $R0
FunctionEnd
!macroend

!define Include_ProcessLastNsisSetupExitStatus "!insertmacro Include_ProcessLastNsisSetupExitStatus"
!macro Include_ProcessLastNsisSetupExitStatus prefix
${Func_ProcessLastNsisSetupExitStatus} "${prefix}"
!macroend

!endif
