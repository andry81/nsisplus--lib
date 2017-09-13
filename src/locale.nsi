!ifndef _NSIS_SETUP_LIB_LOCALE_NSI
!define _NSIS_SETUP_LIB_LOCALE_NSI

!include "${_NSIS_SETUP_LIB_ROOT}\src\stack.nsi"

!define LC_ALL          0
!define LC_COLLATE      1
!define LC_CTYPE        2
!define LC_MONETARY     3
!define LC_NUMERIC      4
!define LC_TIME         5

!define LC_MIN          LC_ALL
!define LC_MAX          LC_TIME

!define Func_GetLanguageStringsFromLCID "!insertmacro Func_GetLanguageStringsFromLCID"
!macro Func_GetLanguageStringsFromLCID un
Function ${un}GetLanguageStringsFromLCID
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

      ${DetailPrint} "GetLanguageStringsFromLCID: unsupported LCID: $\"$R0$\""
      MessageBox MB_OK "GetLanguageStringsFromLCID: unsupported LCID: $\"$R0$\" (${__FILE__}:${__LINE__})" /SD IDOK
  ${EndSwitch}

  ${PopPushStack4} "$R1 $R2 $R3" " " $R0 $R1 $R2 $R3
FunctionEnd
!macroend

!define GetLanguageStringsFromLCID "!insertmacro GetLanguageStringsFromLCID"
!macro GetLanguageStringsFromLCID var_group_country var_short var_long lcid
${Push} `${lcid}`
!ifndef __UNINSTALL__
Call GetLanguageStringsFromLCID
!else
Call un.GetLanguageStringsFromLCID
!endif
${Pop} `${var_long}`
${Pop} `${var_short}`
${Pop} `${var_group_country}`
!macroend

!define Include_GetLanguageStringsFromLCID "!insertmacro Include_GetLanguageStringsFromLCID"
!macro Include_GetLanguageStringsFromLCID un
!ifndef ${un}GetLanguageStringsFromLCID_INCLUDED
!define ${un}GetLanguageStringsFromLCID_INCLUDED
${Func_GetLanguageStringsFromLCID} "${un}"
!endif
!macroend

!define Func_GetCharsetFromLCIDPair "!insertmacro Func_GetCharsetFromLCIDPair"
!macro Func_GetCharsetFromLCIDPair un
Function ${un}GetCharsetFromLCIDPair
  ${ExchStack2} $R0 $R1
  ;R0 - first_lcid
  ;R1 - second_lcid
  ${PushStack2} $R8 $R9

  ; sort LCIDs
  ${If} $R0 < $R1
    StrCpy $R8 "$R0;$R1"
  ${Else}
    StrCpy $R8 "$R1;$R0"
  ${EndIf}

  ${Switch} $R8
    ${Case} "1033;1049" ; english + russian
      StrCpy $R9 1251
      ${Break}
    ${Default}
      StrCpy $R9 ""

      ${DetailPrint} "GetCharsetFromLCIDPair: unsupported LCID: $\"$R0$\""
      MessageBox MB_OK "GetLanguageStringsFromLCID: unsupported LCID: $\"$R0$\" (${__FILE__}:${__LINE__})" /SD IDOK
  ${EndSwitch}

  ${PopPushStack4} "$R9" " " $R0 $R1 $R8 $R9
FunctionEnd
!macroend

!define GetCharsetFromLCIDPair "!insertmacro GetCharsetFromLCIDPair"
!macro GetCharsetFromLCIDPair var_charset first_lcid second_lcid
${Push} `${first_lcid}`
${Push} `${second_lcid}`
!ifndef __UNINSTALL__
Call GetCharsetFromLCIDPair
!else
Call un.GetCharsetFromLCIDPair
!endif
${Pop} `${var_charset}`
!macroend

!define Include_GetCharsetFromLCIDPair "!insertmacro Include_GetCharsetFromLCIDPair"
!macro Include_GetCharsetFromLCIDPair un
!ifndef ${un}GetCharsetFromLCIDPair_INCLUDED
!define ${un}GetCharsetFromLCIDPair_INCLUDED
${Func_GetCharsetFromLCIDPair} "${un}"
!endif
!macroend

!endif
