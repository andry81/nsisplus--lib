!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "${TEST_LIB_ROOT}\common.nsi"
!include "${TEST_LIB_ROOT}\config.nsi"

Name "${TEST_TITLE}"

!insertmacro MUI_PAGE_INSTFILES

Section -Hidden
	MessageBox MB_OK "Waiting Debugger..."

	MessageBox MB_OK "Hello World!"
SectionEnd

ShowInstDetails show

!insertmacro MUI_LANGUAGE "English"
