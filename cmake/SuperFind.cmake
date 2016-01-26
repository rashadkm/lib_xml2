################################################################################
# Project:  SuperFind
# Purpose:  Common CMake script
# Author:   Rashad Kanavath, rashadkm@gmail.com
################################################################################
# Copyright (C) 2015, Rashad Kanavath <rashadkm@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

include(ExternalProject)

set(ZLIB_REPOSITORY_NAME "ZLIB")
set(LibLZMA_REPOSITORY_NAME "lib_lzma")
set(ICONV_REPOSITORY_NAME "lib_iconv")
set(LibXml2_REPOSITORY_NAME "lib_xml2")

#if(NOT DEFINED ep_base)
if(NOT WIN32)
  set(ep_base "/tmp/cmake-build/third-party")
else()
  set(ep_base "C:/cmake-build/third-party")
endif()
set_property(DIRECTORY PROPERTY "EP_BASE" ${ep_base})
#endif()
  
#if(NOT DEFINED EP_URL)
set(EP_URL "https://github.com/rashadkm")
#endif()
  
#if(NOT DEFINED SEARCH_PACKAGE_QUIETLY)
set(SEARCH_PACKAGE_QUIETLY FALSE)
#endif()
  
function(super_find_package name)
  include (CMakeParseArguments)
  set(options OPTIONAL REQUIRED QUIET EXACT MODULE)
  set(oneValueArgs DEFAULT VERSION REPOSITORY_NAME)
  set(multiValueArgs CMAKE_ARGS COMPONENTS)
  cmake_parse_arguments(super_find_package "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )  
  
  if (super_find_package_REQUIRED OR super_find_package_DEFAULT)
    set(_WITH_OPTION_DEFAULT FALSE)
  else()  
    set(_WITH_OPTION_DEFAULT FALSE)
  endif()

  set(_WITH_EXTERNAL_OPTION_DEFAULT FALSE)
  if(WIN32)
    set(_WITH_EXTERNAL_OPTION_DEFAULT TRUE)
  endif()
  
  option(WITH_${name} "Set ON to use ${name}" OFF)

  if(WITH_${name})    
    option(WITH_${name}_EXTERNAL "Set ON to use external ${name}" ${_WITH_EXTERNAL_OPTION_DEFAULT})

    set(${PKG_NAME}_OPTIONS)
    if(super_find_package_COMPONENTS)
      list(APPEND ${name}_OPTIONS "COMPONENTS ${super_find_package_COMPONENTS}")
    endif()
 
    if(WITH_${name}_EXTERNAL)
      
      set(PKG_NAME ${name})

      string(TOUPPER ${name} PKG_NAME_)
      simple_message("WITH_${name} is set. Searching for ${PKG_NAME}")
      find_package(${PKG_NAME} ${${PKG_NAME}_OPTIONS} QUIET)
      if(${PKG_NAME_}_FOUND)
        simple_message("Found ${PKG_NAME} from find_package(${PKG_NAME})")
	# do an empty target.
	add_custom_target(${PKG_NAME})

      else() # if(${PKG_NAME}_FOUND) find_package
	if(EXISTS ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake)

	  find_package(${PKG_NAME} ${${PKG_NAME}_OPTIONS} PATHS ${ep_base}/Build/${PKG_NAME})

	  if(${PKG_NAME_}_FOUND)
	    simple_message("Found ${PKG_NAME} from ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake")
	    set( ${PKG_NAME_}_FOUND_FROM_CONFIG TRUE CACHE "" INTERNAL)
	    add_custom_target(${PKG_NAME}
	      COMMAND ${CMAKE_COMMAND} --build "${ep_base}/Build/${PKG_NAME}"
	      WORKING_DIRECTORY "${ep_base}/Build/${PKG_NAME}")
	  endif()
	else() #if(EXISTS ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake)
	  
	  if(NOT DEFINED GIT_EXECUTABLE)
	    find_package(Git)
	  endif()
	  
	  #find the repo name.
	  if(super_find_package_REPOSITORY_NAME)
	    set(PKG_REPOSITORY_NAME ${super_find_package_REPOSITORY_NAME})
	  elseif(${PKG_NAME}_REPOSITORY_NAME)
	    set(PKG_REPOSITORY_NAME ${${PKG_NAME}_REPOSITORY_NAME})
	  else()
	    set(PKG_REPOSITORY_NAME ${PKG_NAME})
	  endif()
	  
	  simple_message("Adding ExternalProject ${PKG_NAME}")
	  
	  ExternalProject_Add(${PKG_NAME}
	    GIT_REPOSITORY ${EP_URL}/${PKG_REPOSITORY_NAME}
	    DOWNLOAD_COMMAND ""
	    CONFIGURE_COMMAND ""
	    UPDATE_COMMAND ""        
	    INSTALL_COMMAND)
	  
	  set(${PKG_NAME}_INSTALL_DIR ${ep_base}/Install/${PKG_NAME})
	  
	  #download source code.
	  if(NOT EXISTS "${ep_base}/Stamp/${PKG_NAME}/${PKG_NAME}-download")
	    simple_message("Downloading sources via git clone ${EP_URL}/${PKG_REPOSITORY_NAME}")
	    execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 ${EP_URL}/${PKG_REPOSITORY_NAME} ${PKG_NAME}
	      WORKING_DIRECTORY  ${ep_base}/Source RESULT_VARIABLE clone_rv)
	    if(NOT clone_rv)
	      execute_process(COMMAND ${CMAKE_COMMAND}  -E touch "${PKG_NAME}-download"
		WORKING_DIRECTORY ${ep_base}/Stamp/${PKG_NAME} )
	    else()
              message(FATAL_ERROR "error cloning sources")
              return()
	    endif()
	  endif() #if(NOT EXISTS "${ep_base}/Stamp/${PKG_NAME}/${PKG_NAME}-download")
	  
	endif() #if(EXISTS ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake)
      endif() # if(${PKG_NAME}_FOUND) find_package
      
      if(${PKG_NAME_}_FOUND AND ${PKG_NAME_}_FOUND_FROM_CONFIG)
	get_last_commit_id(${PKG_NAME} commit_id_before_pull)
	simple_message("updating sources. HEAD is now at: ${commit_id_before_pull}")
	
	execute_process(COMMAND ${GIT_EXECUTABLE} pull
	  WORKING_DIRECTORY ${ep_base}/Source/${PKG_NAME}
	  OUTPUT_VARIABLE pull_ov)
	
	get_last_commit_id(${PKG_NAME} commit_id_after_pull)
	if(NOT "${commit_id_after_pull}" STREQUAL "${commit_id_before_pull}")
	  simple_message("Sources changed. HEAD is now at: ${commit_id_after_pull}")
	  execute_process(COMMAND
	    ${CMAKE_COMMAND} -E remove_directory "${ep_base}/Build/${PKG_NAME}"
	    WORKING_DIRECTORY ${ep_base}/Build/${PKG_NAME})   
	endif()
	
	#configure
	if(NOT super_find_package_CMAKE_ARGS)
	  set(super_find_package_CMAKE_ARGS "-G${CMAKE_GENERATOR}")
	else()
	  set(super_find_package_CMAKE_ARGS "${super_find_package_CMAKE_ARGS} -G${CMAKE_GENERATOR}")
	endif()
	simple_message("Running cmake configure on ${ep_base}/Source/${PKG_NAME}")    
	execute_process(COMMAND ${CMAKE_COMMAND} ${ep_base}/Source/${PKG_NAME}
	  "-DCMAKE_INSTALL_PREFIX=${${PKG_NAME}_INSTALL_DIR}"
	  "-DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}"
	  "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
	  "${super_find_package_CMAKE_ARGS}"
	  WORKING_DIRECTORY ${ep_base}/Build/${PKG_NAME}
	  RESULT_VARIABLE configure_rv)
	
	if(NOT configure_rv)
	  simple_message("Loading config file from ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake")
	  include(${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake)
	else()
	  message(FATAL_ERROR "error running cmake configure on ${PKG_NAME}")
	endif()	
      endif()  #if(NOT ${PKG_NAME}_FOUND OR EXISTS "${ep_base}/Stamp/${PKG_NAME}/${PKG_NAME}-download")
    else()
      find_package(${name} ${${PKG_NAME}_OPTIONS} REQUIRED)            
    endif() # 	if(${WITH_EXTERNAL_${name}})
     
  endif()     # if(WITH_${name})

    string(TOUPPER ${name} name_)
    set(TARGET_LINK_LIBS ${TARGET_LINK_LIBS} ${${name_}_LIBRARIES} PARENT_SCOPE)
  endfunction()
  

macro(simple_message msg)
  if(NOT SEARCH_PACKAGE_QUIETLY)
    message(STATUS "[SearchPackage] ${msg}")
  endif()
endmacro()

function(get_last_commit_id source_dir result)
  find_package(Git)
  set(${result})
  execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${ep_base}/Source/${source_dir}
    ${GIT_EXECUTABLE} rev-parse HEAD
    OUTPUT_VARIABLE commit_id)
  set(${result} ${commit_id} PARENT_SCOPE)
endfunction()

if(NOT TARGET cleanall)
  add_custom_target(cleanall
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${ep_base}"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
endif()
