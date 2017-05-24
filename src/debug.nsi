!ifndef _NSIS_SETUP_LIB_DEBUG_NSI
!define _NSIS_SETUP_LIB_DEBUG_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\preprocessor.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\builtin.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\log.nsi"

${Include_DetailPrint} ""
${Include_DetailPrint} "un."

!define DBGID_STR_PREFIX "DBGID"
!define WNDPROCID_STR_PREFIX "WNDPROCID"
#!define WNDPROCIDEND_STR_PREFIX "WNDPROCID_END"
!define DLGSHOWID_STR_PREFIX "DLGSHOWID"

; CAUTION:
;   DO NOT USE macro expansion inside these macros to avoid excessive macro expansion and so compilation speed slowdown!
;
; COMPILATION SPEED OPTIMIZATION:
;   1. Wrap macro code into functions if can
;   2. Inline macro calls
;   3. Replace ${If}/${EndIf} by StrCmp/StrCmpS/IntCmp
;   4. Avoid redundant define expansions
;

; DebugMessageBox

; message box with debug extensions
!define DebugMessageBox "!insertmacro DebugMessageBox"
!macro DebugMessageBox func_name current_src_id prev_src_id flags msg_header msg_body argsN
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if "${func_name}" == ""
!error "DebugMessageBox: function name must be defined!"
!endif

!if "${current_src_id}" == ""
!define /redef current_src_id "${__FILE__}:${__LINE__}"
!endif
!if "${prev_src_id}" == ""
!define /redef prev_src_id ""
!endif
!if "${msg_header}" == ""
!define /redef msg_header "Debug message:"
!endif

!define DebugMessageBox__flags ""
!define DebugMessageBox__DumpState 0
!define DebugMessageBox__SD_suffix ""

!searchreplace DebugMessageBox__SD_replaced "${argsN}" "/SD " "*"
!define DebugMessageBox__SD_used 0
!if "${DebugMessageBox__SD_replaced}" != "${argsN}"
!define /redef DebugMessageBox__SD_used 1
!endif

${DebugMessageBoxImpl_DumpStateRecur} "${flags}" ${DebugMessageBox__SD_used} \
  DebugMessageBox_DumpStateRecur__current_elem_def DebugMessageBox_DumpStateRecur__next_elems_def

${DetailPrint} "${func_name}: ${msg_header}$\n$\n|cur_src_id=$\"${current_src_id}$\"$\n|prev_src_id=$\"${prev_src_id}$\"$\n$\n${msg_body}"
${If} $DEBUG <> 0 ; if debug then always show, even in silent mode
  MessageBox "${DebugMessageBox__flags}" \
    "${msg_header}$\n$\n|Executable: $\"$EXEPATH$\"$\n|PluginsDir: $\"$PluginsDir$\"$\n|Function: ${func_name}$\n|Current Src ID: $\"${current_src_id}$\"$\n|Previous Src ID: $\"${prev_src_id}$\"$\n$\n${msg_body}" \
    ${argsN}
${Else}
  MessageBox "${DebugMessageBox__flags}" \
    "${msg_header}$\n$\n|Executable: $\"$EXEPATH$\"$\n|PluginsDir: $\"$PluginsDir$\"$\n|Function: ${func_name}$\n|Current Src ID: $\"${current_src_id}$\"$\n|Previous Src ID: $\"${prev_src_id}$\"$\n$\n${msg_body}" \
    ${DebugMessageBox__SD_suffix} ${argsN}
${EndIf}

!if ${DebugMessageBox__DumpState} <> 0
${If} $DEBUG <> 0 ; if debug then always show, even in silent mode
  Dumpstate::debug
${Else}
  IfSilent +2
  Dumpstate::debug
${EndIf}
!endif

!undef DebugMessageBox__flags
!undef DebugMessageBox__DumpState
!undef DebugMessageBox__SD_suffix
!undef DebugMessageBox__SD_replaced
!undef DebugMessageBox__SD_used
!undef DebugMessageBox_DumpStateRecur__current_elem_def
!undef DebugMessageBox_DumpStateRecur__next_elems_def

!verbose pop
!macroend

!define DebugMessageBoxImpl_DumpStateRecur "!insertmacro DebugMessageBoxImpl_DumpStateRecur"
!macro DebugMessageBoxImpl_DumpStateRecur flags sd_used_flag current_elem_def next_elems_def
${UnfoldMacroArgumentList} "${flags}" ${current_elem_def} ${next_elems_def} "" | ""

; filter /SD
!if ${sd_used_flag} = 0
!if "${${current_elem_def}}" == "MB_OK"
!define /redef DebugMessageBox__SD_suffix "/SD IDOK"
!else if "${${current_elem_def}}" == "MB_OKCANCEL"
!define /redef DebugMessageBox__SD_suffix "/SD IDOK"
!else if "${${current_elem_def}}" == "MB_ABORTRETRYIGNORE"
!define /redef DebugMessageBox__SD_suffix "/SD IDIGNORE"
!else if "${${current_elem_def}}" == "MB_RETRYCANCEL"
!define /redef DebugMessageBox__SD_suffix "/SD IDCANCEL"
!else if "${${current_elem_def}}" == "MB_YESNO"
!define /redef DebugMessageBox__SD_suffix "/SD IDYES"
!else if "${${current_elem_def}}" == "MB_YESNOCANCEL"
!define /redef DebugMessageBox__SD_suffix "/SD IDYES"
!endif
!endif

; filter MB_DUMPSTATE
!if "${${current_elem_def}}" == "MB_DUMPSTATE"
!define /redef DebugMessageBox__DumpState 1
!else if "${DebugMessageBox__flags}" != ""
!define /redef DebugMessageBox__flags "${DebugMessageBox__flags}|${${current_elem_def}}"
!else
!define /redef DebugMessageBox__flags "${${current_elem_def}}"
!endif

; recursive macro call
!if "${${next_elems_def}}" != ""
${DebugMessageBoxImpl_DumpStateRecur} "${${next_elems_def}}" ${sd_used_flag} ${current_elem_def} ${next_elems_def}
!endif
!macroend

; DebugStackEnterFrame

!define DebugStackEnterFrame "!insertmacro DebugStackEnterFrame"
!macro DebugStackEnterFrame code_id frame_id push_all_regs_flag
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!define DebugStackEnterFrame__SRCID_${code_id}_${frame_id} "SRCID::${_NSIS_SETUP_LIB_BUILD_DATE}::${_NSIS_SETUP_LIB_BUILD_TIME}::${__FILE__}/${code_id}/${frame_id}:${__LINE__}"
; define empty
!define DebugStackCheckFrame__SRCID_${code_id}_${frame_id} ""
!define DebugStackLastCheckFrame__SRCID_${code_id}_${frame_id} ""

!if `${code_id}` == ""
!error "DebugStackEnterFrame: code_id must be not empty code block identification string"
!endif
!if `${frame_id}` < 0
!error "DebugStackEnterFrame: frame_id must be not empty and not negative ordinal number of stack frame in a code block"
!endif

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackEnterFrame \
    "${code_id}/${frame_id}" "" MB_OK "" \
    "|push_all_regs_flag=${push_all_regs_flag}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

!if ${ENABLE_DEBUG_STACK_FRAMES} <> 0
${Push} `${DBGID_STR_PREFIX}::${_NSIS_SETUP_LIB_BUILD_GUID16}:${code_id}:${frame_id}::SRCID::${__FILE__}/${code_id}/${frame_id}:${__LINE__}`
!if ${push_all_regs_flag} <> 0
${DebugStackPushAllRegs} `${code_id}` `${frame_id}`
!endif
!endif

!verbose pop
!macroend

; DebugStackCheckFrameImpl

!define Func_DebugStackCheckFrameImpl "!insertmacro Func_DebugStackCheckFrameImpl"
!macro Func_DebugStackCheckFrameImpl un
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

Function ${un}DebugStackCheckFrameImpl_ImplAskAbort
  ${If} $USER_ABORT_ASK_ACCEPTED = 0 ; ignore dialog if already accepted by user
    ${If} $DEBUG <> 0 ; show dialog in silent mode if debugging
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackCheckFrameImpl_ImplAskAbort" \
        $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND $(MSG_SETUP_DEBUG_CHECK_FAILED) $DEBUG_R6 "IDYES abort"
    ${Else}
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackCheckFrameImpl_ImplAskAbort" \
        $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND $(MSG_SETUP_DEBUG_CHECK_FAILED) $DEBUG_R6 "/SD IDNO IDYES abort"
    ${EndIf}
    Return

    ; Workaround for Abort/Quit call from a page control window procedure handler.
    ; Call !Abort again in case if it has been called already from such handler.

    abort:
    StrCpy $USER_ABORT_ASK_ACCEPTED 1
    ; Use Dumpstate plugin on abort in debug mode
    ${Push} $DEBUG_FRAME_ID ; restore last invalid value on top of stack
    ${If} $DEBUG <> 0
      Dumpstate::debug
    ${EndIf}
  ${EndIf}

  !ifdef Init_INCLUDED
    ; !AbortCall macro is not yet defined here
    !ifndef __UNINSTALL__
    Call !Abort
    !else
    Call un.!Abort
    !endif
  !else
    Abort
    Quit ; if not aborted
  !endif
FunctionEnd

!verbose pop
!macroend

!define Include_DebugStackCheckFrameImpl "!insertmacro Include_DebugStackCheckFrameImpl"
!macro Include_DebugStackCheckFrameImpl un
!ifndef ${un}DebugStackCheckFrameImpl_INCLUDED
!define ${un}DebugStackCheckFrameImpl_INCLUDED
${Func_DebugStackCheckFrameImpl} "${un}"
!endif
!macroend

; implementation core procedure to pop from a stack and parse for the marker
!define DebugStackPopForMarkerFrameImpl "!insertmacro DebugStackPopForMarkerFrameImpl"
!macro DebugStackPopForMarkerFrameImpl pop_macro stack_handle not_found_goto found_goto
!if "${pop_macro}" S== "SystemPop"
${${pop_macro}} "${stack_handle}" $DEBUG_FRAME_ID
!else
${${pop_macro}} $DEBUG_FRAME_ID
!endif
!ifndef __UNINSTALL__
Call DebugStackPopForMarkerFrameImpl
!else
Call un.DebugStackPopForMarkerFrameImpl
!endif
IntCmp $DEBUG_R12 0 ${not_found_goto} ${found_goto} ${found_goto}
!macroend

!define Func_DebugStackPopForMarkerFrameImpl "!insertmacro Func_DebugStackPopForMarkerFrameImpl"
!macro Func_DebugStackPopForMarkerFrameImpl un
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

Function ${un}DebugStackPopForMarkerFrameImpl
IntOp $DEBUG_R9 $DEBUG_R9 + 1

StrCpy $DEBUG_R10 0
StrCpy $DEBUG_R12 0

; search for the stack context boundary marker prefix
StrCpy $DEBUG_R11 "${DLGSHOWID_STR_PREFIX}::${_NSIS_SETUP_LIB_BUILD_GUID16}"
StrCmpS $DEBUG_R11 $DEBUG_R7 search2

StrLen $DEBUG_R8 $DEBUG_R11
IntOp $DEBUG_R8 $DEBUG_R8 + 2 ; add length of "::"
StrCpy $DEBUG_R8 $DEBUG_FRAME_ID $DEBUG_R8
StrCmpS $DEBUG_R8 "$DEBUG_R11::" found1

search2:
; search for the stack frame boundary marker prefix
StrLen $DEBUG_R8 $DEBUG_R7
IntOp $DEBUG_R8 $DEBUG_R8 + 2 ; add length of "::"
StrCpy $DEBUG_R8 $DEBUG_FRAME_ID $DEBUG_R8
StrCmpS $DEBUG_R8 "$DEBUG_R7::" found2

Return

found1:
StrCpy $DEBUG_R10 1
Return

found2:
StrCpy $DEBUG_R12 1
FunctionEnd
!macroend

!define Include_DebugStackPopForMarkerFrameImpl "!insertmacro Include_DebugStackPopForMarkerFrameImpl"
!macro Include_DebugStackPopForMarkerFrameImpl un
!ifndef ${un}DebugStackPopForMarkerFrameImpl_INCLUDED
!define ${un}DebugStackPopForMarkerFrameImpl_INCLUDED
${Func_DebugStackPopForMarkerFrameImpl} "${un}"
!endif

!verbose pop
!macroend

!define DebugStackCheckFrameImpl "!insertmacro DebugStackCheckFrameImpl"
!macro DebugStackCheckFrameImpl current_func_name prev_func_name code_id frame_id
!if `${code_id}` == ""
!error "${current_func_name}: code_id must be not empty code block identification string"
!endif
!if `${frame_id}` < 0
!error "${current_func_name}: frame_id must be not empty and not negative ordinal number of stack frame in a code block"
!endif

!if ${ENABLE_DEBUG_STACK_FRAMES} <> 0
!ifndef ${prev_func_name}__SRCID_${code_id}_${frame_id}
!error "DebugStackCheckFrame: appropriate call to $\"${prev_func_name} ${code_id} ${frame_id}$\" must be used before this call!"
!endif

!define DebugStackCheckFrameImpl__LABELID_NOT_FOUND DebugStackCheckFrameImpl__LABELID_NOT_FOUND_${code_id}_${frame_id}_L${__LINE__}
!define DebugStackCheckFrameImpl__LABELID_EXIT DebugStackCheckFrameImpl__LABELID_EXIT_${code_id}_${frame_id}_L${__LINE__}

StrCpy $DEBUG_R7 "${DBGID_STR_PREFIX}::${_NSIS_SETUP_LIB_BUILD_GUID16}:${code_id}:${frame_id}"

${DebugStackPopForMarkerFrameImpl} Pop "" ${DebugStackCheckFrameImpl__LABELID_NOT_FOUND} ${DebugStackCheckFrameImpl__LABELID_EXIT}
${DebugStackCheckFrameImpl__LABELID_NOT_FOUND}:
  StrCpy $DEBUG_R3 "${current_func_name}"
  StrCpy $DEBUG_R4 "${${current_func_name}__SRCID_${code_id}_${frame_id}}"
  StrCpy $DEBUG_R5 "${${prev_func_name}__SRCID_${code_id}_${frame_id}}"
  StrCpy $DEBUG_R6 "|Found Frame: $\"$DEBUG_FRAME_ID$\"$\n|Expected Frame Prefix: $\"$DEBUG_R7$\"$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackCheckFrameImpl_ImplAskAbort
  !else
  Call un.DebugStackCheckFrameImpl_ImplAskAbort
  !endif

${DebugStackCheckFrameImpl__LABELID_EXIT}:
!undef DebugStackCheckFrameImpl__LABELID_NOT_FOUND
!undef DebugStackCheckFrameImpl__LABELID_EXIT
!endif
!macroend

; DebugStackCheckFrame

!define DebugStackCheckFrame "!insertmacro DebugStackCheckFrame"
!macro DebugStackCheckFrame code_id frame_id check_all_regs
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if "${DebugStackCheckFrame__SRCID_${code_id}_${frame_id}}" != ""
!define /redef DebugStackLastCheckFrame__SRCID_${code_id}_${frame_id} "${DebugStackCheckFrame__SRCID_${code_id}_${frame_id}}"
!endif
!define /redef DebugStackCheckFrame__SRCID_${code_id}_${frame_id} \
  "SRCID::${_NSIS_SETUP_LIB_BUILD_DATE}::${_NSIS_SETUP_LIB_BUILD_TIME}::${__FILE__}/${code_id}/${frame_id}:${__LINE__}"

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackCheckFrame "${code_id}/${frame_id}" "" MB_OK "" \
    "|check_all_regs=${check_all_regs}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

!if ${ENABLE_DEBUG_STACK_FRAMES} <> 0
!if ${check_all_regs} <> 0
!if "${DebugStackLastCheckFrame__SRCID_${code_id}_${frame_id}}" != ""
${DebugStackPopAllRegsAndCheckImpl} DebugStackCheckFrame DebugStackLastCheckFrame `${code_id}` `${frame_id}`
!else
${DebugStackPopAllRegsAndCheckImpl} DebugStackCheckFrame DebugStackEnterFrame `${code_id}` `${frame_id}`
!endif
!undef DebugStackPushAllRegs__SRCID_${code_id}_${frame_id}

${DebugStackPushAllRegs} `${code_id}` `${frame_id}`
!endif
!endif

!if "${DebugStackLastCheckFrame__SRCID_${code_id}_${frame_id}}" != ""
${DebugStackCheckFrameImpl} DebugStackCheckFrame DebugStackLastCheckFrame `${code_id}` `${frame_id}`
!else
${DebugStackCheckFrameImpl} DebugStackCheckFrame DebugStackEnterFrame `${code_id}` `${frame_id}`
!endif
${Push} $DEBUG_FRAME_ID

!verbose pop
!macroend

; DebugStackExitFrame

!define DebugStackExitFrame "!insertmacro DebugStackExitFrame"
!macro DebugStackExitFrame code_id frame_id pop_all_regs_and_check_flag
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if "${DebugStackCheckFrame__SRCID_${code_id}_${frame_id}}" != ""
!define /redef DebugStackLastCheckFrame__SRCID_${code_id}_${frame_id} "${DebugStackCheckFrame__SRCID_${code_id}_${frame_id}}"
!endif

!define DebugStackExitFrame__SRCID_${code_id}_${frame_id} \
  "SRCID::${_NSIS_SETUP_LIB_BUILD_DATE}::${_NSIS_SETUP_LIB_BUILD_TIME}::${__FILE__}/${code_id}/${frame_id}:${__LINE__}"

; save errors flag
${PushErrors}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackExitFrame "${code_id}/${frame_id}" "" MB_OK "" \
    "|pop_all_regs_and_check_flag=${pop_all_regs_and_check_flag}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

!if ${ENABLE_DEBUG_STACK_FRAMES} <> 0
!if ${pop_all_regs_and_check_flag} <> 0
${DebugStackPopAllRegsAndCheckImpl} DebugStackExitFrame DebugStackPushAllRegs `${code_id}` `${frame_id}`
!undef DebugStackPushAllRegs__SRCID_${code_id}_${frame_id}
!endif
!endif

!if "${DebugStackLastCheckFrame__SRCID_${code_id}_${frame_id}}" != ""
${DebugStackCheckFrameImpl} DebugStackExitFrame DebugStackLastCheckFrame `${code_id}` `${frame_id}`
!else
${DebugStackCheckFrameImpl} DebugStackExitFrame DebugStackEnterFrame `${code_id}` `${frame_id}`
!endif

; restore errors flag
${PopErrors}

!undef DebugStackExitFrame__SRCID_${code_id}_${frame_id}
!undef DebugStackEnterFrame__SRCID_${code_id}_${frame_id}
!undef DebugStackCheckFrame__SRCID_${code_id}_${frame_id}
!undef DebugStackLastCheckFrame__SRCID_${code_id}_${frame_id}

!verbose pop
!macroend

; DebugStackPushAllRegs

!define DebugStackPushAllRegs "!insertmacro DebugStackPushAllRegs"
!macro DebugStackPushAllRegs code_id frame_id
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!define DebugStackPushAllRegs__SRCID_${code_id}_${frame_id} \
  "SRCID::${_NSIS_SETUP_LIB_BUILD_DATE}::${_NSIS_SETUP_LIB_BUILD_TIME}::${__FILE__}/${code_id}/${frame_id}:${__LINE__}"

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackPushAllRegs "${code_id}/${frame_id}" "" MB_OK "" \
    "|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

${DebugStackCheckFrameImpl} DebugStackPushAllRegs DebugStackEnterFrame `${code_id}` `${frame_id}`

!if ${ENABLE_DEBUG_STACK_FRAMES} <> 0
${Push} $DEBUG_FRAME_ID
${Push} $R0
${Push} $R1
${Push} $R2
${Push} $R3
${Push} $R4
${Push} $R5
${Push} $R6
${Push} $R7
${Push} $R8
${Push} $R9
${Push} $0
${Push} $1
${Push} $2
${Push} $3
${Push} $4
${Push} $5
${Push} $6
${Push} $7
${Push} $8
${Push} $9
${Push} $DEBUG_FRAME_ID ; duplicate the frame marker
!endif

!verbose pop
!macroend

; DebugStackPopAllRegsAndCheckImpl

!define Func_DebugStackPopAllRegsAndCheckImpl "!insertmacro Func_DebugStackPopAllRegsAndCheckImpl"
!macro Func_DebugStackPopAllRegsAndCheckImpl un
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

Function ${un}DebugStackPopAllRegsAndCheck_ImplCheck
  StrCpy $DEBUG_R0 ""

  ${If} $DEBUG_R9 < 0
    Goto end
  ${EndIf}

  ${Switch} $DEBUG_R9
    ${Case} 0
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $9
        StrCpy $DEBUG_R1 "9"
        StrCpy $DEBUG_R2 $9
        Return
      ${EndIf}
    ${Case} 1
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $8
        StrCpy $DEBUG_R1 "8"
        StrCpy $DEBUG_R2 $8
        Return
      ${EndIf}
    ${Case} 2
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $7
        StrCpy $DEBUG_R1 "7"
        StrCpy $DEBUG_R2 $7
        Return
      ${EndIf}
    ${Case} 3
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $6
        StrCpy $DEBUG_R1 "6"
        StrCpy $DEBUG_R2 $6
        Return
      ${EndIf}
    ${Case} 4
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $5
        StrCpy $DEBUG_R1 "5"
        StrCpy $DEBUG_R2 $5
        Return
      ${EndIf}
    ${Case} 5
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $4
        StrCpy $DEBUG_R1 "4"
        StrCpy $DEBUG_R2 $4
        Return
      ${EndIf}
    ${Case} 6
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $3
        StrCpy $DEBUG_R1 "3"
        StrCpy $DEBUG_R2 $3
        Return
      ${EndIf}
    ${Case} 7
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $2
        StrCpy $DEBUG_R1 "2"
        StrCpy $DEBUG_R2 $2
        Return
      ${EndIf}
    ${Case} 8
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $1
        StrCpy $DEBUG_R1 "1"
        StrCpy $DEBUG_R2 $1
        Return
      ${EndIf}
    ${Case} 9
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $0
        StrCpy $DEBUG_R1 "0"
        StrCpy $DEBUG_R2 $0
        Return
      ${EndIf}
    ${Case} 10
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R9
        StrCpy $DEBUG_R1 "R9"
        StrCpy $DEBUG_R2 $R9
        Return
      ${EndIf}
    ${Case} 11
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R8
        StrCpy $DEBUG_R1 "R8"
        StrCpy $DEBUG_R2 $R8
        Return
      ${EndIf}
    ${Case} 12
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R7
        StrCpy $DEBUG_R1 "R7"
        StrCpy $DEBUG_R2 $R7
        Return
      ${EndIf}
    ${Case} 13
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R6
        StrCpy $DEBUG_R1 "R6"
        StrCpy $DEBUG_R2 $R6
        Return
      ${EndIf}
    ${Case} 14
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R5
        StrCpy $DEBUG_R1 "R5"
        StrCpy $DEBUG_R2 $R5
        Return
      ${EndIf}
    ${Case} 15
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R4
        StrCpy $DEBUG_R1 "R4"
        StrCpy $DEBUG_R2 $R4
        Return
      ${EndIf}
    ${Case} 16
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R3
        StrCpy $DEBUG_R1 "R3"
        StrCpy $DEBUG_R2 $R3
        Return
      ${EndIf}
    ${Case} 17
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R2
        StrCpy $DEBUG_R1 "R2"
        StrCpy $DEBUG_R2 $R2
        Return
      ${EndIf}
    ${Case} 18
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R1
        StrCpy $DEBUG_R1 "R1"
        StrCpy $DEBUG_R2 $R1
        Return
      ${EndIf}
    ${Case} 19
      IntOp $DEBUG_R9 $DEBUG_R9 + 1
      ${Pop} $DEBUG_R0
      ${If} $DEBUG_R0 <> $R0
        StrCpy $DEBUG_R1 "R0"
        StrCpy $DEBUG_R2 $R0
        Return
      ${EndIf}
  ${EndSwitch}

  end:
  StrCpy $DEBUG_R9 -1 ; no pending comparisons
FunctionEnd

Function ${un}DebugStackPopAllRegsAndCheck_ImplAskAbort
  ${If} $USER_ABORT_ASK_ACCEPTED = 0 ; ignore dialog if already accepted by user
    ${If} $DEBUG <> 0 ; show dialog in silent mode if debugging
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackPopAllRegsAndCheck_ImplAskAbort" \
        $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND $(MSG_SETUP_DEBUG_CHECK_FAILED) $DEBUG_R6 "IDYES abort"
    ${Else}
      ${DebugMessageBox} "$DEBUG_R3->${un}DebugStackPopAllRegsAndCheck_ImplAskAbort" \
        $DEBUG_R4 $DEBUG_R5 MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND $(MSG_SETUP_DEBUG_CHECK_FAILED) $DEBUG_R6 "/SD IDNO IDYES abort"
    ${EndIf}
    Return

    ; Workaround for Abort/Quit call from a page control window procedure handler.
    ; Call !Abort again in case if it has been called already from such handler.

    abort:
    StrCpy $USER_ABORT_ASK_ACCEPTED 1
    ; Use Dumpstate plugin on abort in debug mode
    ${Push} $DEBUG_R0 ; restore last invalid value on top of stack
    ${If} $DEBUG <> 0
      Dumpstate::debug
    ${EndIf}
  ${EndIf}

  !ifdef Init_INCLUDED
    ; !AbortCall macro is not yet defined here
    !ifndef __UNINSTALL__
    Call !Abort
    !else
    Call un.!Abort
    !endif
  !else
    Abort
    Quit ; if not aborted
  !endif
FunctionEnd

!verbose pop
!macroend

!define Include_DebugStackPopAllRegsAndCheckImpl "!insertmacro Include_DebugStackPopAllRegsAndCheckImpl"
!macro Include_DebugStackPopAllRegsAndCheckImpl un
!ifndef ${un}DebugStackPopAllRegsAndCheckImpl_INCLUDED
!define ${un}DebugStackPopAllRegsAndCheckImpl_INCLUDED
${Func_DebugStackPopAllRegsAndCheckImpl} "${un}"
!endif
!macroend

!define DebugStackPopAllRegsAndCheckImpl "!insertmacro DebugStackPopAllRegsAndCheckImpl"
!macro DebugStackPopAllRegsAndCheckImpl current_func_name prev_func_name code_id frame_id
${DebugStackCheckFrameImpl} `${current_func_name}` `${prev_func_name}` `${code_id}` `${frame_id}`
!if ${ENABLE_DEBUG_STACK_FRAMES} <> 0
!define DebugStackPopAllRegsAndCheckImpl__LABELID_CONTINUE DebugStackPopAllRegsAndCheckImpl__LABELID_CONTINUE_${code_id}_${frame_id}_L${__LINE__}

; macro compilation optimization
StrCpy $DEBUG_R9 0 ; last comparison index

${DebugStackPopAllRegsAndCheckImpl__LABELID_CONTINUE}:
!ifndef __UNINSTALL__
Call DebugStackPopAllRegsAndCheck_ImplCheck
!else
Call un.DebugStackPopAllRegsAndCheck_ImplCheck
!endif

!define DebugStackPopAllRegsAndCheckImpl__LABELID_EXIT DebugStackPopAllRegsAndCheckImpl__LABELID_${code_id}_${frame_id}_L${__LINE__}

IntCmp $DEBUG_R9 0 ${DebugStackPopAllRegsAndCheckImpl__LABELID_EXIT} ${DebugStackPopAllRegsAndCheckImpl__LABELID_EXIT} ; error if >0
  StrCpy $DEBUG_R3 "${current_func_name}"
  StrCpy $DEBUG_R4 "${${current_func_name}__SRCID_${code_id}_${frame_id}}"
  StrCpy $DEBUG_R5 "${${prev_func_name}__SRCID_${code_id}_${frame_id}}"
  StrCpy $DEBUG_R6 "|Register: $\"$DEBUG_R1$\"$\n|Found Value: $\"$DEBUG_R2$\"$\n|Expected Value: $\"$DEBUG_R0$\"$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  ; macro compilation optimization
  !ifndef __UNINSTALL__
  Call DebugStackPopAllRegsAndCheck_ImplAskAbort
  !else
  Call un.DebugStackPopAllRegsAndCheck_ImplAskAbort
  !endif

  IntCmp $DEBUG_R9 0 0 0 ${DebugStackPopAllRegsAndCheckImpl__LABELID_CONTINUE} ; continue popping

${DebugStackPopAllRegsAndCheckImpl__LABELID_EXIT}:
!undef DebugStackPopAllRegsAndCheckImpl__LABELID_CONTINUE
!undef DebugStackPopAllRegsAndCheckImpl__LABELID_EXIT
!endif
!macroend

; DebugStackPopAllRegsAndCheck

!define DebugStackPopAllRegsAndCheck "!insertmacro DebugStackPopAllRegsAndCheck"
!macro DebugStackPopAllRegsAndCheck code_id frame_id
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackPopAllRegsAndCheck "${code_id}/${frame_id}" "" MB_OK "" \
    "|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

${DebugStackPopAllRegsAndCheckImpl} DebugStackPopAllRegsAndCheck DebugStackPushAllRegs `${code_id}` `${frame_id}`
!undef DebugStackPushAllRegs__SRCID_${code_id}_${frame_id}

!verbose pop
!macroend

; DebugStackEnterSection

!define DebugStackEnterSection "!insertmacro DebugStackEnterSection"
!macro DebugStackEnterSection section_var_name
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

IntOp $SECTION_SCOPE_INDEX $SECTION_SCOPE_INDEX + 1 ; increment before enter to enable Abort call from !Abort, otherwise the Quit will be called from !Abort in below functions!

${DebugStackEnterFrame} ${section_var_name} 0 0
${Push} $R0
${Push} $R1
${Push} $R2
${Push} $R3
${Push} $R4
${Push} $R5
${Push} $R6
${Push} $R7
${Push} $R8
${Push} $R9
${Push} $0
${Push} $1
${Push} $2
${Push} $3
${Push} $4
${Push} $5
${Push} $6
${Push} $7
${Push} $8
${Push} $9
${DebugStackEnterFrame} ${section_var_name} 1 0

!verbose pop
!macroend

; DebugStackCheckSection

!define DebugStackCheckSection "!insertmacro DebugStackCheckSection"
!macro DebugStackCheckSection section_var_name
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

${DebugStackCheckFrame} ${section_var_name} 1 0

!verbose pop
!macroend

; DebugStackExitSection

!define DebugStackExitSection "!insertmacro DebugStackExitSection"
!macro DebugStackExitSection section_var_name
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

${DebugStackExitFrame} ${section_var_name} 1 0
${Pop} $9
${Pop} $8
${Pop} $7
${Pop} $6
${Pop} $5
${Pop} $4
${Pop} $3
${Pop} $2
${Pop} $1
${Pop} $0
${Pop} $R9
${Pop} $R8
${Pop} $R7
${Pop} $R6
${Pop} $R5
${Pop} $R4
${Pop} $R3
${Pop} $R2
${Pop} $R1
${Pop} $R0
${DebugStackExitFrame} ${section_var_name} 0 0

IntOp $SECTION_SCOPE_INDEX $SECTION_SCOPE_INDEX - 1 ; decrement just before exit to enable Abort call from !Abort, otherwise the Quit will be called from !Abort in above functions!

!verbose pop
!macroend

; DebugStackEnterFunction

!define DebugStackEnterFunction "!insertmacro DebugStackEnterFunction"
!macro DebugStackEnterFunction function_name
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

${DebugStackEnterFrame} ${function_name} 0 0
${Push} $R0
${Push} $R1
${Push} $R2
${Push} $R3
${Push} $R4
${Push} $R5
${Push} $R6
${Push} $R7
${Push} $R8
${Push} $R9
${Push} $0
${Push} $1
${Push} $2
${Push} $3
${Push} $4
${Push} $5
${Push} $6
${Push} $7
${Push} $8
${Push} $9
${DebugStackEnterFrame} ${function_name} 1 0

!verbose pop
!macroend

; DebugStackCheckFunction

!define DebugStackCheckFunction "!insertmacro DebugStackCheckFunction"
!macro DebugStackCheckFunction function_name
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

${DebugStackCheckFrame} ${function_name} 1 0

!verbose pop
!macroend

; DebugStackExitFunction

!define DebugStackExitFunction "!insertmacro DebugStackExitFunction"
!macro DebugStackExitFunction function_name
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

${If} $PLUGINS_UNLOADED = 0 ; plugins not unloaded yet, can request debug check
  ${DebugStackExitFrame} ${function_name} 1 0
  ${Pop} $9
  ${Pop} $8
  ${Pop} $7
  ${Pop} $6
  ${Pop} $5
  ${Pop} $4
  ${Pop} $3
  ${Pop} $2
  ${Pop} $1
  ${Pop} $0
  ${Pop} $R9
  ${Pop} $R8
  ${Pop} $R7
  ${Pop} $R6
  ${Pop} $R5
  ${Pop} $R4
  ${Pop} $R3
  ${Pop} $R2
  ${Pop} $R1
  ${Pop} $R0
  ${DebugStackExitFrame} ${function_name} 0 0
${EndIf}

!verbose pop
!macroend

!if ${ENABLE_DEBUG_STACK_FRAMES} <> 0
${Include_DebugStackCheckFrameImpl} ''
${Include_DebugStackCheckFrameImpl} 'un.'
${Include_DebugStackPopAllRegsAndCheckImpl} ''
${Include_DebugStackPopAllRegsAndCheckImpl} 'un.'
!endif

; CAUTION:
;   Below functions SHOULD NOT even exist, but because the stack may be corrupted/polluted by the system calls like SendMessage
;   (SendMessage can push into stack different quantity of arguments w/o a number of that quantity), then
;   we have no choice to pop them out to cleanup the stack and before a call to DebugStackExitFrame/DebugStackCheckFrame.
;   To do so the marker having placed into the stack before such corruption/pollution calls and has to be cleanuped up to the marker after a call has made.
!define DebugStackPushMarkerFrame "!insertmacro DebugStackPushMarkerFrame"
!macro DebugStackPushMarkerFrame code_id frame_id marker_str_id
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackPushMarkerFrame "${code_id}/${frame_id}" "" MB_OK "" \
    "|marker_str_id=${marker_str_id}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

${Push} "${marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}::SRCID::${__FILE__}/${code_id}/${frame_id}:${__LINE__}"

!verbose pop
!macroend

; pops stack_frame_size_max stack values (including marker) from the main stack until the marker is found and push them into a private stack
!define DebugStackRestoreMainStackByMarkerFrameImpl "!insertmacro DebugStackRestoreMainStackByMarkerFrameImpl"
!macro DebugStackRestoreMainStackByMarkerFrameImpl code_id frame_id stack_handle stack_frame_size_max reg_list main_stack_marker_str_id private_stack_marker_str_id
!define DebugStackRestoreMainStackByMarkerFrameImpl__SRCID_${code_id}_${frame_id} "SRCID::${__FILE__}/${code_id}/${frame_id}:${__LINE__}"

!define DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_VALID_CALL DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_VALID_CALL_L${__LINE__}
!define DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_L${__LINE__}
!define DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END_L${__LINE__}
!define DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT_L${__LINE__}
!define DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_REVERT DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_REVERT_L${__LINE__}
!define DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND_L${__LINE__}
!define DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_EXIT DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_EXIT_L${__LINE__}

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX <> 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 1
  ${DebugMessageBox} DebugStackRestoreMainStackByMarkerFrameImpl "${code_id}/${frame_id}" "" MB_OK|MB_DUMPSTATE "" "|pos=BEGIN$\n|stack_handle=${stack_handle}$\n|stack_frame_size_max=${stack_frame_size_max}$\n|private_stack_marker_str_id=${private_stack_marker_str_id}" ""
${EndIf}
!endif

; check at first the stack plugin availability and size
IntCmp ${stack_handle} 0 +2
IntCmp $PLUGINS_UNLOADED 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_VALID_CALL}
  StrCpy $DEBUG_R3 "DebugStackRestoreMainStackByMarkerFrameImpl"
  StrCpy $DEBUG_R4 "${DebugStackRestoreMainStackByMarkerFrameImpl__SRCID_${code_id}_${frame_id}}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Invalid Call: stack::dll_size$\n|Stack Handle: ${stack_handle}$\n|Plugins Unloaded: $PLUGINS_UNLOADED$\n$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackInvalidCall_ImplAskAbort
  !else
  Call un.DebugStackInvalidCall_ImplAskAbort
  !endif

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_VALID_CALL}:
; check the out-of-stack-frame access
${stack::ns_size} $DEBUG_ST0
IntCmp $DEBUG_ST0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_EXIT}

StrLen $DEBUG_R3 "${main_stack_marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}::"
StrLen $DEBUG_R4 "${DLGSHOWID_STR_PREFIX}::${_NSIS_SETUP_LIB_BUILD_GUID16}::"
StrLen $DEBUG_R5 "${DBGID_STR_PREFIX}::${_NSIS_SETUP_LIB_BUILD_GUID16}:"

; check stack on other markers presence except the main WindowProc frame marker, exit immediately if found before the main marker
StrCpy $DEBUG_ST1 1 ; counter
${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP}:
  IntCmp $DEBUG_ST1 ${stack_frame_size_max} 0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END}
  IntCmp $DEBUG_ST1 $DEBUG_ST0 0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END}
  ${stack::ns_read} $DEBUG_ST1 $DEBUG_ST2 $NULL
  StrCpy $DEBUG_R8 $DEBUG_ST2 $DEBUG_R3
  StrCmpS $DEBUG_R8 "${main_stack_marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}::" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END}
  StrCpy $DEBUG_R8 $DEBUG_ST2 $DEBUG_R4
  StrCmpS $DEBUG_R8 "${DLGSHOWID_STR_PREFIX}::${_NSIS_SETUP_LIB_BUILD_GUID16}::" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END}
  StrCpy $DEBUG_R8 $DEBUG_ST2 $DEBUG_R5
  StrCmpS $DEBUG_R8 "${DBGID_STR_PREFIX}::${_NSIS_SETUP_LIB_BUILD_GUID16}:" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_EXIT}
  IntOp $DEBUG_ST1 $DEBUG_ST1 + 1
  ${Goto} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP}
${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END}:

; end marker first
!if "${private_stack_marker_str_id}" != "" ; save end marker into private stack
${SystemPush} "${stack_handle}" "${private_stack_marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}::${DebugStackRestoreMainStackByMarkerFrameImpl__SRCID_${code_id}_${frame_id}}"
!endif

StrCpy $DEBUG_R9 0 ; pop/push counter
StrCpy $DEBUG_R7 "${main_stack_marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}"

${DebugStackPopForMarkerFrameImpl} Pop "" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R1 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R1:
; is DLGSHOWID frame found instead?
IntCmp $DEBUG_R10 0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}
${UnfoldMacroArgumentList} "${reg_list}" CURRENT_REG_NAME NEXT_REG_LIST $ | ""
!if "${CURRENT_REG_NAME}" != ""
StrCpy $${CURRENT_REG_NAME} $DEBUG_FRAME_ID
!endif
${SystemPush} "${stack_handle}" $DEBUG_FRAME_ID

!if ${stack_frame_size_max} > 1
${DebugStackPopForMarkerFrameImpl} Pop "" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R2 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R2:
; is DLGSHOWID frame found instead?
IntCmp $DEBUG_R10 0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}
${UnfoldMacroArgumentList} "${NEXT_REG_LIST}" CURRENT_REG_NAME NEXT_REG_LIST $ | ""
!if "${CURRENT_REG_NAME}" != ""
StrCpy $${CURRENT_REG_NAME} $DEBUG_FRAME_ID
!endif
${SystemPush} "${stack_handle}" $DEBUG_FRAME_ID

!if ${stack_frame_size_max} > 2
${DebugStackPopForMarkerFrameImpl} Pop "" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R3 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R3:
; is DLGSHOWID frame found instead?
IntCmp $DEBUG_R10 0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}
${UnfoldMacroArgumentList} "${NEXT_REG_LIST}" CURRENT_REG_NAME NEXT_REG_LIST $ | ""
!if "${CURRENT_REG_NAME}" != ""
StrCpy $${CURRENT_REG_NAME} $DEBUG_FRAME_ID
!endif
${SystemPush} "${stack_handle}" $DEBUG_FRAME_ID

!if ${stack_frame_size_max} > 3
${DebugStackPopForMarkerFrameImpl} Pop "" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R4 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT}_R4:
; is DLGSHOWID frame found instead?
IntCmp $DEBUG_R10 0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}
${UnfoldMacroArgumentList} "${NEXT_REG_LIST}" CURRENT_REG_NAME NEXT_REG_LIST $ | ""
!if "${CURRENT_REG_NAME}" != ""
StrCpy $${CURRENT_REG_NAME} $DEBUG_FRAME_ID
!endif
${SystemPush} "${stack_handle}" $DEBUG_FRAME_ID

!if ${stack_frame_size_max} > 4
!error "DebugStackRestoreMainStackByMarkerFrameImpl: restore supports maximum of 4 stack elements in the row only!"
!endif
!endif
!endif
!endif

!undef CURRENT_REG_NAME
!undef NEXT_REG_LIST

${DebugStackPopForMarkerFrameImpl} Pop "" ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_REVERT} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_REVERT}:
; is DLGSHOWID frame found instead?
IntCmp $DEBUG_R10 0 0 ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX <> 0
  ${DebugMessageBox} DebugStackRestoreMainStackByMarkerFrameImpl "${code_id}/${frame_id}" "" MB_OK|MB_DUMPSTATE "" \
    "|pos=RESTORE$\n|stack_handle=${stack_handle}$\n|stack_frame_size_max=${stack_frame_size_max}" ""
${EndIf}
!endif

${Push} $DEBUG_FRAME_ID ; always restore, because it is not a part of frame

StrCpy $DEBUG_R8 "${stack_handle}"
StrCpy $DEBUG_R10 ${stack_frame_size_max}
!ifndef __UNINSTALL__
Call DebugStackRestoreMainStackByMarkerFrameImpl_Revert
!else
Call un.DebugStackRestoreMainStackByMarkerFrameImpl_Revert
!endif

!if "${private_stack_marker_str_id}" != "" ; markers saved into private stack
${SystemPop} "${stack_handle}" $NULL ; pop end marker
!endif

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX <> 0
  ${DebugMessageBox} DebugStackRestoreMainStackByMarkerFrameImpl "${code_id}/${frame_id}" "" MB_OK|MB_DUMPSTATE "" \
    "|pos=RESTORED$\n|stack_handle=${stack_handle}" ""
${EndIf}
!endif

${Goto} ${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_EXIT}

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND}:
!if "${private_stack_marker_str_id}" != "" ; save into private stack
${If} $DEBUG_R10 = 0
  ${SystemPush} "${stack_handle}" $DEBUG_FRAME_ID ; push to private stack found frame
${Else}
  ${SystemPush} "${stack_handle}" "${main_stack_marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}" ; push WNDPROCID instead DLGSHOWID
${EndIf}
!else
${If} $DEBUG_R10 <> 0
  ${Push} $DEBUG_FRAME_ID ; restore DLGSHOWID frame back if found
${EndIf}
StrCpy $DEBUG_R8 "${stack_handle}"
!ifndef __UNINSTALL__
Call DebugStackRestoreMainStackByMarkerFrameImpl_Cleanup
!else
Call un.DebugStackRestoreMainStackByMarkerFrameImpl_Cleanup
!endif
!endif

${DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_EXIT}:
!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX <> 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 0
  ${DebugMessageBox} DebugStackRestoreMainStackByMarkerFrameImpl "${code_id}/${frame_id}" "" MB_OK|MB_DUMPSTATE "" \
    "|pos=EXIT$\n|stack_handle=${stack_handle}$\n|num_popped_vars=$DEBUG_R9" ""
${EndIf}
!endif

!undef DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_NEXT
!undef DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_REVERT
!undef DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_FRAME_FOUND
!undef DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_EXIT
!undef DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP_END
!undef DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_STACK_MARKER_SEARCH_LOOP
!undef DebugStackRestoreMainStackByMarkerFrameImpl__LABELID_VALID_CALL
!undef DebugStackRestoreMainStackByMarkerFrameImpl__SRCID_${code_id}_${frame_id}
!macroend

!define Func_DebugStackRestoreMainStackByMarkerFrameImpl_Revert "!insertmacro Func_DebugStackRestoreMainStackByMarkerFrameImpl_Revert"
!macro Func_DebugStackRestoreMainStackByMarkerFrameImpl_Revert un
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

Function ${un}DebugStackRestoreMainStackByMarkerFrameImpl_Revert
StrCpy $DEBUG_R9 $DEBUG_R10

${While} $DEBUG_R9 > 0
  ${SystemPopToStack} $DEBUG_R8
  IntOp $DEBUG_R9 $DEBUG_R9 - 1
${EndWhile}
FunctionEnd

!verbose pop
!macroend

!define Func_DebugStackRestoreMainStackByMarkerFrameImpl_Cleanup "!insertmacro Func_DebugStackRestoreMainStackByMarkerFrameImpl_Cleanup"
!macro Func_DebugStackRestoreMainStackByMarkerFrameImpl_Cleanup un
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

Function ${un}DebugStackRestoreMainStackByMarkerFrameImpl_Cleanup
; cleanup used private stack
IntOp $DEBUG_R9 $DEBUG_R9 - 1 ; main stack frame was not pushed

loop:
IntCmp $DEBUG_R9 0 end end
${SystemPop} $DEBUG_R8 $NULL

IntOp $DEBUG_R9 $DEBUG_R9 - 1
Goto loop

end:
FunctionEnd

!verbose pop
!macroend

!define Include_DebugStackRestoreMainStackByMarkerFrameImpl "!insertmacro Include_DebugStackRestoreMainStackByMarkerFrameImpl"
!macro Include_DebugStackRestoreMainStackByMarkerFrameImpl un
!ifndef ${un}DebugStackRestoreMainStackByMarkerFrameImpl_INCLUDED
!define ${un}DebugStackRestoreMainStackByMarkerFrameImpl_INCLUDED
${Func_DebugStackRestoreMainStackByMarkerFrameImpl_Revert} "${un}"
${Func_DebugStackRestoreMainStackByMarkerFrameImpl_Cleanup} "${un}"
!endif
!macroend

!define DebugStackRestoreMainStackByMarkerFrame "!insertmacro DebugStackRestoreMainStackByMarkerFrame"
!macro DebugStackRestoreMainStackByMarkerFrame code_id frame_id stack_handle stack_frame_size_max reg_list main_stack_marker_str_id
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackRestoreMainStackByMarkerFrame "${code_id}/${frame_id}" "" MB_OK "" \
    "|reg_list=${reg_list}$\n|stack_handle=${stack_handle}$\n|stack_frame_size_max=${stack_frame_size_max}$\n|main_stack_marker_str_id=${main_stack_marker_str_id}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

${DebugStackRestoreMainStackByMarkerFrameImpl} ${code_id} ${frame_id} "${stack_handle}" ${stack_frame_size_max} "${reg_list}" "${main_stack_marker_str_id}" ""

!verbose pop
!macroend

!define DebugStackMoveToPrivateStackByMarkerFrame "!insertmacro DebugStackMoveToPrivateStackByMarkerFrame"
!macro DebugStackMoveToPrivateStackByMarkerFrame code_id frame_id stack_handle stack_frame_size_max reg_list main_stack_marker_str_id private_stack_marker_str_id
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackMoveToPrivateStackByMarkerFrame "${code_id}/${frame_id}" "" MB_OK "" \
    "|stack_handle=${stack_handle}$\n|stack_frame_size_max=${stack_frame_size_max}$\n|reg_list=${reg_list}$\n|main_stack_marker_str_id=${main_stack_marker_str_id}$\n|private_stack_marker_str_id=${private_stack_marker_str_id}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

${DebugStackRestoreMainStackByMarkerFrameImpl} ${code_id} ${frame_id} "${stack_handle}" ${stack_frame_size_max} "${reg_list}" "${main_stack_marker_str_id}" "${private_stack_marker_str_id}"

!verbose pop
!macroend

; pops stack_frame_size_max stack values (including marker) from a private stack until the marker is found and push them into the main stack
!define DebugStackRestorePrivateStackByMarkerFrameImpl "!insertmacro DebugStackRestorePrivateStackByMarkerFrameImpl"
!macro DebugStackRestorePrivateStackByMarkerFrameImpl load_to_main_stack_flag code_id frame_id stack_handle stack_frame_size_max main_stack_marker_str_id private_stack_marker_str_id
!define DebugStackMoveFromPrivateStackByMarkerFrame__SRCID_${code_id}_${frame_id} "SRCID::${_NSIS_SETUP_LIB_BUILD_DATE}::${_NSIS_SETUP_LIB_BUILD_TIME}::${__FILE__}/${code_id}/${frame_id}:${__LINE__}"

!define DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT_L${__LINE__}
!define DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_MAIN_STACK_FRAME_NOT_FOUND DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_MAIN_STACK_FRAME_NOT_FOUND_L${__LINE__}
!define DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_FRAME_NOT_FOUND DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_FRAME_NOT_FOUND_L${__LINE__}
!define DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT_L${__LINE__}
!define DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_LOOP DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_LOOP_L${__LINE__}
!define DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_END DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_END_L${__LINE__}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackRestorePrivateStackByMarkerFrameImpl "${code_id}/${frame_id}" "" MB_OK "" \
    "|stack_handle=${stack_handle}$\n|stack_frame_size_max=${stack_frame_size_max}$\n|main_stack_marker_str_id=${main_stack_marker_str_id}$\n|private_stack_marker_str_id=${private_stack_marker_str_id}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX <> 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 1
  ${DebugMessageBox} DebugStackRestorePrivateStackByMarkerFrameImpl "${code_id}/${frame_id}" "" MB_OK|MB_DUMPSTATE "" \
    "|pos=BEGIN$\n|stack_handle=${stack_handle}$\n|private_stack_marker_str_id=${private_stack_marker_str_id}" ""
${EndIf}
!endif

StrCpy $DEBUG_R7 "${main_stack_marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}"

${DebugStackPopForMarkerFrameImpl} SystemPop "${stack_handle}" ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_MAIN_STACK_FRAME_NOT_FOUND} ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_MAIN_FRAME

${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_MAIN_FRAME:
!if ${load_to_main_stack_flag} <> 0
${Push} $DEBUG_FRAME_ID
!endif

StrCpy $DEBUG_R7 "${private_stack_marker_str_id}::${_NSIS_SETUP_LIB_BUILD_GUID16}"

${DebugStackPopForMarkerFrameImpl} SystemPop "${stack_handle}" ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R1 ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT}

${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R1:
!if ${load_to_main_stack_flag} <> 0
${Push} $DEBUG_FRAME_ID
!endif

!if ${stack_frame_size_max} > 1
${DebugStackPopForMarkerFrameImpl} SystemPop "${stack_handle}" ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R2 ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT}

${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R2:
!if ${load_to_main_stack_flag} <> 0
${Push} $DEBUG_FRAME_ID
!endif

!if ${stack_frame_size_max} > 2
${DebugStackPopForMarkerFrameImpl} SystemPop "${stack_handle}" ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R3 ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT}

${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R3:
!if ${load_to_main_stack_flag} <> 0
${Push} $DEBUG_FRAME_ID
!endif

!if ${stack_frame_size_max} > 3
${DebugStackPopForMarkerFrameImpl} SystemPop "${stack_handle}" ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R4 ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT}

${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT}_R4:
!if ${load_to_main_stack_flag} <> 0
${Push} $DEBUG_FRAME_ID
!endif

!if ${stack_frame_size_max} > 4
!error "DebugStackRestorePrivateStackByMarkerFrameImpl: restore supports maximum of 4 stack elements in the row only!"
!endif
!endif
!endif
!endif

${DebugStackPopForMarkerFrameImpl} SystemPop "${stack_handle}" \
  ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT} ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_FRAME_NOT_FOUND}

${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_MAIN_STACK_FRAME_NOT_FOUND}:
${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_FRAME_NOT_FOUND}:
  ; This function should already be debugged, the private and the main stacks DOES NOT try to restore here on error!!!
  ; So we have no choice other than to just ask for abortion.
  StrCpy $DEBUG_R3 "DebugStackRestorePrivateStackByMarkerFrameImpl"
  StrCpy $DEBUG_R4 "${DebugStackMoveFromPrivateStackByMarkerFrame__SRCID_${code_id}_${frame_id}}"
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 "|Found Frame: $\"$DEBUG_FRAME_ID$\"$\n|Expected Frame Prefix: $\"$DEBUG_R7$\"$\n"

  ; dump private stack first 19 values into $DEBUG_R6 if plugins is not unloaded
  StrCpy $DEBUG_R6 "$DEBUG_R6|Plugins Unloaded: $PLUGINS_UNLOADED$\n$\n"
  StrCpy $DEBUG_R6 "$DEBUG_R6|Private Stack Dump: size="
  IntCmp $PLUGINS_UNLOADED 0 +3
    StrCpy $DEBUG_R6 "$DEBUG_R6<unknown>$\n"
    ${Goto} ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_END}
    ${stack::dll_size} ${stack_handle} $DEBUG_ST0
    StrCpy $DEBUG_R6 "$DEBUG_R6$DEBUG_ST0$\n"
    StrCpy $DEBUG_R6 "$DEBUG_R6|0: $\"$DEBUG_FRAME_ID$\"$\n" ; found frame at first
    StrCpy $DEBUG_ST1 1 ; counter
    ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_LOOP}:
      IntCmp $DEBUG_ST1 19 0 0 ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_END}
      IntCmp $DEBUG_ST1 $DEBUG_ST0 0 0 ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_END}
        ${stack::dll_read} ${stack_handle} $DEBUG_ST1 $DEBUG_ST2 $NULL
        StrCpy $DEBUG_R6 "$DEBUG_R6|$DEBUG_ST1: $\"$DEBUG_ST2$\"$\n"
        IntOp $DEBUG_ST1 $DEBUG_ST1 + 1
        ${Goto} ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_LOOP}

  ${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_END}:
  StrCpy $DEBUG_R6 "$DEBUG_R6$\n$(MSG_SETUP_INSTALL_ABORT_ASKING)"

  !ifndef __UNINSTALL__
  Call DebugStackCheckFrameImpl_ImplAskAbort
  !else
  Call un.DebugStackCheckFrameImpl_ImplAskAbort
  !endif

${DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT}:
!if ${ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX} <> 0
${If} $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX <> 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 0
  ${DebugMessageBox} DebugStackRestorePrivateStackByMarkerFrameImpl "${code_id}/${frame_id}" "" MB_OK|MB_DUMPSTATE "" \
    "|pos=EXIT$\n|stack_handle=${stack_handle}$\n|private_stack_marker_str_id=${private_stack_marker_str_id}" ""
${EndIf}
!endif

!undef DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_END
!undef DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_DUMP_LOOP
!undef DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_NEXT
!undef DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_MAIN_STACK_FRAME_NOT_FOUND
!undef DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_PRIVATE_STACK_FRAME_NOT_FOUND
!undef DebugStackMoveFromPrivateStackByMarkerFrame__LABELID_EXIT
!macroend

!define DebugStackRestorePrivateStackByMarkerFrame "!insertmacro DebugStackRestorePrivateStackByMarkerFrame"
!macro DebugStackRestorePrivateStackByMarkerFrame code_id frame_id stack_handle stack_frame_size_max main_stack_marker_str_id private_stack_marker_str_id
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackRestorePrivateStackByMarkerFrame "${code_id}/${frame_id}" "" MB_OK "" \
    "|stack_handle=${stack_handle}$\n|stack_frame_size_max=${stack_frame_size_max}$\n|main_stack_marker_str_id=${main_stack_marker_str_id}$\n|private_stack_marker_str_id=${private_stack_marker_str_id}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

${DebugStackRestorePrivateStackByMarkerFrameImpl} 0 ${code_id} ${frame_id} "${stack_handle}" ${stack_frame_size_max} "${main_stack_marker_str_id}" "${private_stack_marker_str_id}"

!verbose pop
!macroend

!define DebugStackMoveFromPrivateStackByMarkerFrame "!insertmacro DebugStackMoveFromPrivateStackByMarkerFrame"
!macro DebugStackMoveFromPrivateStackByMarkerFrame code_id frame_id stack_handle stack_frame_size_max main_stack_marker_str_id private_stack_marker_str_id
!verbose push
!verbose ${_NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL}

!if ${ENABLE_DEBUG_QUITTING_MSGBOX} <> 0
${If} $QUITTING <> 0
  ${DebugMessageBox} DebugStackMoveFromPrivateStackByMarkerFrame "${code_id}/${frame_id}" "" MB_OK "" \
    "|stack_handle=${stack_handle}$\n|stack_frame_size_max=${stack_frame_size_max}$\n|main_stack_marker_str_id=${main_stack_marker_str_id}$\n|private_stack_marker_str_id=${private_stack_marker_str_id}$\n|aborted=$QUITCALLED$\n|uniniting=$UNINITING$\n|section_scoped_index=$SECTION_SCOPE_INDEX" ""
${EndIf}
!endif

${DebugStackRestoreMainStackByMarkerFrameImpl} 1 ${code_id} ${frame_id} "${stack_handle}" ${stack_frame_size_max} "${main_stack_marker_str_id}" "${private_stack_marker_str_id}"

!verbose pop
!macroend

${Include_DebugStackImpl} ""
${Include_DebugStackImpl} "un."
${Include_DebugStackPopForMarkerFrameImpl} ""
${Include_DebugStackPopForMarkerFrameImpl} "un."
${Include_DebugStackRestoreMainStackByMarkerFrameImpl} ""
${Include_DebugStackRestoreMainStackByMarkerFrameImpl} "un."

!endif
