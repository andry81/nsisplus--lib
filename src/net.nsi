!ifndef _NSIS_SETUP_LIB_NET_NSI
!define _NSIS_SETUP_LIB_NET_NSI

!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\utils.nsi"

!define ERROR_NETWORK_UNREACHABLE 1231
!define ERROR_HOST_UNREACHABLE 1232

!define Func_GetComputerName "!insertmacro Func_GetComputerName"
!macro Func_GetComputerName un
Function ${un}GetComputerName
  ${PushStack2} $R0 $R1

  #${ReadRegStr} $R0 HKLM "System\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName"

  IpConfig::GetHostName
  ${Pop} $R0
  ${Pop} $R1
  ${If} $R0 == "ok"
    ${Push} $R1
  ${Else}
    ${Push} ""
  ${EndIf}
  ${Exch} 2

  ${PopStack2} $R1 $R0
FunctionEnd
!macroend

!define Call_GetComputerName "!insertmacro Call_GetComputerName"
!macro Call_GetComputerName prefix name_var
Call ${prefix}GetComputerName
${Pop} ${name_var}
!macroend

!define GetComputerName "!insertmacro GetComputerName"
!macro GetComputerName
!insertmacro Func_GetComputerName ""
!undef GetComputerName
!define GetComputerName "!insertmacro Call_GetComputerName ''"
!macroend

!define un.GetComputerName "!insertmacro un.GetComputerName"
!macro un.GetComputerName
!insertmacro Func_GetComputerName "un."
!undef un.GetComputerName
!define un.GetComputerName "!insertmacro Call_GetComputerName 'un.'"
!macroend

!define GetPrimaryIP4OfFirstEnabledAdapter "!insertmacro GetPrimaryIP4OfFirstEnabledAdapter"
!macro GetPrimaryIP4OfFirstEnabledAdapter var_ip var_subnet default_ip default_subnet
${Push} ${default_ip}
${Push} ${default_subnet}
Call GetPrimaryIP4OfFirstEnabledAdapter
${Pop} ${var_subnet}
${Pop} ${var_ip}
!macroend

Function GetPrimaryIP4OfFirstEnabledAdapter
  ${ExchStack2} $R0 $R1
  ; $R0 - default_ip
  ; $R1 - default_subnet

  ${PushStack10} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1
  ; $R2 - overall ip counter
  ; $R3 - index of ip selection
  ; $R4 - overall subnet counter
  ; 
  ; $R5 - adapter ID
  ; 
  ; $R6 - selected ip
  ; $R7 - selected subnet
  ; 
  ; $R8 - last callback
  ; $R9 - last ip/subnet
  ; $0  - temp
  ; $1  - temp

  StrCpy $R2 0 ; ip counter reset
  StrCpy $R3 0 ; ip index reset
  StrCpy $R4 0 ; subnet counter reset

  StrCpy $R6 "" ; default return ip value
  StrCpy $R7 "" ; default return subnet value

  GetFunctionAddress $R8 __GetPrimaryIP4OfFirstEnabledAdapter_NetworkAdapterCB
  IpConfig::GetEnabledNetworkAdaptersIDsCB $R8
  ${Pop} $NULL ; ok
  ${Pop} $NULL ; Number of results: N

  ${Push} $R6 ; ip
  ${Exch} 12
  ${Push} $R7 ; subnet
  ${Exch} 12

  ${PopStack12} $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9 $0 $1 $R0 $R1
FunctionEnd

Function __GetPrimaryIP4OfFirstEnabledAdapter_NetworkAdapterCB
  ${Pop} $R5

  GetFunctionAddress $R8 __GetPrimaryIP4OfFirstEnabledAdapter_IPAddressCB
  IpConfig::GetNetworkAdapterIPAddressesCB $R5 $R8
  ${Pop} $NULL ; ok
  ${Pop} $NULL ; ?

  GetFunctionAddress $R8 __GetPrimaryIP4OfFirstEnabledAdapter_IPSubnetCB
  IpConfig::GetNetworkAdapterIPSubNetsCB $R5 $R8
  ${Pop} $NULL ; ok
  ${Pop} $NULL ; Number of results: N
FunctionEnd

Function __GetPrimaryIP4OfFirstEnabledAdapter_IPAddressCB
  ${Pop} $R9
  
  ; always remember first by default
  ${If} $R2 <> 0
    ${If} $R0 != ""
    ${AndIf} $R0 == $R9
      StrCpy $R6 $R9
      IntOp $R3 $R2 + 0
    ${Else}
      ; check on IP equality with subnet mask
      ${GetSubnetMaskedInetIP4} $R0 $R1 $0
      ${GetSubnetMaskedInetIP4} $R9 $R1 $1
      ${If} $0 == $1
        StrCpy $R6 $R9
        IntOp $R3 $R2 + 0
      ${EndIf}
    ${EndIf}
  ${Else}
    StrCpy $R6 $R9
    IntOp $R3 $R2 + 0
  ${EndIf}

  IntOp $R2 $R2 + 1
FunctionEnd

Function __GetPrimaryIP4OfFirstEnabledAdapter_IPSubnetCB
  ${Pop} $R9

  ; select subnet by ip selection index
  ${If} $R4 = $R3
    StrCpy $R7 $R9
  ${EndIf}

  IntOp $R4 $R4 + 1
FunctionEnd

!endif
