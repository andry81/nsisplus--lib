!ifndef _NSIS_SETUP_LIB_PREPROCESSOR_NSI
!define _NSIS_SETUP_LIB_PREPROCESSOR_NSI

!define _NSIS_SETUP_LIB_PREPROCESSOR_PRINT_INCLUDE_TIMES 0
!define _NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL 3 ; 4 for debug proprocessor macros

!define DOLLAR "$$"

!define !debug_echo "!insertmacro !debug_echo"
!macro !debug_echo msg
!verbose push
!verbose 4

!echo "${msg}"

!verbose pop
!macroend

; print compile time in the build log
!define !echo_time "!insertmacro !echo_time"
!macro !echo_time
!verbose push
!verbose 3

!tempfile !include__time_L${__LINE__}

${!echo_time_impl} !include__time_L${__LINE__} "${__FILE__}" "${__LINE__}"

!delfile !include__time_L${__LINE__}

!verbose pop
!macroend

!define !echo_time_impl "!insertmacro !echo_time_impl"
!macro !echo_time_impl temp_file file line
!system '@echo.!define /redef _NSIS_SETUP_LIB_BUILD_DATE_TIME "%DATE%:%TIME%"> "${${temp_file}}"'
!include "${${temp_file}}"

!verbose pop

!echo "Build time: ${_NSIS_SETUP_LIB_BUILD_DATE_TIME} File: $\"${include_file}$\" Line: ${line}"

!verbose push
!verbose 3
!macroend

; include with print compile time into build log before and after inclusion
!define !include "!insertmacro !include"
!macro !include file
!if ${_NSIS_SETUP_LIB_PREPROCESSOR_PRINT_INCLUDE_TIMES} <> 0
  !verbose push
  !verbose 3

  !ifdef !include__N
    !define /redef /math !include__N ${!include__N} + 1
  !else
    !define !include__N 0
  !endif

  !define !include__I${!include__N} "${__LINE__}"

  !tempfile !include__time_L${!include__I${!include__N}}

  ${!echo_time_impl} !include__time_L${!include__I${!include__N}} "${file}" "${__LINE__}"

  !verbose pop

  !include "${file}"

  !verbose push
  !verbose 3

  ${!echo_time_impl} !include__time_L${!include__I${!include__N}} "${file}" "${__LINE__}"

  !delfile !include__time_L${!include__I${!include__N}}

  !undef !include__I${!include__N}

  !if ${!include__N} > 0
    !define /redef /math !include__N ${!include__N} - 1
  !else
    !undef !include__N
  !endif

  !verbose pop
!else
  !include "${file}"
!endif
!macroend

; undefine if defined
!define !undef_ifdef "!insertmacro !undef_ifdef"
!macro !undef_ifdef var_def
!ifdef ${var_def}
  !undef ${var_def}
!endif
!macroend

; define an integer definition variable if expression string has a prefix
!define !define_if_has_prefix_impl_begin "!insertmacro !define_if_has_prefix_impl_begin"
!macro !define_if_has_prefix_impl_begin var_def throw_errors exp prefix
!if ${throw_errors} = 0
  !if "${var_def}" == ""
    !error "!define_if_has_prefix: variable definition name must be defined!"
  !endif
!endif

!if "${var_def}" != ""
  !define ${var_def} 0 ; compile error if already exists
!endif

!if "${prefix}" == ""
  !if ${throw_errors} <> 0
    !error "!define_if_has_prefix: prefix must be defined!"
  !endif
!else
  !define !define_if_has_prefix__exp_wo_prefix "" ; compile error if already exists
  !define !define_if_has_prefix__var "" ; compile error if already exists
  !define !define_if_has_prefix__exp_wo_var "" ; compile error if already exists

  !searchreplace !define_if_has_prefix__exp_wo_prefix "${exp}" "${prefix}" ""

  !if "${!define_if_has_prefix__exp_wo_prefix}" == "${exp}"
    !if ${throw_errors} <> 0
      !error "!define_if_has_prefix: expression string has no prefix: exp=$\"${exp}$\" prefix=${prefix}"
    !endif
  !else
    !searchparse "${exp}" "${prefix}" !define_if_has_prefix__var
    !searchreplace !define_if_has_prefix__exp_wo_var "${exp}" "$${!define_if_has_prefix__var}" ""
    !if "${!define_if_has_prefix__exp_wo_var}" S== "${!define_if_has_prefix__var}"
      !if ${throw_errors} <> 0
        !error "!define_if_has_prefix: expression string has no prefix: exp=$\"${exp}$\" prefix=${prefix}"
      !endif
      !if "${var_def}" != ""
        !define /redef ${var_def} 1
      !endif
    !else
      !if "$${!define_if_has_prefix__var}${!define_if_has_prefix__exp_wo_var}" S!= "${exp}"
        !if ${throw_errors} <> 0
          !error "!define_if_has_prefix: expression string has no prefix: exp=$\"${exp}$\" prefix=${prefix}"
        !endif
        !if "${var_def}" != ""
          !define /redef ${var_def} 1
        !endif
      !endif
    !endif
  !endif
!endif
!macroend

!define !define_if_has_prefix_impl_end "!insertmacro !define_if_has_prefix_impl_end"
!macro !define_if_has_prefix_impl_end
${!undef_ifdef} !define_if_has_prefix__exp_wo_var
${!undef_ifdef} !define_if_has_prefix__var
${!undef_ifdef} !define_if_has_prefix__exp_wo_prefix
!macroend

!define !define_if_has_prefix "!insertmacro !define_if_has_prefix"
!macro !define_if_has_prefix var_def throw_errors exp prefix
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_has_prefix_impl_begin} ${var_def} ${throw_errors} "${exp}" "${prefix}"
${!define_if_has_prefix_impl_end}

!verbose pop
!macroend

; define a define if expression is valid runtime variable token with $ prefix
!define !define_if_valid_var "!insertmacro !define_if_valid_var"
!macro !define_if_valid_var var_def throw_errors exp var_name_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_has_prefix_impl_begin} "${var_def}" ${throw_errors} "${exp}" $
!if "${var_def}" != ""
  !define /redef ${var_def} 0 ; drop return value
!endif

!if "${!define_if_has_prefix__var}" != ""
  !define !define_if_valid_var__var_wo_invalid_chars "${!define_if_has_prefix__var}" ; compile error if already exists

  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "$" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "|" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" ":" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "{" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "}" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "(" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" ")" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "[" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "]" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "<" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" ">" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "~" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "$\"" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "'" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "`" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" ";" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "*" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "\" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "/" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "-" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "+" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "=" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "#" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "%" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "&" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "^" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "!" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "?" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "@" ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "." ""
  !searchreplace !define_if_valid_var__var_wo_invalid_chars "${!define_if_valid_var__var_wo_invalid_chars}" "," ""

  !if "${!define_if_valid_var__var_wo_invalid_chars}" S!= "${!define_if_has_prefix__var}"
    !if ${throw_errors} <> 0
      !error "!define_if_valid_var: expression string is not valid variable token: exp=$\"${exp}$\" filtered=$\"${!define_if_valid_var__var_wo_invalid_chars}$\""
    !endif
  !else
    !if "${var_def}" != ""
      !define /redef ${var_def} 1
    !endif
    !if "${var_name_def}" != ""
      !define ${var_name_def} "${!define_if_has_prefix__var}"
    !endif
  !endif

  !undef !define_if_valid_var__var_wo_invalid_chars
!else
  !if ${throw_errors} <> 0
    !error "!define_if_valid_var: expression string is not valid variable token: exp=$\"${exp}$\""
  !endif
!endif

${!define_if_has_prefix_impl_end}

!if "${${var_def}}" == "0" ; defined to 1 or not defined
  !undef ${var_def}
!endif

!verbose pop
!macroend

; define a define if expression is not valid runtime variable token with $ prefix
!define !define_if_nvalid_var "!insertmacro !define_if_nvalid_var"
!macro !define_if_nvalid_var var_def throw_errors exp var_name_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_valid_var} !define_if_nvalid_var__VALID_VAR 0 "${exp}" ""
!ifdef !define_if_nvalid_var__VALID_VAR
  !undef !define_if_nvalid_var__VALID_VAR
!else
  !define ${var_def} 1 ; compile error if already exists
!endif

!verbose pop
!macroend

; define an integer definition variable if expression string is empty or not-a-number
!define !define_if_empty_NAN "!insertmacro !define_if_empty_NAN"
!macro !define_if_empty_NAN var_def err_msg exp
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!if "${err_msg}" == ""
  !if "${var_def}" == ""
    !error "!define_if_empty_NAN: variable definition name must be defined!"
  !endif
!endif

!if "${var_def}" != ""
  !define ${var_def} 0 ; compile error if already exists
!endif

!if "${exp}" == ""
  !if "${err_msg}" != ""
    !error "${err_msg}"
  !else
    !if "${var_def}" != ""
      !define /redef ${var_def} 1
    !endif
  !endif
!else
  ; test on not-a-number
  !define !define_if_empty_NAN__var "${exp}" ; compile error if already exists
  ${!define_if_has_prefix_impl_begin} !define_if_empty_NAN__plus 0 "${!define_if_empty_NAN__var}" +
  !if ${!define_if_empty_NAN__plus} <> 0
    !define /redef !define_if_empty_NAN__var "${!define_if_has_prefix__var}"
    ${!define_if_has_prefix_impl_end}
  !else
    ${!define_if_has_prefix_impl_end}
    ${!define_if_has_prefix_impl_begin} !define_if_empty_NAN__minus 0 "${!define_if_empty_NAN__var}" -
    !if ${!define_if_empty_NAN__minus} <> 0
      !define /redef !define_if_empty_NAN__var "${!define_if_has_prefix__var}"
    !endif
    ${!define_if_has_prefix_impl_end}
    !undef !define_if_empty_NAN__minus
  !endif
  !undef !define_if_empty_NAN__plus

  !define !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var}" ; compile error if already exists
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "0" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "1" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "2" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "3" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "4" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "5" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "6" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "7" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "8" ""
  !searchreplace !define_if_empty_NAN__var_wo_valid_chars "${!define_if_empty_NAN__var_wo_valid_chars}" "9" ""

  !if "${!define_if_empty_NAN__var_wo_valid_chars}" != ""
    !if "${err_msg}" != ""
      !error "${err_msg}"
    !else
      !if "${var_def}" != ""
        !define /redef ${var_def} 1
      !endif
    !endif
  !endif

  !undef !define_if_empty_NAN__var_wo_valid_chars
  !undef !define_if_empty_NAN__var
!endif

!verbose pop
!macroend

; define an integer definition variable if expression string is empty or not-a-number or 0
!define !define_if_empty_NAN_0 "!insertmacro !define_if_empty_NAN_0"
!macro !define_if_empty_NAN_0 var_def err_msg exp
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_empty_NAN} "${var_def}" "${err_msg}" "${exp}"
!if ${${var_def}} = 0
  !if "${err_msg}" != ""
    !if ${exp} = 0
      !error "${err_msg}"
    !endif
  !else
    !if "${var_def}" != ""
      !if ${exp} = 0
        !define /redef ${var_def} 1
      !endif
    !endif
  !endif
!endif

!verbose pop
!macroend

; error if empty
!define !error_if_empty "!insertmacro !error_if_empty"
!macro !error_if_empty exp err_msg
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!if "${exp}" == ""
  !error "${err_msg}"
!endif

!verbose pop
!macroend

; error if empty or NAN
!define !error_if_empty_NAN "!insertmacro !error_if_empty_NAN"
!macro !error_if_empty_NAN exp err_msg
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_empty_NAN} "" "${err_msg}" "${exp}"

!verbose pop
!macroend

; error if defined to not empty
!define !error_ifdef "!insertmacro !error_ifdef"
!macro !error_ifdef var_def err_msg
!ifdef ${var_def}
  !if "${${var_def}}" != ""
    !error "${err_msg}"
  !endif
!endif
!macroend

; error if not defined or empty
!define !error_ifndef "!insertmacro !error_ifndef"
!macro !error_ifndef var_def err_msg
!ifndef ${var_def}
  !error "${err_msg}"
!else
  !if "${${var_def}}" == ""
    !error "${err_msg}"
  !endif
!endif
!macroend

; error if not defined or not-a-number
!define !error_ifndef_NAN "!insertmacro !error_ifndef_NAN"
!macro !error_ifndef_NAN var_def err_msg
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!ifndef ${var_def}
  !error "${err_msg}"
!else
  ${!error_if_empty_NAN} "${${var_def}}" "${err_msg}"
!endif

!verbose pop
!macroend

; error if not defined or not-a-number or 0
!define !error_ifndef_NAN_0 "!insertmacro !error_ifndef_NAN_0"
!macro !error_ifndef_NAN_0 var_def err_msg
!ifndef ${var_def}
  !error "${err_msg}"
!else
  !if "${${var_def}}" == ""
    !error "${err_msg}"
  !else
    !if ${${var_def}} = 0 ; comparison on not-a-number or 0
      !error "${err_msg}"
    !endif
  !endif
!endif
!macroend

; Extracts argument if it begins by ${elem_prefix_str} and make definition ${arg} with it excluding ${elem_prefix_str}, otherwise make empty.
!define ExtractMacroArgmentVariable "!insertmacro ExtractMacroArgmentVariable"
!macro ExtractMacroArgmentVariable arg var_def elem_prefix_str var_name_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_valid_var} "" 1 "${arg}" "${var_name_def}"

!define /ifndef ${var_def} ""
!if "${arg}" != ""
  ; !searchparse will error on not found prefix or separator strings!
  !if "${elem_prefix_str}" != ""
    !define __CURRENT_MACRO_ExtractMacroArgmentVariable_VAR_PREFIX_CHAR_ESCAPED_next_elems_def "" ; compile error if already exists
    !searchreplace __CURRENT_MACRO_ExtractMacroArgmentVariable_VAR_PREFIX_CHAR_ESCAPED_next_elems_def "${arg}" "${elem_prefix_str}" "*${elem_prefix_str}*"
    !if "${__CURRENT_MACRO_ExtractMacroArgmentVariable_VAR_PREFIX_CHAR_ESCAPED_next_elems_def}" S!= "${arg}" ; variable prefix character is found
      !searchparse "${arg}" "${elem_prefix_str}" ${var_def}
    !else
      !define /redef ${var_def} "${arg}"
    !endif
    !undef __CURRENT_MACRO_ExtractMacroArgmentVariable_VAR_PREFIX_CHAR_ESCAPED_next_elems_def
  !else
    !define /redef ${var_def} "${arg}"
  !endif
!else
  !define /redef ${var_def} ""
!endif

!verbose pop
!macroend

; Extracts first argument if it begins by ${elem_prefix_str} and make definition ${current_elem_def} with it excluding ${elem_prefix_str}, otherwise make empty.
; If ${list_separator_str} is present, then make definition ${next_elems_def} with rest of string after first found ${list_separator_str}, otherwise make empty.
!define UnfoldMacroArgumentList "!insertmacro UnfoldMacroArgumentList"
!macro UnfoldMacroArgumentList arg current_elem_def next_elems_def elem_prefix_str list_separator_str var_name_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!if "${list_separator_str}" == ""
  !define /redef list_separator_str "|"
!endif
!define /ifndef ${current_elem_def} ""
!define /ifndef ${next_elems_def} "${arg}"
!if "${${next_elems_def}}" != ""
  ; !searchparse will error on not found prefix or separator strings!
  !define __CURRENT_MACRO_UnfoldMacroArgumentList_LIST_SEPARATOR_ESCAPED_next_elems_def "" ; compile error if already exists
  !searchreplace __CURRENT_MACRO_UnfoldMacroArgumentList_LIST_SEPARATOR_ESCAPED_next_elems_def "${${next_elems_def}}" "${list_separator_str}" "*${list_separator_str}*"
  !if "${__CURRENT_MACRO_UnfoldMacroArgumentList_LIST_SEPARATOR_ESCAPED_next_elems_def}" S!= "${${next_elems_def}}" ; list separator is found
    !if ! "${elem_prefix_str}" == "" ; double negation to avoid error in case if elem_prefix_str="!"
      ; !searchparse will error on not found prefix or separator strings!
      !define __CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def "" ; compile error if already exists
      !searchreplace __CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def "${${next_elems_def}}" "${elem_prefix_str}" "*${elem_prefix_str}*"
      !if "${__CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def}" S!= "${${next_elems_def}}" ; variable prefix character is found
        !searchparse "${${next_elems_def}}" "${elem_prefix_str}" ${current_elem_def} "${list_separator_str}" ${next_elems_def}
      !else
        !error "UnfoldMacroArgumentList: element prefix is not found: elem_prefix_str=${elem_prefix_str} list_separator_str=${list_separator_str} list=${${next_elems_def}}"
      !endif
      !undef __CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def
    !else
      !searchparse "${${next_elems_def}}" "" ${current_elem_def} "${list_separator_str}" ${next_elems_def}
    !endif
  !else
    !if ! "${elem_prefix_str}" == "" ; double negation to avoid error in case if elem_prefix_str="!"
      ; !searchparse will error on not found prefix or separator strings!
      !define __CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def "" ; compile error if already exists
      !searchreplace __CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def "${${next_elems_def}}" "${elem_prefix_str}" "*${elem_prefix_str}*"
      !if "${__CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def}" S!= "${${next_elems_def}}" ; variable prefix character is found
        !searchparse "${${next_elems_def}}" "${elem_prefix_str}" ${current_elem_def}
      !else
        !error "UnfoldMacroArgumentList: element prefix is not found: elem_prefix_str=${elem_prefix_str} list_separator_str=${list_separator_str} list=${${next_elems_def}}"
      !endif
      !undef __CURRENT_MACRO_UnfoldMacroArgumentList_VAR_PREFIX_CHAR_ESCAPED_next_elems_def
    !else
      !define /redef ${current_elem_def} "${${next_elems_def}}"
    !endif
    !define /redef ${next_elems_def} ""
  !endif
  !undef __CURRENT_MACRO_UnfoldMacroArgumentList_LIST_SEPARATOR_ESCAPED_next_elems_def

  !if "${${current_elem_def}}" != ""
    !if ! "${elem_prefix_str}" != "$" ; double negation to avoid error in case if elem_prefix_str="!"
      ${!define_if_valid_var} "" 1 "$${${current_elem_def}}" "${var_name_def}"
    !else
      !if "${var_name_def}" != ""
        !define ${var_name_def} "${${current_elem_def}}"
      !endif
    !endif
  !endif
!else
  !define /redef ${current_elem_def} ""
  !define /redef ${next_elems_def} ""
!endif

!verbose pop
!macroend

; error if not-a-variable
!define !error_if_nvar "!insertmacro !error_if_nvar"
!macro !error_if_nvar str err_msg
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_nvalid_var} error_nvar__NOT_VALID_VAR 0 "${str}" ""
!ifdef error_nvar__NOT_VALID_VAR
  !error "${err_msg}"
  !undef error_nvar__NOT_VALID_VAR ; just in case
!endif

!verbose pop
!macroend

; error if not defined or not-a-variable
!define !error_ifndef_nvar "!insertmacro !error_ifndef_nvar"
!macro !error_ifndef_nvar var_def err_msg
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!ifndef ${var_def}
  !error "${err_msg}"
!else
  !if "${${var_def}}" == ""
    !error "${err_msg}"
  !else
    ${!error_if_nvar} "${${var_def}}" "${err_msg}"
  !endif
!endif

!verbose pop
!macroend

; error if not defined or ( not-a-variable and not-a-number )
!define !error_ifndef_nvar_NAN "!insertmacro !error_ifndef_nvar_NAN"
!macro !error_ifndef_nvar_NAN var_def err_msg
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!ifndef ${var_def}
  !error "${err_msg}"
!else
  !if "${${var_def}}" == ""
    !error "${err_msg}"
  !else
    ${!define_if_nvalid_var} error_ifndef_nvar_NAN__NOT_VALID_VAR 0 "${${var_def}}" ""
    !ifdef error_ifndef_nvar_NAN__NOT_VALID_VAR
      !if ${${var_def}} = 0 ; comparison on not-a-number or 0
        !if "${${var_def}}" != "0"
          !error "${err_msg}"
        !endif
      !endif
      !undef error_ifndef_nvar_NAN__NOT_VALID_VAR
    !endif
  !endif
!endif

!verbose pop
!macroend

; error if not defined or ( not-a-variable and ( not-a-number or 0 ) )
!define !error_ifndef_nvar_NAN_0 "!insertmacro !error_ifndef_nvar_NAN_0"
!macro !error_ifndef_nvar_NAN_0 var_def err_msg
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!ifndef ${var_def}
  !error "${err_msg}"
!else
  !if "${${var_def}}" == ""
    !error "${err_msg}"
  !else
    ${!define_if_nvalid_var} error_ifndef_nvar_NAN_0__NOT_VALID_VAR 0 "${${var_def}}" ""
    !ifdef error_ifndef_nvar_NAN_0__NOT_VALID_VAR
      !if ${${var_def}} = 0 ; comparison on not-a-number or 0
        !error "${err_msg}"
      !endif
      !undef error_ifndef_nvar_NAN_0__NOT_VALID_VAR
    !endif
  !endif
!endif

!verbose pop
!macroend

; define a define if compile time expression evaludated to true
!define !define_if_impl "!insertmacro !define_if_impl"
!macro !define_if_impl verbose_flag var_def var exp value
!if ${verbose_flag} <> 0
  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!endif

!ifdef ${var_def}
  !error "!define_if: ${var_def} must be not defined!"
!endif

!ifdef ${var}
  !if "${${var}}" != ""
    !define !define_if__value0 ${${var}}
  !else
    !define !define_if__value0 0
  !endif
!else
  !define !define_if__value0 0
!endif

!if "${value}" != ""
  !define !define_if__value1 ${value}
!else
  !define !define_if__value1 0
!endif

!if "${exp}" != ""
  !define !define_if__exp ${exp}
!else
  !define !define_if__exp =
!endif

!if "${!define_if__exp}" == "=="
  !define !define_if__strings_exp
!else
  !if "${!define_if__exp}" == "S=="
    !define !define_if__strings_exp
  !else
    !if "${!define_if__exp}" == "!="
      !define !define_if__strings_exp
    !else
      !if "${!define_if__exp}" == "S!="
        !define !define_if__strings_exp
      !endif
    !endif
  !endif
!endif

!ifdef !define_if__strings_exp
  ; strings comparison expression
  !if "${!define_if__value0}" ${!define_if__exp} "${!define_if__value1}"
    !verbose pop

    !define ${var_def} 1

    !verbose push
    !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
  !endif
!else
  ; arithmetic comparison expression
  !if ${!define_if__value0} ${!define_if__exp} ${!define_if__value1}
    !verbose pop

    !define ${var_def} 1

    !verbose push
    !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
  !endif
!endif

; definitions cleanup
!undef !define_if__value0
!undef !define_if__exp
!undef !define_if__value1

${!undef_ifdef} !define_if__strings_exp

!if ${verbose_flag} <> 0
  !verbose pop
!endif
!macroend

; define a define if compile time expression evaludated to true
!define !define_if "!insertmacro !define_if"
!macro !define_if var_def var exp value
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_impl} 0 ${var_def} "${var}" ${exp} "${value}"

!verbose pop
!macroend

; undefine a define if compile time expression evaludated to true
!define !undef_if "!insertmacro !undef_if"
!macro !undef_if var_def var exp value
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!ifndef ${var_def}
  !error "!undef_if: ${var_def} must be defined!"
!endif

!ifdef ${var}
  !if "${${var}}" != ""
    !define !undef_if__value0 ${${var}}
  !else
    !define !undef_if__value0 0
  !endif
!else
  !define !undef_if__value0 0
!endif

!if "${value}" != ""
  !define !undef_if__value1 ${value}
!else
  !define !undef_if__value1 0
!endif

!if "${exp}" != ""
  !define !undef_if__exp ${exp}
!else
  !define !undef_if__exp =
!endif

!if "${!undef_if__exp}" == "=="
  !define !undef_if__strings_exp
!else
  !if "${!undef_if__exp}" == "S=="
    !define !undef_if__strings_exp
  !else
    !if "${!undef_if__exp}" == "!="
      !define !undef_if__strings_exp
    !else
      !if "${!undef_if__exp}" == "S!="
        !define !undef_if__strings_exp
      !endif
    !endif
  !endif
!endif

!ifdef !undef_if__strings_exp
  ; strings comparison expression
  !if "${!undef_if__value0}" ${!undef_if__exp} "${!undef_if__value1}"
    !verbose pop

    !undef ${var_def}

    !verbose push
    !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
  !endif
!else
  ; arithmetic comparison expression
  !if ${!undef_if__value0} ${!undef_if__exp} ${!undef_if__value1}
    !verbose pop

    !undef ${var_def}

    !verbose push
    !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
  !endif
!endif

; definitions cleanup
!undef !undef_if__value0
!undef !undef_if__exp
!undef !undef_if__value1

${!undef_ifdef} !undef_if__strings_exp

!verbose pop
!macroend

; Special macros to define ENABLE_* internal intergral definition (always not empty) from external F_DISABLE_*/F_ENABLE_* not integral definitions (can be empty), 
; declared by the compiler /D flag.
!define !define_disable_flag_impl "!insertmacro !define_disable_flag_impl"
!macro !define_disable_flag_impl verbose_flag internal_flag_name_def_suffix default_value external_exp_suffix
!if ${verbose_flag} <> 0
  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!endif

${!error_if_empty_NAN} "${default_value}" "!define_disable_flag_impl: default value must be valid integer!"

!define !define_disable_flag_impl__external_exp_suffix "${external_exp_suffix}"
!if "${!define_disable_flag_impl__external_exp_suffix}" == ""
  !define /redef !define_disable_flag_impl__external_exp_suffix "F_DISABLE_${internal_flag_name_def_suffix} <> 0" ; use as default expression the integral expression based on internal flag name
!endif

#${!define_from_args3} !define_disable_flag_impl__env_var_name 0 ${!define_disable_flag_impl__external_exp_suffix}
#${!define_from_env} "" "F_DISABLE_${internal_flag_name_def_suffix}" "${!define_disable_flag_impl__env_var_name}"
${!define_if} "DISABLE_${internal_flag_name_def_suffix}" ${!define_disable_flag_impl__external_exp_suffix}

${!undef_ifdef} F_DISABLE_${internal_flag_name_def_suffix} ; don't leave environment variables defined
#!undef !define_disable_flag_impl__env_var_name
!undef !define_disable_flag_impl__external_exp_suffix

!ifdef DISABLE_${internal_flag_name_def_suffix}
  !verbose pop

  !define ENABLE_${internal_flag_name_def_suffix} 0

  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

  !undef DISABLE_${internal_flag_name_def_suffix} ; should not exist, use ENABLE_* instead!
!else
  !verbose pop
 
  !if ${default_value} <> 0
    !define ENABLE_${internal_flag_name_def_suffix} 0 ; disabled by default if default value is not zero
  !else
    !define ENABLE_${internal_flag_name_def_suffix} 1
  !endif

  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!endif

!if ${verbose_flag} <> 0
  !verbose pop
!endif
!macroend

!define !define_by_disable_flag "!insertmacro !define_by_disable_flag"
!macro !define_by_disable_flag internal_flag_name_def_suffix default_value
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_disable_flag_impl} 0 "${internal_flag_name_def_suffix}" "${default_value}" ""

!verbose pop
!macroend

!define !define_enable_flag_impl "!insertmacro !define_enable_flag_impl"
!macro !define_enable_flag_impl verbose_flag internal_flag_name_def_suffix default_value external_exp_suffix
!if ${verbose_flag} <> 0
  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!endif

${!error_if_empty_NAN} "${default_value}" "!define_enable_flag_impl: default value must be valid integer: default_value=${default_value}"

!define !define_enable_flag_impl__external_exp_suffix "${external_exp_suffix}"
!if "${!define_enable_flag_impl__external_exp_suffix}" == ""
  !define /redef !define_enable_flag_impl__external_exp_suffix "F_ENABLE_${internal_flag_name_def_suffix} <> 0" ; use as default expression the integral expression based on internal flag name
!endif

#${!define_from_args3} !define_enable_flag_impl__env_var_name 0 ${!define_enable_flag_impl__external_exp_suffix}
#${!define_from_env} "" "F_ENABLE_${internal_flag_name_def_suffix}" "${!define_enable_flag_impl__env_var_name}"
${!define_if_impl} 0 "ENABLE_${internal_flag_name_def_suffix}" ${!define_enable_flag_impl__external_exp_suffix}

${!undef_ifdef} F_ENABLE_${internal_flag_name_def_suffix} ; don't leave environment variables defined
#!undef !define_enable_flag_impl__env_var_name
!undef !define_enable_flag_impl__external_exp_suffix

!verbose pop

!define /ifndef ENABLE_${internal_flag_name_def_suffix} ${default_value}

!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!if ${verbose_flag} <> 0
  !verbose pop
!endif
!macroend

!define !define_by_enable_flag "!insertmacro !define_by_enable_flag"
!macro !define_by_enable_flag internal_flag_name_def_suffix default_value
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_enable_flag_impl} 0 "${internal_flag_name_def_suffix}" "${default_value}" ""

!verbose pop
!macroend

!define !define_integer_value_impl "!insertmacro !define_integer_value_impl"
!macro !define_integer_value_impl verbose_flag internal_value_name_def default_value external_value_name_def
!if ${verbose_flag} <> 0
  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!endif

${!error_if_empty_NAN} "${default_value}" "!define_integer_value_impl: default value must be valid integer!"

!if "${external_value_name_def}" == ""
  !define /redef external_value_name_def "F_${internal_value_name_def}" ; use as external value definition name the internal value name definition name
!endif

!ifdef ${external_value_name_def}
  !verbose pop

  !define ${internal_value_name_def} "${${external_value_name_def}}" ; set as internal value the external integral value

  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!else
  !verbose pop

  !define ${internal_value_name_def} ${default_value}

  !verbose push
  !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!endif

!if ${verbose_flag} <> 0
  !verbose pop
!endif
!macroend

!define !define_integer_value "!insertmacro !define_integer_value"
!macro !define_integer_value internal_value_name_def default_value
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_integer_value_impl} 0 "${internal_value_name_def}" "${default_value}" ""

!verbose pop
!macroend

; define a define to a value without prefix from separated by separator list by index
!define !define_list_value_by_index "!insertmacro !define_list_value_by_index"
!macro !define_list_value_by_index is_found_def value_def index list prefix separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!error_if_empty} "${is_found_def}${value_def}" "!define_list_value_by_index: is_found_def or value_def must be not empty!"
${!error_if_empty_NAN} "${index}" "!define_list_value_by_index: index must be a number: index=$\"${index}$\""
!if ${index} < 0
  !error "!define_list_value_by_index: index must be a positive number: index=$\"${index}$\""
!endif
!if ${index} > 255 ; a big value has no sense in compile time
  !error "!define_list_value_by_index: index must be not greater than 255: index=$\"${index}$\""
!endif

; drop return value
!if "${is_found_def}" != ""
  !define ${is_found_def} 0
!endif
!if "${value_def}" != ""
  !define ${value_def} ""
!endif

!define !define_list_value_by_index__elem_index_def 0

!insertmacro !define_list_value_by_index__impl_recur "${is_found_def}" "${value_def}" "${index}" "${list}" "${prefix}" "${separator}" \
  !define_list_value_by_index__current_elem_def !define_list_value_by_index__next_elems_def

!undef !define_list_value_by_index__current_elem_def
!undef !define_list_value_by_index__next_elems_def
!undef !define_list_value_by_index__elem_index_def

!verbose pop
!macroend

!macro !define_list_value_by_index__impl_recur is_found_def value_def index list prefix separator current_elem_def next_elems_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${UnfoldMacroArgumentList} "${list}" ${current_elem_def} ${next_elems_def} "${prefix}" "${separator}" ""

!if ${index} = ${!define_list_value_by_index__elem_index_def}
  ; found
  !if "${is_found_def}" != ""
    !define /redef ${is_found_def} 1
  !endif
  !if "${value_def}" != ""
    !define /redef ${value_def} "${${current_elem_def}}"
  !endif
!else
  ; recursive macro call
  !if "${${next_elems_def}}" != ""
    !define /redef /math !define_list_value_by_index__elem_index_def ${!define_list_value_by_index__elem_index_def} + 1
    !insertmacro !define_list_value_by_index__impl_recur "${is_found_def}" "${value_def}" "${index}" "${${next_elems_def}}" "${prefix}" "${separator}" \
      ${current_elem_def} ${next_elems_def}
  !endif
!endif

!verbose pop
!macroend

; define a define if value without prefix is in a separator separated list tested over expression
!define !define_if_value_in_list "!insertmacro !define_if_value_in_list"
!macro !define_if_value_in_list var_def prefix value exp list separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!error_ifndef} var_def "!define_if_value_in_list: variable definition name must be defined!"
${!error_ifndef} value "!define_if_value_in_list: value must be not empty!"
${!error_ifndef} exp "!define_if_value_in_list: expression must be not empty!"

!define ${var_def} 0 ; drop return value

!insertmacro !define_if_value_in_list__impl_recur ${var_def} "${value}" "${exp}" "${list}" "${prefix}" "${separator}" \
  !define_if_value_in_list__current_elem_def !define_if_value_in_list__next_elems_def

!undef !define_if_value_in_list__current_elem_def
!undef !define_if_value_in_list__next_elems_def

!verbose pop
!macroend

!macro !define_if_value_in_list__impl_recur var_def value exp list prefix separator current_elem_def next_elems_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${UnfoldMacroArgumentList} "${list}" ${current_elem_def} ${next_elems_def} "${prefix}" "${separator}" ""

!if "${value}" ${exp} "${${current_elem_def}}"
  !define /redef ${var_def} 1 ; found
!else
  ; recursive macro call
  !if "${${next_elems_def}}" != ""
    !insertmacro !define_if_value_in_list__impl_recur ${var_def} "${value}" "${exp}" "${${next_elems_def}}" "${prefix}" "${separator}" \
      ${current_elem_def} ${next_elems_def}
  !endif
!endif

!verbose pop
!macroend

!define !error_if_value_in_list "!insertmacro !error_if_value_in_list"
!macro !error_if_value_in_list err_msg var_def prefix value exp list separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_value_in_list} !error_if_value_in_list__is_found "${prefix}" "${value}" "${exp}" "${list}" "${separator}"
!if ${!error_if_value_in_list__is_found} <> 0
  !error "${err_msg}"
!endif
!undef !error_if_value_in_list__is_found

!verbose pop
!macroend

!define !error_if_value_not_in_list "!insertmacro !error_if_value_not_in_list"
!macro !error_if_value_not_in_list err_msg var_def prefix value exp list separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_value_in_list} !error_if_value_in_list__is_found "${prefix}" "${value}" "${exp}" "${list}" "${separator}"
!if ${!error_if_value_in_list__is_found} = 0
  !error "${err_msg}"
!endif
!undef !error_if_value_in_list__is_found

!verbose pop
!macroend

!define StrCpyByList "!insertmacro StrCpyByList"
!macro StrCpyByList lvalue_list rvalue_list separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!insertmacro StrCpyByList__impl_recur "${lvalue_list}" "${rvalue_list}" "${separator}" \
  StrCpyByList__current_lvalue_def StrCpyByList__next_lvalues_def StrCpyByList__current_rvalue_def StrCpyByList__next_rvalues_def

!undef StrCpyByList__current_lvalue_def
!undef StrCpyByList__next_lvalues_def
!undef StrCpyByList__current_rvalue_def
!undef StrCpyByList__next_rvalues_def

!verbose pop
!macroend

!macro StrCpyByList__impl_recur lvalue_list rvalue_list separator \
  current_lvalue_def next_lvalues_def current_rvalue_def next_rvalues_def
${UnfoldMacroArgumentList} "${lvalue_list}" ${current_lvalue_def} ${next_lvalues_def} "" " " "" ; space separated list w/o prefix
${!error_ifndef} ${current_lvalue_def} "StrCpyByList: lvalue must be not empty!"
${UnfoldMacroArgumentList} "${rvalue_list}" ${current_rvalue_def} ${next_rvalues_def} "" "${separator}" "" ; separator separated list w/o prefix

!verbose pop

StrCpy ${${current_lvalue_def}} "${${current_rvalue_def}}"

!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

; recursive macro call
!if "${${next_lvalues_def}}" != ""
  !insertmacro StrCpyByList__impl_recur "${${next_lvalues_def}}" "${${next_rvalues_def}}" "${separator}" \
    ${current_lvalue_def} ${next_lvalues_def} ${current_rvalue_def} ${next_rvalues_def}
!endif
!macroend

; the same as StrCpyByList but rvalue must be not empty too
!define StrCpyByListIfNotEmpty "!insertmacro StrCpyByListIfNotEmpty"
!macro StrCpyByListIfNotEmpty lvalue_list rvalue_list separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!insertmacro StrCpyByListIfNotEmpty__impl_recur "${lvalue_list}" "${rvalue_list}" "${separator}" \
  StrCpyByListIfNotEmpty__current_lvalue_def StrCpyByListIfNotEmpty__next_lvalues_def \
  StrCpyByListIfNotEmpty__current_rvalue_def StrCpyByListIfNotEmpty__next_rvalues_def

!undef StrCpyByListIfNotEmpty__current_lvalue_def
!undef StrCpyByListIfNotEmpty__next_lvalues_def
!undef StrCpyByListIfNotEmpty__current_rvalue_def
!undef StrCpyByListIfNotEmpty__next_rvalues_def

!verbose pop
!macroend

!macro StrCpyByListIfNotEmpty__impl_recur lvalue_list rvalue_list separator \
  current_lvalue_def next_lvalues_def current_rvalue_def next_rvalues_def
${UnfoldMacroArgumentList} "${lvalue_list}" ${current_lvalue_def} ${next_lvalues_def} "" " " "" ; space separated list w/o prefix
${!error_ifndef} ${current_lvalue_def} "StrCpyByListIfNotEmpty: lvalue must be not empty!"
${UnfoldMacroArgumentList} "${rvalue_list}" ${current_rvalue_def} ${next_rvalues_def} "" "${separator}" "" ; separator separated list w/o prefix

!verbose pop

!if "${${current_rvalue_def}}" != ""
StrCpy ${${current_lvalue_def}} "${${current_rvalue_def}}"
!endif

!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

; recursive macro call
!if "${${next_lvalues_def}}" != ""
  !if "${${next_rvalues_def}}" != ""
    !insertmacro StrCpyByListIfNotEmpty__impl_recur "${${next_lvalues_def}}" "${${next_rvalues_def}}" "${separator}" \
      ${current_lvalue_def} ${next_lvalues_def} ${current_rvalue_def} ${next_rvalues_def}
  !endif
!endif
!macroend

!define StrCpyIfNotInList "!insertmacro StrCpyIfNotInList"
!macro StrCpyIfNotInList lvalue rvalue list separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_value_in_list} StrCpyIfNotInList__lvalue_in_list "" "${lvalue}" S== "${list}" "${separator}"
!if ${StrCpyIfNotInList__lvalue_in_list} = 0

!verbose pop

StrCpy ${lvalue} "${rvalue}"

!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!endif
!undef StrCpyIfNotInList__lvalue_in_list

!verbose pop
!macroend

#!define !define_from_args3 "!insertmacro !define_from_args3"
#!macro !define_from_args3 var_def var_index arg0 arg1 arg2
#!if ${var_index} = 0
#  !define ${var_def} "${arg0}"
#!endif
#!if ${var_index} = 1
#  !define ${var_def} "${arg1}"
#!endif
#!if ${var_index} = 2
#  !define ${var_def} "${arg2}"
#!endif
#!macroend

!define !define_if_list_in_list "!insertmacro !define_if_list_in_list"
!macro !define_if_list_in_list var_def llist exp rlist separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!error_ifndef} var_def "!define_if_list_in_list: variable definition name must be defined!"
${!error_ifndef} exp "!define_if_list_in_list: expression must be not empty!"

!define ${var_def} 0 ; drop return value

!insertmacro !define_if_list_in_list__impl_recur "${llist}" "${exp}" "${rlist}" "${separator}" \
  !define_if_list_in_list__current_elem_def !define_if_list_in_list__next_elems_def

!define /redef ${var_def} ${!define_if_list_in_list__lvalue_is_found}

!undef !define_if_list_in_list__current_elem_def
!undef !define_if_list_in_list__next_elems_def
!undef !define_if_list_in_list__lvalue_is_found

!verbose pop
!macroend

!macro !define_if_list_in_list__impl_recur llist exp rlist separator current_elem_def next_elems_def
${UnfoldMacroArgumentList} "${llist}" ${current_elem_def} ${next_elems_def} "" "${separator}" ""

${!undef_ifdef} !define_if_list_in_list__lvalue_is_found

!if "${${current_elem_def}}" != ""
  ${!define_if_value_in_list} !define_if_list_in_list__lvalue_is_found "" "${${current_elem_def}}" "${exp}" "${rlist}" "${separator}"
  !if ${!define_if_list_in_list__lvalue_is_found} = 0
    ; recursive macro call
    !if "${${next_elems_def}}" != ""
      !insertmacro !define_if_list_in_list__impl_recur "${${next_elems_def}}" "${exp}" "${rlist}" "${separator}" ${current_elem_def} ${next_elems_def}
    !endif
  !endif
!else
  !define !define_if_list_in_list__lvalue_is_found 0
!endif
!macroend

!define !error_if_list_in_list "!insertmacro !error_if_list_in_list"
!macro !error_if_list_in_list err_msg llist exp rlist separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_list_in_list} !error_if_list_in_list__is_found "${llist}" "${exp}" "${rlist}" "${separator}"
!if ${!error_if_list_in_list__is_found} <> 0
  !error "${err_msg}"
!endif
!undef !error_if_list_in_list__is_found

!verbose pop
!macroend

; define a define if expression is a register token: $0-$9 or $R0-$R9
!define !define_if_register "!insertmacro !define_if_register"
!macro !define_if_register var_def throw_errors exp var_name_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if_valid_var} !define_if_register__var_def `${throw_errors}` `${exp}` !define_if_register__var_name_def

!if ${!define_if_register__var_def} <> 0
  !undef !define_if_register__var_def ; undef to define again
  ${!define_if_value_in_list} !define_if_register__var_def "" "${!define_if_register__var_name_def}" "S==" "0|1|2|3|4|5|6|7|8|9|R0|R1|R2|R3|R4|R5|R6|R7|R8|R9" "|"
  !if ${!define_if_register__var_def} = 0
    !if ${throw_errors} <> 0
      !error "!define_if_register: expression string is not valid register token: exp=$\"${exp}$\""
    !endif
  !endif
!endif

!if "${var_def}" != ""
  !define ${var_def} ${!define_if_register__var_def} ; compile error if already exists
!endif
!if "${var_name_def}" != ""
  !define ${var_name_def} ${!define_if_register__var_name_def} ; compile error if already exists
!endif

!undef !define_if_register__var_def
!undef !define_if_register__var_name_def

!verbose pop
!macroend

!define !define_def_list "!insertmacro !define_def_list"
!macro !define_def_list def_flags prefix def_list value_list separator
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!insertmacro !define_def_list__impl_recur "${def_flags}" "${prefix}" "${def_list}" "${value_list}" "${separator}" \
  !define_def_list__current_def_def !define_def_list__next_defs_def !define_def_list__current_value_def !define_def_list__next_values_def

!undef !define_def_list__current_def_def
!undef !define_def_list__next_defs_def
!undef !define_def_list__current_value_def
!undef !define_def_list__next_values_def

!verbose pop
!macroend

!macro !define_def_list__impl_recur def_flags prefix def_list value_list separator \
  current_def_def next_defs_def current_value_def next_values_def
${UnfoldMacroArgumentList} "${def_list}" ${current_def_def} ${next_defs_def} "" " " "" ; space separated list w/o prefix
${UnfoldMacroArgumentList} "${value_list}" ${current_value_def} ${next_values_def} "" "${separator}" "" ; separator separated list w/o prefix

!if "${current_def_def}" != ""
  !define ${def_flags} ${prefix}${${current_def_def}} "${${current_value_def}}" ; found

  ; recursive macro call
  !if "${${next_defs_def}}" != ""
    !insertmacro !define_def_list__impl_recur "${def_flags}" "${prefix}" "${${next_defs_def}}" "${${next_values_def}}" "${separator}" \
      ${current_def_def} ${next_defs_def} ${current_value_def} ${next_values_def}
  !endif
!endif
!macroend

!define !undef_def_list "!insertmacro !undef_def_list"
!macro !undef_def_list prefix def_list
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!insertmacro !undef_def_list__impl_recur "${prefix}" "${def_list}" !undef_def_list__current_def_def !undef_def_list__next_defs_def

!undef !undef_def_list__current_def_def
!undef !undef_def_list__next_defs_def

!verbose pop
!macroend

!macro !undef_def_list__impl_recur prefix def_list current_def_def next_defs_def
${UnfoldMacroArgumentList} "${def_list}" ${current_def_def} ${next_defs_def} "" " " "" ; space separated list w/o prefix

!if "${current_def_def}" != ""
  !undef ${prefix}${${current_def_def}} ; found

  ; recursive macro call
  !if "${${next_defs_def}}" != ""
    !insertmacro !undef_def_list__impl_recur "${prefix}" "${${next_defs_def}}" ${current_def_def} ${next_defs_def}
  !endif
!endif
!macroend

; define if not defined through the user macro, otherwise error if previous definition is not the same
!define !define_ifndef_cmd "!insertmacro !define_ifndef_cmd"
!macro !define_ifndef_cmd def_cmd var_def value
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!ifndef ${var_def}
  ${${def_cmd}} ${var_def} ${value}
!else
  !if "${${var_def}}" != "${value}"
    !error "$${!define_ifndef_cmd}: previous definition has different value"
  !endif
!endif

!verbose pop
!macroend

!define !begin_cmd_include_file "!insertmacro !begin_cmd_include_file"
!macro !begin_cmd_include_file tmp_file_name_def
!tempfile ${tmp_file_name_def}
!macroend

!define !end_cmd_include_file "!insertmacro !end_cmd_include_file"
!macro !end_cmd_include_file tmp_file_name_def
!verbose pop

!include "${${tmp_file_name_def}}"

!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

!delfile "${${tmp_file_name_def}}"
!undef ${tmp_file_name_def}
!macroend

#; define through a temp file, temp file name must be defined
#!define !add_cmd_define_from_env "!insertmacro !add_cmd_define_from_env"
#!macro !add_cmd_define_from_env tmp_file_name_def def_flags var_def env_var
#${!error_ifndef} ${tmp_file_name_def} "!add_cmd_define_from_env: ${tmp_file_name_def} is not defined!"
#!ifdef NSIS_WIN32_MAKENSIS
#  ; Windows - cmd.exe
#  ; CAUTION:
#  ;   In Windows empty environment variable does not expand into empty string in case of expanding in a command line.
#  ;   Instead it expands into "%<name>%" placeholder.
#  ;   To avoid that condition we have to expand that variable in a batch-file and call it from another !system command.
#  ${!begin_cmd_include_file} _tmp_file_cmd_line ; our batch-file
#  !system '@echo.@echo.!define ${def_flags} ${var_def} "%${env_var}%" >> "${_tmp_file_cmd_line}"'
#  !system 'cmd.exe /C call "${_tmp_file_cmd_line}" >> "${${tmp_file_name_def}}"'
#  ${!end_cmd_include_file} _tmp_file_cmd_line
#!else
#  ; Posix - sh
#  !system 'echo "!define ${def_flags} ${var_def} \"$$${env_var}\"" >> "${${tmp_file_name_def}}"'
#!endif
#!macroend

; undefine through a temp file, temp file name must be defined
!define !add_cmd_undef "!insertmacro !add_cmd_undef"
!macro !add_cmd_undef tmp_file_name_def var_def
${!error_ifndef} ${tmp_file_name_def} "!add_cmd_undef: ${tmp_file_name_def} is not defined!"
!ifdef NSIS_WIN32_MAKENSIS
  ; Windows - cmd.exe
  !system '@echo.!undef ${var_def} > "${${tmp_file_name_def}}"'
!else
  ; Posix - sh
  !system 'echo "!undef ${var_def}" > "${${tmp_file_name_def}}"'
!endif
!macroend

; define a define through a temp file if another file exists w/o search in the PATH variable, temp file name must be defined
!define !add_cmd_define_iff_exist "!insertmacro !add_cmd_define_iff_exist"
!macro !add_cmd_define_iff_exist tmp_file_name_def var_def value file
${!error_ifndef} ${tmp_file_name_def} "!add_cmd_define_iff_exist: ${tmp_file_name_def} is not defined!"
!ifdef NSIS_WIN32_MAKENSIS
  ; Windows - cmd.exe
  !system '@if exist "${file}" ( @echo !define ${var_def} "${value}" >> "${${tmp_file_name_def}}" )'
!else
  ; Posix - sh
  !system 'if [ -e "${file}" ]; then echo "!define ${var_def} \"${value}\"" >> "${${tmp_file_name_def}}"; fi'
!endif
!macroend

; define a define through a temp file if another file exists w/ search in the PATH variable, temp file name must be defined
!define !add_cmd_define_iff_exist_in_path "!insertmacro !add_cmd_define_iff_exist_in_path"
!macro !add_cmd_define_iff_exist_in_path tmp_file_name_def var_def value file
${!error_ifndef} ${tmp_file_name_def} "!add_cmd_define_iff_exist_in_path: ${tmp_file_name_def} is not defined!"
!ifdef NSIS_WIN32_MAKENSIS
  ; Windows - cmd.exe
  !system '@where "${file}" >nul 2>&1 && ( @echo !define ${var_def} "${value}" >> "${${tmp_file_name_def}}" )'
!else
  ; Posix - sh
  !system 'which "${file}" >/dev/null 2>&1 && { echo "!define ${var_def} \"${value}\"" >> "${${tmp_file_name_def}}" }'
!endif
!macroend

; define a define value from script output through a temp file, temp file name must be defined
!define !add_cmd_define_from_cmd_stdout "!insertmacro !add_cmd_define_from_cmd_stdout"
!macro !add_cmd_define_from_cmd_stdout tmp_file_name_def cmd_str var_def
${!error_ifndef} ${tmp_file_name_def} "!add_cmd_define_from_cmd_stdout: ${tmp_file_name_def} is not defined!"
!ifdef NSIS_WIN32_MAKENSIS
  ; Windows - cmd.exe
  !system '@for /F "usebackq tokens=* delims=" %i in (`${cmd_str}`) do ( @echo !define ${var_def} "%i" >> "${${tmp_file_name_def}}" )'
!else
  ; Posix - sh
  !system 'echo "!define ${var_def} \"$(cmd_str)\"" >> "${${tmp_file_name_def}}"'
!endif
!macroend

#!define !define_from_env "!insertmacro !define_from_env"
#!macro !define_from_env def_flags var_def env_var
#!verbose push
#!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
#
#${!begin_cmd_include_file} _tmp_file_include
#${!add_cmd_define_from_env} _tmp_file_include "${def_flags}" ${var_def} "${env_var}"
#${!end_cmd_include_file} _tmp_file_include
#
#!verbose pop
#!macroend

!define !define_iff_exist "!insertmacro !define_iff_exist"
!macro !define_iff_exist var_def value file
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!begin_cmd_include_file} _tmp_file_include
${!add_cmd_define_iff_exist} _tmp_file_include ${var_def} ${value} ${file}
${!end_cmd_include_file} _tmp_file_include

!verbose pop
!macroend

!define !define_iff_exist_in_path "!insertmacro !define_iff_exist_in_path"
!macro !define_iff_exist_in_path var_def value file
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!begin_cmd_include_file} _tmp_file_include
${!add_cmd_define_iff_exist_in_path} _tmp_file_include ${var_def} ${value} ${file}
${!end_cmd_include_file} _tmp_file_include

!verbose pop
!macroend

!define !define_guid16 "!insertmacro !define_guid16"
!macro !define_guid16 var_def
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

; self tests: test uuidgen utility on existence
!ifdef NSIS_WIN32_MAKENSIS
  ${!define_iff_exist_in_path} _NSIS_SETUP_LIB_TOOLS_UUIDGEN_EXIST 1 "uuidgen.exe" ; see Windows SDK from Visual Studio
!else
  ${!define_iff_exist_in_path} _NSIS_SETUP_LIB_TOOLS_UUIDGEN_EXIST 1 "uuidgen" ; see libuuid package in linux
!endif

!if ${_NSIS_SETUP_LIB_TOOLS_UUIDGEN_EXIST} = 0
  !error "!define_guid16: uuidgen utility must exists in the PATH variable for execution from NSIS $\"!system$\" command!"
!endif

${!begin_cmd_include_file} _tmp_file_include
!ifdef NSIS_WIN32_MAKENSIS
  ; Windows - cmd.exe
  ${!add_cmd_define_from_cmd_stdout} _tmp_file_include "uuidgen.exe" `${var_def}`
!else
  ; Posix - sh
  ${!add_cmd_define_from_cmd_stdout} _tmp_file_include "uuidgen" `${var_def}`
!endif
${!end_cmd_include_file} _tmp_file_include

!verbose pop
!macroend

; include if variable defined and not zero
!define IncludeIf "!insertmacro IncludeIf"
!macro IncludeIf err_if_absent flag_var include_file
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${!define_if} VARIABLE_EXP_TRUE ${flag_var} <> 0
!ifdef VARIABLE_EXP_TRUE
  !undef VARIABLE_EXP_TRUE
  !if ${err_if_absent} = 0
    ${!define_iff_exist} INCLUDE_FILE_EXIST 1 "${include_file}"
    !ifdef INCLUDE_FILE_EXIST
      !undef INCLUDE_FILE_EXIST
      !verbose pop

      !include "${include_file}"

      !verbose push
      !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
    !endif
  !else
    !verbose pop

    !include "${include_file}"

    !verbose push
    !verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
  !endif
!else
  ; test include file on presence only
  !if ${err_if_absent} <> 0
    ${!define_iff_exist} INCLUDE_FILE_EXIST 1 "${include_file}"
    !ifdef INCLUDE_FILE_EXIST
      !undef INCLUDE_FILE_EXIST
    !else
      !error "$${IncludeIf}: ($\"${flag_var}$\" defined and not zero) potential include file does not exist: $\"${include_file}$\""
    !endif
  !endif
!endif

!verbose pop
!macroend

!macro _NoErrors _a _b _t _f
  IfErrors `${_f}` `${_t}`
!macroend
!define NoErrors `"" NoErrors ""`

!macro _FileNotExists _a _b _t _f
  IfFileExists `${_b}` `${_f}` `${_t}`
!macroend
!define FileNotExists `"" FileNotExists`

; Some libraries (like LogicLib) utilizes empty label names (see _If/_EndIf implementation).
; To avoid such bugged behaviour (goto logic should not even compile in that case) we must workaround the problem.
!define GotoImpl "!insertmacro GotoImpl"
!macro GotoImpl label
!if "${label}" == ""
  !error "Goto: label is not defined."
!endif

!verbose pop

Goto `${label}`

!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}
!macroend

!define Goto "!insertmacro Goto"
!macro Goto label
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${GotoImpl} `${label}`

!verbose pop
!macroend

!define GotoIf "!insertmacro GotoIf"
!macro GotoIf label exp
!verbose push
!verbose ${_NSIS_SETUP_LIB_PREPROCESSOR_VERBOSE_LEVEL}

${If} ${exp}
  ${GotoImpl} `${label}`
${EndIf}

!verbose pop
!macroend

!define SystemCallRegisterStaticMap "!insertmacro SystemCallRegisterStaticMap"
!macro SystemCallRegisterStaticMap var_def value
!if "${value}" == "$R0"
  !define ${var_def} "R0"
!else if "${value}" == "$R1"
  !define ${var_def} "R1"
!else if "${value}" == "$R2"
  !define ${var_def} "R2"
!else if "${value}" == "$R3"
  !define ${var_def} "R3"
!else if "${value}" == "$R4"
  !define ${var_def} "R4"
!else if "${value}" == "$R5"
  !define ${var_def} "R5"
!else if "${value}" == "$R6"
  !define ${var_def} "R6"
!else if "${value}" == "$R7"
  !define ${var_def} "R7"
!else if "${value}" == "$R8"
  !define ${var_def} "R8"
!else if "${value}" == "$R9"
  !define ${var_def} "R9"
!else if "${value}" == "$0"
  !define ${var_def} "r0"
!else if "${value}" == "$1"
  !define ${var_def} "r1"
!else if "${value}" == "$2"
  !define ${var_def} "r2"
!else if "${value}" == "$3"
  !define ${var_def} "r3"
!else if "${value}" == "$4"
  !define ${var_def} "r4"
!else if "${value}" == "$5"
  !define ${var_def} "r5"
!else if "${value}" == "$6"
  !define ${var_def} "r6"
!else if "${value}" == "$7"
  !define ${var_def} "r7"
!else if "${value}" == "$8"
  !define ${var_def} "r8"
!else if "${value}" == "$9"
  !define ${var_def} "r9"
!else
  !define ${var_def} ""
!endif
!macroend

!define SystemCallRegisterStaticMapOrError "!insertmacro SystemCallRegisterStaticMapOrError"
!macro SystemCallRegisterStaticMapOrError var_def value
${SystemCallRegisterStaticMap} "${var_def}" "${value}"
!if "${${var_def}}" == ""
  !error "SystemCallRegisterStaticMap: register is unknown: register=$\"${value}$\""
!endif
!macroend

!endif
