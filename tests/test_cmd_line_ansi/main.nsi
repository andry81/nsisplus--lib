!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "${TEST_LIB_ROOT}\common.nsi"
!include "${TEST_LIB_ROOT}\config.nsi"

!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\Stack.nsh"

!include "${_NSIS_SETUP_LIB_ROOT}\src\init.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\win32util.nsi"

Name "${TEST_TITLE}"

!insertmacro MUI_PAGE_INSTFILES

!ifdef NSIS_UNICODE
!error "Test for ANSI version ONLY"
!endif

Var /GLOBAL TEST_ARG0
Var /GLOBAL TEST_SEQ0
Var /GLOBAL TEST_RES0
Var /GLOBAL NUM_TESTS
Var /GLOBAL NUM_TESTS_PASSED

!define TestImpl "!insertmacro TestImpl"
!macro TestImpl impl_func
	!define TestImpl__LABEL_ID_EXIT TestImpl__LABEL_ID_EXIT_L_${__LINE__}
	!define TestImpl__LABEL_ID_PASSED TestImpl__LABEL_ID_PASSED_L_${__LINE__}
	!define TestImpl__LABEL_ID_FAILED TestImpl__LABEL_ID_FAILED_L_${__LINE__}

	IntOp $NUM_TESTS $NUM_TESTS + 1

	StrCpy $0 0
	StrCpy $R1 0

	System::Alloc 128
	Pop $0
	IntCmp $0 0 ${TestImpl__LABEL_ID_FAILED}
	System::Call "*$0(&t128 '$TEST_ARG0')"
	DetailPrint "Test $NUM_TESTS: $0: $TEST_ARG0"
	DetailPrint "$\t* Ethalon: `$TEST_SEQ0`"

	${CommandLineToArgv} $0 $R0 $R1 $R2
	DetailPrint "Return: $R0, $R1, $R2"
	${If} $R0 == "OK"
		StrCpy $TEST_RES0 ""
		StrCpy $R4 0
!if "${impl_func}" == "DerefUInt"
		${DerefUint32} $R6 $R1 0
		#System::Call "*$R4(&i4 .R6)"
		${DoWhile} $R6 <> 0
			System::Call "*$R6(&t${NSIS_MAX_STRLEN} .R8)"
			${If} $TEST_RES0 != ""
				StrCpy $TEST_RES0 "$TEST_RES0$R8|"
			${Else}
				StrCpy $TEST_RES0 "$R8|"
			${EndIf}
			IntOp $R2 $R2 - 1
			${If} $R2 <= 0
				${Break}
			${EndIf}
			IntOp $R4 $R4 + 1
			${DerefUint32} $R6 $R1 $R4
		${Loop}
!else if "${impl_func}" == "GetArgv"
		IntOp $R2 $R2 - 1
		${For} $R4 0 $R2
			${GetArgv} $R8 $R1 $R4
			${If} $TEST_RES0 != ""
				StrCpy $TEST_RES0 "$TEST_RES0$R8|"
			${Else}
				StrCpy $TEST_RES0 "$R8|"
			${EndIf}
		${Next}
!else
		!error "Not implemented."
!endif
		${If} $TEST_RES0 S== $TEST_SEQ0
			Goto ${TestImpl__LABEL_ID_PASSED}
		${EndIf}
	${EndIf}

	Goto ${TestImpl__LABEL_ID_FAILED}

	${TestImpl__LABEL_ID_PASSED}:
	DetailPrint "PASSED: `$TEST_RES0`"
	IntOp $NUM_TESTS_PASSED $NUM_TESTS_PASSED + 1
	Goto ${TestImpl__LABEL_ID_EXIT}

	${TestImpl__LABEL_ID_FAILED}:
	DetailPrint "FAILED: `$TEST_RES0`"

	${TestImpl__LABEL_ID_EXIT}:
	${SystemFree} $0
	${LocalFree} $R1
	DetailPrint ""

	!undef TestImpl__LABEL_ID_EXIT
	!undef TestImpl__LABEL_ID_PASSED
	!undef TestImpl__LABEL_ID_FAILED
!macroend

Function Test1
	StrCpy $TEST_ARG0 '"command.ext" arg1 arg2'
	StrCpy $TEST_SEQ0 "command.ext|arg1|arg2|"
	${TestImpl} "DerefUInt"
	${TestImpl} "GetArgv"
FunctionEnd

Function Test2
	StrCpy $TEST_ARG0 '"dir with spaces\command.ext" "arg with spaces" arg2'
	StrCpy $TEST_SEQ0 "dir with spaces\command.ext|arg with spaces|arg2|"
	${TestImpl} "DerefUInt"
	${TestImpl} "GetArgv"
FunctionEnd

Function Test3
	StrCpy $TEST_ARG0 '"dir with spaces\command.ext" \""arg with spaces"\" arg2'
	StrCpy $TEST_SEQ0 'dir with spaces\command.ext|"arg with spaces"|arg2|'
	${TestImpl} "DerefUInt"
	${TestImpl} "GetArgv"
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
