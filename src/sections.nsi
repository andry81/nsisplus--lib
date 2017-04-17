!ifndef _NSIS_SETUP_LIB_SECTIONS_NSI
!define _NSIS_SETUP_LIB_SECTIONS_NSI

!include "${SETUP_LIBS_ROOT}\_NsisSetupLib\src\utils.nsi"

#!define SECTIONS_INTERNAL_DEBUG 1
!ifdef SECTIONS_INTERNAL_DEBUG
Var /GLOBAL SELECTION_TREE_FLAGS
!endif

!define IsSectionSelected "!insertmacro IsSectionSelected"
!macro IsSectionSelected var section
${PushStack1} $R0

SectionGetFlags `${section}` $R0
IntOp $R0 $R0 & ${SF_SELECTED}
${If} $R0 <> 0
  ${Push} 1
${Else}
  ${Push} 0
${EndIf}

${Exch} 1

${PopStack1} $R0

${Pop} `${var}`
!macroend

!define IsSectionUnselected "!insertmacro IsSectionUnselected"
!macro IsSectionUnselected var section
${IsSectionSelected} `${var}` `${section}`
IntOp `${var}` `${var}` !
!macroend

!define IsSectionVisible "!insertmacro IsSectionVisible"
!macro IsSectionVisible var section
${PushStack1} $R0

SectionGetText `${section}` $R0
${If} $R0 != ""
  ${Push} 1
${Else}
  ${Push} 0
${EndIf}

${Exch} 1

${PopStack1} $R0

${Pop} `${var}`
!macroend

!define IsSectionHidden "!insertmacro IsSectionHidden"
!macro IsSectionHidden var section
${PushStack1} $R0

SectionGetText `${section}` $R0
${If} $R0 == ""
  ${Push} 1
${Else}
  ${Push} 0
${EndIf}

${Exch} 1

${PopStack1} $R0

${Pop} `${var}`
!macroend

!define GotoIfSectionHidden "!insertmacro GotoIfSectionHidden"
!macro GotoIfSectionHidden to section
${IsSectionHidden} $GOTO_R0 `${section}`
${GotoIf} `${to}` "$GOTO_R0 <> 0"
!macroend

!define IsSectionSelectedAndVisible "!insertmacro IsSectionSelectedAndVisible"
!macro IsSectionSelectedAndVisible var section
${PushStack2} $R0 $R1

SectionGetFlags `${section}` $R0
IntOp $R0 $R0 & ${SF_SELECTED}
SectionGetText `${section}` $R1

${If} $R0 <> 0
${AndIf} $R0 != ""
  ${Push} 1
${Else}
  ${Push} 0
${EndIf}

${Exch} 2

${PopStack2} $R1 $R0

${Pop} `${var}`
!macroend

!define SectionIsSelectedAndVisible "'' SectionIsSelectedAndVisible"
!macro _SectionIsSelectedAndVisible _a _b _t _f
  !define _SectionIsSelectedAndVisible__LABELID_END _SectionIsSelectedAndVisible__LABELID_END_L${__LINE__}
  !define _SectionIsSelectedAndVisible__LABELID_FALSE _SectionIsSelectedAndVisible__LABELID_FALSE_L${__LINE__}

  ${PushStack2} $R0 $R1

  SectionGetFlags `${_b}` $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  SectionGetText `${_b}` $R1

  IntCmp $R0 0 ${_SectionIsSelectedAndVisible__LABELID_FALSE}
  StrCmp $R1 "" ${_SectionIsSelectedAndVisible__LABELID_FALSE}

  ${PopStack2} $R0 $R1 
  #${Goto} `${_t}` ; _t is not defined!
  ${Goto} ${_SectionIsSelectedAndVisible__LABELID_END}

  ${_SectionIsSelectedAndVisible__LABELID_FALSE}:
  ${PopStack2} $R0 $R1
  ${Goto} `${_f}`

  ${_SectionIsSelectedAndVisible__LABELID_END}:
  !undef _SectionIsSelectedAndVisible__LABELID_END
  !undef _SectionIsSelectedAndVisible__LABELID_FALSE
!macroend

!define IsSectionSubSelected "!insertmacro IsSectionSubSelected"
!macro IsSectionSubSelected var section
${PushStack2} $R0 $R1

SectionGetFlags `${section}` $R0
IntOp $R1 ${SF_SELECTED} | ${SF_PSELECTED}
IntOp $R1 $R0 & $R1
${If} $R1 <> 0
  ${Push} 1
${Else}
  ${Push} 0
${EndIf}

${Exch} 2

${PopStack2} $R1 $R0

${Pop} `${var}`
!macroend

!define SelectSection "!insertmacro SafeSelectSection"
!macro SafeSelectSection section
${PushStack1} $R0

SectionGetText `${section}` $R0
${If} $R0 != "" ; if not hidden
  ${UnsafeSelectSection} `${section}`
${EndIf}

${PopStack1} $R0
!macroend

!define UnselectSection "!insertmacro SafeUnselectSection"
!macro SafeUnselectSection section
${PushStack1} $R0

SectionGetText `${section}` $R0
${If} $R0 != "" ; if not hidden
  ${UnsafeUnselectSection} `${section}`
${EndIf}

${PopStack1} $R0
!macroend

!define UnsafeSelectSectionAll "!insertmacro UnsafeSelectSectionAll"
!macro UnsafeSelectSectionAll section
${PushStack2} $R0 $R1

SectionGetFlags `${section}` $R0
IntOp $R1 ${SF_PSELECTED} ~
IntOp $R0 $R0 & $R1
IntOp $R0 $R0 | ${SF_SELECTED}
SectionSetFlags `${section}` $R0

${PopStack2} $R0 $R1
!macroend

!define UnsafeSelectSection "!insertmacro UnsafeSelectSection"
!macro UnsafeSelectSection section
!insertmacro SelectSection `${section}`
!macroend

!define UnsafeUnselectSection "!insertmacro UnsafeUnselectSection"
!macro UnsafeUnselectSection section
!insertmacro UnselectSection `${section}`
!macroend

!define UnsafeUnselectSectionAll "!insertmacro UnsafeUnselectSectionAll"
!macro UnsafeUnselectSectionAll section
${PushStack2} $R0 $R1

SectionGetFlags `${section}` $R0
IntOp $R1 ${SF_SELECTED} | ${SF_PSELECTED}
IntOp $R1 $R1 ~
IntOp $R0 $R0 & $R1
SectionSetFlags `${section}` $R0

${PopStack2} $R0 $R1
!macroend

!define EnableSection "!insertmacro EnableSection"
!macro EnableSection section state
${PushStack2} $R0 $R1

; avoid disable of hidden sections, must be already shown to avoid parent partial selection issue
SectionGetText `${section}` $R1 ; ignore hidden items
${If} $R1 != ""
  ${If} ${state} <> 0
    SectionGetFlags `${section}` $R0
    IntOp $R1 ${SF_RO} ~
    IntOp $R0 $R0 & $R1
    SectionSetFlags `${section}` $R0
  ${Else}
    SectionGetFlags `${section}` $R0
    IntOp $R0 $R0 | ${SF_RO}
    SectionSetFlags `${section}` $R0
  ${EndIf}
${EndIf}

${PopStack2} $R0 $R1
!macroend

; CAUTION:
;   1. Show/Hide section must be executed in a page PRE function, not in the SHOW function!
;   2. section still CAN be executed (because can be selected) even if hidden, so is required to call the IsSectionHidden/IsSectionVisible (GotoIfSectionHidden)
;      inside the section and bypass section execution if true.
!define ShowSection "!insertmacro ShowSection"
!macro ShowSection section text
${If} "${text}" != "" ; avoid section hide if name is empty
  ${PushStack2} $R0 $R1

  SectionGetText `${section}` $R1 ; ignore already shown items
  ${If} $R1 == ""
    ; make it show
    SectionSetText `${section}` "${text}"

    ; drop name change flag because the name was not actually changed
    SectionGetFlags `${section}` $R0
    IntOp $R1 ${SF_NAMECHG} ~
    IntOp $R0 $R0 & $R1
    SectionSetFlags `${section}` $R0
  ${EndIf}

  ${PopStack2} $R0 $R1
${EndIf}
!macroend

!define ShowSectionDef "!insertmacro ShowSectionDef"
!macro ShowSectionDef text_var_and_section_var_prefix
${ShowSection} ${${text_var_and_section_var_prefix}_SECTION} "${${text_var_and_section_var_prefix}}"
!macroend

!define HideSection "!insertmacro HideSection"
!macro HideSection section
${PushStack2} $R0 $R1

SectionGetText `${section}` $R1 ; ignore already hidden items
${If} $R1 != ""
  ; remove readonly (overwise the parent will interfere with partial selection) and selection at first
  SectionGetFlags `${section}` $R0
  IntOp $R1 ${SF_RO} ~
  IntOp $R1 $R1 & ${SECTION_OFF}
  IntOp $R0 $R0 & $R1
  SectionSetFlags `${section}` $R0

  ; make it hide
  SectionSetText `${section}` ""

  ; drop name change flag because the name was not actually changed
  SectionGetFlags `${section}` $R0
  IntOp $R1 ${SF_NAMECHG} ~
  IntOp $R0 $R0 & $R1
  SectionSetFlags `${section}` $R0
${EndIf}

${PopStack2} $R0 $R1
!macroend

!define SelectUpdateSectionText "!insertmacro SelectUpdateSectionText"
!macro SelectUpdateSectionText section text
${If} "${text}" != "" ; avoid section hide if name is empty
  ${PushStack1} $R0

  ; avoid enable of hidden sections, must be already shown to avoid parent partial selection issue
  SectionGetText `${section}` $R0 ; ignore hidden items
  ${If} $R0 != ""
    ${UnsafeSelectSection} `${section}`
    SectionSetText `${section}` `${text}`
  ${EndIf}

  ${PopStack1} $R0
${EndIf}
!macroend

; section text safe update without section accidental hide
!define UpdateSectionText "!insertmacro UpdateSectionText"
!macro UpdateSectionText section text
${If} "${text}" != "" ; avoid section hide if name is empty
  ${PushStack1} $R0

  ; avoid enable of hidden sections, must be already shown to avoid parent partial selection issue
  SectionGetText `${section}` $R0 ; ignore hidden items
  ${If} $R0 != ""
  ${AndIf} $R0 S!= "${text}" ; avoid set of SF_NAMECHG in case if text was not actually changed
    SectionSetText `${section}` `${text}`
  ${EndIf}

  ${PopStack1} $R0
${EndIf}
!macroend

!define IsSectionGroupNextSelectionImpl "!insertmacro IsSectionGroupNextSelectionImpl"
!macro IsSectionGroupNextSelectionImpl section_var
!if "${section_var}" != ""
SectionGetText `${${section_var}}` $R0 ; ignore hidden items
${If} $R0 != ""
  SectionGetFlags `${${section_var}}` $R0
  IntOp $R8 ${SF_SELECTED} | ${SF_PSELECTED}
  IntOp $R3 $R0 & ${SF_SELECTED}
  IntOp $R4 $R0 & $R8
  ${If} $R3 = 0
    StrCpy $R1 0 ; by '&' with 0
  ${EndIf}
  ${If} $R4 <> 0
    StrCpy $R2 1 ; by '|' with 1
  ${EndIf}

  IntOp $R9 $R9 + 1
  !ifdef SECTIONS_INTERNAL_DEBUG
  StrCpy $SELECTION_TREE_FLAGS "$SELECTION_TREE_FLAGS:$R0"
${Else}
  SectionGetFlags `${${section_var}}` $R0
  StrCpy $SELECTION_TREE_FLAGS "$SELECTION_TREE_FLAGS:h$R0"
  !endif
${EndIf}
!endif
!macroend

!define IsSectionGroupSelected_ImplBegin "!insertmacro IsSectionGroupSelected_ImplBegin"
!macro IsSectionGroupSelected_ImplBegin
${PushStack7} $R0 $R1 $R2 $R3 $R4 $R8 $R9

StrCpy $R1 1 ; by '&' for children items 'SF_SELECTED'
StrCpy $R2 0 ; by '|' for children items 'SF_SELECTED | SF_PSELECTED'
StrCpy $R9 0 ; counter of not hidden items
!macroend

!define IsSectionGroupSelected_ImplEnd "!insertmacro IsSectionGroupSelected_ImplEnd"
!macro IsSectionGroupSelected_ImplEnd var
${If} $R9 <> 0
  ${If} $R1 <> 0
    ${Push} 1 ; visible items (excluding hidden) are all selected
  ${ElseIf} $R2 = 0
    ${Push} 0 ; visible items (excluding hidden) are all unselected
  ${Else}
    ${Push} -1 ; visible items (excluding hidden) are partial selected
  ${EndIf}
${Else}
  ${Push} -2 ; all children are hidden
${EndIf}

${Exch} 7

${PopStack7} $R1 $R2 $R3 $R4 $R8 $R9 $R0

${Pop} `${var}`
!macroend

!define IsSectionGroupSelected1 "!insertmacro IsSectionGroupSelected1"
!macro IsSectionGroupSelected1 var sec0
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected2 "!insertmacro IsSectionGroupSelected2"
!macro IsSectionGroupSelected2 var sec0 sec1
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected3 "!insertmacro IsSectionGroupSelected3"
!macro IsSectionGroupSelected3 var sec0 sec1 sec2
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected4 "!insertmacro IsSectionGroupSelected4"
!macro IsSectionGroupSelected4 var sec0 sec1 sec2 sec3
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected5 "!insertmacro IsSectionGroupSelected5"
!macro IsSectionGroupSelected5 var sec0 sec1 sec2 sec3 sec4
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected6 "!insertmacro IsSectionGroupSelected6"
!macro IsSectionGroupSelected6 var sec0 sec1 sec2 sec3 sec4 sec5
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected7 "!insertmacro IsSectionGroupSelected7"
!macro IsSectionGroupSelected7 var sec0 sec1 sec2 sec3 sec4 sec5 sec6
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected8 "!insertmacro IsSectionGroupSelected8"
!macro IsSectionGroupSelected8 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected9 "!insertmacro IsSectionGroupSelected9"
!macro IsSectionGroupSelected9 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected10 "!insertmacro IsSectionGroupSelected10"
!macro IsSectionGroupSelected10 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupNextSelectionImpl} `${sec9}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected11 "!insertmacro IsSectionGroupSelected11"
!macro IsSectionGroupSelected11 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupNextSelectionImpl} `${sec9}`
${IsSectionGroupNextSelectionImpl} `${sec10}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected12 "!insertmacro IsSectionGroupSelected12"
!macro IsSectionGroupSelected12 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupNextSelectionImpl} `${sec9}`
${IsSectionGroupNextSelectionImpl} `${sec10}`
${IsSectionGroupNextSelectionImpl} `${sec11}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected13 "!insertmacro IsSectionGroupSelected13"
!macro IsSectionGroupSelected13 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupNextSelectionImpl} `${sec9}`
${IsSectionGroupNextSelectionImpl} `${sec10}`
${IsSectionGroupNextSelectionImpl} `${sec11}`
${IsSectionGroupNextSelectionImpl} `${sec12}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected14 "!insertmacro IsSectionGroupSelected14"
!macro IsSectionGroupSelected14 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12 sec13
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupNextSelectionImpl} `${sec9}`
${IsSectionGroupNextSelectionImpl} `${sec10}`
${IsSectionGroupNextSelectionImpl} `${sec11}`
${IsSectionGroupNextSelectionImpl} `${sec12}`
${IsSectionGroupNextSelectionImpl} `${sec13}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected15 "!insertmacro IsSectionGroupSelected15"
!macro IsSectionGroupSelected15 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12 sec13 sec14
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupNextSelectionImpl} `${sec9}`
${IsSectionGroupNextSelectionImpl} `${sec10}`
${IsSectionGroupNextSelectionImpl} `${sec11}`
${IsSectionGroupNextSelectionImpl} `${sec12}`
${IsSectionGroupNextSelectionImpl} `${sec13}`
${IsSectionGroupNextSelectionImpl} `${sec14}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define IsSectionGroupSelected16 "!insertmacro IsSectionGroupSelected16"
!macro IsSectionGroupSelected16 var sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12 sec13 sec14 sec15
${IsSectionGroupSelected_ImplBegin}
${IsSectionGroupNextSelectionImpl} `${sec0}`
${IsSectionGroupNextSelectionImpl} `${sec1}`
${IsSectionGroupNextSelectionImpl} `${sec2}`
${IsSectionGroupNextSelectionImpl} `${sec3}`
${IsSectionGroupNextSelectionImpl} `${sec4}`
${IsSectionGroupNextSelectionImpl} `${sec5}`
${IsSectionGroupNextSelectionImpl} `${sec6}`
${IsSectionGroupNextSelectionImpl} `${sec7}`
${IsSectionGroupNextSelectionImpl} `${sec8}`
${IsSectionGroupNextSelectionImpl} `${sec9}`
${IsSectionGroupNextSelectionImpl} `${sec10}`
${IsSectionGroupNextSelectionImpl} `${sec11}`
${IsSectionGroupNextSelectionImpl} `${sec12}`
${IsSectionGroupNextSelectionImpl} `${sec13}`
${IsSectionGroupNextSelectionImpl} `${sec14}`
${IsSectionGroupNextSelectionImpl} `${sec15}`
${IsSectionGroupSelected_ImplEnd} `${var}`
!macroend

!define UpdateSectionGroupSelection_ImplBegin "!insertmacro UpdateSectionGroupSelection_ImplBegin"
!macro UpdateSectionGroupSelection_ImplBegin ctx_type group_section_var
${PushStack2} $R0 $R1

!ifdef SECTIONS_INTERNAL_DEBUG
SectionGetFLAGS `${${group_section_var}}` $R1
StrCpy $SELECTION_TREE_FLAGS "${ctx_type}->${group_section_var} $R1:"
!endif
!macroend

!define UpdateSectionGroupSelection_ImplEnd "!insertmacro UpdateSectionGroupSelection_ImplEnd"
!macro UpdateSectionGroupSelection_ImplEnd ctx_type group_section_var unhide_with_group_section_text var
${Switch} "${ctx_type}"
  ${Case} "pre"
    ${If} ${var} >= -1
      ; ShowSection with new text
      ${If} "${unhide_with_group_section_text}" != ""
        SectionGetText `${${group_section_var}}` $R1 ; ignore hidden items
        ${If} $R1 == ""
          !ifdef SECTIONS_INTERNAL_DEBUG
          MessageBox MB_OK "UpdateSectionGroupSelection: Before: ${ctx_type}->${group_section_var}: Show Section (${var}): $\"${unhide_with_group_section_text}$\""
          !endif

          SectionSetText `${${group_section_var}}` `${unhide_with_group_section_text}`
        ${EndIf}
      ${EndIf}
    ${Else}
      ${HideSection} `${${group_section_var}}`
    ${EndIf}
    ${Break}

  ${Case} "show"
  ${Case} "change"
  ${Default}
    ${If} ${var} > 0
      ; Select group section for "All Selected"
      SectionGetText `${${group_section_var}}` $R1 ; ignore hidden items
      ${If} $R1 != ""
        !ifdef SECTIONS_INTERNAL_DEBUG
        MessageBox MB_OK "UpdateSectionGroupSelection: Before: (${var}) ${ctx_type}->${group_section_var}: Full Select"
        !endif

        ${UnsafeSelectSectionAll} `${${group_section_var}}`
      ${EndIf}
    ${ElseIf} ${var} = 0
      !ifdef SECTIONS_INTERNAL_DEBUG
      MessageBox MB_OK "UpdateSectionGroupSelection: Before: (${var}) ${ctx_type}->${group_section_var}: Full Unselect"
      !endif

      ; Unselect group section for "Not Selected"
      ${UnsafeUnselectSectionAll} `${${group_section_var}}`
    ${EndIf}
    ${Break}
${EndSwitch}

!ifdef SECTIONS_INTERNAL_DEBUG
MessageBox MB_OK "UpdateSectionGroupSelection: After: (${var}) $SELECTION_TREE_FLAGS"
!endif

${PopStack2} $R0 $R1
!macroend

!define UpdateSectionGroupSelection1 "!insertmacro UpdateSectionGroupSelection1"
!macro UpdateSectionGroupSelection1 ctx_type group_section_var unhide_with_group_section_text sec0
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected1} $R0 `${sec0}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection2 "!insertmacro UpdateSectionGroupSelection2"
!macro UpdateSectionGroupSelection2 ctx_type group_section_var unhide_with_group_section_text sec0 sec1
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected2} $R0 `${sec0}` `${sec1}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection3 "!insertmacro UpdateSectionGroupSelection3"
!macro UpdateSectionGroupSelection3 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected3} $R0 `${sec0}` `${sec1}` `${sec2}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection4 "!insertmacro UpdateSectionGroupSelection4"
!macro UpdateSectionGroupSelection4 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected4} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection5 "!insertmacro UpdateSectionGroupSelection5"
!macro UpdateSectionGroupSelection5 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected5} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection6 "!insertmacro UpdateSectionGroupSelection6"
!macro UpdateSectionGroupSelection6 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected6} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection7 "!insertmacro UpdateSectionGroupSelection7"
!macro UpdateSectionGroupSelection7 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected7} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection8 "!insertmacro UpdateSectionGroupSelection8"
!macro UpdateSectionGroupSelection8 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected8} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection9 "!insertmacro UpdateSectionGroupSelection9"
!macro UpdateSectionGroupSelection9 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected9} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection10 "!insertmacro UpdateSectionGroupSelection10"
!macro UpdateSectionGroupSelection10 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected10} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}` `${sec9}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection11 "!insertmacro UpdateSectionGroupSelection11"
!macro UpdateSectionGroupSelection11 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected11} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}` `${sec9}` `${sec10}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection12 "!insertmacro UpdateSectionGroupSelection12"
!macro UpdateSectionGroupSelection12 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected12} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}` `${sec9}` `${sec10}` `${sec11}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection13 "!insertmacro UpdateSectionGroupSelection13"
!macro UpdateSectionGroupSelection13 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected13} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}` `${sec9}` `${sec10}` `${sec11}` `${sec12}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection14 "!insertmacro UpdateSectionGroupSelection14"
!macro UpdateSectionGroupSelection14 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12 sec13
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected14} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}` `${sec9}` `${sec10}` `${sec11}` `${sec12}` `${sec13}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection15 "!insertmacro UpdateSectionGroupSelection15"
!macro UpdateSectionGroupSelection15 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12 sec13 sec14
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected15} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}` `${sec9}` `${sec10}` `${sec11}` `${sec12}` `${sec13}` `${sec14}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!define UpdateSectionGroupSelection16 "!insertmacro UpdateSectionGroupSelection16"
!macro UpdateSectionGroupSelection16 ctx_type group_section_var unhide_with_group_section_text sec0 sec1 sec2 sec3 sec4 sec5 sec6 sec7 sec8 sec9 sec10 sec11 sec12 sec13 sec14 sec15
${UpdateSectionGroupSelection_ImplBegin} `${ctx_type}` `${group_section_var}`
${IsSectionGroupSelected16} $R0 `${sec0}` `${sec1}` `${sec2}` `${sec3}` `${sec4}` `${sec5}` `${sec6}` `${sec7}` `${sec8}` `${sec9}` `${sec10}` `${sec11}` `${sec12}` `${sec13}` `${sec14}` `${sec15}`
${UpdateSectionGroupSelection_ImplEnd} `${ctx_type}` `${group_section_var}` `${unhide_with_group_section_text}` $R0
!macroend

!endif
