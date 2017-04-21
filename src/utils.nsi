!ifndef _NSIS_SETUP_LIB_UTILS_NSI
!define _NSIS_SETUP_LIB_UTILS_NSI

!include "LogicLib.nsh"
!include "WordFunc.nsh"

!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"
!include "${_NSIS_SETUP_LIB_ROOT}\src\ppcmd.nsi"

!define StrCpyIfEmpty "!insertmacro StrCpyIfEmpty"
!macro StrCpyIfEmpty var str args_N
${If} "${var}" == ""
  StrCpy ${var} "${str}" ${args_N}
${EndIf}
!macroend

!define SetShellVarContext "!insertmacro SetShellVarContext"
!macro SetShellVarContext ctx
${Switch} "${ctx}"
  ${Case} "all"
    SetShellVarContext all
    StrCpy $SHELL_VAR_CTX "all"
  ${Break}
  ${Case} "current"
    SetShellVarContext current
    StrCpy $SHELL_VAR_CTX "current"
  ${Break}
  ${Default}
    DetailPrint "SetShellVarContext: unknown shell variable context: $\"${ctx}$\""
    MessageBox MB_OK "SetShellVarContext: unknown shell variable context: $\"${ctx}$\" (${__FILE__}:${__LINE__})" /SD IDOK
    ; force context to "current" as most safe or more private
    SetShellVarContext current
    StrCpy $SHELL_VAR_CTX "current"
${EndSwitch}
!macroend

!define PushShellVarContext "!insertmacro PushShellVarContext"
!macro PushShellVarContext shell_ctx
${Push} $SHELL_VAR_CTX
${SetShellVarContext} "${shell_ctx}"
!macroend

!define PopShellVarContext "!insertmacro PopShellVarContext"
!macro PopShellVarContext
${Pop} $SHELL_VAR_CTX
${SetShellVarContext} $SHELL_VAR_CTX
!macroend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate a random number using the RtlGenRandom api
;; P1 :out: Random number
;; P2 :in:  Minimum value
;; P3 :in:  Maximum value
;; min/max P2 and P3 values = -2 147 483 647 / 2 147 483 647
;; max range = 2 147 483 647 (31-bit)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!define Rnd "!insertmacro Rnd"
!macro Rnd var min max
   ${Push} "${max}"
   ${Push} "${min}"
   Call Rnd
   ${Pop} ${var}
!macroend

!define Func_Rnd "!insertmacro Func_Rnd"
!macro Func_Rnd un
Function ${un}Rnd
   ${Exch} $0  ;; Min / return value
   ${Exch} ""
   ${Exch} $1  ;; Max / random value
   ${Push} "$3"  ;; Max - Min range
   ${Push} "$4"  ;; random value buffer
 
   IntOp $3 $1 - $0 ;; calculate range
   IntOp $3 $3 + 1
   System::Call '*(l) i .r4'
   System::Call 'advapi32::SystemFunction036(i r4, i 4)'  ;; RtlGenRandom
   System::Call '*$4(l .r1)'
   System::Free $4
   ;; fit value within range
   System::Int64Op $1 * $3
   ${Pop} $3
   System::Int64Op $3 / 0xFFFFFFFF
   ${Pop} $3
   IntOp $0 $3 + $0  ;; index with minimum value
 
   ${Pop} $4
   ${Pop} $3
   ${Pop} $1
   ${Exch} $0
FunctionEnd
!macroend

!define Include_Rnd "!insertmacro Include_Rnd"
!macro Include_Rnd prefix
!insertmacro Func_Rnd "${prefix}"
!macroend

!define AdvReplaceInFile "!insertmacro AdvReplaceInFile"
!macro AdvReplaceInFile text replace replace_from replace_num file
${Push} `${text}`
${Push} `${replace}`
${Push} `${replace_from}`
${Push} `${replace_num}`
${Push} `${file}`
!ifdef __UNINSTALL__
  Call un.AdvReplaceInFile
!else
  Call AdvReplaceInFile
!endif
!macroend

!define Func_GetLanguageStrings "!insertmacro Func_GetLanguageStrings"
!macro Func_GetLanguageStrings un
Function ${un}GetLanguageStrings
  ${ExchStack1} $R0
  ;R0 - lcid
  ${PushStack3} $R1 $R2 $R3

  ${Switch} $R0
    ${Case} 1033
      StrCpy $R1 "en-us"
      StrCpy $R2 "en"
      StrCpy $R3 "English - United States"
      ${Break}
    ${Case} 1049
      StrCpy $R1 "ru"
      StrCpy $R2 "ru"
      StrCpy $R3 "Russian"
      ${Break}
    ${Default}
      StrCpy $R1 ""
      StrCpy $R2 ""
      StrCpy $R3 ""

      DetailPrint "GetLanguageStrings: unsupported language code: $\"$R0$\""
      MessageBox MB_OK "GetLanguageStrings: unsupported language code: $\"$R0$\" (${__FILE__}:${__LINE__})" /SD IDOK
  ${EndSwitch}

  ${PushStack3} $R1 $R2 $R3

  ${ExchStackStack3} 1

  ${PopStack4} $R3 $R0 $R1 $R2
FunctionEnd
!macroend

!define Call_GetLanguageStrings "!insertmacro Call_GetLanguageStrings"
!macro Call_GetLanguageStrings prefix var_group_country var_short var_long lcid
${Push} `${lcid}`
Call ${prefix}GetLanguageStrings
${Pop} `${var_long}`
${Pop} `${var_short}`
${Pop} `${var_group_country}`
!macroend

!define GetLanguageStrings "!insertmacro GetLanguageStrings"
!macro GetLanguageStrings
!insertmacro Func_GetLanguageStrings ""
!undef GetLanguageStrings
!define GetLanguageStrings "!insertmacro Call_GetLanguageStrings ''"
!macroend

!define un.GetLanguageStrings "!insertmacro un.GetLanguageStrings"
!macro un.GetLanguageStrings
!insertmacro Func_GetLanguageStrings "un."
!undef un.GetLanguageStrings
!define un.GetLanguageStrings "!insertmacro Call_GetLanguageStrings 'un.'"
!macroend

!define ValidateIP "!insertmacro ValidateIP"
!macro ValidateIP ip
${Push} `${ip}`
Call ValidateIP
!macroend

!define ValidatePort "!insertmacro ValidatePort"
!macro ValidatePort port
${Push} `${port}`
Call ValidatePort
!macroend

!define ValidateLoginName "!insertmacro ValidateLoginName"
!macro ValidateLoginName name
${Push} `${name}`
Call ValidateLoginName
!macroend

!define ValidateLoginPass "!insertmacro ValidateLoginPass"
!macro ValidateLoginPass pass
${Push} `${pass}`
Call ValidateLoginPass
!macroend

!define ValidateLocalFilePath "!insertmacro ValidateLocalFilePath"
!macro ValidateLocalFilePath path
${Push} `${path}`
Call ValidateLocalFilePath
!macroend

!define ValidateRemoteFilePath "!insertmacro ValidateRemoteFilePath"
!macro ValidateRemoteFilePath path
${Push} `${path}`
Call ValidateRemoteFilePath
!macroend

!define ValidateNumberValue "!insertmacro ValidateNumberValue"
!macro ValidateNumberValue num
${Push} `${num}`
Call ValidateNumberValue
!macroend

!define ValidateRemoteHostName "!insertmacro ValidateRemoteHostName"
!macro ValidateRemoteHostName name
${Push} `${name}`
Call ValidateRemoteHostName
!macroend

!define ValidateCrossFlowEnvName "!insertmacro ValidateCrossFlowEnvName"
!macro ValidateCrossFlowEnvName name
${Push} `${name}`
Call ValidateCrossFlowEnvName
!macroend

!define Call_RemoveEmptyDirectoryPathImpl "!insertmacro Call_RemoveEmptyDirectoryPathImpl"
!macro Call_RemoveEmptyDirectoryPathImpl prefix persistent_path remove_path
${Push} `${persistent_path}`
${Push} `${remove_path}`
Call ${prefix}RemoveEmptyDirectoryPath
!macroend

!define Call_RemoveEmptyDirectoryPath "!insertmacro Call_RemoveEmptyDirectoryPath"
!macro Call_RemoveEmptyDirectoryPath prefix shell_ctx persistent_path remove_path
${PushShellVarContext} "${shell_ctx}"

${Call_RemoveEmptyDirectoryPathImpl} "${prefix}" "${persistent_path}" "${remove_path}"

${PopShellVarContext}
!macroend

!define RemoveEmptyDirectoryPath "${Call_RemoveEmptyDirectoryPath} ''"
!define un.RemoveEmptyDirectoryPath "${Call_RemoveEmptyDirectoryPath} 'un.'"

!define IsEqualInetIP4 "!insertmacro IsEqualInetIP4"
!macro IsEqualInetIP4 ip1 ip2 res_num
${Push} `${ip1}`
${Push} `${ip2}`
Call IsEqualInetIP4
${Pop} `${res_num}`
!macroend

!define IsIntersectedInetIP4Range "!insertmacro IsIntersectedInetIP4Range"
!macro IsIntersectedInetIP4Range ip1 ip1num ip2 ip2num res_int
${Push} `${ip1}`
${Push} `${ip1num}`
${Push} `${ip2}`
${Push} `${ip2num}`
Call IsIntersectedInetIP4Range
${Pop} `${res_int}`
!macroend

!define IsEqualInetPort16 "!insertmacro IsEqualInetPort16"
!macro IsEqualInetPort16 port1 port2 res_num
${Push} `${port1}`
${Push} `${port2}`
Call IsEqualInetPort16
${Pop} `${res_num}`
!macroend

!define GetSubnetMaskedInetIP4 "!insertmacro GetSubnetMaskedInetIP4"
!macro GetSubnetMaskedInetIP4 ip subnet masked_ip
${Push} `${ip}`
${Push} `${subnet}`
Call GetSubnetMaskedInetIP4
${Pop} `${masked_ip}`
!macroend

!define GetSubnetUnMaskedInetIP4 "!insertmacro GetSubnetUnMaskedInetIP4"
!macro GetSubnetUnMaskedInetIP4 ip subnet unmasked_ip
${Push} `${ip}`
${Push} `${subnet}`
Call GetSubnetUnMaskedInetIP4
${Pop} `${unmasked_ip}`
!macroend

!define InetIP4Op "!insertmacro InetIP4Op"
!macro InetIP4Op var op1 op op2
${Push} `${op}`
${Push} `${op1}`
${Push} `${op2}`
Call InetIP4Op
${Pop} `${var}`
!macroend

!define BitwiseInverseInetIP4 "!insertmacro BitwiseInverseInetIP4"
!macro BitwiseInverseInetIP4 ip result_ip
${Push} `${ip}`
Call BitwiseInverseInetIP4
${Pop} `${result_ip}`
!macroend

!define BitwiseOrInetIP4 "!insertmacro BitwiseOrInetIP4"
!macro BitwiseOrInetIP4 ip1 ip2 result_ip
${Push} `${ip1}`
${Push} `${ip2}`
Call BitwiseOrInetIP4
${Pop} `${result_ip}`
!macroend

!define TrimLeadingChars "!insertmacro TrimLeadingChars"
!macro TrimLeadingChars var value char
${Push} `${value}`
${Push} `${char}`
!ifndef __UNINSTALL__
Call TrimLeadingChars
!else
Call un.TrimLeadingChars
!endif
${Pop} `${var}`
!macroend

!define Func_TrimLeadingChars "!insertmacro Func_TrimLeadingChars"
!macro Func_TrimLeadingChars un
Function ${un}TrimLeadingChars
  ${ExchStack2} $R0 $R1
  ; $R0 - string
  ; $R1 - char
  ${PushStack1} $R2

  ${If} $R0 == ""
    Goto end
  ${EndIf}

Loop:
  StrCpy $R2 "$R0" 1
  StrCmpS "$R2" "$R1" TrimLeft
  Goto end

TrimLeft:
  StrCpy $R0 "$R0" "" 1
  Goto Loop

end:
  ${Push} $R0
  ${Exch} 3
  ${PopStack3} $R1 $R2 $R0
FunctionEnd
!macroend

!define Include_TrimLeadingChars "!insertmacro Include_TrimLeadingChars"
!macro Include_TrimLeadingChars un
!ifndef ${un}TrimLeadingChars_INCLUDED
!define ${un}TrimLeadingChars_INCLUDED
${Func_TrimLeadingChars} "${un}"
!endif
!macroend

!define TrimTrailingChars "!insertmacro TrimTrailingChars"
!macro TrimTrailingChars var value char
${Push} `${value}`
${Push} `${char}`
!ifndef __UNINSTALL__
Call TrimTrailingChars
!else
Call un.TrimTrailingChars
!endif
${Pop} `${var}`
!macroend

!define Func_TrimTrailingChars "!insertmacro Func_TrimTrailingChars"
!macro Func_TrimTrailingChars un
Function ${un}TrimTrailingChars
  ${ExchStack2} $R0 $R1
  ; $R0 - string
  ; $R1 - char
  ${Push} $R2

  ${If} $R0 == ""
    Goto end
  ${EndIf}

Loop:
  StrCpy $R2 "$R0" 1 -1 ; last character
  StrCmpS "$R2" "$R1" TrimRight
  Goto end

TrimRight:
  StrCpy $R0 "$R0" -1
  Goto Loop

end:
  ${Push} $R0
  ${Exch} 3

  ${PopStack3} $R1 $R2 $R0
FunctionEnd
!macroend

!define Include_TrimTrailingChars "!insertmacro Include_TrimTrailingChars"
!macro Include_TrimTrailingChars un
!ifndef ${un}TrimTrailingChars_INCLUDED
!define ${un}TrimTrailingChars_INCLUDED
${Func_TrimTrailingChars} "${un}"
!endif
!macroend

!define TrimLeadingZeros "!insertmacro TrimLeadingZeros"
!macro TrimLeadingZeros var value
${Push} `${value}`
!ifndef __UNINSTALL__
Call TrimLeadingZeros
!else
Call un.TrimLeadingZeros
!endif
${Pop} `${var}`
!macroend

!define Func_TrimLeadingZeros "!insertmacro Func_TrimLeadingZeros"
!macro Func_TrimLeadingZeros un
Function ${un}TrimLeadingZeros
  ${ExchStack1} $R0
  ; $R0 - number

  ${${un}TrimLeadingChars} $R0 $R0 0

  ${If} $R0 == ""
    StrCpy $R0 0
  ${EndIf}

  ${Exch} $R0
FunctionEnd
!macroend

!define Include_TrimLeadingZeros "!insertmacro Include_TrimLeadingZeros"
!macro Include_TrimLeadingZeros un
!ifndef ${un}TrimLeadingZeros_INCLUDED
!define ${un}TrimLeadingZeros_INCLUDED
${Include_TrimLeadingChars} "${un}"
${Func_TrimLeadingZeros} "${un}"
!endif
!macroend

!define ExpandEnvironmentString "!insertmacro ExpandEnvironmentString"
!macro ExpandEnvironmentString var string
${Push} `${string}`
!ifndef __UNINSTALL__
Call ExpandEnvironmentString
!else
Call un.ExpandEnvironmentString
!endif
${Pop} `${var}`
!macroend

!define Func_ExpandEnvironmentString "!insertmacro Func_ExpandEnvironmentString"
!macro Func_ExpandEnvironmentString un
Function ${un}ExpandEnvironmentString
  ${ExchStack1} $R0
  ; $R0 - string
  ${PushStack6} $R1 $R2 $R3 $R4 $R5 $R6

  StrCpy $R9 ""

repeat_search:
  ${${un}StrLoc} $R1 $R0 "%" >
  ${If} $R1 != ""
    StrCpy $R8 $R0 $R1
    StrCpy $R9 "$R9$R8"
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 "" $R1
    ${${un}StrLoc} $R1 $R0 "%" >
    ${If} $R1 != ""
      ${If} $R1 > 0
        StrCpy $R2 $R0 $R1
        ReadEnvStr $R3 "$R2"
        StrCpy $R9 "$R9$R3"
        IntOp $R1 $R1 + 1
        StrCpy $R0 $R0 "" $R1
      ${Else}
        StrCpy $R9 "$R9%"
        StrCpy $R0 $R0 "" 1
      ${EndIf}
      Goto repeat_search
    ${Else}
      StrCpy $R9 "$R9%"
    ${EndIf}
  ${EndIf}

  StrCpy $R9 "$R9$R0"

  ${Push} $R9
  ${Exch} 7

  ${PopStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R0
FunctionEnd
!macroend

!define Include_ExpandEnvironmentString "!insertmacro Include_ExpandEnvironmentString"
!macro Include_ExpandEnvironmentString un
!ifndef ${un}ExpandEnvironmentString_INCLUDED
!define ${un}ExpandEnvironmentString_INCLUDED
!ifndef STRFUNC_INCLUDED
!include "StrFunc.nsh"
!endif

!if "${un}" == ""
!ifndef StrLoc_INCLUDED
${StrLoc}
!endif
!endif

!if "${un}" == "un."
!ifndef UnStrLoc_INCLUDED
${UnStrLoc}
!define un.StrLoc ${UnStrLoc}
!endif
!endif

${Func_ExpandEnvironmentString} "${un}"
!endif
!macroend

!define ApplyStartOptions "!insertmacro ApplyStartOptions"
!macro ApplyStartOptions type num file
; save registers to stack
${PushStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

${Push} `${type}`
${Push} `${num}`
${Push} `${file}`
Call ApplyStartOptions

${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
!macroend

!define Func_GetSysDrive "!insertmacro GetSysDrive"
!macro Func_GetSysDrive un
Function ${un}GetSysDrive
  ${PushStack1} $R0

  ReadEnvStr $R0 SYSTEMDRIVE
  ${If} $R0 == ""
    StrCpy $R0 "$SYSDIR" 3
  ${EndIf}

  ${Exch} $R0
FunctionEnd
!macroend

!define Call_GetSysDrive "!insertmacro Call_GetSysDrive"
!macro Call_GetSysDrive prefix var
  Call ${prefix}GetSysDrive
  ${Pop} `${var}`
!macroend

!define GetSysDrive "!insertmacro GetSysDrive"
!macro GetSysDrive
!insertmacro Func_GetSysDrive ""
!undef GetSysDrive
!define GetSysDrive "${Call_GetSysDrive} ''"
!macroend

!define un.GetSysDrive "!insertmacro un.GetSysDrive"
!macro un.GetSysDrive
!insertmacro Func_GetSysDrive "un."
!undef un.GetSysDrive
!define un.GetSysDrive "${Call_GetSysDrive} 'un.'"
!macroend

!macro Func_AdvReplaceInFile un
Function ${un}AdvReplaceInFile
  ${ExchStack5} $4 $3 $2 $1 $0
  ; $0 - file to replace in
  ; $1 - number to replace after
  ; $2 - replace and onwards
  ; $3 - replace with
  ; $4 - to replace
  ${PushStack12} $5 $6 $7 $8 $9 $R0 $R1 $R2 $R3 $R4 $R5 $R6
  ; $5  - minus count
  ; $6  - universal
  ; $7  - end string
  ; $8  - left string
  ; $9  - right string
  ; $R0 - file1
  ; $R1 - file2
  ; $R2 - read
  ; $R3 - universal
  ; $R4 - count (onwards)
  ; $R5 - count (after)
  ; $R6 - temp file name

  GetTempFileName $R6
  FileOpen $R1 $0 r ;file to search in
  FileOpen $R0 $R6 w ;temp file
  StrLen $R3 $4
  StrCpy $R4 -1
  StrCpy $R5 -1

  loop_read:
  ClearErrors
  FileRead $R1 $R2 ;read line
  IfErrors exit

  StrCpy $5 0
  StrCpy $7 $R2

  loop_filter:
  IntOp $5 $5 - 1
  StrCpy $6 $7 $R3 $5 ;search
  StrCmp $6 "" file_write1
  StrCmp $6 $4 0 loop_filter

  StrCpy $8 $7 $5 ;left part
  IntOp $6 $5 + $R3
  IntCmp $6 0 is0 not0
  is0:
  StrCpy $9 ""
  Goto done
  not0:
  StrCpy $9 $7 "" $6 ;right part
  done:
  StrCpy $7 $8$3$9 ;re-join

  IntOp $R4 $R4 + 1
  StrCmp $2 all loop_filter
  StrCmp $R4 $2 0 file_write2
  IntOp $R4 $R4 - 1

  IntOp $R5 $R5 + 1
  StrCmp $1 all loop_filter
  StrCmp $R5 $1 0 file_write1
  IntOp $R5 $R5 - 1
  Goto file_write2

  file_write1:
  FileWrite $R0 $7 ;write modified line
  Goto loop_read

  file_write2:
  FileWrite $R0 $R2 ;write unmodified line
  Goto loop_read

  exit:
  FileClose $R0
  FileClose $R1

  SetDetailsPrint none
  Delete $0
  Rename $R6 $0
  Delete $R6
  SetDetailsPrint lastused

  ${PopStack17} $4 $3 $2 $1 $0 $5 $6 $7 $8 $9 $R0 $R1 $R2 $R3 $R4 $R5 $R6
FunctionEnd
!macroend

!insertmacro Func_AdvReplaceInFile ""
!insertmacro Func_AdvReplaceInFile "un."

${Include_TrimLeadingZeros} ""

Function ValidateIP
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - ip
  ${PushStack2} $R1 $R2

  ${StrFilter} $R0 1 "." "" $R1
  ${If} $R0 != $R1
    ; invalid characters used
    ;   example: a127.0.0.1
    Goto error
  ${EndIf}

  ${WordFind} $R0 . "#" $R1
  ${If} ${Errors}
    StrCpy $R1 0
  ${EndIf}

  ${If} $R1 <> 4
    ; wrong number of numbers
    ;   example: 127.0.0.
    Goto error
  ${EndIf}

  ${WordFind} $R0 . "*" $R1
  ${If} ${Errors}
    StrCpy $R1 0
  ${EndIf}

  ${If} $R1 <> 3
    ; wrong number of dots
    ;   example: 127.0.0.1.
    Goto error
  ${EndIf}

  ${For} $R2 1 4
    ${WordFind} $R0 . +$R2 $R1
    ${If} ${Errors}
      StrCpy $R1 ""
    ${EndIf}

    ${TrimLeadingZeros} $R1 $R1
    ${If} $R1 >= 255
    ${OrIf} $R1 < 1
      ; invalid number
      ;   example: 500.0.0.1
      Goto error
    ${EndIf}
  ${Next}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidatePort
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - port
  ${PushStack2} $R1 $R2

  ${StrFilter} $R0 1 "" "" $R1
  ${If} $R1 == ""
    ; no port number
    Goto error
  ${EndIf}

  ${If} $R0 != $R1
    ; invalid characters used
    ;   example: a6001
    Goto error
  ${EndIf}

  ${TrimLeadingZeros} $R0 $R0
  ${If} $R0 > 65535
  ${OrIf} $R0 < 0
    ; invalid port
    ;   example: 65536
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidateLoginName
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - name
  ${PushStack2} $R1 $R2

  ${If} $R0 == ""
    ; no login name
    Goto error
  ${EndIf}

  ${StrFilter} $R0 "" "" "$\"" $R1
  ${If} $R0 != $R1
    ; invalid characters used
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidateLoginPass
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - pass
  ${PushStack2} $R1 $R2

  ${StrFilter} $R0 "" "" "$\"" $R1
  ${If} $R0 S!= $R1
    ; invalid characters used
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidateLocalFilePath
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - path
  ${PushStack2} $R1 $R2

  ${If} $R0 == ""
    ; no path
    Goto error
  ${EndIf}

  ${StrFilter} $R0 "" "" "$\"$\'$\`?*&|<>" $R1
  ${If} $R0 S!= $R1
    ; invalid characters used
    Goto error
  ${EndIf}

  StrLen $R1 $R0
  ${If} $R1 < 2
    ; invalid path length
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidateRemoteFilePath
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - path
  ${PushStack2} $R1 $R2

  ${If} $R0 == ""
    ; no path
    Goto error
  ${EndIf}

  ${StrFilter} $R0 "" "" "$\"$\'$\`?*&|<>" $R1
  ${If} $R0 != $R1
    ; invalid characters used
    Goto error
  ${EndIf}

  StrLen $R1 $R0
  ${If} $R1 < 2
    ; invalid canonical path length
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidateNumberValue
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - num
  ${PushStack2} $R1 $R2

  ${If} $R0 == ""
    ; no value
    Goto error
  ${EndIf}

  ${StrFilter} $R0 1 "" "$\"" $R1
  ${If} $R0 != $R1
    ; invalid characters used
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidateRemoteHostName
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - name
  ${PushStack2} $R1 $R2

  StrLen $R1 $R0
  ${If} $R1 > 15
  ${OrIf} $R1 < 1
    ; invalid host name length
    Goto error
  ${EndIf}

  ${StrFilter} $R0 "" "" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789-" $R1
  StrLen $R2 $R1
  ${If} $R2 > 0
    ; invalid characters used
    ;   example: myhost!
    Goto error
  ${EndIf}

  StrCpy $R1 $R0 1
  ${StrFilter} $R1 "" "" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_" $R2
  StrLen $R1 $R2
  ${If} $R1 > 0
    ; invalid first character used
    ;   example: 1myhost
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function ValidateCrossFlowEnvName
  ClearErrors

  ${ExchStack1} $R0
  ; R0 - name
  ${PushStack2} $R1 $R2

  StrLen $R1 $R0
  ${If} $R1 > 32
  ${OrIf} $R1 < 1
    ; invalid host name length
    Goto error
  ${EndIf}

  ${StrFilter} $R0 "" "" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789-" $R1
  StrLen $R2 $R1
  ${If} $R2 > 0
    ; invalid characters used
    ;   example: myhost!
    Goto error
  ${EndIf}

  StrCpy $R1 $R0 1
  ${StrFilter} $R1 "" "" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_" $R2
  StrLen $R1 $R2
  ${If} $R1 > 0
    ; invalid first character used
    ;   example: 1myhost
    Goto error
  ${EndIf}

  Goto end

  error:
  SetErrors

  end:
  ${PopStack3} $R0 $R1 $R2
FunctionEnd

Function IsEqualInetIP4
  ${ExchStack2} $R1 $R2
  ; R1 - ip1
  ; R2 - ip2
  ${PushStack8} $R0 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  StrCpy $R0 0

  ; calculate minimal number of segments to check on equality
  ${WordFind} $R1 . "#" $R3
  ${If} ${Errors}
    StrCpy $R3 0
  ${EndIf}

  ${WordFind} $R2 . "#" $R4
  ${If} ${Errors}
    StrCpy $R4 0
  ${EndIf}

  ${If} $R4 < $R3
    StrCpy $R3 $R4
  ${EndIf}

  ${For} $R5 1 $R3
    ${WordFind} $R1 . +$R5 $R6
    ${If} ${Errors}
      StrCpy $R6 ""
    ${EndIf}

    ${WordFind} $R2 . +$R5 $R7
    ${If} ${Errors}
      StrCpy $R7 ""
    ${EndIf}

    ${TrimLeadingZeros} $R6 $R6
    ${TrimLeadingZeros} $R7 $R7
    ${If} $R6 <> $R7
      StrCpy $R0 1
      ${Break}
    ${EndIf}
  ${Next}

  ${Push} $R0
  ${Exch} 10

  ${PopStack10} $R2 $R0 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $R1
FunctionEnd

Function IsIntersectedInetIP4Range
  ${ExchStack4} $R0 $R1 $R2 $R3
  ; R0 - ip1
  ; R1 - ip1num
  ; R2 - ip2
  ; R3 - ip2num
  ${PushStack6} $R4 $R5 $R6 $R7 $R8 $R9

  StrCpy $R9 0

  ${For} $R8 1 3
    ${WordFind} $R0 . +$R8 $R4
    ${WordFind} $R2 . +$R8 $R5
    ${TrimLeadingZeros} $R4 $R4
    ${TrimLeadingZeros} $R5 $R5
    ${If} $R4 <> $R5
      Goto Done
    ${EndIf}
  ${Next}

  ${WordFind} $R0 . +4 $R4
  ${WordFind} $R2 . +4 $R5
  ${TrimLeadingZeros} $R4 $R4
  ${TrimLeadingZeros} $R5 $R5

  # if ip num is negative - increment ip num and swap bounds
  ${If} $R1 >= 0
    IntOp $R6 $R4 + $R1
  ${Else}
    IntOp $R1 $R1 + 1

    IntOp $R6 $R4 + $R1

    # swap
    ${Push} $R6
    StrCpy $R6 $R4
    ${Pop} $R4
  ${EndIf}

  # if ip num is negative - increment ip num and swap bounds
  ${If} $R3 >= 0
    IntOp $R7 $R5 + $R3
  ${Else}
    IntOp $R3 $R3 + 1

    IntOp $R7 $R5 + $R3

    # swap
    ${Push} $R7
    StrCpy $R7 $R5
    ${Pop} $R5
  ${EndIf}

  ${If} $R4 <= $R5
  ${AndIf} $R5 < $R6
    StrCpy $R9 -1
  ${Else}
    ${If} $R5 <= $R4
    ${AndIf} $R4 < $R7
      StrCpy $R9 1
    ${EndIf}
  ${EndIf}

  Done:
  ${Push} $R9
  ${Exch} 10

  ${PopStack10} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $R0
FunctionEnd

Function IsEqualInetPort16
  ${ExchStack2} $R1 $R2
  ; R1 - port1
  ; R2 - port2
  ${PushStack8} $R0 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  StrCpy $R0 1

  ${StrFilter} $R1 1 "" "" $R3
  ${StrFilter} $R2 1 "" "" $R4

  ${TrimLeadingZeros} $R3 $R3
  ${TrimLeadingZeros} $R4 $R4
  ${If} "$R3" == "$R4"
    StrCpy $R0 0
  ${EndIf}

  ${Push} $R0
  ${Exch} 10

  ${PopStack10} $R2 $R0 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $R1
FunctionEnd

Function GetSubnetMaskedInetIP4
  ${ExchStack2} $R0 $R1
  ; $R1 - subnet
  ; $R0 - ip

  ${PushStack5} $R2 $R3 $R4 $R5 $R6
  ; $R2 - masked_ip
  ; $R3 - ip minimal number segments
  ; $R4 - temp
  ; $R5 - temp
  ; $R6 - temp

  StrCpy $R2 ""

  ; calculate minimal number of segments to check on equality
  ${WordFind} $R0 . "#" $R3
  ${If} ${Errors}
    StrCpy $R3 0
  ${EndIf}

  ${WordFind} $R1 . "#" $R4
  ${If} ${Errors}
    StrCpy $R4 0
  ${EndIf}

  ${If} $R4 < $R3
    StrCpy $R3 $R4
  ${EndIf}
  ${If} $R3 > 4
    StrCpy $R3 4
  ${EndIf}

  ${For} $R4 1 $R3
    ${WordFind} $R0 . +$R4 $R5
    ${If} ${Errors}
      StrCpy $R5 ""
    ${EndIf}

    ${WordFind} $R1 . +$R4 $R6
    ${If} ${Errors}
      StrCpy $R6 ""
    ${EndIf}

    ${TrimLeadingZeros} $R5 $R5
    ${TrimLeadingZeros} $R6 $R6
    IntOp $R5 $R5 & $R6
    IntOp $R5 $R5 & 255
    ; just in case
    ${If} $R5 < 0
      IntOp $R5 256 + $R5
    ${EndIf}

    ${If} $R2 != ""
      StrCpy $R2 "$R2.$R5"
    ${Else}
      StrCpy $R2 "$R5"
    ${EndIf}
  ${Next}

  ; fill IP4 empty segments
  ${If} $R3 < 4
    ${For} $R4 $R3 4
      StrCpy $R2 "$R2.0"
    ${Next}
  ${EndIf}

  ${Push} $R2
  ${Exch} 7

  ${PopStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R0
FunctionEnd

Function GetSubnetUnMaskedInetIP4
  ${ExchStack2} $R0 $R1
  ; $R1 - subnet
  ; $R0 - ip

  ${PushStack2} $R2 $R3

  ; inverse subnet mask
  ${BitwiseInverseInetIP4} $R1 $R2
  ${GetSubnetMaskedInetIP4} $R0 $R2 $R3

  ${Push} $R3
  ${Exch} 4

  ${PopStack4} $R1 $R2 $R3 $R0
FunctionEnd

Function InetIP4Op
  ${ExchStack3} $R0 $R1 $R2
  ; $R0 - op
  ; $R1 - op1
  ; $R2 - op2

  ${PushStack5} $R3 $R4 $R5 $R6 $R9

  StrCpy $R9 ""

  ; calculate minimal number of segments to check on equality
  ${WordFind} $R1 . "#" $R3
  ${If} ${Errors}
    StrCpy $R3 0
  ${EndIf}

  ${WordFind} $R2 . "#" $R4
  ${If} ${Errors}
    StrCpy $R4 0
  ${EndIf}

  ${If} $R4 < $R3
    StrCpy $R3 $R4
  ${EndIf}
  ${If} $R3 > 4
    StrCpy $R3 4
  ${EndIf}

  ${For} $R4 1 $R3
    ${WordFind} $R1 . +$R4 $R5
    ${If} ${Errors}
      StrCpy $R5 ""
    ${EndIf}

    ${WordFind} $R2 . +$R4 $R6
    ${If} ${Errors}
      StrCpy $R6 ""
    ${EndIf}

    ${TrimLeadingZeros} $R5 $R5
    ${TrimLeadingZeros} $R6 $R6

    ${Switch} $R0
      ${Case} "+"
        IntOp $R5 $R5 + $R6
      ${Break}
      ${Case} "-"
        IntOp $R5 $R5 - $R6
      ${Break}
      ${Case} "^"
        IntOp $R5 $R5 ^ $R6
      ${Break}
      ${Case} "&"
        IntOp $R5 $R5 & $R6
      ${Break}
      ${Case} "|"
        IntOp $R5 $R5 | $R6
      ${Break}
      ${Case} "*"
        IntOp $R5 $R5 * $R6
      ${Break}
      ${Case} "/"
        IntOp $R5 $R5 / $R6
      ${Break}
    ${EndSwitch}

    IntOp $R5 $R5 & 255
    ; just in case
    ${If} $R5 < 0
      IntOp $R5 256 + $R5
    ${EndIf}

    ${If} $R9 != ""
      StrCpy $R9 "$R9.$R5"
    ${Else}
      StrCpy $R9 "$R5"
    ${EndIf}
  ${Next}

  ; fill IP4 empty segments
  ${If} $R3 < 4
    ${For} $R4 $R3 4
      StrCpy $R9 "$R9.0"
    ${Next}
  ${EndIf}

  ${Push} $R9
  ${Exch} 8

  ${PopStack8} $R1 $R2 $R3 $R4 $R5 $R6 $R9 $R0
FunctionEnd

Function BitwiseInverseInetIP4
  ${ExchStack1} $R0
  ; $R0 - ip

  ${PushStack4} $R1 $R2 $R3 $R4
  ; $R1 - result_ip
  ; $R2 - ip minimal number segments
  ; $R3 - temp
  ; $R4 - temp

  StrCpy $R1 ""

  ; calculate minimal number of segments to check on equality
  ${WordFind} $R0 . "#" $R2
  ${If} ${Errors}
    StrCpy $R2 0
  ${EndIf}

  ${If} $R2 > 4
    StrCpy $R2 4
  ${EndIf}

  ${For} $R3 1 $R2
    ${WordFind} $R0 . +$R3 $R4
    ${If} ${Errors}
      StrCpy $R4 ""
    ${EndIf}

    ${TrimLeadingZeros} $R4 $R4
    IntOp $R4 $R4 ~
    IntOp $R4 $R4 & 255
    ; just in case
    ${If} $R4 < 0
      IntOp $R4 256 + $R4
    ${EndIf}

    ${If} $R1 != ""
      StrCpy $R1 "$R1.$R4"
    ${Else}
      StrCpy $R1 "$R4"
    ${EndIf}
  ${Next}

  ; fill IP4 empty segments
  ${If} $R2 < 4
    ${For} $R3 $R2 4
      StrCpy $R1 "$R1.0"
    ${Next}
  ${EndIf}

  ${Push} $R1
  ${Exch} 5

  ${PopStack5} $R1 $R2 $R3 $R4 $R0
FunctionEnd

Function BitwiseOrInetIP4
  ${ExchStack2} $R0 $R1
  ; $R1 - ip2
  ; $R0 - ip1

  ${PushStack5} $R2 $R3 $R4 $R5 $R6
  ; $R2 - result_ip
  ; $R3 - ip minimal number segments
  ; $R4 - temp
  ; $R5 - temp
  ; $R6 - temp

  StrCpy $R2 ""

  ; calculate minimal number of segments to check on equality
  ${WordFind} $R0 . "#" $R3
  ${If} ${Errors}
    StrCpy $R3 0
  ${EndIf}

  ${WordFind} $R1 . "#" $R4
  ${If} ${Errors}
    StrCpy $R4 0
  ${EndIf}

  ${If} $R4 < $R3
    StrCpy $R3 $R4
  ${EndIf}
  ${If} $R3 > 4
    StrCpy $R3 4
  ${EndIf}

  ${For} $R4 1 $R3
    ${WordFind} $R0 . +$R4 $R5
    ${If} ${Errors}
      StrCpy $R5 ""
    ${EndIf}

    ${WordFind} $R1 . +$R4 $R6
    ${If} ${Errors}
      StrCpy $R6 ""
    ${EndIf}

    ${TrimLeadingZeros} $R5 $R5
    ${TrimLeadingZeros} $R6 $R6
    IntOp $R5 $R5 | $R6
    IntOp $R5 $R5 & 255
    ; just in case
    ${If} $R5 < 0
      IntOp $R5 256 + $R5
    ${EndIf}

    ${If} $R2 != ""
      StrCpy $R2 "$R2.$R5"
    ${Else}
      StrCpy $R2 "$R5"
    ${EndIf}
  ${Next}

  ; fill IP4 empty segments
  ${If} $R3 < 4
    ${For} $R4 $R3 4
      StrCpy $R2 "$R2.0"
    ${Next}
  ${EndIf}

  ${Push} $R2
  ${Exch} 7

  ${PopStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R0
FunctionEnd

!define Func_RemoveEmptyDirectoryPath "!insertmacro Func_RemoveEmptyDirectoryPath"
!macro Func_RemoveEmptyDirectoryPath un
Function ${un}RemoveEmptyDirectoryPath
  ${ExchStack2} $R0 $R1
  ; R0 - persistent_path
  ; R1 - remove_path
  ${PushStack8} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9

  ; trim trailing slashes from paths
  ${TrimTrailingChars} $R0 $R0 "\"
  ${TrimTrailingChars} $R1 $R1 "\"

  ${WordFind} $R1 "\" "#" $R3
  ${If} ${Errors}
    StrCpy $R3 0
  ${EndIf}

  ${If} $R3 < 1
    ${If} $R1 != ""
      RMDir "$R0\$R1"
    ${EndIf}
    Goto exit
  ${EndIf}

  ${ForEach} $R4 $R3 1 - 1
    StrCpy $R7 $R0
    ${For} $R5 1 $R4
      ${WordFind} $R1 "\" +$R5 $R6
      ${If} ${Errors}
        StrCpy $R6 ""
      ${EndIf}

      ${If} $R7 != ""
        StrCpy $R7 "$R7\$R6"
      ${Else}
        StrCpy $R7 $R6
      ${EndIf}
    ${Next}
    RMDir "$R7"
  ${Next}

  exit:
  ${PopStack10} $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9
FunctionEnd
!macroend

!define Include_RemoveEmptyDirectoryPath "!insertmacro Include_RemoveEmptyDirectoryPath"
!macro Include_RemoveEmptyDirectoryPath un
!ifndef ${un}RemoveEmptyDirectoryPath_INCLUDED
!define ${un}RemoveEmptyDirectoryPath_INCLUDED
${Include_TrimTrailingChars} "${un}"
${Func_RemoveEmptyDirectoryPath} "${un}"
!endif
!macroend

!define Func_UnquoteString "!insertmacro Func_UnquoteString"
!macro Func_UnquoteString un
Function ${un}UnquoteString
  ${ExchStack1} $R0
  ;R0 - str
  ${PushStack1} $R1

  ${${un}RECaptureMatches} $R0 "^$\"?([^$\"]+)$\"?" $R0 0
  ${If} $R0 <> 0
    ; ${Pop} $R1
  ${Else}
    ${Push} ""
  ${EndIf}

  ${Exch} 2

  ${PopStack2} $R1 $R0
FunctionEnd
!macroend

!define Include_UnquoteString "!insertmacro Include_UnquoteString"
!macro Include_UnquoteString un
!ifndef ${un}UnquoteString_INCLUDED
!define ${un}UnquoteString_INCLUDED
!include "${_NSIS_SETUP_LIB_ROOT}\src\3dparty\NSISpcre.nsh"
!insertmacro ${un}REMatches
${Func_UnquoteString} "${un}"
!endif
!macroend

!define UnquoteString "!insertmacro UnquoteString"
!macro UnquoteString var str
${PushStack1} `${str}`

!ifndef __UNINSTALL__
Call UnquoteString
!else
Call un.UnquoteString
!endif

${PopStack1} `${var}`
!macroend

; status_var codes:
; 1 - read and not empty
; 0 - read but empty
; -1 - no read
; -2 - read error
!define ReadINIStrIf "!insertmacro ReadINIStrIf"
!macro ReadINIStrIf status_var var flags ini_file ini_section ini_var
!define __CURRENT_MACRO_LABELID_ReadINIStrIf_NOCALL __CURRENT_MACRO_LABELID_ReadINIStrIf_NOCALL_L${__LINE__}
!define __CURRENT_MACRO_LABELID_ReadINIStrIf_END __CURRENT_MACRO_LABELID_ReadINIStrIf_END_L${__LINE__}

IntCmp ${flags} 0 +2
StrCmp "${var}" "" 0 ${__CURRENT_MACRO_LABELID_ReadINIStrIf_NOCALL}
${Call_ReadINIStrIf} `${var}` `${ini_file}` `${ini_section}` `${ini_var}`
${If} ${NoErrors}
  ${If} "${var}" != ""
    StrCpy ${status_var} 1 ; read and not empty
  ${Else}
    StrCpy ${status_var} 0 ; read but empty
  ${EndIf}
${Else}
  StrCpy ${status_var} -2 ; read error
${EndIf}

${Goto} ${__CURRENT_MACRO_LABELID_ReadINIStrIf_END}

${__CURRENT_MACRO_LABELID_ReadINIStrIf_NOCALL}:
StrCpy ${status_var} -1

${__CURRENT_MACRO_LABELID_ReadINIStrIf_END}:
!undef __CURRENT_MACRO_LABELID_ReadINIStrIf_NOCALL
!undef __CURRENT_MACRO_LABELID_ReadINIStrIf_END
!macroend

!define Call_ReadINIStrIf "!insertmacro Call_ReadINIStrIf"
!macro Call_ReadINIStrIf var ini_file ini_section ini_var
${DebugStackEnterFrame} Call_ReadINIStrIf 0 1

ClearErrors
ReadINIStr $DEBUG_RET0 "${ini_file}" "${ini_section}" "${ini_var}"

${DebugStackExitFrame} Call_ReadINIStrIf 0 1

StrCpy ${var} $DEBUG_RET0
!macroend

; status_var codes:
; 3 - read not empty from local .ini
; 2 - read not empty from command line .ini
; 1 - set not empty from command line key
; 0 - not set by command line or read from .ini
; -1 - set empty from command line key
; -2 - read empty from command line .ini
; -3 - read empty from local .ini
; -255 - set ignore because already not empty
!define LoadConfigVarIf "!insertmacro LoadConfigVarIf"
!macro LoadConfigVarIf status_var flags var cmd_option cmd_ini_file local_ini_file ini_section ini_var status_var_flags
!define __CURRENT_MACRO_LABELID_LoadConfigVarIf_NOCALL __CURRENT_MACRO_LABELID_LoadConfigVarIf_NOCALL_L${__LINE__}
!define __CURRENT_MACRO_LABELID_LoadConfigVarIf_END __CURRENT_MACRO_LABELID_LoadConfigVarIf_END_L${__LINE__}

IntCmp ${flags} 0 +2
StrCmp "${var}" "" 0 ${__CURRENT_MACRO_LABELID_LoadConfigVarIf_NOCALL}

!ifndef __UNINSTALL__
${Call_LoadConfigVarIf} "" `${status_var}` `${var}` `${cmd_option}` `${cmd_ini_file}` `${local_ini_file}` `${ini_section}` `${ini_var}`
!else
${Call_LoadConfigVarIf} "un." `${status_var}` `${var}` `${cmd_option}` `${cmd_ini_file}` `${local_ini_file}` `${ini_section}` `${ini_var}`
!endif

; set additionally status_var as flags
!if "${status_var_flags}" != ""
!if "${status_var}" == ""
!error "LoadConfigVarIf: status_var argument must be not empty!"
!endif
IntCmp ${status_var} 0 ${__CURRENT_MACRO_LABELID_LoadConfigVarIf_END} 0 +2
IntOp ${status_var_flags} ${status_var_flags} | 0x40000000 ; if has setted as empty
IntCmp ${status_var} 1 0 +3 +3
IntOp ${status_var_flags} ${status_var_flags} | 0x80000000 ; negative if has setted directly by a command line key
${Goto} ${__CURRENT_MACRO_LABELID_LoadConfigVarIf_END}
IntCmp ${status_var} 2 0 +3 +3
IntOp ${status_var_flags} ${status_var_flags} | 1
${Goto} ${__CURRENT_MACRO_LABELID_LoadConfigVarIf_END}
IntCmp ${status_var} 3 0 +3 +3
IntOp ${status_var_flags} ${status_var_flags} | 2
${Goto} ${__CURRENT_MACRO_LABELID_LoadConfigVarIf_END}
!endif

${Goto} ${__CURRENT_MACRO_LABELID_LoadConfigVarIf_END}

${__CURRENT_MACRO_LABELID_LoadConfigVarIf_NOCALL}:
; ignore status_var_flags change
StrCpy ${status_var} -255

${__CURRENT_MACRO_LABELID_LoadConfigVarIf_END}:
!undef __CURRENT_MACRO_LABELID_LoadConfigVarIf_NOCALL
!undef __CURRENT_MACRO_LABELID_LoadConfigVarIf_END
!macroend

!define Call_LoadConfigVarIf "!insertmacro Call_LoadConfigVarIf"
!macro Call_LoadConfigVarIf prefix status_var res_var cmd_option cmd_ini_file local_ini_file ini_section ini_var
${DebugStackEnterFrame} Call_LoadConfigVarIf 0 1

${PushStack5} `${cmd_option}` `${cmd_ini_file}` `${local_ini_file}` `${ini_section}` `${ini_var}`
Call ${prefix}LoadConfigVar
${PopStack2} $DEBUG_RET0 $DEBUG_RET1

${DebugStackExitFrame} Call_LoadConfigVarIf 0 1

StrCpy ${status_var} $DEBUG_RET1
!if "${var}" != ""
StrCpy ${var} $DEBUG_RET0
!endif
!macroend

!define Func_LoadConfigVar "!insertmacro Func_LoadConfigVar"
!macro Func_LoadConfigVar un
Function ${un}LoadConfigVar
  ${ExchStack5} $R0 $R1 $R2 $R3 $R4
  ;$R0 - cmd_options
  ;$R1 - cmd_ini_file
  ;$R2 - local_ini_file
  ;$R3 - ini_section
  ;$R4 - ini_var
  ${PushStack5} $R5 $R6 $R7 $R8 $R9

  ${DebugStackEnterFrame} ${un}LoadConfigVar 1 0

  StrCpy $R7 ""
  StrCpy $R8 0 ; read status

  ; read from command line key

  ; add builtin options
  ${If} $R0 != ""
    StrCpy $R0 "$R0|"
  ${EndIf}
  StrCpy $R0 "$R0$R3.$R4=|.$R4="

  ${WordFind} $R0 | "#" $R5
  ${If} ${Errors}
    StrCpy $R5 0
  ${EndIf}

  ${If} $R5 <= 0
    Goto cmd_options_end
  ${EndIf}

  ${For} $R9 1 $R5
    ${WordFind} $R0 | +$R9 $R6
    ${If} ${Errors}
      StrCpy $R6 ""
    ${EndIf}

    ${If} $R6 == ""
      ${Continue}
    ${EndIf}

    ClearErrors
    ${GetOptions} $CMDLINE $R6 $R7
    ${If} ${NoErrors}
      ; found
      ${If} $R7 != ""
        StrCpy $R8 1
      ${Else}
        StrCpy $R8 -1
      ${EndIf}
      Goto end
    ${EndIf}
  ${Next}

  cmd_options_end:

  ; read from command line .ini

  ${If} ${FileExists} "$R1"
    ClearErrors
    StrCpy $R8 0 ; make a read
    ReadINIStr $R7 "$R1" $R3 $R4
    ${If} ${NoErrors}
      ${If} $R7 != ""
        StrCpy $R8 2
      ${Else}
        StrCpy $R8 -2
      ${EndIf}
      Goto end
    ${EndIf}
  ${EndIf}

  ; read from local .ini

  ${If} ${FileExists} "$R2"
    ClearErrors
    StrCpy $R8 0 ; make a read
    ReadINIStr $R7 "$R2" $R3 $R4
    ${If} ${NoErrors}
      ${If} $R7 != ""
        StrCpy $R8 3
      ${Else}
        StrCpy $R8 -3
      ${EndIf}
      Goto end
    ${EndIf}
  ${EndIf}

  end:
  ${DebugStackExitFrame} ${un}LoadConfigVar 1 0
  ${PushStack2} $R7 $R8
  ${ExchStackStack2} 8
  ${PopStack10} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $R0 $R1
FunctionEnd
!macroend

!define Include_LoadConfigIni "!insertmacro Include_LoadConfigIni"
!macro Include_LoadConfigIni prefix
${Func_LoadConfigVar} "${prefix}"
!macroend

; dummy function implementation to enforce compilation warnings/errors in case of macro-body function calls
; (functions implemented via macroses but required compilation warnings/errors as usual functions in case of misuse them in install/uninstall sections)

!macro Func_BeginMacroBodyFunction un
!ifndef ${un}BeginMacroBodyFunction_INCLUDED
!define ${un}BeginMacroBodyFunction_INCLUDED
Function ${un}BeginMacroBodyFunction
FunctionEnd
!endif
!macroend

!macro Func_EndMacroBodyFunction un
!ifndef ${un}EndMacroBodyFunction_INCLUDED
!define ${un}EndMacroBodyFunction_INCLUDED
Function ${un}EndMacroBodyFunction
FunctionEnd
!endif
!macroend

!define Include_BeginMacroBodyFunction "!insertmacro Include_BeginMacroBodyFunction"
!macro Include_BeginMacroBodyFunction prefix
!insertmacro Func_BeginMacroBodyFunction "${prefix}"
!macroend

!define Include_EndMacroBodyFunction "!insertmacro Include_EndMacroBodyFunction"
!macro Include_EndMacroBodyFunction prefix
!insertmacro Func_EndMacroBodyFunction "${prefix}"
!macroend

!define BeginMacroBodyFunction "${Call_BeginMacroBodyFunction} ''"
!define un.BeginMacroBodyFunction "${Call_BeginMacroBodyFunction} 'un.'"

!define EndMacroBodyFunction "${Call_EndMacroBodyFunction} ''"
!define un.EndMacroBodyFunction "${Call_EndMacroBodyFunction} 'un.'"

!define Call_BeginMacroBodyFunction "!insertmacro Call_BeginMacroBodyFunction"
!macro Call_BeginMacroBodyFunction prefix
Call ${prefix}BeginMacroBodyFunction
!macroend

!define Call_EndMacroBodyFunction "!insertmacro Call_EndMacroBodyFunction"
!macro Call_EndMacroBodyFunction prefix
Call ${prefix}EndMacroBodyFunction
!macroend

!define InstallFileToDirMayReboot "!insertmacro InstallFileToDirMayReboot"
!macro InstallFileToDirMayReboot from_dir from_file to_dir to_file
${Push} `${from_dir}`
${Push} `${from_file}`
${Push} `${to_dir}`
${Push} `${to_file}`
Call InstallFileToDirMayReboot
!macroend

!define Func_InstallFileToDirMayReboot "!insertmacro Func_InstallFileToDirMayReboot"
!macro Func_InstallFileToDirMayReboot un
Function ${un}InstallFileToDirMayReboot
  ${ExchStack4} $R0 $R1 $R2 $R3
  ; $R0 - from_dir
  ; $R1 - from_file
  ; $R2 - to_dir
  ; $R3 - to_file
  ${PushStack2} $R8 $R9
  
  ${If} $R3 == ""
    StrCpy $R3 $R1
  ${EndIf}

  ${If} $R2 == ""
    StrCpy $R2 $R0
  ${EndIf}

  ${If} ${FileNotExists} "$R0\$R1"
    Goto end
  ${EndIf}
  ${If} ${FileNotExists} "$R2\*.*"
    Goto end
  ${EndIf}

  # try to copy w/o reboot
  ClearErrors
  DetailPrint "Installing: $\"$R0\$R1$\" -> $\"$R2\$R3$\""
  CopyFiles "$R0\$R1" "$R2\$R3"
  ${If} ${Errors}
    # try copy-rename w/ reboot
    ${Rnd} $R8 0 65535
    ${Rnd} $R9 0 65535
    DetailPrint "Copying: $\"$R0\$R1$\" -> $\"$R2\_reboot_$R8_$R9_$R3$\""
    ClearErrors
    CopyFiles "$R0\$R1" "$R2\_reboot_$R8_$R9_$R3"
    ${If} ${NoErrors}
      DetailPrint "Rename on reboot: $\"$R2\_reboot_$R8_$R9_$R3$\" -> $\"$R2\$R3$\""
      Rename /REBOOTOK "$R2\_reboot_$R8_$R9_$R3" "$R2\$R3"
    ${Else}
      Call AskSetupInstallAbort
    ${EndIf}
  ${EndIf}

  end:
  ${PopStack6} $R0 $R1 $R2 $R3 $R8 $R9
FunctionEnd
!macroend

!define Include_InstallFileToDirMayReboot "!insertmacro Include_InstallFileToDirMayReboot"
!macro Include_InstallFileToDirMayReboot prefix
${Include_Rnd} "${prefix}"
!insertmacro Func_InstallFileToDirMayReboot "${prefix}"
!macroend

!define FindListItem "!insertmacro FindListItem"
!macro FindListItem list separator item flags index_var
${PushStack4} `${list}` `${separator}` `${item}` `${flags}`
!ifndef __UNINSTALL__
Call FindListItem
!else
Call un.FindListItem
!endif
${PopStack1} `${index_var}`
!macroend

!define Include_FindListItem "!insertmacro Include_FindListItem"
!macro Include_FindListItem prefix
${Func_FindListItem} "${prefix}"
!macroend

!define Func_FindListItem "!insertmacro Func_FindListItem"
!macro Func_FindListItem un
Function ${un}FindListItem
  ${ExchStack4} $R0 $R1 $R2 $R3
  ; R0 - list
  ; R1 - separator
  ; R2 - item
  ; R3 - flags
  ${PushStack6} $R4 $R5 $R6 $R7 $R8 $R9

  ${If} $R0 == ""
  ${OrIf} $R1 == ""
  ${OrIf} $R2 == ""
  ${OrIf} $R3 == ""
    StrCpy $R9 -1
    Goto return
  ${EndIf}

  ${WordFind} "$R0$R1" $R1 "#" $R5
  ${If} ${Errors}
    StrCpy $R9 -1
    Goto return
  ${ElseIf} $R0 == ""
    StrCpy $R5 0
  ${EndIf}

  IntOp $R6 $R3 & 0x01 ; 0 - case insensitive
  ${If} $R6 = 0
    ${StrFilter} $R0 + "" "" $R7
    ${StrFilter} $R2 + "" "" $R8
  ${Else}
    StrCpy $R7 $R0
    StrCpy $R8 $R2
  ${EndIf}

  ${For} $R4 1 $R5
    ${WordFind} "$R7$R1" $R1 +$R4 $R9
    ${If} ${NoErrors}
      ${If} $R9 S== $R8
        IntOp $R9 $R4 - 1
        Goto return
      ${EndIf}
    ${EndIf}
  ${Next}

  StrCpy $R9 -1

  return:
  ${Push} $R9
  ${Exch} 10

  ${PopStack10} $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $R0
FunctionEnd
!macroend

# Not completed, seems variables can not store NUL characters
#!define ConvertInt32ToAnsiBE "!insertmacro ConvertInt32ToAnsiBE"
#!macro ConvertInt32ToAnsiBE int32_value out_var
#${PushStack6} $R0 $R1 $R2 $R3 $R8 $R9
#
#StrCpy $R8 "${int32_value}"
#
#IntOp $R0 $R8 & 0xFF
#IntOp $R1 $R8 >> 8
#IntOp $R1 $R1 & 0xFF
#IntOp $R2 $R8 >> 16
#IntOp $R2 $R2 & 0xFF
#IntOp $R3 $R8 >> 24
#IntOp $R3 $R3 & 0xFF
#
#IntFmt $R0 "%c" $R0
#IntFmt $R1 "%c" $R1
#IntFmt $R2 "%c" $R2
#IntFmt $R3 "%c" $R3
#
#StrCpy $R9 "$R3$R2$R1$R0"
#
#${MacroPopStack6} "${out_var}" "$R9" $R0 $R1 $R2 $R3 $R8 $R9
#!macroend

${Include_FindListItem} ""

!endif
