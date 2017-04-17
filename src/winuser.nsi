!ifndef _NSIS_SETUP_LIB_WINUSER_NSI
!define _NSIS_SETUP_LIB_WINUSER_NSI

; GetWindowLong

!define GWL_WNDPROC         -4
!define GWL_HINSTANCE       -6
!define GWL_HWNDPARENT      -8
#!define GWL_STYLE           -16
#!define GWL_EXSTYLE         -20
!define GWL_USERDATA        -21
!define GWL_ID              -12

; GetWindowLongPtr

#!define GWLP_WNDPROC        -4
#!define GWLP_HINSTANCE      -6
#!define GWLP_HWNDPARENT     -8
#!define GWLP_USERDATA       -21
#!define GWLP_ID             -12

; GetClassLong

!define GCL_MENUNAME        -8
!define GCL_HBRBACKGROUND   -10
!define GCL_HCURSOR         -12
!define GCL_HICON           -14
!define GCL_HMODULE         -16
!define GCL_CBWNDEXTRA      -18
!define GCL_CBCLSEXTRA      -20
!define GCL_WNDPROC         -24
!define GCL_STYLE           -26
!define GCW_ATOM            -32

!define GCL_HICONSM         -34

; GetClassLongPtr

!define GCLP_MENUNAME       -8
!define GCLP_HBRBACKGROUND  -10
!define GCLP_HCURSOR        -12
!define GCLP_HICON          -14
!define GCLP_HMODULE        -16
!define GCLP_WNDPROC        -24
!define GCLP_HICONSM        -34

!endif
