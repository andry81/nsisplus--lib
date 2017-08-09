!ifndef _NSIS_SETUP_LIB_INIT_NSI
!define _NSIS_SETUP_LIB_INIT_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\preprocessor.nsi"

; for enable/disable overall setup parameters
${!define_by_disable_flag} APP_DIR_INSTALL 0 ; to disable install/uninstall files from APP_DIR directory
${!define_by_disable_flag} APP_INTEGRATION_DIR_INSTALL 0 ; to disable install/uninstall files from APP_INTEGRATION_DIR directory and all others related to it

${!define_by_enable_flag} APP_DIR_INSTALL_FROM_ARCHIVE 0 ; to enable install from archive in APP_DIR directory and all others related to it
${!define_by_enable_flag} APP_INTEGRATION_DIR_INSTALL_FROM_ARCHIVE 0 ; to enable install from archive in APP_INTEGRATION_DIR directory and all others related to it

; for setup builtin debugging
${!define_by_enable_flag} DEBUG_PUSH 0 ; to enable Push macro overall debug 
${!define_by_enable_flag} DEBUG_POPEXCH 0 ; to enable Pop/Exch macro overall debug 

${!define_by_enable_flag} DEBUG_POPEXCH_OUTOFSTACK 0 ; to enable Pop/Exch out-of-stack debug (require ENABLE_DEBUG_POPEXCH enabled)

${!define_by_enable_flag} DEBUG_PUSHPOP_LOGGING 0 ; 1 to enable builtin Push/Pop/Exch macro logging by DetailPrint (require ENABLE_DEBUG_PUSH/ENABLE_DEBUG_POPEXCH enabled)
${!define_by_enable_flag} DEBUG_SYSTEM_PUSHPOP_MSGBOX 0 ; 1 to enable builtin SystemPush/SystemPop debug by message boxes from DebugStack macro functions
${!define_by_enable_flag} DEBUG_QUITTING_MSGBOX 0 ; 1 to enable builtin DebugStack* debug by message boxes when $QUITTING=1

${!define_by_disable_flag} TEMP_WORKAROUNDS 0 ; to disable temporary made workarounds everythere in code
${!define_by_disable_flag} DEBUG_STACK_FRAMES 0 ; to disable DebugStack*Frame calls

${!define_integer_value} _NSIS_SETUP_LIB_STACK_PUSHPOP_VERBOSE_LEVEL 3 ; 4 for debug the Push/Pop/Exch macro functions
${!define_integer_value} _NSIS_SETUP_LIB_DEBUG_STACK_VERBOSE_LEVEL 3 ; 4 for debug the DebugStack macro functions

Var /GLOBAL Missed_call_to_InitInstall_function
Var /GLOBAL NULL
Var /GLOBAL LAST_ERROR
Var /GLOBAL LAST_STATUS_STR
Var /GLOBAL INITED ; InitInstall/InitUninstall functions has been called and UninitInstall/UinitInstall is not
Var /GLOBAL UNINITING ; UninitInstall/UninitInstall functions has being called flag
Var /GLOBAL UNINIT_EVENT ; Uninit event message
Var /GLOBAL QUITTING ; quit "in progress" flag
Var /GLOBAL QUITCALLED ; specific flag to flag the Abort/Quit first time call ONLY
Var /GLOBAL QUIT_CMD ; command pending to call as quit command
Var /GLOBAL CUSTOM_ABORT ; flags not system abort/quit handler call
Var /GLOBAL CUSTOM_USER_ABORT ; flags customUserAbort which calls after cancel in GUI
Var /GLOBAL POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP ; flags postponed CommonUnloadUninitCleanupImpl call to move some critical unload/uninit/cleanup logic like plugins unload to a system handler call
Var /GLOBAL PLUGINS_UNLOADED ; flags plugin unload call
Var /GLOBAL USER_ABORT_ASK_ACCEPTED ; flags abort ask acception by user
Var /GLOBAL SECTION_SCOPE_INDEX ; if not 0 - section is executing between DebugStackEnterSection/DebugStackExitSection calls
Var /GLOBAL DEBUG
Var /GLOBAL DEBUG_FRAME_ID
Var /GLOBAL INSTDIR_PARAM
Var /GLOBAL INSTDIR_TMP ; auto remove on exit temporary install directory

; registers for debug routines between stack usage
Var /GLOBAL DEBUG_R0
Var /GLOBAL DEBUG_R1
Var /GLOBAL DEBUG_R2
Var /GLOBAL DEBUG_R3
Var /GLOBAL DEBUG_R4
Var /GLOBAL DEBUG_R5
Var /GLOBAL DEBUG_R6
Var /GLOBAL DEBUG_R7
Var /GLOBAL DEBUG_R8
Var /GLOBAL DEBUG_R9
Var /GLOBAL DEBUG_R10
Var /GLOBAL DEBUG_R11
Var /GLOBAL DEBUG_R12

; return values for intermediate store on moment of debugging the real 0-9/R0-R9 registers
Var /GLOBAL DEBUG_RET0
Var /GLOBAL DEBUG_RET1
Var /GLOBAL DEBUG_RET2
Var /GLOBAL DEBUG_RET3

; stack.nsi values for intermediate store on moment of usage the real 0-9/R0-R9 registers and the DEBUG_R* variables
Var /GLOBAL DEBUG_ST0
Var /GLOBAL DEBUG_ST1
Var /GLOBAL DEBUG_ST2

Var /GLOBAL GOTO_R0 ; temporary value before Goto operation to avoid Push/Pop operation over the real 0-9/R0-R9 registers

; temporary storage to store macro arguments
Var /GLOBAL MACRO_ARG0
Var /GLOBAL MACRO_ARG1
Var /GLOBAL MACRO_ARG2
Var /GLOBAL MACRO_ARG3
Var /GLOBAL MACRO_ARG4
Var /GLOBAL MACRO_ARG5
Var /GLOBAL MACRO_ARG6
Var /GLOBAL MACRO_ARG7
Var /GLOBAL MACRO_ARG8
Var /GLOBAL MACRO_ARG9
Var /GLOBAL MACRO_ARG10
Var /GLOBAL MACRO_ARG11
Var /GLOBAL MACRO_ARG12
Var /GLOBAL MACRO_ARG13
Var /GLOBAL MACRO_ARG14
Var /GLOBAL MACRO_ARG15
Var /GLOBAL MACRO_ARG16
Var /GLOBAL MACRO_ARG17
Var /GLOBAL MACRO_ARG18
Var /GLOBAL MACRO_ARG19

; temporary registers to pop/return values into/from 0-9/R0-R9 registers in a macros/functions by a register name
Var /GLOBAL MACRO_POP_VAR0
Var /GLOBAL MACRO_POP_VAR1
Var /GLOBAL MACRO_POP_VAR2
Var /GLOBAL MACRO_POP_VAR3
Var /GLOBAL MACRO_POP_VAR4
Var /GLOBAL MACRO_POP_VAR5
Var /GLOBAL MACRO_POP_VAR6
Var /GLOBAL MACRO_POP_VAR7
Var /GLOBAL MACRO_POP_VAR8
Var /GLOBAL MACRO_POP_VAR9
Var /GLOBAL MACRO_POP_VAR10
Var /GLOBAL MACRO_POP_VAR11
Var /GLOBAL MACRO_POP_VAR12
Var /GLOBAL MACRO_POP_VAR13
Var /GLOBAL MACRO_POP_VAR14
Var /GLOBAL MACRO_POP_VAR15
Var /GLOBAL MACRO_POP_VAR16
Var /GLOBAL MACRO_POP_VAR17
Var /GLOBAL MACRO_POP_VAR18
Var /GLOBAL MACRO_POP_VAR19

Var /GLOBAL MACRO_RET_VAR0
Var /GLOBAL MACRO_RET_VAR1
Var /GLOBAL MACRO_RET_VAR2
Var /GLOBAL MACRO_RET_VAR3
Var /GLOBAL MACRO_RET_VAR4
Var /GLOBAL MACRO_RET_VAR5
Var /GLOBAL MACRO_RET_VAR6
Var /GLOBAL MACRO_RET_VAR7
Var /GLOBAL MACRO_RET_VAR8
Var /GLOBAL MACRO_RET_VAR9
Var /GLOBAL MACRO_RET_VAR10
Var /GLOBAL MACRO_RET_VAR11
Var /GLOBAL MACRO_RET_VAR12
Var /GLOBAL MACRO_RET_VAR13
Var /GLOBAL MACRO_RET_VAR14
Var /GLOBAL MACRO_RET_VAR15
Var /GLOBAL MACRO_RET_VAR16
Var /GLOBAL MACRO_RET_VAR17
Var /GLOBAL MACRO_RET_VAR18
Var /GLOBAL MACRO_RET_VAR19

; runtime debugging variables
Var /GLOBAL ENABLE_DEBUG_PUSHPOP_LOGGING ; from anythere
Var /GLOBAL ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX ; from anythere
Var /GLOBAL ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 ; from stack.nsi

Var /GLOBAL EXEC_NSIS_SETUP_ARGS ; additional exec setup arguments
Var /GLOBAL MSG_ABORT
Var /GLOBAL SETUP_NEST_LVL ; setup in setup nest level index
Var /GLOBAL CURDIR
Var /GLOBAL SYSDRIVE
Var /GLOBAL LANG_PARAM
Var /GLOBAL LANG_GROUP_COUNTRY_STR
Var /GLOBAL LANG_SHORT_STR
Var /GLOBAL LANG_LONG_STR
Var /GLOBAL SHELL_VAR_CTX

Var /GLOBAL REBOOT_STATUS_FLAGS_EXT ; external reboot status, inputs to the setup process (not zero means reboot is requested)
Var /GLOBAL REBOOT_STATUS_FLAGS_INT ; internal reboot status, produces by the setup (not zero means reboot is requested)
Var /GLOBAL SILENT_SETUP
Var /GLOBAL SILENT_SETUP_NOTIFY_POPUP_SHOW_DELAY
Var /GLOBAL ROOT_SILENT_SETUP
Var /GLOBAL COMPONENTS_SILENT_INSTALL
Var /GLOBAL ADMINISTRATIVE_INSTALL
Var /GLOBAL ADMINISTRATIVE_INSTALL_ROOT
Var /GLOBAL PARENT_CONTROL_SETUP ; indicating that setup being runned from parent setup
Var /GLOBAL RAW_PARAM
Var /GLOBAL SETUP_INI_IN ; will be set only once in initialization
Var /GLOBAL SETUP_INI_OUT
Var /GLOBAL SMDIR
Var /GLOBAL START_MENU_DIR

Var /GLOBAL SYSDIR32 ; system32 on x32 OS and SysWOW64 on x64 OS
Var /GLOBAL SYSDIR64 ; empty if x32 OS

; need to initialize it in a custom GUI onInit function, but NOT in .onInit!
Var /GLOBAL Missed_call_to_InitInstallGUI_function
Var /GLOBAL APP_NAME_PREFIX
Var /GLOBAL APP_NAME
Var /GLOBAL SETUP_SESSION_DIR_PATH
Var /GLOBAL SETUP_SESSION_DIR_PATH_LOCAL

Var /GLOBAL COMPUTERNAME
Var /GLOBAL UNINSTALL_STRING

Var /GLOBAL MSG_NOTIFY_PRODUCT_SETUP_BEGIN
Var /GLOBAL MSG_NOTIFY_PRODUCT_SETUP_COMPLETED
Var /GLOBAL MSG_NOTIFY_PRODUCT_SETUP_CANCELED
Var /GLOBAL MSG_NOTIFY_PRODUCT_SETUP_ABORTED

Var /GLOBAL WNDPROC_STACK_HANDLE
Var /GLOBAL GUI_MAIN_DIALOG_LAST_HWND ; last hwnd from nsDialogs::create

!include "LogicLib.nsh"

; generate _NsisSetupLib builtin definitions
${!define_guid16} _NSIS_SETUP_LIB_BUILD_GUID16
!define _NSIS_SETUP_LIB_BUILD_DATE "${__DATE__}"
!define _NSIS_SETUP_LIB_BUILD_TIME "${__TIME__}"

!include "${_NSIS_SETUP_LIB_ROOT}\src\builtin.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\log.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\debug.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\notify.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\uninit.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\win32.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\utils.nsi"


!define InitInstall "!insertmacro InitInstall"
!macro InitInstall shell_ctx install_root setup_session_dir user_on_init_before_uac
${DebugStackEnterFrame} InitInstall 0 1
${Push} `${shell_ctx}`
${Push} `${install_root}`
${Push} `${setup_session_dir}`
${Push} `${user_on_init_before_uac}`
Call Init_ImplBegin

; user .onInit before UAC promotion
!if `${user_on_init_before_uac}` != ""
${If} $ADMINISTRATIVE_INSTALL = 0
  ; second argument of GetFunctionAddress must be a compile time value, otherwise wiil be an error message: `Error: resolving install function "..." in function "..."'
  GetFunctionAddress $R9 `${user_on_init_before_uac}`
  Call $R9
${EndIf}
!endif

Call Init_ImplEnd

${DebugStackExitFrame} InitInstall 0 1
!macroend

!define InitUninstall "!insertmacro InitUninstall"
!macro InitUninstall shell_ctx
${DebugStackEnterFrame} InitUninstall 0 1
${Push} `${shell_ctx}`
Call un.Init
${DebugStackExitFrame} InitUninstall 0 1
!macroend

!define InitInstallGUI "!insertmacro InitInstallGUI"
!macro InitInstallGUI
${DebugStackEnterFrame} InitInstallGUI 0 1
Call InitGUI
${DebugStackExitFrame} InitInstallGUI 0 1
!macroend

!define Func_InitInstall "!insertmacro Func_InitInstall"
!macro Func_InitInstall
Function Init_ImplBegin
  ${ExchStack4} $R0 $R1 $R2 $R3
  ;R0 - shell_ctx
  ;R1 - install_root
  ;R2 - setup_session_dir
  ;R3 - user_on_init_before_uac
  ${PushStack6} $R4 $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} Init 1 0

  ; Initialization before UAC promotion
  StrCpy $Missed_call_to_InitInstall_function "" ; dummy to suppress "Variable ... not referenced ..." warnings

  ; Drop last error level
  ClearErrors     ; setup internal
  SetErrorLevel 0 ; win32 API

  StrCpy $ERRORS 0
  StrCpy $ERRORS_STACK ""
  StrCpy $LAST_ERROR 0
  StrCpy $LAST_STATUS_STR ""
  StrCpy $INITED 0
  StrCpy $UNINITING 0
  StrCpy $UNINIT_EVENT ""
  StrCpy $QUITTING 0
  StrCpy $QUITCALLED 0
  StrCpy $QUIT_CMD ""
  StrCpy $CUSTOM_ABORT 0
  StrCpy $CUSTOM_USER_ABORT 0
  StrCpy $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP 0
  StrCpy $PLUGINS_UNLOADED 0
  StrCpy $USER_ABORT_ASK_ACCEPTED 0
  StrCpy $SECTION_SCOPE_INDEX 0
  StrCpy $DEBUG 0

  StrCpy $DEBUG_R0 ""
  StrCpy $DEBUG_R1 ""
  StrCpy $DEBUG_R2 ""
  StrCpy $DEBUG_R3 ""
  StrCpy $DEBUG_R4 ""
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 ""
  StrCpy $DEBUG_R7 ""
  StrCpy $DEBUG_R8 ""
  StrCpy $DEBUG_R9 ""
  StrCpy $DEBUG_R10 ""
  StrCpy $DEBUG_R11 ""
  StrCpy $DEBUG_R12 ""
  StrCpy $DEBUG_RET0 ""
  StrCpy $DEBUG_RET1 ""
  StrCpy $DEBUG_RET2 ""
  StrCpy $DEBUG_RET3 ""
  StrCpy $DEBUG_ST0 ""
  StrCpy $DEBUG_ST1 ""
  StrCpy $DEBUG_ST2 ""

  StrCpy $GOTO_R0 ""

  StrCpy $MACRO_POP_VAR0 ""
  StrCpy $MACRO_POP_VAR1 ""
  StrCpy $MACRO_POP_VAR2 ""
  StrCpy $MACRO_POP_VAR3 ""
  StrCpy $MACRO_POP_VAR4 ""
  StrCpy $MACRO_POP_VAR5 ""
  StrCpy $MACRO_POP_VAR6 ""
  StrCpy $MACRO_POP_VAR7 ""
  StrCpy $MACRO_POP_VAR8 ""
  StrCpy $MACRO_POP_VAR9 ""
  StrCpy $MACRO_POP_VAR10 ""
  StrCpy $MACRO_POP_VAR11 ""
  StrCpy $MACRO_POP_VAR12 ""
  StrCpy $MACRO_POP_VAR13 ""
  StrCpy $MACRO_POP_VAR14 ""
  StrCpy $MACRO_POP_VAR15 ""
  StrCpy $MACRO_POP_VAR16 ""
  StrCpy $MACRO_POP_VAR17 ""
  StrCpy $MACRO_POP_VAR18 ""
  StrCpy $MACRO_POP_VAR19 ""

  StrCpy $MACRO_RET_VAR0 ""
  StrCpy $MACRO_RET_VAR1 ""
  StrCpy $MACRO_RET_VAR2 ""
  StrCpy $MACRO_RET_VAR3 ""
  StrCpy $MACRO_RET_VAR4 ""
  StrCpy $MACRO_RET_VAR5 ""
  StrCpy $MACRO_RET_VAR6 ""
  StrCpy $MACRO_RET_VAR7 ""
  StrCpy $MACRO_RET_VAR8 ""
  StrCpy $MACRO_RET_VAR9 ""
  StrCpy $MACRO_RET_VAR10 ""
  StrCpy $MACRO_RET_VAR11 ""
  StrCpy $MACRO_RET_VAR12 ""
  StrCpy $MACRO_RET_VAR13 ""
  StrCpy $MACRO_RET_VAR14 ""
  StrCpy $MACRO_RET_VAR15 ""
  StrCpy $MACRO_RET_VAR16 ""
  StrCpy $MACRO_RET_VAR17 ""
  StrCpy $MACRO_RET_VAR18 ""
  StrCpy $MACRO_RET_VAR19 ""

  StrCpy $ENABLE_DEBUG_PUSHPOP_LOGGING 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 0

  StrCpy $EXEC_NSIS_SETUP_ARGS ""

  StrCpy $SILENT_SETUP_NOTIFY_POPUP_SHOW_DELAY 0 ; in case of uninit before complete init

  StrCpy $WNDPROC_STACK_HANDLE 0
  StrCpy $GUI_MAIN_DIALOG_LAST_HWND 0

  ${GetOptions} $CMDLINE "/debug" $NULL
  ${If} ${NoErrors}
    StrCpy $DEBUG 1
    StrCpy $EXEC_NSIS_SETUP_ARGS "$EXEC_NSIS_SETUP_ARGS /debug"
  ${EndIf}

  ${DebugStackCheckFrame} Init 1 0

  StrCpy $REBOOT_STATUS_FLAGS_EXT 0
  StrCpy $REBOOT_STATUS_FLAGS_INT 0

  StrCpy $UAC_PROCESS_ELEVATION_STATUS_FLAGS -1
  StrCpy $PROCESS_ID 0

  System::Call "kernel32::GetCurrentProcessId() i.R9"
  StrCpy $PROCESS_ID $R9

  System::Call "kernel32::GetCurrentDirectory(i ${NSIS_MAX_STRLEN}, t .R9) i"
  StrCpy $CURDIR $R9

  ; administrative install
  ${GetOptions} $CMDLINE "/A" $NULL
  ${If} ${NoErrors}
    StrCpy $ADMINISTRATIVE_INSTALL 1
    ${GetOptions} $CMDLINE "/A=" $ADMINISTRATIVE_INSTALL_ROOT
    ${If} $ADMINISTRATIVE_INSTALL_ROOT == ""
      StrCpy $ADMINISTRATIVE_INSTALL_ROOT "$CURDIR\_$EXEFILE"
    ${Else}
      ${GetAbsolutePath} $ADMINISTRATIVE_INSTALL_ROOT "$ADMINISTRATIVE_INSTALL_ROOT"
    ${EndIf}
    ${DetailPrint} "Making administrative installation into $\"$ADMINISTRATIVE_INSTALL_ROOT$\"..."
  ${Else}
    StrCpy $ADMINISTRATIVE_INSTALL 0
  ${EndIf}

  ${DebugStackCheckFrame} Init 1 0

  ; $Temp directory is shared between other installers, but $PluginsDir directory is unique
  ${If} $R2 != ""
    StrCpy $SETUP_SESSION_DIR_PATH_LOCAL "$PluginsDir\$R2"
  ${Else}
    StrCpy $SETUP_SESSION_DIR_PATH_LOCAL "$PluginsDir\shared" ; must be subdirectory to be shared w/o collisions
  ${EndIf}
  CreateDirectory "$SETUP_SESSION_DIR_PATH_LOCAL"

  ; external Setup Session Directory
  ${GetOptions} $CMDLINE "/SETUP_SESSION_DIR_PATH=" $SETUP_SESSION_DIR_PATH
  ${If} $SETUP_SESSION_DIR_PATH == ""
    StrCpy $SETUP_SESSION_DIR_PATH $SETUP_SESSION_DIR_PATH_LOCAL
  ${EndIf}

  ${GetOptions} $CMDLINE "/SETUP_INI_IN=" $SETUP_INI_IN
  ${If} $SETUP_INI_IN == ""
    StrCpy $SETUP_INI_IN "$SETUP_SESSION_DIR_PATH\setup.ini"
  ${EndIf}

  ; read builtin variables immmediately
  ${If} $SETUP_INI_IN != ""
    ${If} ${FileExists} $SETUP_INI_IN
      ReadINIStr $REBOOT_STATUS_FLAGS_EXT "$SETUP_INI_IN" setup REBOOT_STATUS_FLAGS ; as external reboot status
    ${EndIf}
  ${EndIf}

  ${GetOptions} $CMDLINE "/SETUP_INI_OUT=" $SETUP_INI_OUT
  ${If} "$SETUP_INI_OUT" == ""
    StrCpy $SETUP_INI_OUT "$SETUP_SESSION_DIR_PATH_LOCAL\setup_out.ini" ; use different name to avoid accidental read of output setup.ini as input
  ${EndIf}

  ${DebugStackCheckFrame} Init 1 0

  WriteINIStr "$SETUP_INI_OUT" setup PROCESS_ID "$PROCESS_ID"
FunctionEnd

Function Init_ImplEnd
  ${DebugStackCheckFrame} Init 1 0

  ; UAC promotion: elevate only in non Administrative install
  ${If} $ADMINISTRATIVE_INSTALL = 0
    ${UAC_RunElevation} ; fork elevated process and quit, otherwise continue
    ${DebugStackCheckFrame} Init 1 0
  ${EndIf}

  ; Initialization after UAC promotion
  ${SetShellVarContext} $R0

  ${If} ${Silent}
    StrCpy $COMPONENTS_SILENT_INSTALL 1
  ${Else}
    StrCpy $COMPONENTS_SILENT_INSTALL 0
  ${EndIf}

  ${ReadRegStr} $UNINSTALL_STRING HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
  ${UnquoteString} $UNINSTALL_STRING $UNINSTALL_STRING

  ${DebugStackCheckFrame} Init 1 0

  ${GetOptions} $CMDLINE "/RAW" $NULL
  ${If} ${NoErrors}
    StrCpy $RAW_PARAM 1
  ${Else}
    StrCpy $RAW_PARAM 0
  ${EndIf}

  ; parent control setup flag
  ${GetOptions} $CMDLINE "/PARENT_CONTROL_SETUP" $NULL
  ${If} ${NoErrors}
    StrCpy $PARENT_CONTROL_SETUP 1
  ${Else}
    StrCpy $PARENT_CONTROL_SETUP 0
  ${EndIf}

  ; setup in setup NSIS nest level index
  ${GetOptions} $CMDLINE "/N=" $SETUP_NEST_LVL
  ${If} $SETUP_NEST_LVL == ""
    StrCpy $SETUP_NEST_LVL 0
  ${EndIf}

  ${DebugStackCheckFrame} Init 1 0

  StrCpy $SILENT_SETUP 0
  StrCpy $SILENT_SETUP_NOTIFY_POPUP_SHOW_DELAY 5000 ; 5 seconds
  StrCpy $ROOT_SILENT_SETUP 0
  ${If} $ADMINISTRATIVE_INSTALL <> 0
    StrCpy $SILENT_SETUP 1
    StrCpy $ROOT_SILENT_SETUP 1
  ${ElseIf} ${Silent}
    StrCpy $SILENT_SETUP 1
    ${If} $SETUP_NEST_LVL = 0
      StrCpy $ROOT_SILENT_SETUP 1
    ${EndIf}
  ${EndIf}

  ${GetSysDrive} $SYSDRIVE

  ; WORKAROUND for broken /D parameter
  ${If} $INSTDIR != ""
    ; /D was used
    StrCpy $INSTDIR_PARAM $INSTDIR
  ${Else}
    ; Set some default
    ${StrRep} $R9 $R1 '{{SYSDRIVE}}' '$SYSDRIVE'
    StrCpy $INSTDIR $R9 ; Update install root variable
  ${EndIf}

  StrCpy $INSTDIR_TMP "" ; must be initialized by the user later

  ; Language selection
  ${GetOptions} $CMDLINE "/L=" $LANG_PARAM
  ${If} $LANG_PARAM == ""
    ${If} $ADMINISTRATIVE_INSTALL = 0
      !insertmacro MUI_LANGDLL_DISPLAY
    ${EndIf}
  ${Else}
    StrCpy $LANGUAGE $LANG_PARAM
  ${EndIf}

  ${DebugStackCheckFrame} Init 1 0

  ${GetLanguageStrings} $LANG_GROUP_COUNTRY_STR $LANG_SHORT_STR $LANG_LONG_STR $LANGUAGE

  !ifdef APP_NAME_PREFIX
  StrCpy $APP_NAME "${APP_NAME_PREFIX}"
  !else
  StrCpy $APP_NAME $(APP_NAME_PREFIX)
  !endif
  !ifdef APP_NAME
  StrCpy $APP_NAME "${APP_NAME}"
  !else
  StrCpy $APP_NAME $(APP_NAME)
  !endif

  !ifndef MUI_PAGE_STARTMENU_HIDE
  StrCpy $START_MENU_DIR $(START_MENU_DEFAULT_DIR)
  !else
  StrCpy $START_MENU_DIR ""
  !endif

  ; SYSDIR32/SYSDIR64
  ${If} ${IsWow64}
    StrCpy $R9 ""
    System::Call "kernel32::GetSystemWow64Directory(t .R9, i ${NSIS_MAX_STRLEN})"
    StrCpy $SYSDIR32 $R9
    StrCpy $SYSDIR64 $SYSDIR
  ${else}
    StrCpy $SYSDIR32 $SYSDIR
    StrCpy $SYSDIR64 ""
  ${EndIf}

  ; Start menu 
  ${GetOptions} $CMDLINE "/SMDIR=" $SMDIR
  !ifndef MUI_PAGE_STARTMENU_HIDE
  ${If} $SMDIR != ""
    ${StrRep} $START_MENU_DIR "$(START_MENU_DIR)" '{{SMDIR}}' '$SMDIR'
  ${EndIf}
  !endif

  ${GetComputerName} $COMPUTERNAME

  ${DebugStackCheckFrame} Init 1 0

  ${If} $ADMINISTRATIVE_INSTALL <> 0
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_BEGIN      "$(MSG_NOTIFY_PRODUCT_UNPACK_BEGIN)"
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_COMPLETED  "$(MSG_NOTIFY_PRODUCT_UNPACK_COMPLETED)"
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_CANCELED   "$(MSG_NOTIFY_PRODUCT_UNPACK_CANCELED)"
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_ABORTED    "$(MSG_NOTIFY_PRODUCT_UNPACK_ABORTED)"
  ${Else}
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_BEGIN      "$(MSG_NOTIFY_PRODUCT_INSTALL_BEGIN)"
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_COMPLETED  "$(MSG_NOTIFY_PRODUCT_INSTALL_COMPLETED)"
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_CANCELED   "$(MSG_NOTIFY_PRODUCT_INSTALL_CANCELED)"
    StrCpy $MSG_NOTIFY_PRODUCT_SETUP_ABORTED    "$(MSG_NOTIFY_PRODUCT_INSTALL_ABORTED)"
  ${EndIf}

  ; install/unpack notify message
  !if "${PARENT.PRODUCT_VERSION}" == ""
    ${ShowSilentSetupNotify} "$APP_NAME" "$MSG_NOTIFY_PRODUCT_SETUP_BEGIN"
  !else
    ${ShowSilentSetupNotify} "$APP_NAME v${PARENT.PRODUCT_VERSION}${PARENT.BUILD_NUMBER_VERSION_SUFFIX}" "$MSG_NOTIFY_PRODUCT_SETUP_BEGIN"
  !endif

  ${DebugStackCheckFrame} Init 1 0

  InitPluginsDir

  ${If} $ADMINISTRATIVE_INSTALL <> 0
  ${AndIf} $RAW_PARAM <> 0
    StrCpy $INITED 1

    ; Extract files from setup executable via external 7-zip command line tool (must be UNICODE version, not ANSI version!)
    ; The result will be raw NSIS archive file system.
    File "/oname=$PluginsDir\7z.exe" "${CONTOOLS_ROOT}\7zip\7z.exe"
    CreateDirectory "$ADMINISTRATIVE_INSTALL_ROOT"
    SetOverwrite on
    SetOutPath "$ADMINISTRATIVE_INSTALL_ROOT" ; Working directory
    ${ExecWaitNoStdout} '"$PluginsDir\7z.exe"' 'x -y -o"$ADMINISTRATIVE_INSTALL_ROOT" "$EXEPATH"' $LAST_ERROR
    Delete "$PluginsDir\7z.exe"

    ${UpdateSilentSetupNotify}

    ${DebugStackCheckFrame} Init 1 0

    ${!Exit}
  ${EndIf}
  
  ; elevate only in non Administrative install
  ${If} $ADMINISTRATIVE_INSTALL = 0
    ${UAC_PostInitAndReadShellGlobals}
  ${EndIf}

  ; create handles from plugins here
  ${stack::dll_create} $WNDPROC_STACK_HANDLE

  StrCpy $INITED 1

  ${DebugStackExitFrame} Init 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Include_InitInstall "!insertmacro Include_InitInstall"
!macro Include_InitInstall
!ifndef InitInstall_INCLUDED
!define InitInstall_INCLUDED
!define /redef Init_INCLUDED

!ifndef StrRep_INCLUDED
${StrRep}
!endif
!ifndef StrLoc_INCLUDED
${StrLoc}
!endif
!ifndef StrStr_INCLUDED
${StrStr}
!endif
${Include_DetailPrint} ""
${Include_GetLanguageStrings} ""
${Include_GetSysDrive} ""
${Include_GetComputerName} ""
${Include_GetAbsolutePath} ""
${Include_UAC} ""
${Include_UnquoteString} ""
${Include_RebootStatus} ""
${Func_InitInstall}
${Func_InitInstallGUI}

${Include_Exit} ""
${Include_Exit} "un."
${Include_Abort} ""
${Include_Abort} "un."
${Include_Quit} ""
${Include_Quit} "un."

${Include_GetLastNsisSetupExitStatus} ""
${Include_ProcessLastNsisSetupExitStatus} ""
${Include_Exec} ""
${Include_ExecWait} ""
${Include_ExecShell} ""
${Include_ExecWaitNsisSetup} ""
${Include_ExecWaitNoStdout} ""
${Include_ExecWaitStdoutToLog} ""
${Include_ExecWaitWusaSetup} ""

!endif
!macroend

!define Func_InitUninstall "!insertmacro Func_InitUninstall"
!macro Func_InitUninstall
Function un.Init
  ${ExchStack1} $R0
  ;R0 - shell_ctx
  ${PushStack9} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} un.Init 1 0

  ; Initialization before UAC promotion

  ; Drop last error level
  ClearErrors     ; setup internal
  SetErrorLevel 0 ; win32 API

  StrCpy $ERRORS 0
  StrCpy $ERRORS_STACK ""
  StrCpy $LAST_ERROR 0
  StrCpy $LAST_STATUS_STR ""
  StrCpy $INITED 0
  StrCpy $UNINITING 0
  StrCpy $UNINIT_EVENT ""
  StrCpy $QUITTING 0
  StrCpy $QUITCALLED 0
  StrCpy $QUIT_CMD ""
  StrCpy $CUSTOM_ABORT 0
  StrCpy $CUSTOM_USER_ABORT 0
  StrCpy $POSTPONED_COMMON_UNLOAD_UNINIT_CLEANUP 0
  StrCpy $PLUGINS_UNLOADED 0
  StrCpy $USER_ABORT_ASK_ACCEPTED 0
  StrCpy $SECTION_SCOPE_INDEX 0
  StrCpy $DEBUG 0

  StrCpy $DEBUG_R0 ""
  StrCpy $DEBUG_R1 ""
  StrCpy $DEBUG_R2 ""
  StrCpy $DEBUG_R3 ""
  StrCpy $DEBUG_R4 ""
  StrCpy $DEBUG_R5 ""
  StrCpy $DEBUG_R6 ""
  StrCpy $DEBUG_R7 ""
  StrCpy $DEBUG_R8 ""
  StrCpy $DEBUG_R9 ""
  StrCpy $DEBUG_R10 ""
  StrCpy $DEBUG_R11 ""
  StrCpy $DEBUG_R12 ""
  StrCpy $DEBUG_RET0 ""
  StrCpy $DEBUG_RET1 ""
  StrCpy $DEBUG_RET2 ""
  StrCpy $DEBUG_RET3 ""
  StrCpy $DEBUG_ST0 ""
  StrCpy $DEBUG_ST1 ""
  StrCpy $DEBUG_ST2 ""

  StrCpy $GOTO_R0 ""

  StrCpy $MACRO_POP_VAR0 ""
  StrCpy $MACRO_POP_VAR1 ""
  StrCpy $MACRO_POP_VAR2 ""
  StrCpy $MACRO_POP_VAR3 ""
  StrCpy $MACRO_POP_VAR4 ""
  StrCpy $MACRO_POP_VAR5 ""
  StrCpy $MACRO_POP_VAR6 ""
  StrCpy $MACRO_POP_VAR7 ""
  StrCpy $MACRO_POP_VAR8 ""
  StrCpy $MACRO_POP_VAR9 ""
  StrCpy $MACRO_POP_VAR10 ""
  StrCpy $MACRO_POP_VAR11 ""
  StrCpy $MACRO_POP_VAR12 ""
  StrCpy $MACRO_POP_VAR13 ""
  StrCpy $MACRO_POP_VAR14 ""
  StrCpy $MACRO_POP_VAR15 ""
  StrCpy $MACRO_POP_VAR16 ""
  StrCpy $MACRO_POP_VAR17 ""
  StrCpy $MACRO_POP_VAR18 ""
  StrCpy $MACRO_POP_VAR19 ""

  StrCpy $MACRO_RET_VAR0 ""
  StrCpy $MACRO_RET_VAR1 ""
  StrCpy $MACRO_RET_VAR2 ""
  StrCpy $MACRO_RET_VAR3 ""
  StrCpy $MACRO_RET_VAR4 ""
  StrCpy $MACRO_RET_VAR5 ""
  StrCpy $MACRO_RET_VAR6 ""
  StrCpy $MACRO_RET_VAR7 ""
  StrCpy $MACRO_RET_VAR8 ""
  StrCpy $MACRO_RET_VAR9 ""
  StrCpy $MACRO_RET_VAR10 ""
  StrCpy $MACRO_RET_VAR11 ""
  StrCpy $MACRO_RET_VAR12 ""
  StrCpy $MACRO_RET_VAR13 ""
  StrCpy $MACRO_RET_VAR14 ""
  StrCpy $MACRO_RET_VAR15 ""
  StrCpy $MACRO_RET_VAR16 ""
  StrCpy $MACRO_RET_VAR17 ""
  StrCpy $MACRO_RET_VAR18 ""
  StrCpy $MACRO_RET_VAR19 ""

  StrCpy $ENABLE_DEBUG_PUSHPOP_LOGGING 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX 0
  StrCpy $ENABLE_DEBUG_SYSTEM_PUSHPOP_MSGBOX_IMPL0 0

  StrCpy $EXEC_NSIS_SETUP_ARGS ""

  StrCpy $WNDPROC_STACK_HANDLE 0
  StrCpy $GUI_MAIN_DIALOG_LAST_HWND 0

  ${GetOptions} $CMDLINE "/debug" $NULL
  ${If} ${NoErrors}
    StrCpy $DEBUG 1
    StrCpy $EXEC_NSIS_SETUP_ARGS "$EXEC_NSIS_SETUP_ARGS /debug"
  ${EndIf}

  ${DebugStackCheckFrame} un.Init 1 0

  StrCpy $REBOOT_STATUS_FLAGS_EXT 0
  StrCpy $REBOOT_STATUS_FLAGS_INT 0

  StrCpy $UAC_PROCESS_ELEVATION_STATUS_FLAGS -1
  StrCpy $PROCESS_ID 0

  System::Call "kernel32::GetCurrentProcessId() i.R9"
  StrCpy $PROCESS_ID $R9

  ${DebugStackCheckFrame} un.Init 1 0

  ; UAC promotion
  ${UAC_RunElevation} ; fork elevated process and quit, otherwise continue

  ${DebugStackCheckFrame} un.Init 1 0

  ; Initialization after UAC promotion
  ${SetShellVarContext} $R0

  ${If} ${Silent}
    StrCpy $COMPONENTS_SILENT_INSTALL 1
  ${Else}
    StrCpy $COMPONENTS_SILENT_INSTALL 0
  ${EndIf}

  ${ReadRegStr} $UNINSTALL_STRING HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
  ${UnquoteString} $UNINSTALL_STRING $UNINSTALL_STRING

  ${DebugStackCheckFrame} un.Init 1 0

  System::Call "kernel32::GetCurrentDirectory(i ${NSIS_MAX_STRLEN}, t .R9) i"
  StrCpy $CURDIR $R9

  ; parent control setup flag
  ${GetOptions} $CMDLINE "/PARENT_CONTROL_SETUP" $NULL
  ${If} ${NoErrors}
    StrCpy $PARENT_CONTROL_SETUP 1
  ${Else}
    StrCpy $PARENT_CONTROL_SETUP 0
  ${EndIf}

  ; setup in setup NSIS nest level index
  ${GetOptions} $CMDLINE "/N=" $SETUP_NEST_LVL
  ${If} $SETUP_NEST_LVL == ""
    StrCpy $SETUP_NEST_LVL 0
  ${EndIf}

  StrCpy $SILENT_SETUP 0
  StrCpy $ROOT_SILENT_SETUP 0
  ${If} ${Silent}
    StrCpy $SILENT_SETUP 1
    ${If} $SETUP_NEST_LVL = 0
      StrCpy $ROOT_SILENT_SETUP 1
    ${EndIf}
  ${EndIf}

  ${GetSysDrive} $SYSDRIVE

  ${DebugStackCheckFrame} un.Init 1 0

  #; Language selection
  #!insertmacro MUI_UNGETLANGUAGE
  #
  #${GetOptions} $CMDLINE "/L=" $LANG_PARAM
  #${If} $LANG_PARAM != ""
  #  StrCpy $LANGUAGE $LANG_PARAM
  #${EndIf}

  ${GetLanguageStrings} $LANG_GROUP_COUNTRY_STR $LANG_SHORT_STR $LANG_LONG_STR $LANGUAGE

  !ifdef APP_NAME_PREFIX
  StrCpy $APP_NAME "${APP_NAME_PREFIX}"
  !else
  StrCpy $APP_NAME $(APP_NAME_PREFIX)
  !endif
  !ifdef APP_NAME
  StrCpy $APP_NAME "${APP_NAME}"
  !else
  StrCpy $APP_NAME $(APP_NAME)
  !endif

  ${GetComputerName} $COMPUTERNAME

  StrCpy $MSG_NOTIFY_PRODUCT_SETUP_BEGIN      "$(MSG_NOTIFY_PRODUCT_UNINSTALL_BEGIN)"
  StrCpy $MSG_NOTIFY_PRODUCT_SETUP_COMPLETED  "$(MSG_NOTIFY_PRODUCT_UNINSTALL_COMPLETED)"
  StrCpy $MSG_NOTIFY_PRODUCT_SETUP_CANCELED   "$(MSG_NOTIFY_PRODUCT_UNINSTALL_CANCELED)"
  StrCpy $MSG_NOTIFY_PRODUCT_SETUP_ABORTED    "$(MSG_NOTIFY_PRODUCT_UNINSTALL_ABORTED)"

  ; uninstall notify message
  !if "${PARENT.PRODUCT_VERSION}" == ""
    ${ShowSilentSetupNotify} "$APP_NAME" "$MSG_NOTIFY_PRODUCT_SETUP_BEGIN"
  !else
    ${ShowSilentSetupNotify} "$APP_NAME v${PARENT.PRODUCT_VERSION}" "$MSG_NOTIFY_PRODUCT_SETUP_BEGIN"
  !endif

  InitPluginsDir

  ${UAC_PostInitAndReadShellGlobals}

  ; create handles from plugins here
  ${stack::dll_create} $WNDPROC_STACK_HANDLE

  StrCpy $INITED 1

  ${DebugStackExitFrame} un.Init 1 0

  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Include_InitUninstall "!insertmacro Include_InitUninstall"
!macro Include_InitUninstall
!ifndef InitUninstall_INCLUDED
!define InitUninstall_INCLUDED
!define /redef Init_INCLUDED

!ifndef UnStrRep_INCLUDED
${UnStrRep}
!endif
!ifndef UnStrLoc_INCLUDED
${UnStrLoc}
!endif
!ifndef UnStrStr_INCLUDED
${UnStrStr}
!endif
${Include_DetailPrint} "un."
${Include_GetLanguageStrings} "un."
${Include_GetSysDrive} "un."
${Include_GetComputerName} "un."
${Include_GetAbsolutePath} "un."
${Include_UAC} "un."
${Include_UnquoteString} "un."
${Include_RebootStatus} "un."
${Func_InitUninstall}

!endif
!macroend

!define Func_InitInstallGUI "!insertmacro Func_InitInstallGUI"
!macro Func_InitInstallGUI
Function InitGUI
  ${DebugStackEnterFrame} InitGUI 0 0

  StrCpy $Missed_call_to_InitInstallGUI_function "" ; dummy to suppress "Variable ... not referenced ..." warnings

  ; Reload variables from language tables (language variables initializes ONLY after .onInit call!)
  !ifdef APP_NAME_PREFIX
  StrCpy $APP_NAME "${APP_NAME_PREFIX}"
  !else
  StrCpy $APP_NAME $(APP_NAME_PREFIX)
  !endif
  !ifdef APP_NAME
  StrCpy $APP_NAME "${APP_NAME}"
  !else
  StrCpy $APP_NAME $(APP_NAME)
  !endif

  !ifndef MUI_PAGE_STARTMENU_HIDE
  StrCpy $START_MENU_DIR $(START_MENU_DEFAULT_DIR)
  !else
  StrCpy $START_MENU_DIR ""
  !endif

  ; Start menu 
  ${GetOptions} $CMDLINE "/SMDIR=" $SMDIR
  !ifndef MUI_PAGE_STARTMENU_HIDE
  ${If} $SMDIR != ""
    ${StrRep} $START_MENU_DIR "$(START_MENU_DIR)" '{{SMDIR}}' '$SMDIR'
  ${EndIf}
  !endif

  ${DebugStackExitFrame} InitGUI 0 0
FunctionEnd
!macroend

!define ExecuteUninstallFromInstall "!insertmacro ExecuteUninstallFromInstall"
!macro ExecuteUninstallFromInstall
${DebugStackEnterFrame} ExecuteUninstallFromInstall 0 1

${PushStack2} $R0 $R1

${DebugStackEnterFrame} ExecuteUninstallFromInstall 1 0

${If} $UNINSTALL_STRING != ""
  ${If} ${FileExists} "$UNINSTALL_STRING"
    MessageBox MB_YESNO|MB_TOPMOST|MB_SETFOREGROUND "$(MSG_ASK_UNINST_FROM_INST)" /SD IDYES IDYES +1 IDNO ExecuteUninstallFromInstall_quit
    CopyFiles "$UNINSTALL_STRING" "$PluginsDir\"
    #Sleep 500 ; CopyFiles sync
    ${GetFileName} "$UNINSTALL_STRING" $R0
    ${DetailPrint} "Executing uninstaller: $\"$PluginsDir\$R0$\""
    #MessageBox MB_YESNO "$PluginsDir\$R0 : $INSTDIR"
    ${If} ${Silent}
      ${ExecWait} '"$PluginsDir\$R0"' '/S /R /L=$LANGUAGE _?=$INSTDIR' $LAST_ERROR
    ${Else}
      ${ExecWait} '"$PluginsDir\$R0"' '/R /L=$LANGUAGE _?=$INSTDIR' $LAST_ERROR
    ${EndIf}
    ${DetailPrint} "Last error code: $LAST_ERROR"
    Delete "$PluginsDir\$R0"

    ${IsSilentSetupNotify} $R1
    ${If} $R1 <> 0
      Sleep 1000 ; to leave previous notify message on a moment on the screen
    ${EndIf}

    ; install/unpack notify message (must be shown again to update previous uninstall message)
    !if "${PARENT.PRODUCT_VERSION}" == ""
      ${ShowSilentSetupNotify} "$APP_NAME" "$MSG_NOTIFY_PRODUCT_SETUP_BEGIN"
    !else
      ${ShowSilentSetupNotify} "$APP_NAME v${PARENT.PRODUCT_VERSION}" "$MSG_NOTIFY_PRODUCT_SETUP_BEGIN"
    !endif
  ${EndIf}
${EndIf}

Goto ExecuteUninstallFromInstall_end
ExecuteUninstallFromInstall_quit:
  ${DebugStackCheckFrame} ExecuteUninstallFromInstall 1 0

  ${!Abort}
ExecuteUninstallFromInstall_end:

${DebugStackExitFrame} ExecuteUninstallFromInstall 1 0

${PopStack2} $R0 $R1

${DebugStackExitFrame} ExecuteUninstallFromInstall 0 1
!macroend

!define GetLastNsisSetupExitStatus "!insertmacro GetLastNsisSetupExitStatus"
!macro GetLastNsisSetupExitStatus event_msg_var event_str_var cmd args setup_ini_out
${DebugStackEnterFrame} GetLastNsisSetupExitStatus 0 1

${PushStack3} `${cmd}` `${args}` `${setup_ini_out}`
!ifndef __UNINSTALL__
Call GetLastNsisSetupExitStatus
!else
Call un.GetLastNsisSetupExitStatus
!endif
${PopStack2} $DEBUG_RET0 $DEBUG_RET1

${DebugStackExitFrame} GetLastNsisSetupExitStatus 0 1

StrCpy `${event_msg_var}` $DEBUG_RET1
StrCpy `${event_str_var}` $DEBUG_RET0
!macroend

!define Func_GetLastNsisSetupExitStatus "!insertmacro Func_GetLastNsisSetupExitStatus"
!macro Func_GetLastNsisSetupExitStatus un
Function ${un}GetLastNsisSetupExitStatus
  ${ExchStack3} $R0 $R1 $R2
  ; R0 - cmd
  ; R1 - args
  ; R2 - setup_ini_out
  ${PushStack3} $R7 $R8 $R9

  ${DebugStackEnterFrame} ${un}GetLastNsisSetupExitStatus 1 0

  ${If} ${FileExists} $R2
    ReadINIStr $R7 $R2 setup PROCESS_ID
    ReadINIStr $R8 $R2 setup EXIT_STATUS_TYPE
    ${If} $R8 != ""
      ${Switch} $R8
        ${Case} "onInstSuccess"
          StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_ONINST_SUCCESS)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: $R7$\n|Event msg: $R8'
          ${Break}
        ${Case} "onInstFailed"
          StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_ONINST_FAILED)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: $R7$\n|Event msg: $R8'
          ${Break}
        ${Case} "customUserAbort"
          StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_CUSTOM_USER_ABORT)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: $R7$\n|Event msg: $R8'
          ${Break}
        ${Case} "Exit"
          StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_EXIT)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: $R7$\n|Event msg: $R8'
          ${Break}
        ${Case} "Abort"
          StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_ABORT)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: $R7$\n|Event msg: $R8'
          ${Break}
        ${Default}
          StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_UNKNOWN)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: $R7$\n|Event msg: $R8'
      ${EndSwitch}
    ${Else}
      StrCpy $R8 "afterInitTerminate"
      StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_AFTER_INIT_TERMINATED)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: $R7$\n|Event msg: $R8'
    ${EndIf}
  ${Else}
    StrCpy $R8 "beforeInitTerminate" ; event msg
    StrCpy $R9 '$(MSG_SETUP_EXIT_STATUS_BEFORE_INIT_TERMINATED)$\n$\n|Command: $R0$\n|Arguments: $R1$\n|Process ID: <unknown>$\n|Event msg: $R8'
  ${EndIf}

  ${DebugStackExitFrame} ${un}GetLastNsisSetupExitStatus 1 0

  ${PopPushStack6} "$R9 $R8" " " $R0 $R1 $R2 $R7 $R8 $R9
FunctionEnd
!macroend

!define Include_GetLastNsisSetupExitStatus "!insertmacro Include_GetLastNsisSetupExitStatus"
!macro Include_GetLastNsisSetupExitStatus un
!ifndef ${un}GetLastNsisSetupExitStatus_INCLUDED
!define ${un}GetLastNsisSetupExitStatus_INCLUDED
${Func_GetLastNsisSetupExitStatus} "${un}"
!endif
!macroend

!define Exec "!insertmacro Exec"
!macro Exec cmd args
${DebugStackEnterFrame} Exec 0 1

${PushStack2} `${cmd}` `${args}`
!ifndef __UNINSTALL__
Call Exec
!else
Call un.Exec
!endif

${DebugStackExitFrame} Exec 0 1
!macroend

!define Func_Exec "!insertmacro Func_Exec"
!macro Func_Exec un
Function ${un}Exec
  ${ExchStack2} $R0 $R1
  ; R0 - cmd
  ; R1 - args
  ${PushStack1} $R9

  ${DebugStackEnterFrame} ${un}Exec 1 0

  ${UnquoteString} $R9 $R0
  ${If} ${FileNotExists} $R9
    ${DebugMessageBox} ${un}Exec "${__FILE__}:${__LINE__}" "" MB_OK "File is not found:" $R9 ''
    Goto exit
  ${EndIf}

  Exec '"$R9" $R1' ; use requoted $R0 to cover case w/o quotes

  exit:
  ${DebugStackExitFrame} ${un}Exec 1 0

  ${PopStack3} $R0 $R1 $R9
FunctionEnd
!macroend

!define Include_Exec "!insertmacro Include_Exec"
!macro Include_Exec un
!ifndef ${un}Exec_INCLUDED
!define ${un}Exec_INCLUDED
${Include_UnquoteString} "${un}"
${Func_Exec} "${un}"
!endif
!macroend

!define ExecWait "!insertmacro ExecWait"
!macro ExecWait cmd args retcode_var
${DebugStackEnterFrame} ExecWait 0 1

${PushStack2} `${cmd}` `${args}`
!ifndef __UNINSTALL__
Call ExecWait
!else
Call un.ExecWait
!endif
${PopStack1} $DEBUG_RET0

${DebugStackExitFrame} ExecWait 0 1

StrCpy ${retcode_var} $DEBUG_RET0
!macroend

!define Func_ExecWait "!insertmacro Func_ExecWait"
!macro Func_ExecWait un
Function ${un}ExecWait
  ${ExchStack2} $R0 $R1
  ; R0 - cmd
  ; R1 - args
  ${PushStack1} $R9

  ${DebugStackEnterFrame} ${un}ExecWait 1 0

  ${UnquoteString} $R9 $R0
  ${If} ${FileNotExists} $R9
    ${DebugMessageBox} ${un}ExecWait "${__FILE__}:${__LINE__}" "" MB_OK "File is not found:" $R9 ''
    StrCpy $R9 -1
    Goto exit
  ${EndIf}

  ExecWait '"$R9" $R1' $R9 ; use requoted $R0 to cover case w/o quotes

  exit:
  ${DebugStackExitFrame} ${un}ExecWait 1 0

  ${PopPushStack3} "$R9" " " $R0 $R1 $R9
FunctionEnd
!macroend

!define Include_ExecWait "!insertmacro Include_ExecWait"
!macro Include_ExecWait un
!ifndef ${un}ExecWait_INCLUDED
!define ${un}ExecWait_INCLUDED
${Include_UnquoteString} "${un}"
${Func_ExecWait} "${un}"
!endif
!macroend

!define ExecShell "!insertmacro ExecShell"
!macro ExecShell action cmd args flags
${DebugStackEnterFrame} ExecShell 0 1

${PushStack2} `${cmd}` `${args}`

; must be called as a Function to force parameters evaluation before the use
!ifndef __UNINSTALL__
Call ExecShellImplBegin
!else
Call un.ExecShellImplBegin
!endif

${If} $R9 >= 0
  ; must be called directly, because some parameters evaluates only at compile time!
  ${If} $R1 != ""
    ExecShell ${action} '"$R8"' $R1 ${flags} ; use requoted $R0 to cover case w/o quotes
  ${Else}
    ExecShell ${action} '"$R8"' '' ${flags} ; use requoted $R0 to cover case w/o quotes
  ${EndIf}
${EndIf}

!ifndef __UNINSTALL__
Call ExecShellImplEnd
!else
Call un.ExecShellImplEnd
!endif

${DebugStackExitFrame} ExecShell 0 1
!macroend

!define Func_ExecShell "!insertmacro Func_ExecShell"
!macro Func_ExecShell un
Function ${un}ExecShellImplBegin
  ${ExchStack2} $R0 $R1
  ; R0 - cmd
  ; R1 - args
  ${PushStack2} $R8 $R9

  ${DebugStackEnterFrame} ${un}ExecShell 1 0

  StrCpy $R9 0

  ${UnquoteString} $R8 $R0
  ${If} ${FileNotExists} $R8
    ${DebugMessageBox} ${un}ExecShell "${__FILE__}:${__LINE__}" "" MB_OK "File is not found:" $R8 ''
    StrCpy $R9 -1
    Return
  ${EndIf}
FunctionEnd

Function ${un}ExecShellImplEnd
  ${DebugStackExitFrame} ${un}ExecShell 1 0

  ${PopStack4} $R0 $R1 $R8 $R9
FunctionEnd
!macroend

!define Include_ExecShell "!insertmacro Include_ExecShell"
!macro Include_ExecShell un
!ifndef ${un}ExecShell_INCLUDED
!define ${un}ExecShell_INCLUDED
${Include_UnquoteString} "${un}"
${Func_ExecShell} "${un}"
!endif
!macroend

!define ExecWaitNsisSetup "!insertmacro ExecWaitNsisSetup"
!macro ExecWaitNsisSetup cmd args setup_ini_out retcode_var
${DebugStackEnterFrame} ExecWaitNsisSetup 0 1

${PushStack3} `${cmd}` `${args}` `${setup_ini_out}`
!ifndef __UNINSTALL__
Call ExecWaitNsisSetup
!else
Call un.ExecWaitNsisSetup
!endif
${PopStack1} $DEBUG_RET0

${DebugStackExitFrame} ExecWaitNsisSetup 0 1

StrCpy ${retcode_var} $DEBUG_RET0
!macroend

!define Func_ExecWaitNsisSetup "!insertmacro Func_ExecWaitNsisSetup"
!macro Func_ExecWaitNsisSetup un
Function ${un}ExecWaitNsisSetup
  ${ExchStack3} $R0 $R1 $R2
  ; R0 - cmd
  ; R1 - args
  ; R2 - setup_ini_out
  ${PushStack2} $R8 $R9

  ${DebugStackEnterFrame} ${un}ExecWaitNsisSetup 1 0

  ${UnquoteString} $R9 $R0
  ${If} ${FileNotExists} $R9
    ${DebugMessageBox} ${un}ExecWaitNsisSetup "${__FILE__}:${__LINE__}" "" MB_OK "File is not found:" $R9 ''
    StrCpy $R9 -1
    Goto exit
  ${EndIf}

  IntOp $SETUP_NEST_LVL $SETUP_NEST_LVL + 1
  ${ExecWait} '$R0' '/N=$SETUP_NEST_LVL$EXEC_NSIS_SETUP_ARGS $R1' $R9 ; use $R0 as is
  IntOp $SETUP_NEST_LVL $SETUP_NEST_LVL - 1

  ${DebugStackCheckFrame} ${un}ExecWaitNsisSetup 1 0

  !if $R2 != ""
  ; process builtin setup variables
  ${If} ${FileExists} $R2
    ReadINIStr $R8 $R2 setup REBOOT_STATUS_FLAGS
    IntOp $R8 $R8 & 0x0000FFFF ; use only internal reboot status
    ; merge child internal reboot status into parent internal reboot status
    IntOp $REBOOT_STATUS_FLAGS_INT $REBOOT_STATUS_FLAGS_INT | $R8
    ; update reboot status by internal reboot status ONLY
    IntOp $R8 $REBOOT_STATUS_FLAGS_INT & 0x0000FFFF ; just in case
    ${UpdateRebootStatus} $R8
  ${EndIf}
  !endif

  ${DebugStackCheckFrame} ${un}ExecWaitNsisSetup 1 0

  ${ProcessLastNsisSetupExitStatus} $R0 $R1 $R2 $R9

  exit:
  ${DebugStackExitFrame} ${un}ExecWaitNsisSetup 1 0

  ${PopPushStack5} "$R9" " " $R0 $R1 $R2 $R8 $R9
FunctionEnd
!macroend

!define Include_ExecWaitNsisSetup "!insertmacro Include_ExecWaitNsisSetup"
!macro Include_ExecWaitNsisSetup un
!ifndef ${un}ExecWaitNsisSetup_INCLUDED
!define ${un}ExecWaitNsisSetup_INCLUDED
${Include_UnquoteString} "${un}"
${Func_ExecWaitNsisSetup} "${un}"
!endif
!macroend

!define ExecWaitNoStdout "!insertmacro ExecWaitNoStdout"
!macro ExecWaitNoStdout cmd args retcode_var
${DebugStackEnterFrame} ExecWaitNoStdout 0 1

${PushStack2} `${cmd}` `${args}`

!ifndef __UNINSTALL__
Call ExecWaitNoStdout
!else
Call un.ExecWaitNoStdout
!endif
${PopStack1} $DEBUG_RET0

${DebugStackExitFrame} ExecWaitNoStdout 0 1

StrCpy ${retcode_var} $DEBUG_RET0
!macroend

!define Func_ExecWaitNoStdout "!insertmacro Func_ExecWaitNoStdout"
!macro Func_ExecWaitNoStdout un
Function ${un}ExecWaitNoStdout
  ${ExchStack2} $R0 $R1
  ; R0 - cmd
  ; R1 - args
  ${PushStack1} $R9

  ${DebugStackEnterFrame} ${un}ExecWaitNoStdout 1 0

  ${UnquoteString} $R9 $R0
  ${If} ${FileNotExists} $R9
    ${DebugMessageBox} ${un}ExecWaitNoStdout "${__FILE__}:${__LINE__}" "" MB_OK "File is not found:" $R9 ''
    StrCpy $R9 -1
    Goto exit
  ${EndIf}

  ${If} $R1 != ""
    ${DetailPrint} 'Executing: "$R9" $R1'
    nsExec::Exec '"$R9" $R1' ; use requoted $R0 to cover case w/o quotes
  ${Else}
    ${DetailPrint} 'Executing: "$R9"'
    nsExec::Exec '"$R9"' ; use requoted $R0 to cover case w/o quotes
  ${EndIf}
  ${Pop} $LAST_STATUS_STR

  ; test result on number, if not then error code has returned a status string!
  ${If} $LAST_STATUS_STR != 0 ; as string comparison
  ${AndIf} $LAST_STATUS_STR = 0 ; arithmetic comparison, any not-a-number string will be converted to 0 before the comparison!
    StrCpy $R9 -1 ; unknown
    ${DetailPrint} "Last error code: N/A ($LAST_STATUS_STR)"
  ${Else}
    ; the last status string is error code number
    StrCpy $R9 $LAST_STATUS_STR
    StrCpy $LAST_STATUS_STR ""
    ${DetailPrint} "Last error code: $R9"
  ${EndIf}

  exit:
  ${DebugStackExitFrame} ${un}ExecWaitNoStdout 1 0

  ${PopPushStack3} "$R9" " " $R0 $R1 $R9
FunctionEnd
!macroend

!define Include_ExecWaitNoStdout "!insertmacro Include_ExecWaitNoStdout"
!macro Include_ExecWaitNoStdout un
!ifndef ${un}ExecWaitNoStdout_INCLUDED
!define ${un}ExecWaitNoStdout_INCLUDED
${Include_UnquoteString} "${un}"
${Func_ExecWaitNoStdout} "${un}"
!endif
!macroend

!define ExecWaitStdoutToLog "!insertmacro ExecWaitStdoutToLog"
!macro ExecWaitStdoutToLog cmd args retcode_var
${DebugStackEnterFrame} ExecWaitStdoutToLog 0 1

${PushStack2} `${cmd}` `${args}`

!ifndef __UNINSTALL__
Call ExecWaitStdoutToLog
!else
Call un.ExecWaitStdoutToLog
!endif
${PopStack1} $DEBUG_RET0

${DebugStackExitFrame} ExecWaitStdoutToLog 0 1

StrCpy ${retcode_var} $DEBUG_RET0
!macroend

!define Func_ExecWaitStdoutToLog "!insertmacro Func_ExecWaitStdoutToLog"
!macro Func_ExecWaitStdoutToLog un
Function ${un}ExecWaitStdoutToLog
  ${ExchStack2} $R0 $R1
  ; R0 - cmd
  ; R1 - args
  ${PushStack1} $R9

  ${DebugStackEnterFrame} ${un}ExecWaitStdoutToLog 1 0

  ${UnquoteString} $R9 $R0
  ${If} ${FileNotExists} $R9
    ${DebugMessageBox} ${un}ExecWaitStdoutToLog "${__FILE__}:${__LINE__}" "" MB_OK "File is not found:" $R9 ''
    StrCpy $R9 -1
    Goto exit
  ${EndIf}

  ${If} $R1 != ""
    ${DetailPrint} 'Executing: "$R9" $R1'
    nsExec::ExecToLog '"$R9" $R1' ; use requoted $R0 to cover case w/o quotes
  ${Else}
    ${DetailPrint} 'Executing: "$R9"'
    nsExec::ExecToLog '"$R9"' ; use requoted $R0 to cover case w/o quotes
  ${EndIf}
  ${Pop} $LAST_STATUS_STR

  ; test result on number, if not then error code has returned a status string!
  ${If} $LAST_STATUS_STR != 0 ; as string comparison
  ${AndIf} $LAST_STATUS_STR = 0 ; arithmetic comparison, any not-a-number string will be converted to 0 before the comparison!
    StrCpy $R9 -1 ; unknown
    ${DetailPrint} "Last error code: N/A ($LAST_STATUS_STR)"
  ${Else}
    ; the last status string is error code number
    StrCpy $R9 $LAST_STATUS_STR
    StrCpy $LAST_STATUS_STR ""
    ${DetailPrint} "Last error code: $R9"
  ${EndIf}

  exit:
  ${DebugStackExitFrame} ${un}ExecWaitStdoutToLog 1 0

  ${PopPushStack3} "$R9" " " $R0 $R1 $R9
FunctionEnd
!macroend

!define Include_ExecWaitStdoutToLog "!insertmacro Include_ExecWaitStdoutToLog"
!macro Include_ExecWaitStdoutToLog un
!ifndef ${un}ExecWaitStdoutToLog_INCLUDED
!define ${un}ExecWaitStdoutToLog_INCLUDED
${Include_UnquoteString} "${un}"
${Func_ExecWaitStdoutToLog} "${un}"
!endif
!macroend

!define ExecWaitWusaSetup "!insertmacro ExecWaitWusaSetup"
!macro ExecWaitWusaSetup cmd args retcode_var
${DebugStackEnterFrame} ExecWaitWusaSetup 0 1

${PushStack2} `${cmd}` `${args}`
!ifndef __UNINSTALL__
Call ExecWaitWusaSetup
!else
Call un.ExecWaitWusaSetup
!endif
${PopStack1} $DEBUG_RET0

${DebugStackExitFrame} ExecWaitWusaSetup 0 1

StrCpy ${retcode_var} $DEBUG_RET0
!macroend

!define Func_ExecWaitWusaSetup "!insertmacro Func_ExecWaitWusaSetup"
!macro Func_ExecWaitWusaSetup un
Function ${un}ExecWaitWusaSetup
  ${ExchStack2} $R0 $R1
  ; R0 - cmd
  ; R1 - args
  ${PushStack1} $R9

  ${DebugStackEnterFrame} ${un}ExecWaitWusaSetup 1 0

  ${UnquoteString} $R9 $R0
  ${If} ${FileNotExists} $R9
    ${DebugMessageBox} ${un}ExecWaitWusaSetup "${__FILE__}:${__LINE__}" "" MB_OK "File is not found:" $R9 ''
    StrCpy $R9 -1
    Goto exit
  ${EndIf}

  #${DetailPrint} `Executing: "$SYSDIR32\wusa.exe" $R0`
  ${If} $R1 != ""
    ${ExecWait} '"$SYSDIR32\wusa.exe"' '"$R9" $R1' $R9 ; use requoted $R0 to cover case w/o quotes
  ${Else}
    ${ExecWait} '"$SYSDIR32\wusa.exe"' '"$R9"' $R9 ; use requoted $R0 to cover case w/o quotes
  ${EndIf}
  ${DetailPrint} "Last error code: $R9"
  ${UpdateSilentSetupNotify}
  ${If} $R9 <> 0
  ${AndIf} $R9 <> 3010 ; Soft reboot flagged
    ; see error codes for details here: https://support.microsoft.com/en-us/kb/938205
    ; Examples:
    ;   0x00240006 WU_S_ALREADY_INSTALLED The update to be installed is already installed on the system
    ;   0x80240017 WU_E_NOT_APPLICABLE Operation was not performed because there are no applicable updates.
    ;
    ; http://www.nudoq.org/#!/Packages/CommonWin32/CommonWin32/HRESULT/F/TRUST_E_NO_SIGNER_CERT
    ;   0x80096002 TRUST_E_NO_SIGNER_CERT The certificate for the signer of the message is invalid or not found.
  ${AndIf} $R9 <> -2145124329 ; 0x80240017
  ${AndIf} $R9 <> 2359302 ; 0x00240006
  ${AndIf} $R9 <> -2146869246 ; 0x80096002
    Call AskSetupInstallAbort
  ${EndIf}

  exit:
  ${DebugStackExitFrame} ${un}ExecWaitWusaSetup 1 0

  ${PopPushStack3} "$R9" " " $R0 $R1 $R9
FunctionEnd
!macroend

!define Include_ExecWaitWusaSetup "!insertmacro Include_ExecWaitWusaSetup"
!macro Include_ExecWaitWusaSetup un
!ifndef ${un}ExecWaitWusaSetup_INCLUDED
!define ${un}ExecWaitWusaSetup_INCLUDED
${Include_UnquoteString} "${un}"
${Func_ExecWaitWusaSetup} "${un}"
!endif
!macroend

!define DeclareInstallFromArchive "!insertmacro DeclareInstallFromArchive"
!macro DeclareInstallFromArchive def_if_var_list
${!define_by_enable_flag} INSTALL_FROM_ARCHIVE 0 ; to enable install APP_DIR from archive

${DeclareInstallFromArchiveImpl_Recur} "${def_if_var_list}" \
  DeclareInstallFromArchive__current_elem_def DeclareInstallFromArchive__next_elems_def

!if ${ENABLE_INSTALL_FROM_ARCHIVE} <> 0
  !ifdef NSIS_WIN32_MAKENSIS
    ${!define_iff_exist} _NSIS_SETUP_LIB_TOOLS_7ZIP_7ZA_EXIST 1 "${_NSIS_SETUP_LIB_ROOT}\tools\7zip\7za.exe"
  !else
    !error "7zip/7za executable call does not supported on this platform!"
  !endif
  !if ${_NSIS_SETUP_LIB_TOOLS_7ZIP_7ZA_EXIST} = 0
    !error "7zip/7za command line tool executable is not found in the _NsisSetupLib/tools directory!"
  !endif
!endif

!undef DeclareInstallFromArchive__current_elem_def
!undef DeclareInstallFromArchive__next_elems_def
!macroend

!define DeclareInstallFromArchiveImpl_Recur "!insertmacro DeclareInstallFromArchiveImpl_Recur"
!macro DeclareInstallFromArchiveImpl_Recur def_if_var_list current_elem_def next_elems_def
${UnfoldMacroArgumentList} "${def_if_var_list}" ${current_elem_def} ${next_elems_def} "" | ""

!if ${ENABLE_${${current_elem_def}}} <> 0
  !define /redef ENABLE_INSTALL_FROM_ARCHIVE 1
!else
  ${DeclareInstallFromArchiveImpl_Recur} "${${next_elems_def}}" ${current_elem_def} ${next_elems_def}
!endif
!macroend

!define BeginInstallFromArchive "!insertmacro BeginInstallFromArchive"
!macro BeginInstallFromArchive
!if ${ENABLE_INSTALL_FROM_ARCHIVE} = 0
  !error "InstallFromArchive: BeginInstallFromArchive was not called or didn't declare the feature!"
!endif

; $Temp directory is shared between other installers, but $PluginsDir directory is unique
CreateDirectory "$PluginsDir\7zip"
File "/oname=$PluginsDir\7zip\7za.exe" "${_NSIS_SETUP_LIB_ROOT}\tools\7zip\7za.exe"
!macroend

!define EndInstallFromArchive "!insertmacro EndInstallFromArchive"
!macro EndInstallFromArchive
!if ${ENABLE_INSTALL_FROM_ARCHIVE} = 0
  !error "InstallFromArchive: EndInstallFromArchive was not called or didn't declare the feature!"
!endif

Delete "$PluginsDir\7zip\7za.exe"
RMDir "$PluginsDir\7zip"
!macroend

!define InstallFromArchive "!insertmacro InstallFromArchive"
!macro InstallFromArchive flags path
!if ${ENABLE_INSTALL_FROM_ARCHIVE} = 0
  !error "InstallFromArchive: DeclareInstallFromArchive was not called or didn't declare the feature!"
!endif
!if "${flags}" == ""
  !error "InstallFromArchive: flags must be set."
!endif

!define /math InstallFromArchive__flag_IGNORE_ABSENT ${flags} & 0x01

!if ${InstallFromArchive__flag_IGNORE_ABSENT} <> 0
${If} ${FileExists} "${path}"
!endif

${ExecWaitStdoutToLog} '"$PluginsDir\7zip\7za.exe"' 'x -y -bso1 -bsp0 -bb2 "${path}"' $LAST_ERROR
${UpdateSilentSetupNotify}
${If} $LAST_ERROR <> 0
  ${DebugMessageBox} InstallFromArchive "${__FILE__}:${__LINE__}" "" MB_OK "Install from archive has failed:" \
    "path=$\"${path}$\"$\n|LAST_ERROR=$LAST_ERROR$\n" ""
${EndIf}

!if ${InstallFromArchive__flag_IGNORE_ABSENT} <> 0
${EndIf}
!endif

!undef InstallFromArchive__flag_IGNORE_ABSENT
!macroend

!endif
