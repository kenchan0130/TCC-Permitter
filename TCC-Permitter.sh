#!/bin/zsh
#######################################
# Allow services that are denied in the TCC database.
# Arguments:
#   $1: Bundle ID or Binary path
#   $2: TCC service name, case sensitive
#       Multiple can be specified separated by commas
#     - Accessibility
#     - AddressBook
#     - All
#     - AppleEvents
#     - Calendar
#     - Camera
#     - ContactsFull
#     - ContactsLimited
#     - DeveloperTool
#     - Facebook
#     - FileProviderDomain
#     - FileProviderPresence
#     - LinkedIn
#     - ListenEvent
#     - Liverpool
#     - Location
#     - MediaLibrary
#     - Microphone
#     - Motion
#     - Photos
#     - PhotosAdd
#     - PostEvent
#     - Reminders
#     - ScreenCapture
#     - ShareKit
#     - SinaWeibo
#     - Siri
#     - SpeechRecognition
#     - SystemPolicyAllFiles
#     - SystemPolicyDesktopFolder
#     - SystemPolicyDeveloperFiles
#     - SystemPolicyDocumentsFolder
#     - SystemPolicyDownloadsFolder
#     - SystemPolicyNetworkVolumes
#     - SystemPolicyRemovableVolumes
#     - SystemPolicySysAdminFiles
#     - TencentWeibo
#     - Twitter
#     - Ubiquity
#     - Willow
#######################################

VERSION='0.2.1'
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# MARK: Functions

#######################################
# Run arguments as current user.
# Globals:
#   CURRENT_USER
# Arguments:
#   $@: Script to run
#######################################
run_as_user() {
  local uid
  uid=$(id -u "${CURRENT_USER}")
  launchctl asuser "${uid}" sudo -u "${CURRENT_USER}" "$@"
}

#######################################
# Output info log with timestamp.
# Arguments:
#   $@: Script to run
# Outputs:
#   Writes a argument with timestamp to stdout
#######################################
print_info_log(){
  local timestamp
  timestamp=$(date +%F\ %T)

  echo "$timestamp [INFO] $1"
}

#######################################
# Output error log with timestamp.
# Arguments:
#   $@: Script to run
# Outputs:
#   Writes a argument with timestamp to stdout
#######################################
print_error_log(){
  local timestamp
  timestamp=$(date +%F\ %T)

  echo "$timestamp [ERROR] $1"
}

#######################################
# Get TCC service list.
# Arguments:
#   None
# Outputs:
#   Writes TCC servcies list to stdout
#######################################
get_ttc_services(){
  strings /System/Library/PrivateFrameworks/TCC.framework/TCC | grep kTCCService | grep -v '%'
}

# MARK: Main script

autoload is-at-least

if ! is-at-least 10.14 "$(sw_vers -productVersion)";then
  # PPPC is available from Mojave
  print_error_log "TCC-Permiter requires at least macOS 10.14 Mojave."
  exit 98
fi

if [[ "${1}" = "/" ]];then
  # Jamf uses sends '/' as the first argument
  print_info_log "Shifting arguments for Jamf."
  shift 3
fi

if [[ "${1:l}" = "version" ]];then
  echo "${VERSION}"
  exit 0
fi

if [[ ! "${1}" ]];then
  print_error_log "You need to set Bundle ID or Binary path as first argument."
  exit 1
fi
BUNDLE_ID_OR_BINARY_PATH="${1}"

if [[ ! "${2}" ]];then
  print_error_log "You need to set service name as second argument."
  exit 1
fi
TCC_SERVICE_NAME_LIST=($(echo "${2}" | tr ',' ' '))

for TCC_SERVICE_NAME in "${TCC_SERVICE_NAME_LIST[@]}";do
  if ! get_ttc_services | sed -e 's/kTCCService//' | sort | grep -qE "^${TCC_SERVICE_NAME}$";then
    print_error_log "${TCC_SERVICE_NAME} is invalid name as TCC Service."
    exit 1
  fi
done

print_info_log "Start TCC-Permitter..."

CURRENT_USER=$(stat -f%Su /dev/console)
CURRENT_USER_HOME_DIRECTORY_PATH=$(dscl /Local/Default read "/Users/${CURRENT_USER}" NFSHomeDirectory | awk '{print $2}')
TCC_DB_PATH="${CURRENT_USER_HOME_DIRECTORY_PATH}/Library/Application Support/com.apple.TCC/TCC.db"

if [[ ! -e "${TCC_DB_PATH}" ]];then
  print_error_log "Perhaps you have not been granted full disk access rights in this execution environment."
  exit 1
fi

for TCC_SERVICE_NAME in "${TCC_SERVICE_NAME_LIST[@]}";do
  print_info_log "Granting ${TCC_SERVICE_NAME}..."

  TCC_NOT_ALLOWED_ACCESS_PRESENT=$(run_as_user sqlite3 "${TCC_DB_PATH}" "SELECT service FROM access WHERE allowed = '0' AND client = '${BUNDLE_ID_OR_BINARY_PATH}' AND service = 'kTCCService${TCC_SERVICE_NAME}'")

  if [[ ! "${TCC_NOT_ALLOWED_ACCESS_PRESENT}" ]];then
    TCC_ALLOWED_ACCESS_PRESENT=$(run_as_user sqlite3 "${TCC_DB_PATH}" "SELECT service FROM access WHERE allowed = '1' AND client = '${BUNDLE_ID_OR_BINARY_PATH}' AND service = 'kTCCService${TCC_SERVICE_NAME}'")

    if [[ "${TCC_ALLOWED_ACCESS_PRESENT}" ]];then
      print_info_log "${TCC_SERVICE_NAME} of ${BUNDLE_ID_OR_BINARY_PATH} is already allowed."
    else
      print_info_log "There does not seem to be a single prompt for TCC access rights yet."
    fi
  else
    run_as_user sqlite3 "${TCC_DB_PATH}" "UPDATE access SET allowed = '1', last_modified = '$(date +%s)' WHERE allowed = '0' AND client = '${BUNDLE_ID_OR_BINARY_PATH}' AND service = 'kTCCService${TCC_SERVICE_NAME}'"

    print_info_log "Successfully allowed for ${TCC_SERVICE_NAME} TCC service of ${BUNDLE_ID_OR_BINARY_PATH}."
  fi
done

exit 0
