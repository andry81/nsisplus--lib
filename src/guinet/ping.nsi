!ifndef _NSIS_SETUP_LIB_GUINET_PING_NSI
!define _NSIS_SETUP_LIB_GUINET_PING_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\net.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\gui.nsi"

; UserMgr IP ping + status label + handler variables
!define DeclareAddressPingGUIStatusLabelVariables "!insertmacro DeclareAddressPingGUIStatusLabelVariables"
!macro DeclareAddressPingGUIStatusLabelVariables page_name_prefix ctrl_name_prefix
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatusCount ; ping status count from last reset
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingAddressToken
; immediate ping response: -255 - undefined, -1 - first request, 0 - OK, 1 - address is unreachable, 2 - network is unreachable, 254 - undescripted error, 255 - async request error
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatus
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatus ; the same as original status, but avoids trigger to -1 (first request) state until reset
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatusError ; error code if ping error
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingRequestAsyncID
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateFromTimer

Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsDataBuf ; Window class buffer
Var /GLOBAL ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsOldUserData ; Window class data
!macroend

; UserMgr address ping + status label + handler functions
!define DeclareAddressPingGUIStatusLabelFunctions "!insertmacro DeclareAddressPingGUIStatusLabelFunctions"
!macro DeclareAddressPingGUIStatusLabelFunctions \
            page_name_prefix ctrl_name_prefix address_value_var ignore_page_update_var internal_ping_timeout_msec_value external_timer_update_timeout_msec_value \
            callback_funcs
${!error_if_nvar} "${address_value_var}" "DeclareAddressPingGUIStatusLabelFunctions: address_value_var must be a variable!"
${!error_if_nvar} "${ignore_page_update_var}" "DeclareAddressPingGUIStatusLabelFunctions: ignore_page_update_var must be a variable!"

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_InitPingStatus
  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatus
  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatusLabelParams
FunctionEnd
  
Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatus
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusCount 0
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingAddressToken "0.0.0.0" ; empty address token
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus -255
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatus $${page_name_prefix}_${ctrl_name_prefix}PingStatus
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatusError 0
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingRequestAsyncID 0
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateFromTimer 0
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync

  ${NSD_KillTimer} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateTimer

  UserMgr::CancelPingAsync $${page_name_prefix}_${ctrl_name_prefix}PingRequestAsyncID
  Pop $LAST_STATUS_STR

  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatus

  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync_Callback

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_PingSync
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_PingSync

  IntOp $${page_name_prefix}_${ctrl_name_prefix}PingStatusCount $${page_name_prefix}_${ctrl_name_prefix}PingStatusCount + 1
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingAddressToken "${address_value_var}" ; address token
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus -1 ; first request
  ${If} $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatus = -255 ; only once until reset
    StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatus $${page_name_prefix}_${ctrl_name_prefix}PingStatus
  ${EndIf}

  UserMgr::PingAsync "${address_value_var}" "${page_name_prefix}:${ctrl_name_prefix}" "${internal_ping_timeout_msec_value}" ; internal ping timeout (msec)
  Pop $LAST_STATUS_STR
  Pop $${page_name_prefix}_${ctrl_name_prefix}PingRequestAsyncID ; async queue handle id, negative if asynchronous request pending
  
  ; start ping status update timer
  ${NSD_CreateTimer} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateTimer ${external_timer_update_timeout_msec_value} ; external timer update function timeout (msec)

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_PingSync
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatusLabelParams
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatusLabelParams

  ${Switch} $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatus
    ${Case} -1 ; first request
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $(PRODUCT_IP_ADDRESS_PING_STATUS_PENDING) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}PingStatusCount"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor 0x996633
    ${Break}

    ${Case} 0 ; OK
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $(PRODUCT_IP_ADDRESS_PING_STATUS_OK) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}PingStatusCount"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor 0x33CC33
    ${Break}

    ${Case} 1 ; address is unreachable
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $(PRODUCT_IP_ADDRESS_PING_STATUS_ADDRESS_UNREACHABLE) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}PingStatusCount"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor 0xFF0000
    ${Break}

    ${Case} 2 ; network is unreachable
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $(PRODUCT_IP_ADDRESS_PING_STATUS_NETWORK_UNREACHABLE) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}PingStatusCount"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor 0xFF0000
    ${Break}

    ${Case} 254 ; undescripted ping error
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $(PRODUCT_IP_ADDRESS_PING_STATUS_UNSCRIPTED_ERROR) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}PingStatusCount"
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel "{{ERROR_STR}}" "$${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatusError"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor 0xFF0000
    ${Break}

    ${Case} 255 ; async request error (may be Win32 ERROR_OPERATION_ABORTED or may be internal asynchronous request error)
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $(PRODUCT_IP_ADDRESS_PING_STATUS_ASYNC_REQUEST_ERROR) "{{STATUS_COUNT}}" "$${page_name_prefix}_${ctrl_name_prefix}PingStatusCount"
      ${StrRep} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel "{{ERROR_STR}}" "$${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatusError"
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor 0xFF0000
    ${Break}

    ${Default}
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel " " ; label should not be empty at creation!
  ${EndSwitch}

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatusLabelParams
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update

  StrCpy ${ignore_page_update_var} 1 ; ignore page update recursive call, we need only one label change w/o whole page update

  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ResetPingStatusLabelParams

  ; transparent label redraw trick through Hide-Show
  ShowWindow $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID ${SW_HIDE} ; always hide in case of cancel state

  ${GUISetGetTextVar} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabel

  ${If} $${page_name_prefix}_${ctrl_name_prefix}PingStatus >= -1
    ${UpdateWindowClassCtlColors} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelColor "transparent" \
      $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsDataBuf $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsOldUserData
    ShowWindow $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID ${SW_SHOW}
  ${EndIf}

  StrCpy ${ignore_page_update_var} 0

  ${PushStack2} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatus
  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update_Callback

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_AddressToken_Callback
  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}PingStatus_AddressToken_Callback__value_def \
    0 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}PingStatus_AddressToken_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Ping" "AddressToken"
    Call ${${page_name_prefix}_${ctrl_name_prefix}PingStatus_AddressToken_Callback__value_def}
  !else
    ${PushStack1} $${page_name_prefix}_${ctrl_name_prefix}PingAddressToken
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}PingStatus_AddressToken_Callback__value_def
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback
  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback__value_def \
    1 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Ping" "ValidateAddress"
    Call ${${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback__value_def}
  !else
    ${PushStack1} 1
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback__value_def
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update_Callback
  ${ExchStack2} $R0 $R1

  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update_Callback__value_def \
    2 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Ping" "CancelPingAsync"
    Call ${${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update_Callback__value_def}
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update_Callback__value_def

  ${PopStack2} $R0 $R1
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync_Callback
  ${!define_list_value_by_index} "" \
    ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync_Callback__value_def \
    3 "${callback_funcs}" "" ":"
  !if "${${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync_Callback__value_def}" != ""
    #${PushStack4} "${page_name_prefix}" "${ctrl_name_prefix}" "Ping" "CancelPingAsync"
    Call ${${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync_Callback__value_def}
  !endif
  !undef ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync_Callback__value_def
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateTimer
  ${If} $${page_name_prefix}_${ctrl_name_prefix}PingRequestAsyncID = 0 ; nothing to update or in cancelling state
    Return
  ${EndIf}

  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateTimer

  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_AddressToken_Callback
  ${PopStack1} $R8

  ; check if address has changed
  ${If} $${page_name_prefix}_${ctrl_name_prefix}PingAddressToken == $R8
    UserMgr::GetPingAsyncStatus $${page_name_prefix}_${ctrl_name_prefix}PingRequestAsyncID
    Pop $R0 ; async request status code
    Pop $LAST_STATUS_STR ; status string
    Pop $R1 ; RTT
    Pop $R2 ; status
    Pop $R3 ; address
    Pop $R4 ; responses
    Pop $R5 ; reply

    ${If} $R0 >= ${ASYNC_REQUEST_STATUS_ACCOMPLISH}
      ${GetUserMgrErrorMessage} $LAST_STATUS_STR $LAST_ERROR $NULL
    ${EndIf}

    ${If} $R0 = ${ASYNC_REQUEST_STATUS_ACCOMPLISH}
      UserMgr::GetPingStatusMessage $R2
      Pop $R6

      ${If} $LAST_ERROR = 0 ; ping has no Win32 errors
        ${If} $R6 == "IP_SUCCESS"
          StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus 0
        ${Else}
          StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus 1 ; treat as "address is unreachable"
        ${EndIf}
      ${Else}
        ; $LAST_ERROR = 0x2B02 ("Error due to lack of resources.") - special case, there is not enough ping timeout to return "correct-by-system" answer
        ; To handle that case we can test directly on "IP_REQ_TIMED_OUT" ping status
        ${If} $LAST_ERROR <> ${ERROR_NETWORK_UNREACHABLE}
        ${AndIf} $LAST_ERROR <> ${ERROR_HOST_UNREACHABLE}
          ${If} $R6 == "IP_REQ_TIMED_OUT"
            StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus 1 ; treat as "address is unreachable"
          ${Else}
            StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus 254
            IntFmt $R9 "0x%08X" $LAST_ERROR
            StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatusError "$R6 ($R9)"
          ${EndIf}
        ${Else}
          StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus 2
          StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatusError "$R6 ($R9)"
        ${EndIf}
      ${EndIf}
    ${ElseIf} $R0 > ${ASYNC_REQUEST_STATUS_ACCOMPLISH}
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus 255
      IntFmt $R9 "0x%08X" $LAST_ERROR
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatusError "$R9"
    ${EndIf}

    ${If} $R0 >= ${ASYNC_REQUEST_STATUS_ACCOMPLISH} ; asynchronous request is ended, we have to restart asynchronous ping...
      StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingLastResponseStatus $${page_name_prefix}_${ctrl_name_prefix}PingStatus

      Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
      ${PopStack1} $R8
      ${If} $R8 <> 0
        Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_PingSync
      ${Else}
        Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync ; ...otherwise cancel even if not started (the asynchronous ping should ignore cancel on not started ping)
      ${EndIf}
    ${Else}
      ; ping is still in progress
      IntOp $${page_name_prefix}_${ctrl_name_prefix}PingStatusCount $${page_name_prefix}_${ctrl_name_prefix}PingStatusCount + 1
    ${Endif}
  ${Else}
    ; reset ping
    Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync

    Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
    ${PopStack1} $R8
    ${If} $R8 <> 0
      Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_PingSync
    ${EndIf}
  ${EndIf}

  ; from timer handler update
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateFromTimer 1
  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update
  StrCpy $${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateFromTimer 0

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatus_UpdateTimer
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_ResetWindowClassCtlColors
  ${DebugStackEnterFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_ResetWindowClassCtlColors

  ${ResetWindowClassCtlColors} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID \
    $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsDataBuf $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsOldUserData

  ${DebugStackExitFunction} ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_ResetWindowClassCtlColors
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}_PageLeave
  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync
  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_ResetWindowClassCtlColors
FunctionEnd

Function ${page_name_prefix}_${ctrl_name_prefix}_PingStatusUpdate
  ; start ping and update status immediately
  ${If} $${page_name_prefix}_${ctrl_name_prefix}PingStatus = -255
    Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
    ${PopStack1} $R8
    ${If} $R8 <> 0
      Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_PingSync
    ${EndIf}
  ${EndIf}

  ${If} $${page_name_prefix}_${ctrl_name_prefix}PingStatus = -1
    Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_ValidateAddress_Callback ; ...but only if state of address is valid...
    ${PopStack1} $R8
    ${If} $R8 = 0
      Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_CancelPingAsync
    ${EndIf}
  ${EndIf}

  Call ${page_name_prefix}_${ctrl_name_prefix}PingStatus_Update ; always update
FunctionEnd
!macroend

!define GUIInsertAddressPingStatusLabel "!insertmacro GUIInsertAddressPingStatusLabel"
!macro GUIInsertAddressPingStatusLabel page_name_prefix ctrl_name_prefix left top width height label id_var style font_name font_size font_weight create_font_flags
  ${DebugStackEnterFunction} GUIInsertAddressPingStatusLabel

  ${GUIInsertLabel} "${left}" "${top}" "${width}" "${height}" "${label}" "${id_var}" "${style}"
  ${UpdateWindowClassCtlColors} $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID "" transparent \
    $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsDataBuf $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID_CtlColorsOldUserData
  #SetCtlColors $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID 0xFF0000 transparent
  ShowWindow $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID ${SW_HIDE}
  CreateFont $R9 "${font_name}" "${font_size}" "${font_weight}" ${create_font_flags}
  SendMessage $${page_name_prefix}_${ctrl_name_prefix}PingStatusLabelID ${WM_SETFONT} $R9 0

  ${DebugStackExitFunction} GUIInsertAddressPingStatusLabel
!macroend

!endif
