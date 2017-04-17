!ifndef USER_MGR_INCLUDED
!define USER_MGR_INCLUDED

!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\win32.nsi"

!define SG_ADMINISTRATORS                 "S-1-5-32-544"
!define SG_USERS                          "S-1-5-32-545"
!define SG_POWERUSERS                     "S-1-5-32-547"
!define SG_GUESTS                         "S-1-5-32-546"

!define SG_EVERYONE                       "S-1-1-0"
!define SG_CREATOROWNER                   "S-1-3-0"
!define SG_NTAUTHORITY_NETWORK            "S-1-5-2"
!define SG_NTAUTHORITY_INTERACTIVE        "S-1-5-4"
!define SG_NTAUTHORITY_SYSTEM             "S-1-5-18"
!define SG_NTAUTHORITY_AUTHENTICATEDUSERS "S-1-5-11"
!define SG_NTAUTHORITY_LOCALSERVICE       "S-1-5-19"
!define SG_NTAUTHORITY_NETWORKSERVICE     "S-1-5-20"

; order is matter
!define ASYNC_REQUEST_STATUS_UNINIT       -2    ; handle is valid but asynchronous request thread is not yet initialized
!define ASYNC_REQUEST_STATUS_PENDING      -1    ; handle is valid and asynchronous request thread is initialized but is still pending
!define ASYNC_REQUEST_STATUS_ACCOMPLISH   0     ; asynchronous request is finished
!define ASYNC_REQUEST_STATUS_ABORTED      1     ; asynchronous request is aborted in alive thread
!define ASYNC_REQUEST_STATUS_CANCELLED    254   ; asynchronous request is cancelled, thread associated with the request is terminated
!define ASYNC_REQUEST_STATUS_NOT_FOUND    255   ; handle is not associated to anyone asynchronous request


!define GetUserMgrError "!insertmacro GetUserMgrError"
!macro GetUserMgrError mgr_msg err_var
${PushStack4} $R0 $R1 $R2 $R9

!if "${mgr_msg}" S!= "$R0"
StrCpy $R0 "${mgr_msg}"
!endif

StrCpy $R9 ""

StrCpy $R1 $R0 6
${If} $R1 == "ERROR "
  StrCpy $R2 $R0 "" 6
${Else}
  StrCpy $R2 0
${EndIf}

${MacroPopStack4} "${err_var}" "$R2" $R0 $R1 $R2 $R9
!macroend

!define GetUserMgrErrorMessage "!insertmacro GetUserMgrErrorMessage"
!macro GetUserMgrErrorMessage mgr_msg err_var msg_var
${PushStack4} $R0 $R1 $R2 $R9

!if "${mgr_msg}" S!= "$R0"
StrCpy $R0 "${mgr_msg}"
!endif

StrCpy $R9 ""

StrCpy $R1 $R0 6
${If} $R1 == "ERROR "
  StrCpy $R2 $R0 "" 6
  ${GetWin32ErrorMesssage} $R2 $R9
${Else}
  StrCpy $R2 0
${EndIf}

${MacroPopStack4} "${err_var} ${msg_var}" "$R2 $R9" $R0 $R1 $R2 $R9
!macroend

!endif
