!ifndef _NSIS_SETUP_LIB_GUINET_LOGON_NSI
!define _NSIS_SETUP_LIB_GUINET_LOGON_NSI

!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\net.nsi"
!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\gui.nsi"

; UserMgr IP logon + status label + handler variables
!define DeclareAddressLogonGUIStatusLabelVariables "!insertmacro DeclareAddressLogonGUIStatusLabelVariables"
!macro DeclareAddressLogonGUIStatusLabelVariables page_name_prefix ctrl_name_prefix
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount ; logon status count from last reset
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonAddressToken
; immediate logon response: -255 - undefined, -1 - first request, 0 - OK, 1 - system error, 255 - async request error
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatus
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatus ; the same as original status, but avoids trigger to -1 (first request) state until reset
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError ; error code if logon error
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonRequestAsyncID
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateFromTimer

Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelColor
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsDataBuf ; Window class buffer
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsOldUserData ; Window class data
!macroend

; UserMgr address logon + status label + handler functions
!define DeclareAddressLogonGUIStatusLabelFunctions "!insertmacro DeclareAddressLogonGUIStatusLabelFunctions"
!macro DeclareAddressLogonGUIStatusLabelFunctions \
    page_name_prefix ctrl_name_prefix address_value_var user_name user_pass ignore_page_update_var external_timer_update_timeout_msec_value \
    callback_funcs
${!error_if_nvar} "${address_value_var}" "DeclareAddressLogonGUIStatusLabelFunctions: address_value_var must be a variable!"
${!error_if_nvar} "${ignore_page_update_var}" "DeclareAddressLogonGUIStatusLabelFunctions: ignore_page_update_var must be a variable!"
${!error_if_empty} "${user_name}" "DeclareAddressLogonGUIStatusLabelFunctions: user_name must be not empty!"

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_InitLogonStatus
  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatus
  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatusLabelParams
FunctionEnd
  
Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatus
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount 0
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonAddressToken ":" ; empty address token
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus -255
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatus $${page_name_prefix}_${ctrl_name_prefix}LogonStatus
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError 0
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonRequestAsyncID 0
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateFromTimer 0
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync

  ${NSD_KillTimer} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateTimer

  UserMgr::CancelLogonNetShareAsync $${page_name_prefix}_${ctrl_name_prefix}LogonRequestAsyncID
  Pop $LAST_STATUS_STR

  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatus

  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync_Callback

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_LogonSync
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_LogonSync

  IntOp $${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount $${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount + 1
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonAddressToken "${user_name}@${user_pass}:${address_value_var}" ; address token
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus -1 ; first request
  ${If} $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatus = -255 ; only once until reset
    StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatus $${page_name_prefix}_${ctrl_name_prefix}LogonStatus
  ${EndIf}

  UserMgr::TryLogonNetShareAsync "${address_value_var}" "${user_name}" "${user_pass}"
  Pop $LAST_STATUS_STR
  Pop $${page_name_prefix}_${ctrl_name_prefix}LogonRequestAsyncID ; async queue handle id, negative if asynchronous request pending
  
  ; start logon status update timer
  ${NSD_CreateTimer} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateTimer ${external_timer_update_timeout_msec_value} ; external timer update function timeout (msec)

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_LogonSync
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatusLabelParams
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatusLabelParams

  ${Switch} $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatus
    ${Case} -1 ; first request
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel $(PRODUCT_IP_ADDRESS_LOGON_STATUS_PENDING) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelColor 0x996633
    ${Break}

    ${Case} 0 ; OK
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel $(PRODUCT_IP_ADDRESS_LOGON_STATUS_OK) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelColor 0x33CC33
    ${Break}

    ${Case} 1 ; system error
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel $(PRODUCT_IP_ADDRESS_LOGON_STATUS_SYSTEM_ERROR) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount"
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel "{{ERROR_STR}}" "$${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelColor 0xFF0000
    ${Break}

    ${Case} 255 ; async request error (may be Win32 ERROR_OPERATION_ABORTED or may be internal asynchronous request error)
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel $(PRODUCT_IP_ADDRESS_LOGON_STATUS_ASYNC_REQUEST_ERROR) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount"
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel "{{ERROR_STR}}" "$${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelColor 0xFF0000
    ${Break}

    ${Default}
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel " " ; label should not be empty at creation!
  ${EndSwitch}

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatusLabelParams
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update

  StrCpy ${ignore_page_update_var} 1 ; ignore page update recursive call, we need only one label change w/o whole page update

  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ResetLogonStatusLabelParams

  ; transparent label redraw trick through Hide-Show
  ShowWindow $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID ${SW_HIDE} ; always hide in case of cancel state

  ${GUISetGetTextVar} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabel

  ${If} $${page_name_prefix}_${ctrl_name_prefix}LogonStatus >= -1
    ${UpdateWindowClassCtlColors} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelColor "transparent" \
      $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsDataBuf $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsOldUserData
    ShowWindow $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID ${SW_SHOW}
  ${EndIf}

  StrCpy ${ignore_page_update_var} 0

  ${PushStack2} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatus
  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update_Callback

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_AddressToken_Callback
  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_AddressToken_Callback__value_def \
    0 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_AddressToken_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Logon" "AddressToken"
    Call ${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_AddressToken_Callback__value_def}
  !else
    ${PushStack1} $${page_name_prefix}_${ctrl_name_prefix}LogonAddressToken
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_AddressToken_Callback__value_def
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback
  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback__value_def \
    1 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Logon" "ValidateAddress"
    Call ${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback__value_def}
  !else
    ${PushStack1} 1
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback__value_def
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update_Callback
  ${ExchStack2} $R0 $R1

  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update_Callback__value_def \
    2 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Logon" "Update"
    Call ${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update_Callback__value_def}
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update_Callback__value_def

  ${PopStack2} $R0 $R1
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync_Callback
  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLongAsync_Callback__value_def \
    3 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLongAsync_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Logon" "CancelLogonAsync"
    Call ${${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLongAsync_Callback__value_def}
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLongAsync_Callback__value_def
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateTimer
  ${If} $${page_name_prefix}_${ctrl_name_prefix}LogonRequestAsyncID = 0 ; nothing to update or in cancelling state
    Return
  ${EndIf}

  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateTimer

  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_AddressToken_Callback
  ${PopStack1} $R8

  ; check if address has changed
  ${If} $${page_name_prefix}_${ctrl_name_prefix}LogonAddressToken == $R8
    UserMgr::GetLogonNetShareAsyncStatus $${page_name_prefix}_${ctrl_name_prefix}LogonRequestAsyncID
    Pop $R0 ; async request status code
    Pop $LAST_STATUS_STR ; status string
    Pop $R1 ; WNet error code
    Pop $R2 ; WNet error string

    ${If} $R0 >= ${ASYNC_REQUEST_STATUS_ACCOMPLISH}
      ${GetUserMgrErrorMessage} $LAST_STATUS_STR $LAST_ERROR $R4
    ${EndIf}

    ${If} $R0 = ${ASYNC_REQUEST_STATUS_ACCOMPLISH}
      ${If} $LAST_ERROR = 0 ; logon has no Win32 errors
        StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus 0
      ${Else}
        StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus 1
        IntFmt $R9 "0x%08X" $LAST_ERROR
        ${If} $LAST_STATUS_STR != ""
          StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError "$R9: $R4"
        ${ElseIf} $R2 != ""
          StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError "$R9: $R2"
        ${Else}
          StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError "$R9: Unscripted error."
        ${EndIf}
      ${EndIf}
    ${ElseIf} $R0 > ${ASYNC_REQUEST_STATUS_ACCOMPLISH}
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus 255
      IntFmt $R9 "0x%08X" $LAST_ERROR
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatusError "$R9"
    ${EndIf}

    ${If} $R0 >= ${ASYNC_REQUEST_STATUS_ACCOMPLISH} ; asynchronous request is ended, we have to restart asynchronous logon...
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonLastResponseStatus $${page_name_prefix}_${ctrl_name_prefix}LogonStatus

      Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
      ${PopStack1} $R8
      ${If} $R8 <> 0
        Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_LogonSync
      ${Else}
        Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync ; ...otherwise cancel even if not started (the asynchronous logon should ignore cancel on not started logon)
      ${EndIf}
    ${Else}
      ; logon is still in progress
      IntOp $${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount $${page_name_prefix}_${ctrl_name_prefix}LogonStatusCount + 1
    ${Endif}
  ${Else}
    ; reset logon
    Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync

    Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
    ${PopStack1} $R8
    ${If} $R8 <> 0
      Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_LogonSync
    ${EndIf}
  ${EndIf}

  ; from timer handler update
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateFromTimer 1
  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateFromTimer 0

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_UpdateTimer
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_ResetWindowClassCtlColors
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_ResetWindowClassCtlColors

  ${ResetWindowClassCtlColors} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID \
    $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsDataBuf $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsOldUserData

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_ResetWindowClassCtlColors
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}_PageLeave
  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync
  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_ResetWindowClassCtlColors
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}_LogonStatusUpdate
  ; start logon and update status immediately
  ${If} $${page_name_prefix}_${ctrl_name_prefix}LogonStatus = -255
    Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
    ${PopStack1} $R8
    ${If} $R8 <> 0
      Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_LogonSync
    ${EndIf}
  ${EndIf}

  ${If} $${page_name_prefix}_${ctrl_name_prefix}LogonStatus = -1
    Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
    ${PopStack1} $R8
    ${If} $R8 = 0
      Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_CancelLogonAsync
    ${EndIf}
  ${EndIf}

  Call ${page_name_prefix}_${ctrl_name_prefix}LogonStatus_Update ; always update
FunctionEnd
!macroend

!define GUIInsertAddressLogonStatusLabel "!insertmacro GUIInsertAddressLogonStatusLabel"
!macro GUIInsertAddressLogonStatusLabel page_name_prefix ctrl_name_prefix left top width height label id_var style font_name font_size font_weight create_font_flags
  ${DebugStackEnterFunction} GUIInsertAddressLogonStatusLabel

  ${GUIInsertLabel} "${left}" "${top}" "${width}" "${height}" "${label}" "${id_var}" "${style}"
  ${UpdateWindowClassCtlColors} $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID "" transparent \
    $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsDataBuf $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID_CtlColorsOldUserData
  #SetCtlColors $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID 0xFF0000 transparent
  ShowWindow $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID ${SW_HIDE}
  CreateFont $R9 "${font_name}" "${font_size}" "${font_weight}" ${create_font_flags}
  SendMessage $${page_name_prefix}_${ctrl_name_prefix}LogonStatusLabelID ${WM_SETFONT} $R9 0

  ${DebugStackExitFunction} GUIInsertAddressLogonStatusLabel
!macroend

!endif
