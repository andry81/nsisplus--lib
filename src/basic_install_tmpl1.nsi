!ifndef _NSIS_SETUP_LIB_BASIC_INSTALL_TMPL1_NSI
!define _NSIS_SETUP_LIB_BASIC_INSTALL_TMPL1_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\uninit.nsi"

!define MUI_CUSTOMFUNCTION_ABORT customUserAbort

Name "$(APP_TITLE_STRING)"
Caption "$(CAPTION_TEXT)"

# installer pages
ComponentText "$(COMPONENT_TEXT0)" "$(COMPONENT_TEXT1)" "$(COMPONENT_TEXT2)"

; welcome page
!ifdef SETUP_PAGE_INCLUDE_WELCOME
!include "${SETUP_PAGE_INCLUDE_WELCOME}"
!endif

!ifndef MUI_PAGE_WELCOME_HIDE
!insertmacro MUI_PAGE_WELCOME
!endif

!ifdef SETUP_PAGE_INCLUDE_DIRECTORY
!include "${SETUP_PAGE_INCLUDE_DIRECTORY}"
!endif

!ifndef SETUP_PAGE_DIRECTORY_HIDE
!insertmacro MUI_PAGE_DIRECTORY
!endif

; custom start option page 0
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS0
!include "${SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS0}"
!endif

; license page
!ifdef SETUP_PAGE_INCLUDE_LICENSE
!include "${SETUP_PAGE_INCLUDE_LICENSE}"
!endif

!ifdef PRODUCT_LICENSE_FILE
!insertmacro MUI_PAGE_LICENSE ${PRODUCT_LICENSE_FILE}
!endif

; custom start option page 1-
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS1
!include "${SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS1}"
!endif
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS2
!include "${SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS2}"
!endif
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS3
!include "${SETUP_PAGE_INCLUDE_CUSTOM_START_OPTIONS3}"
!endif

!ifdef SETUP_PAGE_INCLUDE_COMPONENTS_OPTIONS
!include "${SETUP_PAGE_INCLUDE_COMPONENTS_OPTIONS}"
!endif

!ifndef MUI_PAGE_COMPONENTS_HIDE
!insertmacro MUI_PAGE_COMPONENTS
!endif

!ifndef MUI_PAGE_STARTMENU_HIDE
; Start menu page
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_DIR_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"

!insertmacro MUI_PAGE_STARTMENU Application "$START_MENU_DIR"
!endif

!ifndef MUI_PAGE_INSTFILES_HIDE
!insertmacro MUI_PAGE_INSTFILES
!endif

; custom finish option pages
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS0
!include "${SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS0}"
!endif
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS1
!include "${SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS1}"
!endif
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS2
!include "${SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS2}"
!endif
!ifdef SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS3
!include "${SETUP_PAGE_INCLUDE_CUSTOM_FINISH_OPTIONS3}"
!endif

!ifdef SETUP_PAGE_INCLUDE_FINISH
!include "${SETUP_PAGE_INCLUDE_FINISH}"
!endif

!ifndef MUI_PAGE_FINISH_HIDE
!insertmacro MUI_PAGE_FINISH
!endif

; Uninstaller pages
!ifdef SETUP_PAGE_INCLUDE_UNINSTALL_OPTIONS
!include "${SETUP_PAGE_INCLUDE_UNINSTALL_OPTIONS}"
!endif

!ifndef MUI_UNPAGE_CONFIRM_HIDE
!insertmacro MUI_UNPAGE_CONFIRM
!endif

!ifndef MUI_UNPAGE_INSTFILES_HIDE
!insertmacro MUI_UNPAGE_INSTFILES
!endif


; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Russian"


; Reserve files
ReserveFile /plugin "InstallOptions.dll"
ReserveFile /plugin "nsDialogs.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\LogEx.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\dumpstate.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\stack.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\StdUtils.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\UAC.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\registry.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\ShellLink.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\nsResize.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\NSISpcre.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\Locate.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\NotifyIcon.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\FindProcDLL.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\SimpleSC.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\SimpleFC.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\liteFirewall.dll"
ReserveFile /plugin "${_NSIS_SETUP_LIB_ROOT}\bin\UserMgr.dll"

# Installer attributes
InstProgressFlags smooth colored
BrandingText /TRIMRIGHT "$(BRANDING_TEXT)"

; DO NOT USE InstallDir, otherwise the /D parameter WILL NOT WORK
#InstallDir "c:\BlaBla"

CRCCheck on
XPStyle on
ShowUninstDetails show
ShowInstDetails show

InstallDirRegKey HKLM "${PRODUCT_SETUP_REGKEY}" InstallRoot

!endif
