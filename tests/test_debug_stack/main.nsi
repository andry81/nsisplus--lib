!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "${TEST_LIB_ROOT}\common.nsi"
!include "${TEST_LIB_ROOT}\config.nsi"

!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\Stack.nsh"

!include "${_NSIS_SETUP_LIB_ROOT}\src\init.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\debug.nsi"

${Include_DetailPrint} ""

Name "${TEST_TITLE}"

!insertmacro MUI_PAGE_INSTFILES

!define InitRegsNotEmpty "!insertmacro InitRegsNotEmpty"
!macro InitRegsNotEmpty
; initialize all registers by predefined values to detect changes
StrCpy $0 "--0--"
StrCpy $1 "--1--"
StrCpy $2 "--2--"
StrCpy $3 "--3--"
StrCpy $4 "--4--"
StrCpy $5 "--5--"
StrCpy $6 "--6--"
StrCpy $7 "--7--"
StrCpy $8 "--8--"
StrCpy $9 "--9--"
StrCpy $R0 "--R0--"
StrCpy $R1 "--R1--"
StrCpy $R2 "--R2--"
StrCpy $R3 "--R3--"
StrCpy $R4 "--R4--"
StrCpy $R5 "--R5--"
StrCpy $R6 "--R6--"
StrCpy $R7 "--R7--"
StrCpy $R8 "--R8--"
StrCpy $R9 "--R9--"
!macroend

!define InitRegsEmpty "!insertmacro InitRegsEmpty"
!macro InitRegsEmpty
; initialize all registers by predefined values to detect changes
StrCpy $0 ""
StrCpy $1 ""
StrCpy $2 ""
StrCpy $3 ""
StrCpy $4 ""
StrCpy $5 ""
StrCpy $6 ""
StrCpy $7 ""
StrCpy $8 ""
StrCpy $9 ""
StrCpy $R0 ""
StrCpy $R1 ""
StrCpy $R2 ""
StrCpy $R3 ""
StrCpy $R4 ""
StrCpy $R5 ""
StrCpy $R6 ""
StrCpy $R7 ""
StrCpy $R8 ""
StrCpy $R9 ""
!macroend


!define TestMacroImpl "!insertmacro TestMacroImpl"
!macro TestMacroImpl func_name init_func has_return
DetailPrint "${func_name}: ${init_func}"

${${init_func}}

${DebugStackEnterFrame} ${func_name} 0 1

${PushStack4} 333 222 111 000
Call ${func_name}

!if ${has_return} <> 0
${PopStack1} $DEBUG_RET0

DetailPrint "${func_name}: returned: $\"$DEBUG_RET0$\""
!endif

${DebugStackExitFrame} ${func_name} 0 1

DetailPrint ""
!macroend

!define TestImpl "!insertmacro TestImpl"
!macro TestImpl func_name
${DebugStackEnterFrame} "${func_name}" 1 0

; some random usage
StrCpy $R0 000
StrCpy $R1 111
StrCpy $R2 222
StrCpy $R3 333
StrCpy $R8 888
StrCpy $R9 999

${DebugStackExitFrame} "${func_name}" 1 0
!macroend


; TESTS

!define Test_01_forget_to_push "!insertmacro Test_01_forget_to_push"
!macro Test_01_forget_to_push init_func
${TestMacroImpl} Test_01_forget_to_push ${init_func} 0
!macroend

Function Test_01_forget_to_push
  ${ExchStack4} $R0 $R1 $R2 $R3
  ${PushStack2} $R8 $R9

  ${TestImpl} Test_01_forget_to_push
  StrCpy $R4 444 ; forget to push

  ${PopStack6} $R0 $R1 $R2 $R3 $R8 $R9
FunctionEnd

!define Test_02_forget_to_pop "!insertmacro Test_02_forget_to_pop"
!macro Test_02_forget_to_pop init_func
${TestMacroImpl} Test_02_forget_to_pop ${init_func} 0
!macroend

Function Test_02_forget_to_pop
  ${ExchStack4} $R0 $R1 $R2 $R3
  ${PushStack2} $R8 $R9

  ${TestImpl} Test_02_forget_to_pop

  ${PopStack5} $R1 $R2 $R3 $R8 $R9 ; missed $R0 pop
FunctionEnd

!define Test_03_miss_exch_out "!insertmacro Test_03_miss_exch_out"
!macro Test_03_miss_exch_out init_func
${TestMacroImpl} Test_03_miss_exch_out ${init_func} 1
!macroend

Function Test_03_miss_exch_out
  ${ExchStack4} $R0 $R1 $R2 $R3
  ${PushStack2} $R8 $R9

  ${TestImpl} Test_03_miss_exch_out

  ${PushStack1} "return value 123"
  ${ExchStack1} 7 ; invalid stack offset window, outside of frame

  ${PopStack6} $R1 $R2 $R3 $R8 $R9 $R0
FunctionEnd

; really dangerous variant, because a crash/misbehaviour will happen later after the return value usage
!define Test_04_miss_exch_in "!insertmacro Test_04_miss_exch_in"
!macro Test_04_miss_exch_in init_func
${TestMacroImpl} Test_04_miss_exch_in ${init_func} 1
!macroend

Function Test_04_miss_exch_in
  ${ExchStack4} $R0 $R1 $R2 $R3
  ${PushStack2} $R8 $R9

  ${TestImpl} Test_04_miss_exch_in

  ${PushStack1} "return value 123"
  ${ExchStack1} 5 ; invalid stack offset window, inside of frame

  ${PopStack6} $R1 $R2 $R3 $R8 $R9 $R0
FunctionEnd

; fixes previous dangerous variant
!define Test_05_fixed_exch_in "!insertmacro Test_05_fixed_exch_in"
!macro Test_05_fixed_exch_in init_func
${TestMacroImpl} Test_05_fixed_exch_in ${init_func} 1
!macroend

Function Test_05_fixed_exch_in
  ${ExchStack4} $R0 $R1 $R2 $R3
  ${PushStack2} $R8 $R9

  ${TestImpl} Test_05_fixed_exch_in

  StrCpy $R9 "return value 123"

  ${PopPushStack6} "$R9" " " $R0 $R1 $R2 $R3 $R8 $R9
FunctionEnd

Section -Hidden
  MessageBox MB_OK "Waiting Debugger..."

  ${Test_01_forget_to_push} InitRegsNotEmpty
  ${Test_01_forget_to_push} InitRegsEmpty

  ${Test_02_forget_to_pop} InitRegsNotEmpty
  ${Test_02_forget_to_pop} InitRegsEmpty

  ${Test_03_miss_exch_out} InitRegsNotEmpty
  ${Test_03_miss_exch_out} InitRegsEmpty

  ${Test_04_miss_exch_in} InitRegsNotEmpty
  ${Test_04_miss_exch_in} InitRegsEmpty

  ${Test_05_fixed_exch_in} InitRegsNotEmpty
  Dumpstate::debug
  ${Test_05_fixed_exch_in} InitRegsEmpty
SectionEnd

ShowInstDetails show

!insertmacro MUI_LANGUAGE "English"

!include "${_NSIS_SETUP_LIB_ROOT}\src\basic_lang.nsi"
