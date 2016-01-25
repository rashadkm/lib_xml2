include(ExternalProject)

find_package(Git)
if(NOT WIN32)
  set(ep_base "/tmp/cmake-build/third-party")
else()
  set(ep_base "C:/cmake-build/third-party")
endif()
set_property(DIRECTORY PROPERTY "EP_BASE" ${ep_base})
set(EP_URL "https://github.com/rashadkm")

function(super_find_package name)
    include (CMakeParseArguments)
    set(options OPTIONAL REQUIRED QUIET EXACT MODULE)
    set(oneValueArgs DEFAULT VERSION REPO)
    set(multiValueArgs CMAKE_ARGS COMPONENTS)
    cmake_parse_arguments(super_find_package "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )  

    if (super_find_package_REQUIRED OR super_find_package_DEFAULT)
        set(_WITH_OPTION_ON TRUE)
    else()  
        set(_WITH_OPTION_ON FALSE)
    endif()
    
    set(WITHOPT "${WITHOPT}option(WITH_${name} \"Set ON to use ${name}\" ${_WITH_OPTION_ON})\n")
    set(WITHOPT "${WITHOPT}option(WITH_${name}_EXTERNAL \"Set ON to use external ${name}\" OFF)\n")

    option(WITH_${name} "Set ON to use ${name}" ${_WITH_OPTION_ON})
  
    set(PKG_NAME ${name})
    if (super_find_package_REPO)
      set(PKG_REPO ${super_find_package_REPO})
    else()
      set(PKG_REPO ${PKG_NAME})
    endif()
#    message(FATAL_ERROR "super_find_package_repourl=${super_find_package_REPO}")
    
      
  # set (extra_args ${ARGN})
  # list(LENGTH extra_args num_extra_args)
  # if (${num_extra_args} GREATER 0)
  #   list(GET extra_args 0 PKG_REPO)
  # endif ()

  if(EXISTS ${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake)
    message(STATUS "[SuperFind] ${PKG_NAME} using config from ${ep_base}/Build/${PKG_NAME}")
    find_package(${PKG_NAME} PATHS ${ep_base}/Build/${PKG_NAME})
  else()
    message(STATUS "[SuperFind] ${PKG_NAME} no config")
    find_package(${PKG_NAME} QUIET)
  endif()
  
  if(NOT ${PKG_NAME}_FOUND)
    message(STATUS "[SuperFind] Adding ExternalProject ${PKG_NAME}. update add_dependencies() if needed")    
    ExternalProject_Add(${PKG_NAME}
      GIT_REPOSITORY ${EP_URL}/${PKG_REPO}
      DOWNLOAD_COMMAND ""
      CONFIGURE_COMMAND ""
      UPDATE_COMMAND ""        
      INSTALL_COMMAND)
    set(${PKG_NAME}_INSTALL_DIR ${ep_base}/Install/${PKG_NAME})
    
    #download source code.
    if(NOT EXISTS "${ep_base}/Stamp/${PKG_NAME}/${PKG_NAME}-download")
      execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 ${EP_URL}/${PKG_REPO} ${PKG_NAME}
        WORKING_DIRECTORY  ${ep_base}/Source)
      execute_process(COMMAND ${CMAKE_COMMAND}  -E touch "${PKG_NAME}-download"
        WORKING_DIRECTORY ${ep_base}/Stamp/${PKG_NAME} )  
    endif()

    #configure
    if(NOT super_find_package_CMAKE_ARGS)
      set(super_find_package_CMAKE_ARGS "-G${CMAKE_GENERATOR}")
    else()
      set(super_find_package_CMAKE_ARGS "${super_find_package_CMAKE_ARGS} -G${CMAKE_GENERATOR}")
    endif()
    
    execute_process(COMMAND ${CMAKE_COMMAND} ${ep_base}/Source/${PKG_NAME}
      "-DCMAKE_INSTALL_PREFIX=${${PKG_NAME}_INSTALL_DIR}"
      "-DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}"
      "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
      "${super_find_package_CMAKE_ARGS}"
	WORKING_DIRECTORY ${ep_base}/Build/${PKG_NAME} )

    include(${ep_base}/Build/${PKG_NAME}/${PKG_NAME}Config.cmake)
    
  endif()

endfunction()

