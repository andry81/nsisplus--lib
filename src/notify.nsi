!ifndef _NSIS_SETUP_LIB_NOTIFY_NSI
!define _NSIS_SETUP_LIB_NOTIFY_NSI

!define ShowSilentSetupNotify "!insertmacro ShowSilentSetupNotify"
!macro ShowSilentSetupNotify title text
${DebugStackEnterFrame} ShowSilentSetupNotify 0 1

${If} $SILENT_SETUP <> 0
  ; WARNING:
  ;   Always remove icon which might be added in different process (for example, in uninstaller or in parent installer), otherwise it WON'T BE UPDATED!
  ;
  NotifyIcon::Icon "r" 103
  !if ${ENABLE_TEMP_WORKAROUNDS} <> 0
  ; WTF?
  ${Pop} $NULL
  !endif
  NotifyIcon::Icon "aiy" 103
  NotifyIcon::Icon "b" "${title}" "${text}"
  NotifyIcon::Icon "p" "Completed %d%%"
${EndIf}

${DebugStackExitFrame} ShowSilentSetupNotify 0 1
!macroend

!define UpdateSilentSetupNotify "!insertmacro UpdateSilentSetupNotify"
!macro UpdateSilentSetupNotify
${DebugStackEnterFrame} UpdateSilentSetupNotify 0 1

${If} $SILENT_SETUP <> 0
  ; icon update with autodetect
  NotifyIcon::Icon "p" "Completed %d%%"
${EndIf}

${DebugStackExitFrame} UpdateSilentSetupNotify 0 1
!macroend

!define IsSilentSetupNotify "!insertmacro IsSilentSetupNotify"
!macro IsSilentSetupNotify var
StrCpy ${var} $SILENT_SETUP
!macroend

!endif
