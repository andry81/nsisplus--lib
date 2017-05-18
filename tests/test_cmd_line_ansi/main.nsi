!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "${TEST_LIB_ROOT}\common.nsi"
!include "${TEST_LIB_ROOT}\config.nsi"

!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\Stack.nsh"

!include "${_NSIS_SETUP_LIB_ROOT}\src\init.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\win32util.nsi"

!insertmacro MUI_PAGE_INSTFILES

!ifdef NSIS_UNICODE
!error "Test for ANSI version ONLY"
!endif

Var /GLOBAL TEST_ARG0
Var /GLOBAL NUM_TESTS
Var /GLOBAL NUM_TESTS_PASSED

Function TestImpl
	IntOp $NUM_TESTS $NUM_TESTS + 1

	StrCpy $0 0
	StrCpy $R1 0

	System::Alloc 4
	Pop $0
	IntCmp $0 0 failed
	System::Call "*$0(&t128 '$TEST_ARG0')"
	DetailPrint "Test $NUM_TESTS: $0: $TEST_ARG0"

	${CommandLineToArgv} $0 $R0 $R1 $R2
	DetailPrint "Return: $R0, $R1, $R2"
	${If} $R0 == "OK"
		StrCpy $R9 ""
		StrCpy $R4 0
		${DerefUint32} $R6 $R1 0
		#System::Call "*$R4(&i4 .R6)"
		${DoWhile} $R6 <> 0
			System::Call "*$R6(&t${NSIS_MAX_STRLEN} .R8)"
			${If} $R9 != ""
				StrCpy $R9 "$R9$R8|"
			${Else}
				StrCpy $R9 "$R8|"
			${EndIf}
			IntOp $R2 $R2 - 1
			${If} $R2 <= 0
				${Break}
			${EndIf}
			IntOp $R4 $R4 + 1
			${DerefUint32} $R6 $R1 $R4
		${Loop}
		DetailPrint "PASSED: R0=`$R9`"
		Goto Passed
	${EndIf}

	DetailPrint "FAILED."
	Goto failed

	passed:
	IntOp $NUM_TESTS_PASSED $NUM_TESTS_PASSED + 1
	Goto exit

	failed:
	DetailPrint "FAILED."

	exit:
	${SystemFree} $0
	${LocalFree} $R1
	DetailPrint ""
FunctionEnd

Function Test1
	StrCpy $TEST_ARG0 '"command.ext" arg1 arg2'
  Call TestImpl
FunctionEnd

Function Test2
	StrCpy $TEST_ARG0 '"dir with spaces/command.ext" "arg with spaces" arg2'
  Call TestImpl
FunctionEnd

Function Test3
	StrCpy $TEST_ARG0 '"dir with spaces\command.ext" \""arg with spaces"\" arg2'
  Call TestImpl
FunctionEnd

Section -Hidden
	MessageBox MB_OK "Waiting Debugger..."

	StrCpy $NUM_TESTS 0
	StrCpy $NUM_TESTS_PASSED 0

	Call Test1
	Call Test2
	Call Test3

	exit:
	DetailPrint "$NUM_TESTS_PASSED of $NUM_TESTS is passed."
SectionEnd

ShowInstDetails show

!insertmacro MUI_LANGUAGE "English"
