# **********************************************************
#      2024 : Arthur JEULIN
#      Copyright (c) Coast Autonomous 
#      Created by Arthur JEULIN on 05/05/2024.
# **********************************************************
cmake_minimum_required(VERSION 3.27.5)


# RTMaps Package Name
set(PCK pck)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY C:/dev/rtmaps/user_sdk/packages/${PCK})

set(CMAKE_CXX_STANDARD 20)
set(POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)   # Enforce the C++ standard requirement
set(CMAKE_CXX_EXTENSIONS        OFF)  # Non-portable compiler-specific extensions are NOT required

if(UNIX)
    set(RTMAPS_SDKDIR "/opt/rtmaps")
endif()
if(WIN32)
    set(RTMAPS_SDKDIR "C:/Program Files/Intempora/RTMaps 4")
    set(rtmaps_input_reader "C:/Program Files/Intempora/RTMaps 4/packages/rtmaps_input_reader")
endif()
    
    
project("${PCK}.u"
  VERSION 0.0.1
  DESCRIPTION "pck RTMaps package"
  LANGUAGES C CXX
)


# If -D"RTMAPS_SDKDIR=<RTMaps Install Dir>" has NOT been passed to 
# the "cmake" command
if (NOT DEFINED RTMAPS_SDKDIR) 
# Try to use the default RTMaps installation
    if (DEFINED ENV{RTMAPS_SDKDIR})  
        set(RTMAPS_SDKDIR "$ENV{RTMAPS_SDKDIR}" 
        CACHE PATH "Path the RTMaps installation directory")
    else()
        message(FATAL_ERROR
        "RTMAPS_SDKDIR not defined. Either pass -D/"RTMAPS_SDKDIR=.../" 
        to CMake or define an RTMAPS_SDKDIR environment variable")
    endif()
endif()

if (NOT TARGET rtmaps_input_reader)
    # In this particular example, we know the path of of the rtmaps_input_readerConfig.cmake file.
    # In your custom components, you might want to use something like:
    set(rtmaps_input_reader_DIR "${RTMAPS_SDKDIR}/packages/rtmaps_input_reader/lib/cmake/rtmaps_input_reader" CACHE PATH "")
    if (NOT rtmaps_input_reader_DIR)
        get_filename_component(rtmaps_input_reader_DIR "${CMAKE_CURRENT_LIST_DIR}/../lib/cmake/rtmaps_input_reader" ABSOLUTE CACHE)
    endif()
    find_package(rtmaps_input_reader CONFIG REQUIRED NO_DEFAULT_PATH)
endif()



# REQUIRED: Include the RTMaps CMake configuration file
include("${RTMAPS_SDKDIR}/templates.u/rtmaps.cmake")


add_rtmaps_package(${PCK} PCKINFO "${PCK}.pckinfo"
    # add sources, headers and/or directories
    "local_interfaces"                    
    "src"                              
)


target_include_directories(${PCK} PRIVATE 
  ${PROJECT_SOURCE_DIR}/rtmaps/local_interfaces
)

# HIGHLY RECOMMENDED: Append useful compiler flags
if (MSVC)
    # Winmm.lib Needed in Windows to Gettime (API of Windows)
    target_link_libraries(${PCK}
    Winmm.lib 
    kernel32.lib
    rtmaps_input_reader
    )
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # NE BUILD PAS EN DEBUG AVEC RTMAPS
    # Options pour le mode Debug
    # Ne peut pas utiliser se flag pour une raison que j'igonre /MPd
    # rtmaps_pck.lib est compiler en release donc on ne peut pas utliser
    # certains flags de debug car non compatible => rechercher a faire
      target_compile_options(${PCK} PRIVATE  /W3 /WX /MD )
    elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
      # Options pour le mode Release
      target_compile_options(${PCK} PRIVATE /MD /MP /GL /W3 /WX -DNDEBUG)
    endif()
    # TO IMPROVE IN THE FUTURE
    # Trouver un moyen de ne pas à copier manuellement le nom des dll
    # Attention *.dll ne fonctionne pas sur windows
    #   add_custom_command(TARGET ${PCK} POST_BUILD
    #   # Create the bin folder next to the pck
    #   COMMAND ${CMAKE_COMMAND} -E make_directory C:/dev/rtmaps/user_sdk/packages/${PCK}/$<CONFIG>/bin
    #   # Copy the dll in the bin folder
    #   COMMAND ${CMAKE_COMMAND} -E copy_if_different
    #   C:/dev/rtmaps/user_sdk/packages/${PCK}/$<CONFIG>/gflags.dll
    #   C:/dev/rtmaps/user_sdk/packages/${PCK}/$<CONFIG>/glog.dll
    #   # Destination
    #   C:/dev/rtmaps/user_sdk/packages/${PCK}/$<CONFIG>/bin
      
      
    # # Delete the dll the where in the same folder as CMAKE_RUNTIME_OUTPUT_DIRECTORY
    # COMMAND ${CMAKE_COMMAND} -E remove
    #   C:/dev/rtmaps/user_sdk/packages/${PCK}/$<CONFIG>/gflags.dll
    #   C:/dev/rtmaps/user_sdk/packages/${PCK}/$<CONFIG>/glog.dll
    #   VERBATIM
    #   )
      
else()
  # LINUX 
    target_link_libraries(${PCK})
    target_compile_options(${PCK} PRIVATE
    -Wall -Wextra -Wpedantic -finline-functions -fexceptions 
    -O3 -fdiagnostics-show-option -pedantic)
endif()


if(WIN32)
  install(TARGETS ${PCK}
          CONFIGURATIONS Release
          RUNTIME DESTINATION ${RTMAPS_SDKDIR}/user_sdk/packages/${PCK}
  )
  # this copies more than strictly necessary but I don't know how to do it better
  install(DIRECTORY 
        "C:/dev/rtmaps/user_sdk/packages/${PCK}/Release/bin"
         # Destination (pas besoin d'ajouter bin dans le chemin on copie le dossier bin)
         DESTINATION ${RTMAPS_SDKDIR}/user_sdk/packages/${PCK}
  )
endif()
