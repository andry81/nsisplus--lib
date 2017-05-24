; GUI operations

!ifndef _NSIS_SETUP_LIB_GUI_NSI
!define _NSIS_SETUP_LIB_GUI_NSI

Var /GLOBAL ClientDlg_HWnd
Var /Global ClientDlg_left
Var /Global ClientDlg_top
Var /Global ClientDlg_right
Var /Global ClientDlg_bottom
Var /Global ClientDlg_width
Var /Global ClientDlg_height

Var /GLOBAL OutRect_left
Var /GLOBAL OutRect_top
Var /GLOBAL OutRect_right
Var /GLOBAL OutRect_bottom
Var /GLOBAL OutRect_width
Var /GLOBAL OutRect_height

Var /GLOBAL InRect_left
Var /GLOBAL InRect_top
Var /GLOBAL InRect_right
Var /GLOBAL InRect_bottom
Var /GLOBAL InRect_width
Var /GLOBAL InRect_height

Var /GLOBAL NextRect_left
Var /GLOBAL NextRect_top
Var /GLOBAL NextRect_right
Var /GLOBAL NextRect_bottom
Var /GLOBAL NextRect_width
Var /GLOBAL NextRect_height

; CAUTION:
;   nsDialogs::Show and nsDialogs.nsh functions forms differed stack frame, we have to use stack wrapper functions to use common window procedure over differed stack frames!
;   redefine nsDialogs.nsh definitions to avoid usage broken macro functions directly.

!define /redef NSD_Check "!insertmacro NSD_SafeCheck"
!macro NSD_SafeCheck id
${GUIWindowProcBeginMarkerFrame} NSD_SafeCheck 0

!insertmacro __NSD_Check "${id}"

${GUIWindowProcEndMarkerFrame} NSD_SafeCheck 0
!macroend

!define /redef NSD_Uncheck "!insertmacro NSD_SafeUncheck"
!macro NSD_SafeUncheck id
${GUIWindowProcBeginMarkerFrame} NSD_SafeUncheck 0

!insertmacro __NSD_Uncheck "${id}"

${GUIWindowProcEndMarkerFrame} NSD_SafeUncheck 0
!macroend

!define /redef NSD_GetState "!insertmacro NSD_SafeGetState"
!macro NSD_SafeGetState id var
${GUIWindowProcBeginMarkerFrame} NSD_SafeGetState 0

!insertmacro __NSD_GetState "${id}" ${var}

${GUIWindowProcEndMarkerFrame} NSD_SafeGetState 0
!macroend

!define /redef NSD_SetState "!insertmacro NSD_SafeSetState"
!macro NSD_SafeSetState id state
${GUIWindowProcBeginMarkerFrame} NSD_SafeSetState 0

!insertmacro __NSD_SetState "${id}" "${state}"

${GUIWindowProcEndMarkerFrame} NSD_SafeSetState 0
!macroend

!define /redef NSD_GetText "!insertmacro NSD_SafeGetText"
!macro NSD_SafeGetText id var
${GUIWindowProcBeginMarkerFrame} NSD_SafeGetText 0

!insertmacro __NSD_GetText "${id}" ${var}

${GUIWindowProcEndMarkerFrame} NSD_SafeGetText 0
!macroend

!define /redef NSD_SetText "!insertmacro NSD_SafeSetText"
!macro NSD_SafeSetText id text
${GUIWindowProcBeginMarkerFrame} NSD_SafeSetText 0

!insertmacro __NSD_SetText "${id}" "${text}"

${GUIWindowProcEndMarkerFrame} NSD_SafeSetText 0
!macroend

!define /redef NSD_SetTextLimit "!insertmacro NSD_SafeSetTextLimit"
!macro NSD_SafeSetTextLimit id limit
${GUIWindowProcBeginMarkerFrame} NSD_SafeSetTextLimit 0

!insertmacro _NSD_SetTextLimit "${id}" "${limit}"

${GUIWindowProcEndMarkerFrame} NSD_SafeSetTextLimit 0
!macroend

!define /redef NSD_SetFocus "!insertmacro NSD_SafeSetFocus"
!macro NSD_SafeSetFocus hwnd
${GUIWindowProcBeginMarkerFrame} NSD_SafeSetFocus 0

!insertmacro __NSD_SetFocus "${hwnd}"

${GUIWindowProcEndMarkerFrame} NSD_SafeSetFocus 0
!macroend

; CB

!define /redef NSD_CB_SelectString "!insertmacro NSD_CB_SafeSelectString"
!macro NSD_CB_SafeSelectString id str
${GUIWindowProcBeginMarkerFrame} NSD_CB_SafeSelectString 0

!insertmacro _NSD_CB_SelectString "${id}" "${str}"

${GUIWindowProcEndMarkerFrame} NSD_CB_SafeSelectString 0
!macroend

!define /redef NSD_CB_GetSelection "!insertmacro NSD_CB_SafeGetSelection"
!macro NSD_CB_SafeGetSelection id var
${GUIWindowProcBeginMarkerFrame} NSD_CB_SafeGetSelection 0

!insertmacro __NSD_CB_GetSelection_Call "${id}" ${var}

${GUIWindowProcEndMarkerFrame} NSD_CB_SafeGetSelection 0
!macroend

!define /redef NSD_CB_AddString "!insertmacro NSD_CB_SafeAddString"
!macro NSD_CB_SafeAddString id str
${GUIWindowProcBeginMarkerFrame} NSD_CB_SafeAddString 0

!insertmacro _NSD_CB_AddString "${id}" "${str}"

${GUIWindowProcEndMarkerFrame} NSD_CB_SafeAddString 0
!macroend

!define /redef NSD_CB_DelString "!insertmacro NSD_CB_SafeDelString"
!macro NSD_CB_SafeDelString id str
${GUIWindowProcBeginMarkerFrame} NSD_CB_SafeDelString 0

!insertmacro __NSD_CB_DelString_Call "${id}" "${str}"

${GUIWindowProcEndMarkerFrame} NSD_CB_SafeDelString 0
!macroend

!define /redef NSD_CB_GetCount "!insertmacro NSD_CB_SafeGetCount"
!macro NSD_CB_SafeGetCount id var
${GUIWindowProcBeginMarkerFrame} NSD_CB_SafeGetCount 0

!insertmacro __NSD_CB_GetCount "${id}" ${var}

${GUIWindowProcEndMarkerFrame} NSD_CB_SafeGetCount 0
!macroend

!define /redef NSD_CB_Clear "!insertmacro NSD_CB_SafeClear"
!macro NSD_CB_SafeClear id
${GUIWindowProcBeginMarkerFrame} NSD_CB_SafeClear 0

!insertmacro __NSD_CB_Clear "${id}"

${GUIWindowProcEndMarkerFrame} NSD_CB_SafeClear 0
!macroend

; LB

!define /redef NSD_LB_SelectString "!insertmacro NSD_LB_SafeSelectString"
!macro NSD_LB_SafeSelectString id str
${GUIWindowProcBeginMarkerFrame} NSD_LB_SafeSelectString 0

!insertmacro _NSD_LB_SelectString "${id}" "${str}"

${GUIWindowProcEndMarkerFrame} NSD_LB_SafeSelectString 0
!macroend

!define /redef NSD_LB_GetSelection "!insertmacro NSD_LB_SafeGetSelection"
!macro NSD_LB_SafeGetSelection id var
${GUIWindowProcBeginMarkerFrame} NSD_LB_SafeGetSelection 0

!insertmacro __NSD_LB_GetSelection "${id}" ${var}

${GUIWindowProcEndMarkerFrame} NSD_LB_SafeGetSelection 0
!macroend

!define /redef NSD_LB_AddString "!insertmacro NSD_LB_SafeAddString"
!macro NSD_LB_SafeAddString id str
${GUIWindowProcBeginMarkerFrame} NSD_LB_SafeAddString 0

!insertmacro __NSD_LB_AddString "${id}" "${str}"

${GUIWindowProcEndMarkerFrame} NSD_LB_SafeAddString 0
!macroend

!define /redef NSD_LB_DelString "!insertmacro NSD_LB_SafeDelString"
!macro NSD_LB_SafeDelString id str
${GUIWindowProcBeginMarkerFrame} NSD_LB_SafeDelString 0

!insertmacro __NSD_LB_DelString_Call "${id}" "${str}"

${GUIWindowProcEndMarkerFrame} NSD_LB_SafeDelString 0
!macroend

!define /redef NSD_LB_GetCount "!insertmacro NSD_LB_SafeGetCount"
!macro NSD_LB_SafeGetCount id var
${GUIWindowProcBeginMarkerFrame} NSD_LB_SafeGetCount 0

!insertmacro __NSD_LB_GetCount "${id}" ${var}

${GUIWindowProcEndMarkerFrame} NSD_LB_SafeGetCount 0
!macroend

!define /redef NSD_LB_Clear "!insertmacro NSD_LB_SafeClear"
!macro NSD_LB_SafeClear id var
${GUIWindowProcBeginMarkerFrame} NSD_LB_SafeClear 0

!insertmacro __NSD_LB_Clear "${id}" ${var}

${GUIWindowProcEndMarkerFrame} NSD_LB_SafeClear 0
!macroend

; LV

!define /redef NSD_LV_InsertColumn "!insertmacro NSD_LV_SafeInsertColumn"
!macro NSD_LV_SafeInsertColumn id col x text
${GUIWindowProcBeginMarkerFrame} NSD_LV_SafeInsertColumn 0

!insertmacro __NSD_LV_InsertColumn_Call "${id}" "${col}" "${x}" "${text}"

${GUIWindowProcEndMarkerFrame} NSD_LV_SafeInsertColumn 0
!macroend

!define /redef NSD_LV_SetItemText "!insertmacro NSD_LV_SafeSetItemText"
!macro NSD_LV_SafeSetItemText id item sub_item text
${GUIWindowProcBeginMarkerFrame} NSD_LV_SafeSetItemText 0

!insertmacro __NSD_LV_SetItemText_Call "${id}" "${item}" "${sub_item}" "${text}"

${GUIWindowProcEndMarkerFrame} NSD_LV_SafeSetItemText 0
!macroend

!define SkipPage "!insertmacro SkipPage"
!macro SkipPage
; TODO: Abort has double meaning in different places, so to avoid accidental call SkipPage from inappropriate places
;       do set a condition for the Abort to call from the GUI function

Abort ; uncondition call
!macroend

; nsDialogs::Create may crash after Abort (not Quit!) call, because call to Abort from the Show calls Show on the next page, which calls to the nsDialog::Create again.
; To avoid such bugged condition DO NOT call skip loging before the nsDialog::Create call!
!define GUIDialogCreate "!insertmacro GUIDialogCreate"
!macro GUIDialogCreate var_id hwnd_var on_back_func_name
nsDialogs::Create 1018
${Pop} `${var_id}`

; always reget dialog window handle and sizes
FindWindow ${hwnd_var} "#32770" "" $HWNDPARENT
StrCpy $GUI_MAIN_DIALOG_LAST_HWND ${hwnd_var} ; save HWND of last created dialog
${GetClientRect} ${hwnd_var} $ClientDlg_left $ClientDlg_top $ClientDlg_right $ClientDlg_bottom $ClientDlg_width $ClientDlg_height

${If} "${var_id}" == "error"
  ${!Quit} ; quit on error
${EndIf}

!if "${on_back_func_name}" != ""
${NSD_OnBack} "${on_back_func_name}" ; works only after nsDialog::Create
!endif
!macroend

!define GUIUpdateControls "!insertmacro GUIUpdateControls"
!macro GUIUpdateControls update_func
; init registers
StrCpy $R0 0  ; window handle, 0 - if first time update
StrCpy $R1 0  ; window message id
StrCpy $R2 "" ; wparam
StrCpy $R3 "" ; lparam
; first time update
Call ${update_func}
!macroend

!define GUIDialogsShow "!insertmacro GUIDialogsShow"
!macro GUIDialogsShow code_id
  ; CAUTION:
  ;   nsDialogs::Show and nsDialogs.nsh functions forms differed stack frame, we have to use stack wrapper functions to use common window procedure over differed stack frames!
  ${GUIDialogsShowBeginMarkerFrame} ${code_id} 0

  nsDialogs::Show

  ${GUIDialogsShowEndMarkerFrame} ${code_id} 0
!macroend

!define GUIAddStyle "!insertmacro GUIAddStyle"
!macro GUIAddStyle id_var style
${DebugStackEnterFrame} GUIAddStyle 0 0

!if "${style}" != ""
${PushStack3} $R0 $R1 $R2

${StrFilter} "${style}" 12 "" " " $R0
${If} "${style}" != $R0
  ${WordFind} "${style} " " " "#" $R1
  ${If} ${Errors}
  ${OrIf} "${style}" == ""
    StrCpy $R1 0
  ${EndIf}

  ${For} $R0 1 $R1
    ${WordFind} "${style} " " " +$R0 $R2
    ${If} ${Errors}
      StrCpy $R2 ""
    ${EndIf}

    ${NSD_AddStyle} ${id_var} $R2
  ${Next}
${Else}
  ${NSD_AddStyle} ${id_var} "${style}"
${EndIf}

${PopStack3} $R0 $R1 $R2
!endif

${DebugStackExitFrame} GUIAddStyle 0 0
!macroend

!define GUIRemoveStyle "!insertmacro GUIRemoveStyle"
!macro GUIRemoveStyle id_var style
${DebugStackEnterFrame} GUIRemoveStyle 0 0

!if "${style}" != ""
${PushStack3} $R0 $R1 $R2

${StrFilter} "${style}" 12 "" " " $R0
${If} "${style}" != $R0
  ${WordFind} "${style} " " " "#" $R1
  ${If} ${Errors}
  ${OrIf} "${style}" == ""
    StrCpy $R1 0
  ${EndIf}

  ${For} $R0 1 $R1
    ${WordFind} "${style} " " " +$R0 $R2
    ${If} ${Errors}
      StrCpy $R2 ""
    ${EndIf}

    ${NSD_RemoveStyle} ${id_var} $R2
  ${Next}
${Else}
  ${NSD_RemoveStyle} ${id_var} "${style}"
${EndIf}

${PopStack3} $R0 $R1 $R2
!endif

${DebugStackExitFrame} GUIRemoveStyle 0 0
!macroend

; NSD_Check/NSD_Uncheck/NSD_GetState (for RadioButton ONLY)
!define GUISetRadioButtonState "!insertmacro GUISetRadioButtonState"
!macro GUISetRadioButtonState id state handler
${DebugStackEnterFrame} GUISetRadioButtonState 0 0

${Switch} ${state}
  ${Case} ${BST_CHECKED}
    ${NSD_Check} "${id}"
!if "${handler}" != ""
    ${PushStack4} $R0 $R1 $R2 $R3
    StrCpy $R0 "${id}"  ; window handle
    StrCpy $R1 0        ; window message id
    StrCpy $R2 ""       ; wparam
    StrCpy $R3 ""       ; lparam
    Call ${handler}
    ${PopStack4} $R0 $R1 $R2 $R3
!endif
  ${Break}
  ${Case} ${BST_UNCHECKED}
    ${NSD_Uncheck} "${id}"
!if "${handler}" != ""
    ${PushStack4} $R0 $R1 $R2 $R3
    StrCpy $R0 "${id}"  ; window handle
    StrCpy $R1 0        ; window message id
    StrCpy $R2 ""       ; wparam
    StrCpy $R3 ""       ; lparam
    Call ${handler}
    ${PopStack4} $R0 $R1 $R2 $R3
!endif
  ${Break}
${EndSwitch}

${DebugStackExitFrame} GUISetRadioButtonState 0 0
!macroend

!define GUISetGetRadioButtonState "!insertmacro GUISetGetRadioButtonState"
!macro GUISetGetRadioButtonState id state var handler
${DebugStackEnterFrame} GUISetGetRadioButtonState 0 0

${GUISetRadioButtonState} "${id}" "${state}" "${handler}"
${NSD_GetState} "${id}" ${var}

${DebugStackExitFrame} GUISetGetRadioButtonState 0 0
!macroend

!define GUISetGetRadioButtonStateVar "!insertmacro GUISetGetRadioButtonStateVar"
!macro GUISetGetRadioButtonStateVar id state_var handler
${GUISetGetRadioButtonState} ${id} ${state_var} ${state_var} ${handler}
!macroend

; NSD_SetState/NSD_GetState (for example, CheckBox)
!define GUISetState "!insertmacro GUISetState"
!macro GUISetState id state
${DebugStackEnterFrame} GUISetState 0 0

${NSD_SetState} "${id}" "${state}"

${DebugStackExitFrame} GUISetState 0 0
!macroend

!define GUISetGetState "!insertmacro GUISetGetState"
!macro GUISetGetState id state var
${DebugStackEnterFrame} GUISetGetState 0 0

${GUISetState} "${id}" "${state}"
${NSD_GetState} "${id}" ${var}

${DebugStackExitFrame} GUISetGetState 0 0
!macroend

!define GUISetGetStateVar "!insertmacro GUISetGetStateVar"
!macro GUISetGetStateVar id state_var
${GUISetGetState} ${id} ${state_var} ${state_var}
!macroend

; NSD_SetText/NSD_GetText (for example, Label/EditBox)
!define GUISetText "!insertmacro GUISetText"
!macro GUISetText id text
${DebugStackEnterFrame} GUISetText 0 0

${NSD_SetText} "${id}" "${text}"

${DebugStackExitFrame} GUISetText 0 0
!macroend

!define GUISetGetText "!insertmacro GUISetGetText"
!macro GUISetGetText id text var
${DebugStackEnterFrame} GUISetGetText 0 0

${GUISetText} ${id} "${text}"
${NSD_GetText} "${id}" ${var}

${DebugStackExitFrame} GUISetGetText 0 0
!macroend

!define GUISetGetTextVar "!insertmacro GUISetGetTextVar"
!macro GUISetGetTextVar id text_var
${GUISetGetText} ${id} "${text_var}" ${text_var}
!macroend

; NSD_CB_SelectString/NSD_GetText (for example, ComboBox/ListBox)
!define GUISelectComboBoxText "!insertmacro GUISelectComboBoxText"
!macro GUISelectComboBoxText id text
${DebugStackEnterFrame} GUISelectComboBoxText 0 0

${NSD_CB_SelectString} "${id}" "${text}"

${DebugStackExitFrame} GUISelectComboBoxText 0 0
!macroend

!define GUISelectGetComboBoxText "!insertmacro GUISelectGetComboBoxText"
!macro GUISelectGetComboBoxText id text var
${DebugStackEnterFrame} GUISelectGetComboBoxText 0 0

${GUISelectComboBoxText} ${id} "${text}"
${NSD_GetText} "${id}" ${var}

${DebugStackExitFrame} GUISelectGetComboBoxText 0 0
!macroend

!define GUISelectGetComboBoxTextVar "!insertmacro GUISelectGetComboBoxTextVar"
!macro GUISelectGetComboBoxTextVar id text_var
${GUISelectGetComboBoxText} ${id} "${text_var}" ${text_var}
!macroend

!define GUIInsertGroupBox "!insertmacro GUIInsertGroupBox"
!macro GUIInsertGroupBox left top width height label id_var
${DebugStackEnterFrame} GUIInsertGroupBox 0 0

${NSD_CreateGroupBox} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GetGroupBoxInnerClientRect} ${id_var} $ClientDlg_left $ClientDlg_top $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height
${GetClientRect} ${id_var} $OutRect_left $OutRect_top $OutRect_right $OutRect_bottom $OutRect_width $OutRect_height

${DebugStackExitFrame} GUIInsertGroupBox 0 0
!macroend

!define GUIInsertLabel "!insertmacro GUIInsertLabel"
!macro GUIInsertLabel left top width height label id_var style
${DebugStackEnterFrame} GUIInsertLabel 0 0

${NSD_CreateLabel} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertLabel 0 0
!macroend

!define GUIInsertText "!insertmacro GUIInsertText"
!macro GUIInsertText left top width height label id_var text_limit style
${DebugStackEnterFrame} GUIInsertText 0 0

${NSD_CreateText} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
!if "${text_limit}" != ""
${NSD_SetTextLimit} ${id_var} "${text_limit}"
!endif
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertText 0 0
!macroend

!define GUIInsertComboBox "!insertmacro GUIInsertComboBox"
!macro GUIInsertComboBox left top width height label id_var text_limit style
${DebugStackEnterFrame} GUIInsertComboBox 0 0

${NSD_CreateComboBox} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
!if "${text_limit}" != ""
${NSD_SetTextLimit} ${id_var} "${text_limit}"
!endif
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertComboBox 0 0
!macroend

!define GUIInsertDropList "!insertmacro GUIInsertDropList"
!macro GUIInsertDropList left top width height label id_var text_limit style
${DebugStackEnterFrame} GUIInsertDropList 0 0

${NSD_CreateDropList} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
!if "${text_limit}" != ""
${NSD_SetTextLimit} ${id_var} "${text_limit}"
!endif
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertDropList 0 0
!macroend

!define GUIInsertListBox "!insertmacro GUIInsertListBox"
!macro GUIInsertListBox left top width height label id_var text_limit style
${DebugStackEnterFrame} GUIInsertListBox 0 0

${NSD_CreateListBox} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
!if "${text_limit}" != ""
${NSD_SetTextLimit} ${id_var} ${text_limit}
!endif
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertListBox 0 0
!macroend

!define GUIInsertRadioButton "!insertmacro GUIInsertRadioButton"
!macro GUIInsertRadioButton left top width height label id_var state style
${DebugStackEnterFrame} GUIInsertRadioButton 0 0

${NSD_CreateRadioButton} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
!if "${state}" != ""
${NSD_SetState} ${id_var} "${state}"
!endif
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertRadioButton 0 0
!macroend

!define GUIInsertCheckbox "!insertmacro GUIInsertCheckbox"
!macro GUIInsertCheckbox left top width height label id_var state style
${DebugStackEnterFrame} GUIInsertCheckbox 0 0

${NSD_CreateCheckbox} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
!if "${state}" != ""
${NSD_SetState} ${id_var} "${state}"
!endif
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertCheckbox 0 0
!macroend

!define GUIInsertListView "!insertmacro GUIInsertListView"
!macro GUIInsertListView left top width height label id_var style
${DebugStackEnterFrame} GUIInsertListView 0 0

${NSD_CreateListView} ${left} ${top} ${width} ${height} "${label}"
${Pop} ${id_var}
${GUIAddStyle} ${id_var} "${style}"
${GetClientRect} ${id_var} $InRect_left $InRect_top $InRect_right $InRect_bottom $InRect_width $InRect_height

${DebugStackExitFrame} GUIInsertListView 0 0
!macroend

!define GUISetNextRect "!insertmacro GUISetNextRect"
!macro GUISetNextRect left top right bottom
!if "${left}" != ""
IntOp $NextRect_left ${left} + 0
!endif
!if "${top}" != ""
IntOp $NextRect_top ${top} + 0
!endif
!if "${right}" != ""
IntOp $NextRect_right ${right} + 0
!endif
!if "${bottom}" != ""
IntOp $NextRect_bottom ${bottom} + 0
!endif
!macroend

!define GUIOffsetNextRect "!insertmacro GUIOffsetNextRect"
!macro GUIOffsetNextRect left top right bottom
!if "${left}" != ""
IntOp $NextRect_left $NextRect_left + ${left}
!endif
!if "${top}" != ""
IntOp $NextRect_top $NextRect_top + ${top}
!endif
!if "${right}" != ""
IntOp $NextRect_right $NextRect_right + ${right}
!endif
!if "${bottom}" != ""
IntOp $NextRect_bottom $NextRect_bottom + ${bottom}
!endif
!macroend

!define GUIPushNextRect "!insertmacro GUIPushNextRect"
!macro GUIPushNextRect
${PushStack4} $NextRect_left $NextRect_top $NextRect_right $NextRect_bottom
!macroend

!define GUIPopNextRect "!insertmacro GUIPopNextRect"
!macro GUIPopNextRect
${PopStack4} $NextRect_left $NextRect_top $NextRect_right $NextRect_bottom
!macroend

!define GUISetNextRectFromInRect "!insertmacro GUISetNextRectFromInRect"
!macro GUISetNextRectFromInRect left top right bottom
!if "${left}" != ""
IntOp $NextRect_left $InRect_left + ${left}
!else
IntOp $NextRect_left $InRect_left + 0
!endif
!if "${top}" != ""
IntOp $NextRect_top $InRect_top + ${top}
!else
IntOp $NextRect_top $InRect_top +  0
!endif
!if "${right}" != ""
IntOp $NextRect_right $InRect_right + ${right}
!else
IntOp $NextRect_right $InRect_right + 0
!endif
!if "${bottom}" != ""
IntOp $NextRect_bottom $InRect_bottom + ${bottom}
!else
IntOp $NextRect_bottom $InRect_bottom + 0
!endif

IntOp $NextRect_width $InRect_right - $InRect_left
IntOp $NextRect_height $InRect_bottom - $InRect_top
!macroend

!define GUISetNextRectFromOutRect "!insertmacro GUISetNextRectFromOutRect"
!macro GUISetNextRectFromOutRect left top right bottom
!if "${left}" != ""
IntOp $NextRect_left $OutRect_left + ${left}
!else
IntOp $NextRect_left $OutRect_left + 0
!endif
!if "${top}" != ""
IntOp $NextRect_top $OutRect_top + ${top}
!else
IntOp $NextRect_top $OutRect_top + 0
!endif
!if "${right}" != ""
IntOp $NextRect_right $OutRect_right + ${right}
!else
IntOp $NextRect_right $OutRect_right + 0
!endif
!if "${bottom}" != ""
IntOp $NextRect_bottom $OutRect_bottom + ${bottom}
!else
IntOp $NextRect_bottom $OutRect_bottom + 0
!endif

IntOp $NextRect_width $OutRect_right - $OutRect_left
IntOp $NextRect_height $OutRect_bottom - $OutRect_top
!macroend

!define EnableNextButton "!insertmacro EnableNextButton"
!macro EnableNextButton var enable
${DebugStackEnterFrame} EnableNextButton 0 1

${Push} `${enable}`
Call EnableNextButton
${Pop} $DEBUG_RET0

${DebugStackExitFrame} EnableNextButton 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

Function EnableNextButton
  ${ExchStack1} $R1
  ;R1 - enable
  ${PushStack1} $R2

  ${DebugStackEnterFrame} EnableNextButton 1 0

  GetDlgItem $R2 $HWNDPARENT 1 ; next/install=1, cancel=2, back=3
  EnableWindow $R2 $R1

  ${DebugStackExitFrame} EnableNextButton 1 0

  ${PopPushStack2} "$R1" " " $R1 $R2
FunctionEnd

!define GetNextButtonText "!insertmacro GetNextButtonText"
!macro GetNextButtonText var
${DebugStackEnterFrame} GetNextButtonText 0 1

Call GetNextButtonText
${Pop} $DEBUG_RET0

${DebugStackExitFrame} GetNextButtonText 0 1

StrCpy `${var}` $DEBUG_RET0
!macroend

Function GetNextButtonText
  ${PushStack2} $R1 $R2

  ${DebugStackEnterFrame} GetNextButtonText 1 0

  GetDlgItem $R2 $HWNDPARENT 1 ; next/install=1, cancel=2, back=3
  ${NSD_GetText} $R2 $R1

  ${DebugStackExitFrame} GetNextButtonText 1 0

  ${PopPushStack2} "$R1" " " $R1 $R2
FunctionEnd

!define SetNextButtonText "!insertmacro SetNextButtonText"
!macro SetNextButtonText text
${DebugStackEnterFrame} SetNextButtonText 0 1

${Push} `${text}`
Call SetNextButtonText

${DebugStackExitFrame} SetNextButtonText 0 1
!macroend

Function SetNextButtonText
  ${ExchStack1} $R1
  ;R1 - text
  ${PushStack1} $R2

  ${DebugStackEnterFrame} SetNextButtonText 1 0

  GetDlgItem $R2 $HWNDPARENT 1 ; next/install=1, cancel=2, back=3
  ${GUISetText} $R2 $R1

  ${DebugStackExitFrame} SetNextButtonText 1 0

  ${PopStack2} $R1 $R2
FunctionEnd

!define GetGroupBoxInnerClientRect "!insertmacro GetGroupBoxInnerClientRect"
!macro GetGroupBoxInnerClientRect winId origin_left origin_top left top right bottom width height
${!error_if_list_in_list} "GetGroupBoxInnerClientRect: arguments already used as intermediate storage" "$R0 $R1" S== "${left} ${top} ${right} ${bottom} ${width} ${height}" " " ; space separated

${PushStack2} $R0 $R1

${DebugStackEnterFrame} GetGroupBoxInnerClientRect 0 0

${GetClientRect} `${winId}` `${left}` `${top}` `${right}` `${bottom}` `${width}` `${height}`
${GetWindowTextHeight} `${winId}` $R0

IntOp $R1 $R0 + 8

IntOp `${left}`   `${left}` - `${origin_left}`
IntOp `${right}`  `${right}` - `${origin_left}`
IntOp `${top}`    `${top}` - `${origin_top}`
IntOp `${bottom}` `${bottom}` - `${origin_top}`

IntOp `${left}`   `${left}` + 12
IntOp `${right}`  `${right}` - 12
IntOp `${top}`    `${top}` + $R0
IntOp `${bottom}` `${bottom}` - 8
IntOp `${width}` `${width}` - 24
IntOp `${height}` `${height}` - $R1

${DebugStackExitFrame} GetGroupBoxInnerClientRect 0 0

${PopStack2} $R0 $R1
!macroend

!define GetWindowRect "!insertmacro GetWindowRect"
!macro GetWindowRect winId left top right bottom width height
${!error_if_list_in_list} "GetWindowRect: arguments already used as intermediate storage" "$R1 $R2 $R3 $R4 $R5 $R6 $R7" S== "${left} ${top} ${right} ${bottom} ${width} ${height}" " " ; space separated

${PushStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R7

${DebugStackEnterFrame} GetWindowRect 0 0

${Push} `${winId}`
Call GetWindowRect

StrCpy `${left}`    $R2
StrCpy `${top}`     $R3
StrCpy `${right}`   $R4
StrCpy `${bottom}`  $R5
StrCpy `${width}`   $R6
StrCpy `${height}`  $R7

${DebugStackExitFrame} GetWindowRect 0 0

${PopStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R7
!macroend

Function GetWindowRect
  System::Call "User32::GetWindowRect(i s, @ R1)"
  System::Call "*$R1(i.R2, i.R3, i.R4, i.R5)"
  IntOp $R6 $R4 - $R2
  IntOp $R7 $R5 - $R3
FunctionEnd

!define GetClientRect "!insertmacro GetClientRect"
!macro GetClientRect winId left top right bottom width height
${!error_if_list_in_list} "GetClientRect: arguments already used as intermediate storage" "$R1 $R2 $R3 $R4 $R5 $R6 $R7" S== "${left} ${top} ${right} ${bottom} ${width} ${height}" " " ; space separated

${PushStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R7

${DebugStackEnterFrame} GetClientRect 0 0

${Push} `${winId}`
Call GetClientRect

StrCpy `${left}`    $R2
StrCpy `${top}`     $R3
StrCpy `${right}`   $R4
StrCpy `${bottom}`  $R5
StrCpy `${width}`   $R6
StrCpy `${height}`  $R7

${DebugStackExitFrame} GetClientRect 0 0

${PopStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R7
!macroend

Function GetClientRect
  System::Call "User32::GetWindowRect(p s, @ R1)"
  System::Call "User32::MapWindowPoints(p 0, p $HWNDPARENT, p R1, i 2)"
  System::Call "*$R1(i.R2, i.R3, i.R4, i.R5)"
  IntOp $R6 $R4 - $R2
  IntOp $R7 $R5 - $R3
FunctionEnd

!define GetWindowWidthHeight "!insertmacro GetWindowWidthHeight"
!macro GetWindowWidthHeight winId width_var height_var
${DebugStackEnterFrame} GetWindowWidthHeight 0 1

${Push} `${winId}`
Call GetWindowWidthHeight
${Pop} $DEBUG_RET0
${Pop} $DEBUG_RET1

${DebugStackExitFrame} GetWindowWidthHeight 0 1

StrCpy `${width_var}` $DEBUG_RET0
StrCpy `${height_var}` $DEBUG_RET1
!macroend

Function GetWindowWidthHeight
  ${ExchStack1} $R0
  ; R0 - winId
  ${PushStack7} $R1 $R2 $R3 $R4 $R5 $R6 $R9

  ${DebugStackEnterFrame} GetWindowWidthHeight 1 0

  System::Call "User32::GetWindowRect(p R0, @ R9)"
  System::Call "*$R9(i.R1, i.R2, i.R3, i.R4)"
  IntOp $R5 $R3 - $R1
  IntOp $R6 $R4 - $R2

  ${DebugStackExitFrame} GetWindowWidthHeight 1 0

  ${PopPushStack8} "$R6 $R5" " " $R0 $R1 $R2 $R3 $R4 $R5 $R6 $R9
FunctionEnd

!define GetWindowTextHeight "!insertmacro GetWindowTextHeight"
!macro GetWindowTextHeight winId height_var
${DebugStackEnterFrame} GetWindowTextHeight 0 1

${Push} `${winId}`
Call GetWindowTextHeight
${Pop} $DEBUG_RET0

${DebugStackExitFrame} GetWindowTextHeight 0 1

StrCpy `${height_var}` $DEBUG_RET0
!macroend

Function GetWindowTextHeight
  ${ExchStack1} $R0
  ; $R0 - winId
  ${PushStack3} $R1 $R2 $R3

  ${DebugStackEnterFrame} GetWindowTextHeight 1 0

  ; get text height by window DC
  System::Call "User32::GetDC(p R0) p .R1"
  System::Call "Gdi32::GetTextMetrics(p R1, @ R2)"
  System::Call "*$R2(i.R3)" ; TEXTMETRIC structure
  System::Call "User32::ReleaseDC(p R0, p R1)"

  ${DebugStackExitFrame} GetWindowTextHeight 1 0

  ${PopPushStack4} "$R3" " " $R0 $R1 $R2 $R3
FunctionEnd

!define GUIConvertUnitPointsToPixels "!insertmacro GUIConvertUnitPointsToPixels"
!macro GUIConvertUnitPointsToPixels pixels_var winId unit_points dim
${DebugStackEnterFrame} GUIConvertUnitPointsToPixels 0 1

${Push} `${winId}`
${Push} `${unit_points}`
${Push} `${dim}`
Call GUIConvertUnitPointsToPixels
${Pop} $DEBUG_RET0

${DebugStackExitFrame} GUIConvertUnitPointsToPixels 0 1

StrCpy `${pixels_var}` $DEBUG_RET0
!macroend

Function GUIConvertUnitPointsToPixels
  ${ExchStack3} $R0 $R1 $R2
  ; $R0 - winId
  ; $R1 - unit_points
  ; $R2 - dimension
  ${PushStack2} $R8 $R9

  ${DebugStackEnterFrame} GUIConvertUnitPointsToPixels 1 0

  ; Create temporary label to read it's width as converted value
  ${If} $R2 == "x"
  ${OrIf} $R2 = 0
    ${NSD_CreateLabel} 0 -10 $R1 10 " "
    ${Pop} $R8
    ShowWindow $R8 ${SW_HIDE} ; avoid control show
    ${GetWindowWidthHeight} $R8 $R9 $NULL
    System::Call "user32::DestroyWindow(i R8)"
  ${Else}
    ${If} $R2 == "y"
    ${OrIf} $R2 = 1
      ${NSD_CreateLabel} 0 -$R1 10 $R1 " "
      ${Pop} $R8
      ShowWindow $R8 ${SW_HIDE} ; avoid control show
      ${GetWindowWidthHeight} $R8 $NULL $R9
      System::Call "user32::DestroyWindow(i R8)"
    ${Else}
      StrCpy $R8 1
    ${EndIf}
  ${EndIf}

  ${DebugStackExitFrame} GUIConvertUnitPointsToPixels 1 0

  ${PopPushStack5} "$R9" " " $R0 $R1 $R2 $R8 $R9
FunctionEnd

!define ColorRGB2BGR "!insertmacro ColorRGB2BGR"
!macro ColorRGB2BGR color_var
${PushStack4} $R0 $R1 $R2 $R9

StrCpy $R0 ${color_var}

IntOp $R1 $R0 & 0xFF
IntOp $R1 $R1 << 16
IntOp $R2 $R0 & 0xFF00
IntOp $R1 $R1 | $R2
IntOp $R2 $R0 & 0xFF0000
IntOp $R2 $R2 >> 16
IntOp $R9 $R1 | $R2

${MacroPopStack4} "${color_var}" "$R9" $R0 $R1 $R2 $R9
!macroend

; SetCtlColors replacement because of the issue in the implementation: https://sourceforge.net/p/nsis/bugs/1161/
Function SetWindowClassCtlColors
  ${ExchStack4} $R0 $R1 $R2 $R5
  ; R0 - control id
  ; R1 - text color
  ; R2 - background color
  ; R5 - input buffer
  ${PushStack2} $R8 $R9

  ${If} $R1 != ""
    ${ColorRGB2BGR} $R1

    ${If} $R2 != ""
    ${AndIf} $R2 != "transparent"
      ${ColorRGB2BGR} $R2

      ${If} $R5 != ""
      ${AndIf} $R5 <> 0
        System::Call "*$R5(i,i,i,i,i,i) ($R1,$R2,${BS_SOLID},0,${OPAQUE},${CC_TEXT}|${CC_BK}|${CC_BKB})"
        StrCpy $R9 0 ; not allocated
      ${Else}
        System::Call "*(i,i,i,i,i,i)p ($R1,$R2,${BS_SOLID},0,${OPAQUE},${CC_TEXT}|${CC_BK}|${CC_BKB}) .R9"
        StrCpy $R5 $R9 ; allocated
      ${EndIf}
    ${Else}
      ${If} $R5 != ""
      ${AndIf} $R5 <> 0
        ; reuse already allocated buffer
        System::Call "*$R5(i,i,i,i,i,i) ($R1,0,${BS_NULL},0,${TRANSPARENT},${CC_TEXT}|${CC_BKB})"
        StrCpy $R9 0 ; not allocated
      ${Else}
        ; allocate new buffer
        System::Call "*(i,i,i,i,i,i)p ($R1,0,${BS_NULL},0,${TRANSPARENT},${CC_TEXT}|${CC_BKB}) .R9"
        StrCpy $R5 $R9 ; allocated
      ${EndIf}
    ${EndIf}

    System::Call "user32::SetWindowLong(p,i,l)l ($R0, ${GWL_USERDATA}, $R5) .R8"

    ${PopPushStack6} "$R9 $R8" " " $R0 $R1 $R2 $R5 $R8 $R9
  ${Else}
    ${If} $R2 != ""
    ${AndIf} $R2 != transparent
      ${ColorRGB2BGR} $R2

      ${If} $R5 != ""
      ${AndIf} $R5 <> 0
        System::Call "*$R5(i,i,i,i,i,i) (0,$R2,${BS_SOLID},0,${OPAQUE},${CC_BK}|${CC_BKB})"
        StrCpy $R9 0 ; not allocated
      ${Else}
        System::Call "*(i,i,i,i,i,i)p (0,$R2,${BS_SOLID},0,${OPAQUE},${CC_BK}|${CC_BKB}) .R9"
        StrCpy $R5 $R9 ; allocated
      ${EndIf}

      System::Call "user32::SetWindowLong(p,i,l)l ($R0, ${GWL_USERDATA}, $R5) .R8"

      ${PopPushStack6} "$R9 $R8" " " $R0 $R1 $R2 $R5 $R8 $R9
    ${Else}
      ; not allocated and not set
      ${PopPushStack6} "0 -1" " " $R0 $R1 $R2 $R5 $R8 $R9
    ${EndIf}
  ${EndIf}
FunctionEnd

!define SetWindowClassCtlColors "!insertmacro SetWindowClassCtlColors"
!macro SetWindowClassCtlColors id text bg in_buffer out_buffer_var old_userdata_var
${PushStack4} `${id}` `${text}` `${bg}` `${in_buffer}`

Call SetWindowClassCtlColors

!if "${old_userdata_var}" != ""
  ${Pop} `${old_userdata_var}`
!else
  ${Pop} $NULL
!endif
!if "${out_buffer_var}" != ""
  ${Pop} `${out_buffer_var}`
!else
  ${Pop} $NULL
!endif
!macroend

!define UpdateWindowClassCtlColors "!insertmacro UpdateWindowClassCtlColors"
!macro UpdateWindowClassCtlColors id text bg inout_buffer_var old_userdata_var
${If} "${inout_buffer_var}" != ""
${AndIf} "${inout_buffer_var}" <> 0
  ; old_userdata_var must have previous User Data here
  ${SetWindowClassCtlColors} `${id}` `${text}` `${bg}` `${inout_buffer_var}` "" ""
${Else}
  ${SetWindowClassCtlColors} `${id}` `${text}` `${bg}` `${inout_buffer_var}` `${inout_buffer_var}` `${old_userdata_var}`
${EndIf}
!macroend

!define ResetWindowClassCtlColors "!insertmacro ResetWindowClassCtlColors"
!macro ResetWindowClassCtlColors id buffer_var userdata_var
${If} "${buffer_var}" != ""
${AndIf} "${buffer_var}" <> 0
  ${SetWindowClassUserData} ${id} "${userdata_var}" "" ; reset
${EndIf}
${SystemFree} "${buffer_var}"
!macroend

!endif
