; variables and functions related to the 3dparty setup components

!ifndef _NSIS_SETUP_LIB_3DPARTY_NSI
!define _NSIS_SETUP_LIB_3DPARTY_NSI

!define COMPONENT_SETUP_SILENT_INSTALL_NSIS3_FLAGS "/S /L=$LANGUAGE" ; silent install flags
!define COMPONENT_SETUP_INSTALL_NSIS3_FLAGS "/L=$LANGUAGE"           ; not silent install flags

!define COMPONENT_SETUP_SILENT_INSTALL_NSIS2_FLAGS "/S /LANG=$LANG_SHORT_STR"
!define COMPONENT_SETUP_INSTALL_NSIS2_FLAGS "/LANG=$LANG_SHORT_STR"

!define COMPONENT_SETUP_SILENT_INSTALL_MSI2_FLAGS "/quite /norestart REBOOT=ReallySupress"
!define COMPONENT_SETUP_INSTALL_MSI2_FLAGS "/norestart REBOOT=ReallySupress"

!define COMPONENT_SETUP_SILENT_INSTALL_MSI3_FLAGS "/q /qn /norestart REBOOT=ReallySupress"
!define COMPONENT_SETUP_INSTALL_MSI3_FLAGS "/norestart REBOOT=ReallySupress"

!define COMPONENT_SETUP_SILENT_INSTALL_MSI_MSU_FLAGS "/quiet /norestart"
!define COMPONENT_SETUP_INSTALL_MSI_MSU_FLAGS "" ; /norestart works only with /quiet

!define COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2008_FLAGS "/q /lcid $LANGUAGE"
!define COMPONENT_SETUP_INSTALL_MSI_MSVC2008_FLAGS "/lcid $LANGUAGE"

!define COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2010_FLAGS "/q /norestart /lcid $LANGUAGE"
!define COMPONENT_SETUP_INSTALL_MSI_MSVC2010_FLAGS "/norestart /lcid $LANGUAGE"

!define COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2012_FLAGS "/q /norestart /lcid $LANGUAGE"
!define COMPONENT_SETUP_INSTALL_MSI_MSVC2012_FLAGS "/norestart /lcid $LANGUAGE"

!define COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2013_FLAGS "/q /norestart /lcid $LANGUAGE"
!define COMPONENT_SETUP_INSTALL_MSI_MSVC2013_FLAGS "/norestart /lcid $LANGUAGE"

!define COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2015_FLAGS "/q /norestart /lcid $LANGUAGE"
!define COMPONENT_SETUP_INSTALL_MSI_MSVC2015_FLAGS "/norestart /lcid $LANGUAGE"

!define COMPONENT_SETUP_SILENT_INSTALL_WISE_FLAGS "/S"
!define COMPONENT_SETUP_INSTALL_WISE_FLAGS ""

; WARNING: we must switch the installshield setup into repair mode (flag /f) in silent mode (flag /s), otherwise setup will silently cancel with 0x80042000 exit code
!define COMPONENT_SETUP_SILENT_INSTALL_INSTALLSHIELD_MSI3_FLAGS "/s /f /v$\"/q /qn /norestart REBOOT=ReallySupress$\""
!define COMPONENT_SETUP_INSTALL_INSTALLSHIELD_MSI3_FLAGS "/v$\"/norestart REBOOT=ReallySupress$\""

!define COMPONENT_SETUP_SILENT_INSTALL_INNOSETUP_FLAGS "/VERYSILENT /NOREBOOT /SUPPRESSMSGBOXES"
!define COMPONENT_SETUP_INSTALL_INNOSETUP_FLAGS "/NOREBOOT"

!define COMPONENT_SETUP_SILENT_INSTALL_WDREG_FLAGS "-silent"
!define COMPONENT_SETUP_INSTALL_WDREG_FLAGS ""

Var /GLOBAL COMPONENT_SETUP_INSTALL_NSIS2_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_NSIS3_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI2_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI3_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI_MSU_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI_MSVC2008_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI_MSVC2010_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI_MSVC2012_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI_MSVC2013_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_MSI_MSVC2015_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_WISE_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_INSTALLSHIELD_MSI3_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_INNOSETUP_FLAGS
Var /GLOBAL COMPONENT_SETUP_INSTALL_WDREG_FLAGS

!define BeginInstall3dparty "!insertmacro BeginInstall3dparty"
!macro BeginInstall3dparty
${If} $COMPONENTS_SILENT_INSTALL <> 0
  StrCpy $COMPONENT_SETUP_INSTALL_NSIS2_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_NSIS2_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_NSIS3_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_NSIS3_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI2_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI2_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI3_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI3_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSU_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI_MSU_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2008_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2008_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2010_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2010_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2012_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2012_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2013_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2013_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2015_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_MSI_MSVC2015_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_WISE_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_WISE_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_INSTALLSHIELD_MSI3_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_INSTALLSHIELD_MSI3_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_INNOSETUP_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_INNOSETUP_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_WDREG_FLAGS "${COMPONENT_SETUP_SILENT_INSTALL_WDREG_FLAGS}"
${Else}
  StrCpy $COMPONENT_SETUP_INSTALL_NSIS2_FLAGS "${COMPONENT_SETUP_INSTALL_NSIS2_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_NSIS3_FLAGS "${COMPONENT_SETUP_INSTALL_NSIS3_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI2_FLAGS "${COMPONENT_SETUP_INSTALL_MSI2_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI3_FLAGS "${COMPONENT_SETUP_INSTALL_MSI3_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSU_FLAGS "${COMPONENT_SETUP_INSTALL_MSI_MSU_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2008_FLAGS "${COMPONENT_SETUP_INSTALL_MSI_MSVC2008_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2010_FLAGS "${COMPONENT_SETUP_INSTALL_MSI_MSVC2010_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2012_FLAGS "${COMPONENT_SETUP_INSTALL_MSI_MSVC2012_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2013_FLAGS "${COMPONENT_SETUP_INSTALL_MSI_MSVC2013_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_MSI_MSVC2015_FLAGS "${COMPONENT_SETUP_INSTALL_MSI_MSVC2015_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_WISE_FLAGS "${COMPONENT_SETUP_INSTALL_WISE_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_INSTALLSHIELD_MSI3_FLAGS "${COMPONENT_SETUP_INSTALL_INSTALLSHIELD_MSI3_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_INNOSETUP_FLAGS "${COMPONENT_SETUP_INSTALL_INNOSETUP_FLAGS}"
  StrCpy $COMPONENT_SETUP_INSTALL_WDREG_FLAGS "${COMPONENT_SETUP_INSTALL_WDREG_FLAGS}"
${EndIf}
!macroend

!endif
