# SPDX-FileCopyrightText: 2012-2021 Istituto Italiano di Tecnologia (IIT)
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
GetAllCMakeProperties
---------------------

Return a list containing the names of all known CMake Properties.

Only properties returned by ``cmake --help-property-list`` are returned,
custom properties will not be on the returned list.

Properties containing ``<CONFIG>`` or ``<LANG>`` are expanded to the correct
property name.
#]=======================================================================]

cmake_policy(PUSH)
if(POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW)
endif()

function(GET_ALL_CMAKE_PROPERTIES _var)

  execute_process(COMMAND ${CMAKE_COMMAND} --help-property-list
                  OUTPUT_VARIABLE ${_var}
                  OUTPUT_STRIP_TRAILING_WHITESPACE)

  string(REGEX REPLACE "[\r\n]+" ";" ${_var} "${${_var}}")
  list(REMOVE_DUPLICATES ${_var})

  foreach(_prop_name ${${_var}})
    if("${_prop_name}" MATCHES "LOCATION")
      # Remove *LOCATION* properties (see CMP0026)
      list(REMOVE_ITEM _all_properties "${_prop_name}")
    elseif("${_prop_name}" MATCHES "<CONFIG>")
      # Replace all possible configurations
      list(REMOVE_ITEM ${_var} "${_prop_name}")
      foreach(_config Release Debug)
        string(TOUPPER "${_config}" _config)
        string(REPLACE "<CONFIG>" "${_config}" _prop_name_config "${_prop_name}")
        list(APPEND ${_var} ${_prop_name_config})
      endforeach()
    elseif("${_prop_name}" MATCHES "<LANG>")
      # Replace all possible languages
      list(REMOVE_ITEM ${_var} "${_prop_name}")
      foreach(_config C CXX Fortran)
        string(REPLACE "<LANG>" "${_config}" _prop_name_lang "${_prop_name}")
        list(APPEND ${_var} ${_prop_name_lang})
      endforeach()
    endif()
  endforeach()

  set(${_var} ${${_var}} PARENT_SCOPE)

endfunction()

cmake_policy(POP)
