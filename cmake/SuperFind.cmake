include(ExternalProject)

#if(NOT DEFINED ep_base)
  if(NOT WIN32)
    set(ep_base "/tmp/cmake-build/third-party")
  else()
    set(ep_base "C:/cmake-build/third-party")
  endif()
  set_property(DIRECTORY PROPERTY "EP_BASE" ${ep_base})
#endif()
  
#    if(NOT DEFINED EP_URL)
set(EP_URL "https://github.com/rashadkm")
#  endif()
  
#if(NOT DEFINED SEARCH_PACKAGE_QUIETLY)
  set(SEARCH_PACKAGE_QUIETLY FALSE)
#endif()
  
function(super_find_package name)
    include (CMakeParseArguments)
    set(options OPTIONAL REQUIRED QUIET EXACT MODULE)
    set(oneValueArgs DEFAULT VERSION REPO)
    set(multiValueArgs CMAKE_ARGS COMPONENTS)
    cmake_parse_arguments(super_find_package "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )  

    if (super_find_package_REQUIRED OR super_find_package_DEFAULT)
        set(_WITH_OPTION_DEFAULT TRUE)
    else()  
        set(_WITH_OPTION_DEFAULT TRUE)
    endif()
    
    set(WITHOPT "${WITHOPT}option(WITH_${name} \"Set ON to use ${name}\" ${_WITH_OPTION_ON})\n")
    set(WITHOPT "${WITHOPT}option(WITH_${name}_EXTERNAL \"Set ON to use external ${name}\" OFF)\n")

    option(WITH_${name} "Set ON to use ${name}" ${_WITH_OPTION_DEFAULT})

    if(${WITH_${name}})
      simple_message("WITH_${name} is set. Searching ${PKG_NAME}")     
      set(PKG_NAME ${name})
      if (super_find_package_REPO)
	set(PKG_REPO ${super_find_package_REPO})
      else()
	set(PKG_REPO ${PKG_NAME})
      endif()

      if(EXISTS ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake)
	find_package(${PKG_NAME} PATHS ${ep_base}/Build/${PKG_NAME})
	if(${PKG_NAME}_FOUND)
	  simple_message("Found ${PKG_NAME} from ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake")
	endif()
      else()
	message(STATUS "[SuperFind] ${PKG_NAME} no config")
	#find_package(${PKG_NAME} QUIET)
	if(${PKG_NAME}_FOUND)
          simple_message("Found ${PKG_NAME} from find_package(${PKG_NAME} QUIET)")
	endif()
      endif()
      
      if(${PKG_NAME}_FOUND)
	add_custom_target(${PKG_NAME}
	  COMMAND ${CMAKE_COMMAND} --build "${ep_base}/Build/${PKG_NAME}"
	  WORKING_DIRECTORY "${ep_base}/Build/${PKG_NAME}")
      endif()
      
      if(NOT ${PKG_NAME}_FOUND)
	simple_message("Adding ExternalProject ${PKG_NAME}")
	ExternalProject_Add(${PKG_NAME}
	  GIT_REPOSITORY ${EP_URL}/${PKG_REPO}
	  DOWNLOAD_COMMAND ""
	  CONFIGURE_COMMAND ""
	  UPDATE_COMMAND ""        
	  INSTALL_COMMAND)
	set(${PKG_NAME}_INSTALL_DIR ${ep_base}/Install/${PKG_NAME})
	
	if(NOT DEFINED GIT_EXECUTABLE)
	  find_package(Git)
	endif()
	
    #download source code.
    if(NOT EXISTS "${ep_base}/Stamp/${PKG_NAME}/${PKG_NAME}-download")
      simple_message("Downloading sources via git clone ${EP_URL}/${PKG_REPO}")
      execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 ${EP_URL}/${PKG_REPO} ${PKG_NAME}
	WORKING_DIRECTORY  ${ep_base}/Source RESULT_VARIABLE clone_rv)
      if(NOT clone_rv)
	execute_process(COMMAND ${CMAKE_COMMAND}  -E touch "${PKG_NAME}-download"
          WORKING_DIRECTORY ${ep_base}/Stamp/${PKG_NAME} )
      else()
        message(FATAL_ERROR "error cloning sources")
        return()
      endif()
    else()
      simple_message("updating sources via git pull")
      execute_process(COMMAND ${GIT_EXECUTABLE} pull WORKING_DIRECTORY ${ep_base}/Source/${PKG_NAME})	
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
  endif() #end Adding ExternalProject(
endif()     # if(WITH_${name})
endfunction()


macro(simple_message msg)
  if(NOT SEARCH_PACKAGE_QUIETLY)
    message(STATUS "[SearchPackage] ${msg}")
  endif()
endmacro()
