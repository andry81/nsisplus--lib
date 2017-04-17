!ifndef _NSIS_SETUP_LIB_WINCTRL_NSI
!define _NSIS_SETUP_LIB_WINCTRL_NSI

!ifndef WINMESSAGES_INCLUDED
!include "WinMessages.nsh"
!endif

#!define /math EM_GETLIMITTEXT           ${WM_USER} + 37
#!define /math EM_POSFROMCHAR            ${WM_USER} + 38
#!define /math EM_CHARFROMPOS            ${WM_USER} + 39

#!define /math EM_SCROLLCARET            ${WM_USER} + 49

!define /math EM_CANPASTE               ${WM_USER} + 50
!define /math EM_DISPLAYBAND            ${WM_USER} + 51
!define /math EM_EXGETSEL               ${WM_USER} + 52
#!define /math EM_EXLIMITTEXT            ${WM_USER} + 53
!define /math EM_EXLINEFROMCHAR         ${WM_USER} + 54
!define /math EM_EXSETSEL               ${WM_USER} + 55
!define /math EM_FINDTEXT               ${WM_USER} + 56
!define /math EM_FORMATRANGE            ${WM_USER} + 57
!define /math EM_GETCHARFORMAT          ${WM_USER} + 58
!define /math EM_GETEVENTMASK           ${WM_USER} + 59
!define /math EM_GETOLEINTERFACE        ${WM_USER} + 60
!define /math EM_GETPARAFORMAT          ${WM_USER} + 61
!define /math EM_GETSELTEXT             ${WM_USER} + 62
!define /math EM_HIDESELECTION          ${WM_USER} + 63
!define /math EM_PASTESPECIAL           ${WM_USER} + 64
!define /math EM_REQUESTRESIZE          ${WM_USER} + 65
!define /math EM_SELECTIONTYPE          ${WM_USER} + 66
!define /math EM_SETBKGNDCOLOR          ${WM_USER} + 67
!define /math EM_SETCHARFORMAT          ${WM_USER} + 68
!define /math EM_SETEVENTMASK           ${WM_USER} + 69
!define /math EM_SETOLECALLBACK         ${WM_USER} + 70
!define /math EM_SETPARAFORMAT          ${WM_USER} + 71
!define /math EM_SETTARGETDEVICE        ${WM_USER} + 72
!define /math EM_STREAMIN               ${WM_USER} + 73
!define /math EM_STREAMOUT              ${WM_USER} + 74
!define /math EM_GETTEXTRANGE           ${WM_USER} + 75
!define /math EM_FINDWORDBREAK          ${WM_USER} + 76
!define /math EM_SETOPTIONS             ${WM_USER} + 77
!define /math EM_GETOPTIONS             ${WM_USER} + 78
!define /math EM_FINDTEXTEX             ${WM_USER} + 79

!define /math EM_GETWORDBREAKPROCEX     ${WM_USER} + 80
!define /math EM_SETWORDBREAKPROCEX     ${WM_USER} + 81


; RichEdit 2.0 messages 
!define /math EM_SETUNDOLIMIT           ${WM_USER} + 82
!define /math EM_REDO                   ${WM_USER} + 84
!define /math EM_CANREDO                ${WM_USER} + 85
!define /math EM_GETUNDONAME            ${WM_USER} + 86
!define /math EM_GETREDONAME            ${WM_USER} + 87
!define /math EM_STOPGROUPTYPING        ${WM_USER} + 88

!define /math EM_SETTEXTMODE            ${WM_USER} + 89
!define /math EM_GETTEXTMODE            ${WM_USER} + 90

!endif
