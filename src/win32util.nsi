; utilities based on win32 API functions

!ifndef _NSIS_SETUP_LIB_WIN32UTIL_NSI
!define _NSIS_SETUP_LIB_WIN32UTIL_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\preprocessor.nsi"

!define StrIndexOf "!insertmacro StrIndexOf"
!macro StrIndexOf index_var str substr str_offset no_case_flag
!define StrIndexOf__index_var StrIndexOf__index_var_L${__LINE__}
!define StrIndexOf__LABELID_EXIT StrIndexOf__LABELID_EXIT_L${__LINE__}
!define StrIndexOf__LABELID_QUIT StrIndexOf__LABELID_QUIT_L${__LINE__}

; check on invalid str_offset
IntCmp "${str_offset}" -1 ${StrIndexOf__LABELID_QUIT} ${StrIndexOf__LABELID_QUIT}
IntCmp "${str_offset}" ${NSIS_MAX_STRLEN} ${StrIndexOf__LABELID_QUIT} 0 ${StrIndexOf__LABELID_QUIT}

${SystemCallRegisterStaticMapOrError} ${StrIndexOf__index_var} "${index_var}"

${PushStack6} $R0 $R1 $R2 $R9 $0 $1

StrCpy $R0 "${str}"
StrCpy $R1 "${substr}"
StrCpy $R2 ${str_offset}
StrCpy $R9 -1

StrCpy $0 0
StrCpy $1 0

; allocate buffers
System::Alloc ${NSIS_MAX_STRLEN}
Pop $0
IntCmp $0 0 ${StrIndexOf__LABELID_EXIT}

System::Alloc ${NSIS_MAX_STRLEN}
Pop $1
IntCmp $1 0 ${StrIndexOf__LABELID_EXIT}

; write buffers
System::Call "*$0(&t${NSIS_MAX_STRLEN} R0)"
System::Call "*$1(&t${NSIS_MAX_STRLEN} R1)"

IntOp $R2 $R2 * ${NSIS_CHAR_SIZE}
IntOp $R2 $R2 + $0

IntCmp "${no_case_flag}" 0 0 +3 +3
System::Call "shlwapi::StrStr(p R2, p r1) p.R9"
Goto +2
System::Call "shlwapi::StrStrI(p R2, p r1) p.R9"

IntCmp $R9 0 +3
IntOp $R9 $R9 - $0
Goto +2
StrCpy $R9 -1

${StrIndexOf__LABELID_EXIT}:
IntCmp $0 0 +2
System::Free $0

IntCmp $1 0 +2
System::Free $1

; in case of conditions fail
IntCmp $R9 -1 +3 +2
IntCmp $R9 ${NSIS_MAX_STRLEN} 0 +2
StrCpy $R9 -1

${MacroPopStack6} "${index_var}" "$R9" $R0 $R1 $R2 $R9 $0 $1

Goto +2 ; ignores below jump point
${StrIndexOf__LABELID_QUIT}:
StrCpy ${index_var} -1

StrCpy $0 0

!undef StrIndexOf__index_var
!undef StrIndexOf__LABELID_EXIT
!undef StrIndexOf__LABELID_QUIT
!macroend

!endif
