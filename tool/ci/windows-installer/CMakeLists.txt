# .msi for the Windows release runner directory (CPack + WiX v3). Driven by
# tool/ci/package_artifacts.sh --target windows; modelled on
# toxee/tool/ci/windows-installer.
cmake_minimum_required(VERSION 3.16)
project(morsecq_windows_installer LANGUAGES NONE)

foreach(_var MORSECQ_INSTALLER_SOURCE_DIR MORSECQ_RELEASE_VERSION MORSECQ_PACKAGE_ARCH)
  if(NOT DEFINED ${_var} OR "${${_var}}" STREQUAL "")
    message(FATAL_ERROR "${_var} is required")
  endif()
endforeach()
if(NOT EXISTS "${MORSECQ_INSTALLER_SOURCE_DIR}/morsecq.exe")
  message(FATAL_ERROR "No morsecq.exe in ${MORSECQ_INSTALLER_SOURCE_DIR}")
endif()

set(_app_dir "${CMAKE_CURRENT_LIST_DIR}/../../../apps/morsecq")

# CPACK_PACKAGE_NAME is the WiX product name: what Add/Remove Programs shows.
# The .msi file name (CPACK_PACKAGE_FILE_NAME) and morsecq.exe stay lowercase.
set(CPACK_PACKAGE_NAME "MorseCQ")
set(CPACK_PACKAGE_VENDOR "agentx-icu")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Morse code trainer and serverless Morse chat over Tox")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/agentx-icu/morsecq")
set(CPACK_PACKAGE_VERSION "${MORSECQ_RELEASE_VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "MorseCQ")
# Start-menu shortcut "MorseCQ" -> morsecq.exe
set(CPACK_PACKAGE_EXECUTABLES "morsecq;MorseCQ")
set(CPACK_PACKAGE_FILE_NAME "morsecq-${MORSECQ_RELEASE_VERSION}-windows-${MORSECQ_PACKAGE_ARCH}")
set(CPACK_GENERATOR "WIX")
# LANGUAGES NONE leaves the pointer size unset, and CPack then builds an x86
# package into "Program Files (x86)"; the runner is x64.
set(CPACK_WIX_SIZEOF_VOID_P 8)
set(CPACK_WIX_ARCHITECTURE x64)
# Fixed forever: lets a newer .msi upgrade an installed older one in place.
set(CPACK_WIX_UPGRADE_GUID "D6EFE18F-E131-44A3-B026-E5A5BD9BFECF")
set(CPACK_WIX_PRODUCT_ICON "${_app_dir}/windows/runner/resources/app_icon.ico")
set(CPACK_WIX_PROGRAM_MENU_FOLDER "MorseCQ")
set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "https://github.com/agentx-icu/morsecq")

# WiX wants the licence as .txt/.rtf.
file(READ "${CMAKE_CURRENT_LIST_DIR}/../../../LICENSE" _licence)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/LICENSE.txt" "${_licence}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_BINARY_DIR}/LICENSE.txt")

install(DIRECTORY "${MORSECQ_INSTALLER_SOURCE_DIR}/" DESTINATION "." USE_SOURCE_PERMISSIONS)

include(CPack)
