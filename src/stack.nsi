; common stack utils

!ifndef _NSIS_SETUP_LIB_STACK_NSI
!define _NSIS_SETUP_LIB_STACK_NSI

!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\preprocessor.nsi"
!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\builtin.nsi"

!define Func_DebugStackImpl "!insertmacro Func_DebugStackImpl"
!macro Func_DebugStackImpl un
Function ${un}DebugStackPopExchOutOfStack_ImplAskAbort
  ${If} $USER_ABORT_ASK_ACCEPTED = 0 ; ignore dialog if already accepted by user
    ${If} $DEBUG <> 0 ; show dialog in silent mode if debugging
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackPopExchOutOfStack_ImplAskAbort" $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "Out of stack:" $DEBUG_R6 "IDYES abort"
    ${Else}
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackPopExchOutOfStack_ImplAskAbort" $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "Out of stack:" $DEBUG_R6 "/SD IDNO IDYES abort"
    ${EndIf}
    Return

    ; Workaround for Abort/Quit call from a page control window procedure handler.
    ; Call !Abort again in case if it has been called already from such handler.

    abort:
    StrCpy $USER_ABORT_ASK_ACCEPTED 1
    ; Use Dumpstate plugin on abort in debug mode
    ${If} $DEBUG <> 0
      Dumpstate::debug
    ${EndIf}
  ${EndIf}

  !ifndef __UNINSTALL__
  Call !Abort
  !else
  Call un.!Abort
  !endif
FunctionEnd

Function ${un}DebugStackInvalidCall_ImplAskAbort
  ${If} $USER_ABORT_ASK_ACCEPTED = 0 ; ignore dialog if already accepted by user
    ${If} $DEBUG <> 0 ; show dialog in silent mode if debugging
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackInvalidCall_ImplAskAbort" $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "Invalid call:" $DEBUG_R6 "IDYES abort"
    ${Else}
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackInvalidCall_ImplAskAbort" $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "Invalid call:" $DEBUG_R6 "/SD IDNO IDYES abort"
    ${EndIf}
    Return

    ; Workaround for Abort/Quit call from a page control window procedure handler.
    ; Call !Abort again in case if it has been called already from such handler.

    abort:
    StrCpy $USER_ABORT_ASK_ACCEPTED 1
    ; Use Dumpstate plugin on abort in debug mode
    ${If} $DEBUG <> 0
      Dumpstate::debug ; will reload on demand
    ${EndIf}
  ${EndIf}

  !ifndef __UNINSTALL__
  Call !Abort
  !else
  Call un.!Abort
  !endif
FunctionEnd
!macroend

!define Include_DebugStackImpl "!insertmacro Include_DebugStackImpl"
!macro Include_DebugStackImpl prefix
${Func_DebugStackImpl} "${prefix}"
!macroend

; Push/Pop/Exch macroses with private stack support, logging and out-of-stack debugging

; Push
!define PushImpl "!insertmacro PushImpl"
!macro PushImpl push_macro stack_handle exp
!define __CURRENT_MACRO_SRCID_PushImpl "${__FILE__}:${__LINE__}"
!define __CURRENT_MACRO_LABELID_PushImpl_VALID_CALL __CURRENT_MACRO_LABELID_PushImpl_VALID_CALL_L${__LINE__}

!define __CURRENT_MACRO_DEF_PushImpl_exp_ESCAPED "" ; compile error if already exists
!searchreplace __CURRENT_MACRO_DEF_PushImpl_exp_ESCAPED "${exp}" "$" "$$"

!if ${ENABLE_DEBUG_PUSHPOP_LOGGING} <> 0
IntCmp $ENABLE_DEBUG_PUSHPOP_LOGGING 0 +2
DetailPrint '${push_macro}: "${__CURRENT_MACRO_DEF_PushImpl_exp_ESCAPED}" = "${exp}" (${__CURRENT_MACRO_SRCID_PushImpl})'
#MessageBox MB_OK '${push_macro}: "${__CURRENT_MACRO_DEF_PushImpl_exp_ESCAPED}" = "${exp}" ($\t${__CURRENT_MACRO_SRCID_PushImpl})'
!endif

!if "${push_macro}" S== "stack::dll_insert"
${!define_if_valid_var} PushImpl__exp_is_valid_var 0 "${exp}" PushImpl__exp_var
!if ${PushImpl__exp_is_valid_var} <> 0
!define PushImpl__exp "$$${PushImpl__exp_var}"
!else
!define PushImpl__exp "${exp}"
!endif
!undef PushImpl__exp_is_valid_var
!undef PushImpl__exp_var

IntCmp ${stack_handle} 0 +2
IntCmp $PLUGINS_UNLOADED 0 ${__CURRENT_MACRO_LABELID_PushImpl_VALID_CALL}
  StrCpy $DEBUG_R3 "PushImpl"
  StrCpy $DEBUG_R4 "${__CURRENT_MACRO_SRCID_PushImpl}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Invalid Call: stack::dll_insert$\n|Expression: $\"${PushImpl__exp}$\"$\n|Expression Value: $\"${exp}$\"$\n|Stack Handle: ${stack_handle}$\n|Plugins Unloaded: $PLUGINS_UNLOADED$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackInvalidCall_ImplAskAbort
  !else
  Call un.DebugStackInvalidCall_ImplAskAbort
  !endif

${__CURRENT_MACRO_LABELID_PushImpl_VALID_CALL}:
!undef PushImpl__exp
${!error_ifndef_nvar_NAN_0} stack_handle "PushImpl: stack handle must be defined and valid handle value: stack_handle=$\"${stack_handle}$\""
!verbose pop

${${push_macro}} `${stack_handle}` `${exp}` 1 $LAST_ERROR ; stack::dll_insert interface, index begins from +/- 1

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!else
${!error_ifdef} stack_handle "PushImpl: stack handle must be not defined or empty: stack_handle=$\"${stack_handle}$\""
!verbose pop

${push_macro} `${exp}` ; builtin Push interface

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!endif

!undef __CURRENT_MACRO_DEF_PushImpl_exp_ESCAPED
!undef __CURRENT_MACRO_LABELID_PushImpl_VALID_CALL
!undef __CURRENT_MACRO_SRCID_PushImpl
!macroend

!define Push "!insertmacro Push"
!macro Push exp
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 "${exp}"

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushImplEntry "!insertmacro PushImplEntry"
!macro PushImplEntry verbose_flag exp
!if ${ENABLE_DEBUG_PUSH} = 0

!verbose pop

Push `${exp}`

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

!else

!if ${verbose_flag} <> 0
  !verbose push
  !verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!endif

${PushImpl} Push `` `${exp}`

!if ${verbose_flag} <> 0
  !verbose pop
!endif

!endif
!macroend

; Pop
!define PopImpl "!insertmacro PopImpl"
!macro PopImpl pop_macro stack_handle exp
!define __CURRENT_MACRO_SRCID_PopImpl "${__FILE__}:${__LINE__}"
!define __CURRENT_MACRO_LABELID_PopImpl_VALID_CALL __CURRENT_MACRO_LABELID_PopImpl_VALID_CALL_L${__LINE__}

!define __CURRENT_MACRO_DEF_PopImpl_exp_ESCAPED "" ; compile error if already exists
!searchreplace __CURRENT_MACRO_DEF_PopImpl_exp_ESCAPED "${exp}" "$" "$$"

!if ${ENABLE_DEBUG_PUSHPOP_LOGGING} <> 0
IntCmp $ENABLE_DEBUG_PUSHPOP_LOGGING 0 +2
StrCpy $DEBUG_ST0 '"${__CURRENT_MACRO_DEF_PopImpl_exp_ESCAPED}" = "${exp}"'
!endif

!if "${pop_macro}" S== "stack::dll_delete"
${!define_if_valid_var} PopImpl__exp_is_valid_var 0 "${exp}" PopImpl__exp_var
!if ${PopImpl__exp_is_valid_var} <> 0
!define PopImpl__exp "$$${PopImpl__exp_var}"
!else
!define PopImpl__exp "${exp}"
!endif
!undef PopImpl__exp_is_valid_var
!undef PopImpl__exp_var

IntCmp ${stack_handle} 0 +2 ${__CURRENT_MACRO_LABELID_PopImpl_VALID_CALL} ${__CURRENT_MACRO_LABELID_PopImpl_VALID_CALL}
IntCmp $PLUGINS_UNLOADED 0 ${__CURRENT_MACRO_LABELID_PopImpl_VALID_CALL}
  StrCpy $DEBUG_R3 "PopImpl"
  StrCpy $DEBUG_R4 "${__CURRENT_MACRO_SRCID_PopImpl}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Invalid Call: stack::dll_size$\n|Expression: $\"${PopImpl__exp}$\"$\n|Expression Value: $\"${exp}$\"$\n|Stack Handle: ${stack_handle}$\n|Plugins Unloaded: $PLUGINS_UNLOADED$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackInvalidCall_ImplAskAbort
  !else
  Call un.DebugStackInvalidCall_ImplAskAbort
  !endif

${__CURRENT_MACRO_LABELID_PopImpl_VALID_CALL}:
!if ${ENABLE_DEBUG_POPEXCH_OUTOFSTACK} <> 0
!define __CURRENT_MACRO_LABELID_PopImpl_VALID_PRIVATE_STACK_SIZE __CURRENT_MACRO_LABELID_PopImpl_VALID_PRIVATE_STACK_SIZE_L${__LINE__}

; assert out-of-stack
${stack::dll_size} $WNDPROC_STACK_HANDLE $DEBUG_ST0
IntCmp $DEBUG_ST0 0 0 0 ${__CURRENT_MACRO_LABELID_PopImpl_VALID_PRIVATE_STACK_SIZE}
  StrCpy $DEBUG_R3 "PopImpl"
  StrCpy $DEBUG_R4 "${__CURRENT_MACRO_SRCID_PopImpl}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Invalid Call: stack::dll_delete$\n|Expression: $\"${PopImpl__exp}$\"$\n|Expression Value: $\"${exp}$\"$\n|Stack Handle: ${stack_handle}$\n|Stack Size: $DEBUG_ST0$\n|Plugins Unloaded: $PLUGINS_UNLOADED$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackInvalidCall_ImplAskAbort
  !else
  Call un.DebugStackInvalidCall_ImplAskAbort
  !endif

${__CURRENT_MACRO_LABELID_PopImpl_VALID_PRIVATE_STACK_SIZE}:
!undef __CURRENT_MACRO_LABELID_PopImpl_VALID_PRIVATE_STACK_SIZE
!endif

!undef PopImpl__exp
${!error_ifndef_nvar_NAN_0} stack_handle "PopImpl: stack handle must be defined and valid handle value: stack_handle=$\"${stack_handle}$\""
!verbose pop

${${pop_macro}} `${stack_handle}` 1 `${exp}` $LAST_ERROR ; stack::dll_delete interface, index begins from +/- 1

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!else
${!error_ifdef} stack_handle "PopImpl: stack handle must be not defined or empty: stack_handle=$\"${stack_handle}$\""
!verbose pop

${pop_macro} `${exp}` ; buildin Pop interface

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!endif

!if ${ENABLE_DEBUG_PUSHPOP_LOGGING} <> 0
IntCmp $ENABLE_DEBUG_PUSHPOP_LOGGING 0 +2
DetailPrint '${pop_macro}: $DEBUG_ST0 -> "${exp}" (${__CURRENT_MACRO_SRCID_PopImpl})'
#MessageBox MB_OK '${pop_macro}: $DEBUG_ST0 -> "${exp}" (${__CURRENT_MACRO_SRCID_PopImpl})'
!endif

!undef __CURRENT_MACRO_DEF_PopImpl_exp_ESCAPED
!undef __CURRENT_MACRO_LABELID_PopImpl_VALID_CALL
!undef __CURRENT_MACRO_SRCID_PopImpl
!macroend

!define Pop "!insertmacro Pop"
!macro Pop exp
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

${PopImplEntry} 0 "${exp}"

!verbose pop
!macroend

!define PopImplEntry "!insertmacro PopImplEntry"
!macro PopImplEntry verbose_flag exp
!if ${ENABLE_DEBUG_POPEXCH} = 0
!verbose pop

Pop `${exp}`

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!else

!if ${ENABLE_DEBUG_POPEXCH_OUTOFSTACK} <> 0
!if ${verbose_flag} <> 0
  !verbose push
  !verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!endif

!define __CURRENT_MACRO_SRCID_Pop "${__FILE__}:${__LINE__}"
!define __CURRENT_MACRO_LABELID_Pop_VALID_CALL __CURRENT_MACRO_LABELID_Pop_VALID_CALL_L${__LINE__}
!define __CURRENT_MACRO_LABELID_Pop_EXIT __CURRENT_MACRO_LABELID_Pop_EXIT_L${__LINE__}

${!define_if_valid_var} Pop__exp_is_valid_var 0 "${exp}" Pop__exp_var
!if ${Pop__exp_is_valid_var} <> 0
!define Pop__exp "$$${Pop__exp_var}"
!else
!define Pop__exp "${exp}"
!endif
!undef Pop__exp_is_valid_var
!undef Pop__exp_var

IntCmp $PLUGINS_UNLOADED 0 ${__CURRENT_MACRO_LABELID_Pop_VALID_CALL}
  StrCpy $DEBUG_R3 "Pop"
  StrCpy $DEBUG_R4 "${__CURRENT_MACRO_SRCID_Pop}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Invalid Call: stack::ns_size$\n|Expression: $\"${Pop__exp}$\"$\n|Expression Value: $\"${exp}$\"$\n|Plugins Unloaded: $PLUGINS_UNLOADED$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackInvalidCall_ImplAskAbort
  !else
  Call un.DebugStackInvalidCall_ImplAskAbort
  !endif

${__CURRENT_MACRO_LABELID_Pop_VALID_CALL}:
; assert out-of-stack
${stack::ns_size} $DEBUG_ST0
IntCmp $DEBUG_ST0 0 0 0 ${__CURRENT_MACRO_LABELID_Pop_EXIT}
  StrCpy $DEBUG_R3 "Pop"
  StrCpy $DEBUG_R4 "${__CURRENT_MACRO_SRCID_Pop}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Expression: $\"${Pop__exp}$\"$\n|Expression Value: $\"${exp}$\"$\n|Current Size: $DEBUG_ST0$\n|Expected Size: >=1$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackPopExchOutOfStack_ImplAskAbort
  !else
  Call un.DebugStackPopExchOutOfStack_ImplAskAbort
  !endif

${__CURRENT_MACRO_LABELID_Pop_EXIT}:
!undef Pop__exp
!undef __CURRENT_MACRO_LABELID_Pop_EXIT
!undef __CURRENT_MACRO_LABELID_Pop_VALID_CALL
!undef __CURRENT_MACRO_SRCID_Pop
!endif

${PopImpl} Pop `` `${exp}`

!if ${verbose_flag} <> 0
  !verbose pop
!endif

!endif
!macroend

; Exch
!define ExchImpl "!insertmacro ExchImpl"
!macro ExchImpl exp
!if "${exp}" == ""
!define /redef exp 1
!endif

!define __CURRENT_MACRO_SRCID_ExchImpl "${__FILE__}:${__LINE__}"
!define __CURRENT_MACRO_LABELID_ExchImpl __CURRENT_MACRO_LABELID_ExchImpl_L${__LINE__}

!define __CURRENT_MACRO_DEF_ExchImpl_exp_ESCAPED "" ; compile error if already exists
!searchreplace __CURRENT_MACRO_DEF_ExchImpl_exp_ESCAPED "${exp}" "$" "$$"

!if ${ENABLE_DEBUG_PUSHPOP_LOGGING} <> 0
IntCmp $ENABLE_DEBUG_PUSHPOP_LOGGING 0 ${__CURRENT_MACRO_LABELID_ExchImpl}
!else
${Goto} ${__CURRENT_MACRO_LABELID_ExchImpl}
!endif

Pop $DEBUG_ST1 ; read stack top value
Push $DEBUG_ST1 ; restore it
!if "${__CURRENT_MACRO_DEF_ExchImpl_exp_ESCAPED}" S!= "${exp}"
; check expression on not-a-number value in compile time: exp contains a $ sign, so it is a string, not a number
StrCpy $DEBUG_ST0 '"${__CURRENT_MACRO_DEF_ExchImpl_exp_ESCAPED}" = "${exp}"'
!else
!define __CURRENT_MACRO_LABELID_ExchImpl_END __CURRENT_MACRO_LABELID_ExchImpl_END_L${__LINE__}

; check expression on not-a-number in runtime
StrCpy $DEBUG_ST0 '"${__CURRENT_MACRO_DEF_ExchImpl_exp_ESCAPED}"'
IntCmp `${exp}` 0 0 +3 +3 ; numbers comparison, any not-a-number string will be converted to 0 before the comparison!
StrCpy $DEBUG_ST0 '"${__CURRENT_MACRO_DEF_ExchImpl_exp_ESCAPED}" = "${exp}"'
${Goto} ${__CURRENT_MACRO_LABELID_ExchImpl}
Exch `${exp}`
Exch $DEBUG_ST2
StrCpy $DEBUG_ST0 '$DEBUG_ST0 = "$DEBUG_ST2"'
Exch $DEBUG_ST2 ; restore
${Goto} ${__CURRENT_MACRO_LABELID_ExchImpl_END} ; ignore last exchange
!endif

!ifdef __CURRENT_MACRO_LABELID_ExchImpl
${__CURRENT_MACRO_LABELID_ExchImpl}:
!undef __CURRENT_MACRO_LABELID_ExchImpl
!endif

!verbose pop

Exch `${exp}`

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

!ifdef __CURRENT_MACRO_LABELID_ExchImpl_END
${__CURRENT_MACRO_LABELID_ExchImpl_END}:
!undef __CURRENT_MACRO_LABELID_ExchImpl_END
!endif

!if ${ENABLE_DEBUG_PUSHPOP_LOGGING} <> 0
IntCmp $ENABLE_DEBUG_PUSHPOP_LOGGING 0 +2
DetailPrint 'Exch: $DEBUG_ST0 <-> "$DEBUG_ST1" (${__CURRENT_MACRO_SRCID_ExchImpl})'
#MessageBox MB_OK 'Exch: $DEBUG_ST0 <-> "$DEBUG_ST1" (${__CURRENT_MACRO_SRCID_ExchImpl})'
!endif

!undef __CURRENT_MACRO_DEF_ExchImpl_exp_ESCAPED
!undef __CURRENT_MACRO_SRCID_ExchImpl
!macroend

!define Exch "!insertmacro Exch"
!macro Exch exp
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 "${exp}"

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchImplEntry "!insertmacro ExchImplEntry"
!macro ExchImplEntry verbose_flag exp
!if ${ENABLE_DEBUG_POPEXCH} = 0
!verbose pop

Exch `${exp}`

!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!else
!if ${verbose_flag} <> 0
  !verbose push
  !verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}
!endif

!if ${ENABLE_DEBUG_POPEXCH_OUTOFSTACK} <> 0
!define __CURRENT_MACRO_SRCID_Exch "${__FILE__}:${__LINE__}"
!define __CURRENT_MACRO_LABELID_Exch_VALID_CALL __CURRENT_MACRO_LABELID_Exch_VALID_CALL_L${__LINE__}
!define __CURRENT_MACRO_LABELID_Exch_EXIT __CURRENT_MACRO_LABELID_Exch_EXIT_L${__LINE__}

; out-of-stack assertion
StrCpy $DEBUG_ST0 1 ; default needed size

!if "${exp}" != ""
; check if exchanging with a variable expression
${!define_if_empty_NAN} Exch__exp_is_empty_NAN "" "${exp}"
${!define_if_valid_var} Exch__exp_is_valid_var 0 "${exp}" Exch__exp_var

StrCpy $DEBUG_ST1 1

!if ${Exch__exp_is_valid_var} <> 0
!define Exch__exp "$$${Exch__exp_var}"
!endif
!undef Exch__exp_var
!undef Exch__exp_is_valid_var

!if ${Exch__exp_is_empty_NAN} = 0
!define /redef Exch__exp "${exp}"
!if ${Exch__exp} > 0 ; just in case
IntOp $DEBUG_ST1 $DEBUG_ST1 + ${Exch__exp}
!endif
!endif
!undef Exch__exp_is_empty_NAN

!else
!define Exch__exp ""

StrCpy $DEBUG_ST1 2 ; exchange top 2 values
!endif

IntCmp $PLUGINS_UNLOADED 0 ${__CURRENT_MACRO_LABELID_Exch_VALID_CALL}
  StrCpy $DEBUG_R3 "Exch"
  StrCpy $DEBUG_R4 "${__CURRENT_MACRO_SRCID_Exch}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Invalid Call: stack::ns_size$\n|Expression: $\"${Exch__exp}$\"$\n|Expression Value: $\"${exp}$\"$\n|Plugins Unloaded: $PLUGINS_UNLOADED$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackInvalidCall_ImplAskAbort
  !else
  Call un.DebugStackInvalidCall_ImplAskAbort
  !endif

${__CURRENT_MACRO_LABELID_Exch_VALID_CALL}:
; assert out-of-stack
${stack::ns_size} $DEBUG_ST0
IntCmp $DEBUG_ST0 $DEBUG_ST1 ${__CURRENT_MACRO_LABELID_Exch_EXIT} 0 ${__CURRENT_MACRO_LABELID_Exch_EXIT}
  StrCpy $DEBUG_R3 "Exch"
  StrCpy $DEBUG_R4 "${__CURRENT_MACRO_SRCID_Exch}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Expression: $\"${Exch__exp}$\"$\n|Expression Value: $\"${exp}$\"$\n|Current Size: $DEBUG_ST0$\n|Expected Size: >=$DEBUG_ST0$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackPopExchOutOfStack_ImplAskAbort
  !else
  Call un.DebugStackPopExchOutOfStack_ImplAskAbort
  !endif

${__CURRENT_MACRO_LABELID_Exch_EXIT}:
!undef Exch__exp
!undef __CURRENT_MACRO_LABELID_Exch_EXIT
!undef __CURRENT_MACRO_LABELID_Exch_VALID_CALL
!undef __CURRENT_MACRO_SRCID_Exch
!endif

${ExchImpl} `${exp}`

!if ${verbose_flag} <> 0
  !verbose pop
!endif

!endif
!macroend

; SystemPush

; uses private stack to push into
!define SystemPush "!insertmacro SystemPush"
!macro SystemPush stack_handle value
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 <> 0
  MessageBox MB_OK "SystemPush: stack_handle=${stack_handle} value=${value}"
${EndIf}
!endif

${PushImpl} stack::dll_insert `${stack_handle}` `${value}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

; SystemPop

; uses private stack to pop from a global variable
!define SystemPop "!insertmacro SystemPop"
!macro SystemPop stack_handle var
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
!define __CURRENT_MACRO_DEF_SystemPop_var_ESCAPED "" ; compile error if already exists
!searchreplace __CURRENT_MACRO_DEF_SystemPop_var_ESCAPED "${var}" "$" "$$"
!endif

; save errors flag
${PushErrors}

${PopImpl} stack::dll_delete `${stack_handle}` ${var}

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 <> 0
  MessageBox MB_OK "SystemPop: stack_handle=${stack_handle} var=${__CURRENT_MACRO_DEF_SystemPop_var_ESCAPED} value=${var}"
${EndIf}

!undef __CURRENT_MACRO_DEF_SystemPop_var_ESCAPED
!endif

; restore errors flag
${PopErrors}

!verbose pop
!macroend

; SystemPopToStack

; uses private stack to pop from a value and push it into main stack
!define SystemPopToStack "!insertmacro SystemPopToStack"
!macro SystemPopToStack stack_handle
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

Push $R9 ; save R9
${PopImpl} stack::dll_delete `${stack_handle}` $R9

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 <> 0
  MessageBox MB_OK "SystemPopToStack: stack_handle=${stack_handle} value=$R9"
${EndIf}
!endif

Exch $R9 ; exchange R9 with top value on the main stack

; restore errors flag
${PopErrors}

!verbose pop
!macroend

; PushStack1

!define PushStack1 "!insertmacro PushStack1"
!macro PushStack1 var0
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack2 "!insertmacro PushStack2"
!macro PushStack2 var0 var1
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack3 "!insertmacro PushStack3"
!macro PushStack3 var0 var1 var2
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack4 "!insertmacro PushStack4"
!macro PushStack4 var0 var1 var2 var3
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack5 "!insertmacro PushStack5"
!macro PushStack5 var0 var1 var2 var3 var4
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack6 "!insertmacro PushStack6"
!macro PushStack6 var0 var1 var2 var3 var4 var5
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack7 "!insertmacro PushStack7"
!macro PushStack7 var0 var1 var2 var3 var4 var5 var6
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack8 "!insertmacro PushStack8"
!macro PushStack8 var0 var1 var2 var3 var4 var5 var6 var7
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack9 "!insertmacro PushStack9"
!macro PushStack9 var0 var1 var2 var3 var4 var5 var6 var7 var8
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack10 "!insertmacro PushStack10"
!macro PushStack10 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack11 "!insertmacro PushStack11"
!macro PushStack11 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack12 "!insertmacro PushStack12"
!macro PushStack12 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack13 "!insertmacro PushStack13"
!macro PushStack13 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack14 "!insertmacro PushStack14"
!macro PushStack14 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`
${PushImplEntry} 0 `${var13}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack15 "!insertmacro PushStack15"
!macro PushStack15 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`
${PushImplEntry} 0 `${var13}`
${PushImplEntry} 0 `${var14}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack16 "!insertmacro PushStack16"
!macro PushStack16 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`
${PushImplEntry} 0 `${var13}`
${PushImplEntry} 0 `${var14}`
${PushImplEntry} 0 `${var15}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack17 "!insertmacro PushStack17"
!macro PushStack17 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`
${PushImplEntry} 0 `${var13}`
${PushImplEntry} 0 `${var14}`
${PushImplEntry} 0 `${var15}`
${PushImplEntry} 0 `${var16}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack18 "!insertmacro PushStack18"
!macro PushStack18 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`
${PushImplEntry} 0 `${var13}`
${PushImplEntry} 0 `${var14}`
${PushImplEntry} 0 `${var15}`
${PushImplEntry} 0 `${var16}`
${PushImplEntry} 0 `${var17}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack19 "!insertmacro PushStack19"
!macro PushStack19 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`
${PushImplEntry} 0 `${var13}`
${PushImplEntry} 0 `${var14}`
${PushImplEntry} 0 `${var15}`
${PushImplEntry} 0 `${var16}`
${PushImplEntry} 0 `${var17}`
${PushImplEntry} 0 `${var18}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PushStack20 "!insertmacro PushStack20"
!macro PushStack20 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18 var19
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PushImplEntry} 0 `${var0}`
${PushImplEntry} 0 `${var1}`
${PushImplEntry} 0 `${var2}`
${PushImplEntry} 0 `${var3}`
${PushImplEntry} 0 `${var4}`
${PushImplEntry} 0 `${var5}`
${PushImplEntry} 0 `${var6}`
${PushImplEntry} 0 `${var7}`
${PushImplEntry} 0 `${var8}`
${PushImplEntry} 0 `${var9}`
${PushImplEntry} 0 `${var10}`
${PushImplEntry} 0 `${var11}`
${PushImplEntry} 0 `${var12}`
${PushImplEntry} 0 `${var13}`
${PushImplEntry} 0 `${var14}`
${PushImplEntry} 0 `${var15}`
${PushImplEntry} 0 `${var16}`
${PushImplEntry} 0 `${var17}`
${PushImplEntry} 0 `${var18}`
${PushImplEntry} 0 `${var19}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

; PopStack

!define PopStack1 "!insertmacro PopStack1"
!macro PopStack1 var0
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack2 "!insertmacro PopStack2"
!macro PopStack2 var0 var1
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack3 "!insertmacro PopStack3"
!macro PopStack3 var0 var1 var2
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack4 "!insertmacro PopStack4"
!macro PopStack4 var0 var1 var2 var3
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack5 "!insertmacro PopStack5"
!macro PopStack5 var0 var1 var2 var3 var4
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack6 "!insertmacro PopStack6"
!macro PopStack6 var0 var1 var2 var3 var4 var5
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack7 "!insertmacro PopStack7"
!macro PopStack7 var0 var1 var2 var3 var4 var5 var6
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack8 "!insertmacro PopStack8"
!macro PopStack8 var0 var1 var2 var3 var4 var5 var6 var7
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack9 "!insertmacro PopStack9"
!macro PopStack9 var0 var1 var2 var3 var4 var5 var6 var7 var8
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack10 "!insertmacro PopStack10"
!macro PopStack10 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack11 "!insertmacro PopStack11"
!macro PopStack11 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack12 "!insertmacro PopStack12"
!macro PopStack12 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack13 "!insertmacro PopStack13"
!macro PopStack13 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack14 "!insertmacro PopStack14"
!macro PopStack14 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var13}`
${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack15 "!insertmacro PopStack15"
!macro PopStack15 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var14}`
${PopImplEntry} 0 `${var13}`
${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack16 "!insertmacro PopStack16"
!macro PopStack16 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var15}`
${PopImplEntry} 0 `${var14}`
${PopImplEntry} 0 `${var13}`
${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack17 "!insertmacro PopStack17"
!macro PopStack17 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var16}`
${PopImplEntry} 0 `${var15}`
${PopImplEntry} 0 `${var14}`
${PopImplEntry} 0 `${var13}`
${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack18 "!insertmacro PopStack18"
!macro PopStack18 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var17}`
${PopImplEntry} 0 `${var16}`
${PopImplEntry} 0 `${var15}`
${PopImplEntry} 0 `${var14}`
${PopImplEntry} 0 `${var13}`
${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack19 "!insertmacro PopStack19"
!macro PopStack19 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var18}`
${PopImplEntry} 0 `${var17}`
${PopImplEntry} 0 `${var16}`
${PopImplEntry} 0 `${var15}`
${PopImplEntry} 0 `${var14}`
${PopImplEntry} 0 `${var13}`
${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define PopStack20 "!insertmacro PopStack20"
!macro PopStack20 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18 var19
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${PopImplEntry} 0 `${var19}`
${PopImplEntry} 0 `${var18}`
${PopImplEntry} 0 `${var17}`
${PopImplEntry} 0 `${var16}`
${PopImplEntry} 0 `${var15}`
${PopImplEntry} 0 `${var14}`
${PopImplEntry} 0 `${var13}`
${PopImplEntry} 0 `${var12}`
${PopImplEntry} 0 `${var11}`
${PopImplEntry} 0 `${var10}`
${PopImplEntry} 0 `${var9}`
${PopImplEntry} 0 `${var8}`
${PopImplEntry} 0 `${var7}`
${PopImplEntry} 0 `${var6}`
${PopImplEntry} 0 `${var5}`
${PopImplEntry} 0 `${var4}`
${PopImplEntry} 0 `${var3}`
${PopImplEntry} 0 `${var2}`
${PopImplEntry} 0 `${var1}`
${PopImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

; MacroPopStack

!define MacroPopStack1 "!insertmacro MacroPopStack1"
!macro MacroPopStack1 ret_vars_list_ext ret_vars_list_int var0
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack1} $MACRO_POP_VAR0
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0" " "

!verbose pop
!macroend

!define MacroPopStack2 "!insertmacro MacroPopStack2"
!macro MacroPopStack2 ret_vars_list_ext ret_vars_list_int var0 var1
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack2} $MACRO_POP_VAR0 $MACRO_POP_VAR1
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1" " "

!verbose pop
!macroend

!define MacroPopStack3 "!insertmacro MacroPopStack3"
!macro MacroPopStack3 ret_vars_list_ext ret_vars_list_int var0 var1 var2
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack3} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2" " "

!verbose pop
!macroend

!define MacroPopStack4 "!insertmacro MacroPopStack4"
!macro MacroPopStack4 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack4} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3" " "

!verbose pop
!macroend

!define MacroPopStack5 "!insertmacro MacroPopStack5"
!macro MacroPopStack5 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack5} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4" " "

!verbose pop
!macroend

!define MacroPopStack6 "!insertmacro MacroPopStack6"
!macro MacroPopStack6 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack6} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5" " "

!verbose pop
!macroend

!define MacroPopStack7 "!insertmacro MacroPopStack7"
!macro MacroPopStack7 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack7} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6" " "

!verbose pop
!macroend

!define MacroPopStack8 "!insertmacro MacroPopStack8"
!macro MacroPopStack8 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack8} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7" " "

!verbose pop
!macroend

!define MacroPopStack9 "!insertmacro MacroPopStack9"
!macro MacroPopStack9 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack9} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8" " "

!verbose pop
!macroend

!define MacroPopStack10 "!insertmacro MacroPopStack10"
!macro MacroPopStack10 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack10} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9" " "

!verbose pop
!macroend

!define MacroPopStack11 "!insertmacro MacroPopStack11"
!macro MacroPopStack11 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack11} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10" " "

!verbose pop
!macroend

!define MacroPopStack12 "!insertmacro MacroPopStack12"
!macro MacroPopStack12 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack12} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11" " "

!verbose pop
!macroend

!define MacroPopStack13 "!insertmacro MacroPopStack13"
!macro MacroPopStack13 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack13} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12" " "

!verbose pop
!macroend

!define MacroPopStack14 "!insertmacro MacroPopStack14"
!macro MacroPopStack14 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack14} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12 $MACRO_POP_VAR13
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var13} $MACRO_POP_VAR13 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13" " "

!verbose pop
!macroend

!define MacroPopStack15 "!insertmacro MacroPopStack15"
!macro MacroPopStack15 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack15} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12 $MACRO_POP_VAR13 $MACRO_POP_VAR14
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var13} $MACRO_POP_VAR13 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var14} $MACRO_POP_VAR14 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14" " "

!verbose pop
!macroend

!define MacroPopStack16 "!insertmacro MacroPopStack16"
!macro MacroPopStack16 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack16} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12 $MACRO_POP_VAR13 $MACRO_POP_VAR14 $MACRO_POP_VAR15
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var13} $MACRO_POP_VAR13 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var14} $MACRO_POP_VAR14 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var15} $MACRO_POP_VAR15 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15" " "

!verbose pop
!macroend

!define MacroPopStack17 "!insertmacro MacroPopStack17"
!macro MacroPopStack17 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack17} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12 $MACRO_POP_VAR13 $MACRO_POP_VAR14 $MACRO_POP_VAR15 $MACRO_POP_VAR16
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var13} $MACRO_POP_VAR13 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var14} $MACRO_POP_VAR14 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var15} $MACRO_POP_VAR15 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var16} $MACRO_POP_VAR16 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16" " "

!verbose pop
!macroend

!define MacroPopStack18 "!insertmacro MacroPopStack18"
!macro MacroPopStack18 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack18} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12 $MACRO_POP_VAR13 $MACRO_POP_VAR14 $MACRO_POP_VAR15 $MACRO_POP_VAR16 $MACRO_POP_VAR17
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16 $MACRO_RET_VAR17" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var13} $MACRO_POP_VAR13 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var14} $MACRO_POP_VAR14 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var15} $MACRO_POP_VAR15 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var16} $MACRO_POP_VAR16 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var17} $MACRO_POP_VAR17 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16 $MACRO_RET_VAR17" " "

!verbose pop
!macroend

!define MacroPopStack19 "!insertmacro MacroPopStack19"
!macro MacroPopStack19 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack19} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12 $MACRO_POP_VAR13 $MACRO_POP_VAR14 $MACRO_POP_VAR15 $MACRO_POP_VAR16 $MACRO_POP_VAR17 $MACRO_POP_VAR18
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16 $MACRO_RET_VAR17 $MACRO_RET_VAR18" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var13} $MACRO_POP_VAR13 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var14} $MACRO_POP_VAR14 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var15} $MACRO_POP_VAR15 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var16} $MACRO_POP_VAR16 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var17} $MACRO_POP_VAR17 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var18} $MACRO_POP_VAR18 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16 $MACRO_RET_VAR17 $MACRO_RET_VAR18" " "

!verbose pop
!macroend

!define MacroPopStack20 "!insertmacro MacroPopStack20"
!macro MacroPopStack20 ret_vars_list_ext ret_vars_list_int var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18 var19
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; pop into intermediate variables
${PopStack20} $MACRO_POP_VAR0 $MACRO_POP_VAR1 $MACRO_POP_VAR2 $MACRO_POP_VAR3 $MACRO_POP_VAR4 $MACRO_POP_VAR5 $MACRO_POP_VAR6 $MACRO_POP_VAR7 $MACRO_POP_VAR8 $MACRO_POP_VAR9 $MACRO_POP_VAR10 $MACRO_POP_VAR11 $MACRO_POP_VAR12 $MACRO_POP_VAR13 $MACRO_POP_VAR14 $MACRO_POP_VAR15 $MACRO_POP_VAR16 $MACRO_POP_VAR17 $MACRO_POP_VAR18 $MACRO_POP_VAR19
; copy internal variables used for return
${StrCpyByListIfNotEmpty} "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16 $MACRO_RET_VAR17 $MACRO_RET_VAR18 $MACRO_RET_VAR19" "${ret_vars_list_int}" " "
; restore non return variables
${StrCpyIfNotInList} ${var0} $MACRO_POP_VAR0 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var1} $MACRO_POP_VAR1 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var2} $MACRO_POP_VAR2 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var3} $MACRO_POP_VAR3 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var4} $MACRO_POP_VAR4 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var5} $MACRO_POP_VAR5 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var6} $MACRO_POP_VAR6 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var7} $MACRO_POP_VAR7 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var8} $MACRO_POP_VAR8 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var9} $MACRO_POP_VAR9 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var10} $MACRO_POP_VAR10 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var11} $MACRO_POP_VAR11 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var12} $MACRO_POP_VAR12 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var13} $MACRO_POP_VAR13 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var14} $MACRO_POP_VAR14 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var15} $MACRO_POP_VAR15 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var16} $MACRO_POP_VAR16 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var17} $MACRO_POP_VAR17 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var18} $MACRO_POP_VAR18 "${ret_vars_list_ext}" " "
${StrCpyIfNotInList} ${var19} $MACRO_POP_VAR19 "${ret_vars_list_ext}" " "
; copy saved internal variables used for return into external
${StrCpyByList} "${ret_vars_list_ext}" "$MACRO_RET_VAR0 $MACRO_RET_VAR1 $MACRO_RET_VAR2 $MACRO_RET_VAR3 $MACRO_RET_VAR4 $MACRO_RET_VAR5 $MACRO_RET_VAR6 $MACRO_RET_VAR7 $MACRO_RET_VAR8 $MACRO_RET_VAR9 $MACRO_RET_VAR10 $MACRO_RET_VAR11 $MACRO_RET_VAR12 $MACRO_RET_VAR13 $MACRO_RET_VAR14 $MACRO_RET_VAR15 $MACRO_RET_VAR16 $MACRO_RET_VAR17 $MACRO_RET_VAR18 $MACRO_RET_VAR19" " "

!verbose pop
!macroend

; ExchStack

!define ExchStack1 "!insertmacro ExchStack1"
!macro ExchStack1 var0
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var0}`

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack2 "!insertmacro ExchStack2"
!macro ExchStack2 var0 var1
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 1

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack3 "!insertmacro ExchStack3"
!macro ExchStack3 var0 var1 var2
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 2

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack4 "!insertmacro ExchStack4"
!macro ExchStack4 var0 var1 var2 var3
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 3

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack5 "!insertmacro ExchStack5"
!macro ExchStack5 var0 var1 var2 var3 var4
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 4

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack6 "!insertmacro ExchStack6"
!macro ExchStack6 var0 var1 var2 var3 var4 var5
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 5

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack7 "!insertmacro ExchStack7"
!macro ExchStack7 var0 var1 var2 var3 var4 var5 var6
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 6

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack8 "!insertmacro ExchStack8"
!macro ExchStack8 var0 var1 var2 var3 var4 var5 var6 var7
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 7

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack9 "!insertmacro ExchStack9"
!macro ExchStack9 var0 var1 var2 var3 var4 var5 var6 var7 var8
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 8

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack10 "!insertmacro ExchStack10"
!macro ExchStack10 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 9

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack11 "!insertmacro ExchStack11"
!macro ExchStack11 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 10

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack12 "!insertmacro ExchStack12"
!macro ExchStack12 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 11

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack13 "!insertmacro ExchStack13"
!macro ExchStack13 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 12

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack14 "!insertmacro ExchStack14"
!macro ExchStack14 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var13}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 12
${ExchImplEntry} 0 13
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 13

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack15 "!insertmacro ExchStack15"
!macro ExchStack15 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var14}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var13}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 12
${ExchImplEntry} 0 13
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 13
${ExchImplEntry} 0 14
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 14

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack16 "!insertmacro ExchStack16"
!macro ExchStack16 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var15}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var14}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var13}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 12
${ExchImplEntry} 0 13
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 13
${ExchImplEntry} 0 14
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 14
${ExchImplEntry} 0 15
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 15

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack17 "!insertmacro ExchStack17"
!macro ExchStack17 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var16}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var15}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var14}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var13}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 12
${ExchImplEntry} 0 13
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 13
${ExchImplEntry} 0 14
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 14
${ExchImplEntry} 0 15
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 15
${ExchImplEntry} 0 16
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 16

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack18 "!insertmacro ExchStack18"
!macro ExchStack18 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var17}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var16}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var15}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var14}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var13}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 12
${ExchImplEntry} 0 13
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 13
${ExchImplEntry} 0 14
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 14
${ExchImplEntry} 0 15
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 15
${ExchImplEntry} 0 16
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 16
${ExchImplEntry} 0 17
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 17

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack19 "!insertmacro ExchStack19"
!macro ExchStack19 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var18}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var17}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var16}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var15}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var14}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var13}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 12
${ExchImplEntry} 0 13
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 13
${ExchImplEntry} 0 14
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 14
${ExchImplEntry} 0 15
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 15
${ExchImplEntry} 0 16
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 16
${ExchImplEntry} 0 17
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 17
${ExchImplEntry} 0 18
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 18

; restore errors flag
${PopErrors}

!verbose pop
!macroend

!define ExchStack20 "!insertmacro ExchStack20"
!macro ExchStack20 var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18 var19
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

; save errors flag
${PushErrors}

${ExchImplEntry} 0 `${var19}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 `${var18}`
${ExchImplEntry} 0 1
${ExchImplEntry} 0 2
${ExchImplEntry} 0 `${var17}`
${ExchImplEntry} 0 2
${ExchImplEntry} 0 3
${ExchImplEntry} 0 `${var16}`
${ExchImplEntry} 0 3
${ExchImplEntry} 0 4
${ExchImplEntry} 0 `${var15}`
${ExchImplEntry} 0 4
${ExchImplEntry} 0 5
${ExchImplEntry} 0 `${var14}`
${ExchImplEntry} 0 5
${ExchImplEntry} 0 6
${ExchImplEntry} 0 `${var13}`
${ExchImplEntry} 0 6
${ExchImplEntry} 0 7
${ExchImplEntry} 0 `${var12}`
${ExchImplEntry} 0 7
${ExchImplEntry} 0 8
${ExchImplEntry} 0 `${var11}`
${ExchImplEntry} 0 8
${ExchImplEntry} 0 9
${ExchImplEntry} 0 `${var10}`
${ExchImplEntry} 0 9
${ExchImplEntry} 0 10
${ExchImplEntry} 0 `${var9}`
${ExchImplEntry} 0 10
${ExchImplEntry} 0 11
${ExchImplEntry} 0 `${var8}`
${ExchImplEntry} 0 11
${ExchImplEntry} 0 12
${ExchImplEntry} 0 `${var7}`
${ExchImplEntry} 0 12
${ExchImplEntry} 0 13
${ExchImplEntry} 0 `${var6}`
${ExchImplEntry} 0 13
${ExchImplEntry} 0 14
${ExchImplEntry} 0 `${var5}`
${ExchImplEntry} 0 14
${ExchImplEntry} 0 15
${ExchImplEntry} 0 `${var4}`
${ExchImplEntry} 0 15
${ExchImplEntry} 0 16
${ExchImplEntry} 0 `${var3}`
${ExchImplEntry} 0 16
${ExchImplEntry} 0 17
${ExchImplEntry} 0 `${var2}`
${ExchImplEntry} 0 17
${ExchImplEntry} 0 18
${ExchImplEntry} 0 `${var1}`
${ExchImplEntry} 0 18
${ExchImplEntry} 0 19
${ExchImplEntry} 0 `${var0}`
${ExchImplEntry} 0 19

; restore errors flag
${PopErrors}

!verbose pop
!macroend

; Stack self exchange.
; Format: ExchStackStackN offset_to
;   N - top N items to exchange with
;   offset_to - offset from last item to next N items to exchange with
!define ExchStackStack1 "!insertmacro ExchStackStack1"
!macro ExchStackStack1 offset_to
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

!define /math ExchStackStack1_offset_to ${offset_to} + 1

; save errors flag
${PushErrors}

${ExchImplEntry} 0 ${ExchStackStack1_offset_to}

; restore errors flag
${PopErrors}

!undef ExchStackStack1_offset_to

!verbose pop
!macroend

!define ExchStackStack2 "!insertmacro ExchStackStack2"
!macro ExchStackStack2 offset_to
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

!define /math ExchStackStack2_offset0_to ${offset_to} + 3
!define /math ExchStackStack2_offset1_to ${offset_to} + 2

; save errors flag
${PushErrors}

${ExchImplEntry} 0 1
${ExchImplEntry} 0 ${ExchStackStack2_offset0_to}
${ExchImplEntry} 0 1
${ExchImplEntry} 0 ${ExchStackStack2_offset1_to}

; restore errors flag
${PopErrors}

!undef ExchStackStack2_offset0_to
!undef ExchStackStack2_offset1_to

!verbose pop
!macroend

!define ExchStackStack3 "!insertmacro ExchStackStack3"
!macro ExchStackStack3 offset_to
!verbose push
!verbose ${_NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL}

!define /math ExchStackStack3_offset0_to ${offset_to} + 5
!define /math ExchStackStack3_offset1_to ${offset_to} + 4
!define /math ExchStackStack3_offset2_to ${offset_to} + 3

; save errors flag
${PushErrors}

${ExchImplEntry} 0 2
${ExchImplEntry} 0 ${ExchStackStack3_offset0_to}
${ExchImplEntry} 0 2
${ExchImplEntry} 0 1
${ExchImplEntry} 0 ${ExchStackStack3_offset1_to}
${ExchImplEntry} 0 1
${ExchImplEntry} 0 ${ExchStackStack3_offset2_to}

; restore errors flag
${PopErrors}

!undef ExchStackStack3_offset0_to
!undef ExchStackStack3_offset1_to
!undef ExchStackStack3_offset2_to

!verbose pop
!macroend

!endif
