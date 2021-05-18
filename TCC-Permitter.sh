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
#     - BluetoothAlways  # Introduced by 11.0
#     - BluetoothPeripheral  # Introduced by 11.0
#     - BluetoothWhileInUse  # Introduced by 11.0
#     - Calendar
#     - Calls  # Introduced by 11.0
#     - Camera
#     - ContactsFull
#     - ContactsLimited
#     - DeveloperTool
#     - FaceID  # Introduced by 11.0
#     - Facebook
#     - FileProviderDomain
#     - FileProviderPresence
#     - KeyboardNetwork  # Introduced by 11.0
#     - LinkedIn
#     - ListenEvent
#     - Liverpool
#     - Location  # Gone from 11.0
#     - MSO  # Introduced by 11.0
#     - MediaLibrary
#     - Microphone
#     - Motion
#     - Photos
#     - PhotosAdd
#     - PostEvent
#     - Reminders
#     - ScreenCapture
#     - SensorKitAmbientLightSensor  # Introduced by 11.0
#     - SensorKitDeviceUsage  # Introduced by 11.0
#     - SensorKitElevation  # Introduced by 11.0
#     - SensorKitForegroundAppCategory  # Introduced by 11.0
#     - SensorKitKeyboardMetrics  # Introduced by 11.0
#     - SensorKitLocationMetrics  # Introduced by 11.0
#     - SensorKitMessageUsage  # Introduced by 11.0
#     - SensorKitMotion  # Introduced by 11.0
#     - SensorKitMotionHeartRate  # Introduced by 11.0
#     - SensorKitOdometer  # Introduced by 11.0
#     - SensorKitPedometer  # Introduced by 11.0
#     - SensorKitPhoneUsage  # Introduced by 11.0
#     - SensorKitSpeechMetrics  # Introduced by 11.0
#     - SensorKitStrideCalibration  # Introduced by 11.0
#     - SensorKitWatchAmbientLightSensor  # Introduced by 11.0
#     - SensorKitWatchFallStats  # Introduced by 11.0
#     - SensorKitWatchForegroundAppCategory  # Introduced by 11.0
#     - SensorKitWatchHeartRate  # Introduced by 11.0
#     - SensorKitWatchMotion  # Introduced by 11.0
#     - SensorKitWatchOnWristState  # Introduced by 11.0
#     - SensorKitWatchPedometer  # Introduced by 11.0
#     - SensorKitWatchSpeechMetrics  # Introduced by 11.0
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

VERSION='0.3.0'
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
#   $1: text to print
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
#   $1: text to print
# Outputs:
#   Writes a argument with timestamp to stdout
#######################################
print_error_log(){
  local timestamp
  timestamp=$(date +%F\ %T)

  echo "$timestamp [ERROR] $1"
}

# MARK: Main script

# This list was obtained with the following command
#
# 11.0 and later:
#   otool -V -s __TEXT __cstring /System/Library/PrivateFrameworks/TCC.framework/Versions/A/Resources/tccd | awk '{ print $2 }' | grep -E '^kTCCService.+' | sort | uniq
# 10.15 and older:
#   otool -V -s __TEXT __cstring /System/Library/PrivateFrameworks/TCC.framework/Versions/Current/TCC |awk '{ print $2 }' | grep -E '^kTCCService.+' | sort | uniq
TCC_SERVICE_NAME_LIST=(
"kTCCServiceAccessibility"
"kTCCServiceAddressBook"
"kTCCServiceAll"
"kTCCServiceAppleEvents"
"kTCCServiceBluetoothAlways"
"kTCCServiceBluetoothPeripheral"
"kTCCServiceBluetoothWhileInUse"
"kTCCServiceCalendar"
"kTCCServiceCalls"
"kTCCServiceCamera"
"kTCCServiceContactsFull"
"kTCCServiceContactsLimited"
"kTCCServiceDeveloperTool"
"kTCCServiceFaceID"
"kTCCServiceFacebook"
"kTCCServiceFileProviderDomain"
"kTCCServiceFileProviderPresence"
"kTCCServiceKeyboardNetwork"
"kTCCServiceLinkedIn"
"kTCCServiceListenEvent"
"kTCCServiceLiverpool"
"kTCCServiceLocation"
"kTCCServiceMSO"
"kTCCServiceMediaLibrary"
"kTCCServiceMicrophone"
"kTCCServiceMotion"
"kTCCServicePhotos"
"kTCCServicePhotosAdd"
"kTCCServicePostEvent"
"kTCCServiceReminders"
"kTCCServiceScreenCapture"
"kTCCServiceSensorKitAmbientLightSensor"
"kTCCServiceSensorKitDeviceUsage"
"kTCCServiceSensorKitElevation"
"kTCCServiceSensorKitForegroundAppCategory"
"kTCCServiceSensorKitKeyboardMetrics"
"kTCCServiceSensorKitLocationMetrics"
"kTCCServiceSensorKitMessageUsage"
"kTCCServiceSensorKitMotion"
"kTCCServiceSensorKitMotionHeartRate"
"kTCCServiceSensorKitOdometer"
"kTCCServiceSensorKitPedometer"
"kTCCServiceSensorKitPhoneUsage"
"kTCCServiceSensorKitSpeechMetrics"
"kTCCServiceSensorKitStrideCalibration"
"kTCCServiceSensorKitWatchAmbientLightSensor"
"kTCCServiceSensorKitWatchFallStats"
"kTCCServiceSensorKitWatchForegroundAppCategory"
"kTCCServiceSensorKitWatchHeartRate"
"kTCCServiceSensorKitWatchMotion"
"kTCCServiceSensorKitWatchOnWristState"
"kTCCServiceSensorKitWatchPedometer"
"kTCCServiceSensorKitWatchSpeechMetrics"
"kTCCServiceShareKit"
"kTCCServiceSinaWeibo"
"kTCCServiceSiri"
"kTCCServiceSpeechRecognition"
"kTCCServiceSystemPolicyAllFiles"
"kTCCServiceSystemPolicyDesktopFolder"
"kTCCServiceSystemPolicyDeveloperFiles"
"kTCCServiceSystemPolicyDocumentsFolder"
"kTCCServiceSystemPolicyDownloadsFolder"
"kTCCServiceSystemPolicyNetworkVolumes"
"kTCCServiceSystemPolicyRemovableVolumes"
"kTCCServiceSystemPolicySysAdminFiles"
"kTCCServiceTencentWeibo"
"kTCCServiceTwitter"
"kTCCServiceUbiquity"
"kTCCServiceWillow"
)
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
ALLOWING_TCC_SERVICE_SHORT_NAME_LIST=($(echo "${2}" | tr ',' ' '))

INVALID_TCC_SERVICE_SHORT_NAME_LIST=()
for ALLOWING_TCC_SERVICE_SHORT_NAME in "${ALLOWING_TCC_SERVICE_SHORT_NAME_LIST[@]}";do
  ALLOWING_TCC_SERVICE_NAME="kTCCService${ALLOWING_TCC_SERVICE_SHORT_NAME}"
  if ! (($TCC_SERVICE_NAME_LIST[(Ie)${ALLOWING_TCC_SERVICE_NAME}]));then
    INVALID_TCC_SERVICE_SHORT_NAME_LIST+=("${ALLOWING_TCC_SERVICE_SHORT_NAME}")
  fi
done

if [[ "${#INVALID_TCC_SERVICE_SHORT_NAME_LIST[@]}" -ne 0 ]];then
  print_error_log "${(j:, :)INVALID_TCC_SERVICE_SHORT_NAME_LIST} are invalid name as TCC Service."
  exit 1
fi

print_info_log "Start TCC-Permitter..."

CURRENT_USER=$(stat -f%Su /dev/console)
CURRENT_USER_HOME_DIRECTORY_PATH=$(dscl /Local/Default read "/Users/${CURRENT_USER}" NFSHomeDirectory | awk '{print $2}')
TCC_DB_PATH="${CURRENT_USER_HOME_DIRECTORY_PATH}/Library/Application Support/com.apple.TCC/TCC.db"

if [[ ! -e "${TCC_DB_PATH}" ]];then
  print_error_log "Perhaps you have not been granted full disk access rights in this execution environment."
  exit 1
fi

ACCESS_SCHEMA=$(run_as_user sqlite3 "${TCC_DB_PATH}" ".schema access")
HAS_AUTH_VALUE_COLUMN=$(echo "${ACCESS_SCHEMA}" | (grep auth_value || true))
if [[ "${HAS_AUTH_VALUE_COLUMN}" ]];then
  DENIED_SQL_CONDITION="auth_value = '0'"
  ALLOWED_SQL_CONDITION="auth_value = '2'"
else
  DENIED_SQL_CONDITION="allowed = '0'"
  ALLOWED_SQL_CONDITION="allowed = '1'"
fi

for ALLOWING_TCC_SERVICE_SHORT_NAME in "${ALLOWING_TCC_SERVICE_SHORT_NAME_LIST[@]}";do
  print_info_log "Granting ${ALLOWING_TCC_SERVICE_SHORT_NAME}..."

  TCC_NOT_ALLOWED_ACCESS_PRESENT=$(run_as_user sqlite3 "${TCC_DB_PATH}" "SELECT service FROM access WHERE ${DENIED_SQL_CONDITION} AND client = '${BUNDLE_ID_OR_BINARY_PATH}' AND service = 'kTCCService${ALLOWING_TCC_SERVICE_SHORT_NAME}'")

  if [[ ! "${TCC_NOT_ALLOWED_ACCESS_PRESENT}" ]];then
    TCC_ALLOWED_ACCESS_PRESENT=$(run_as_user sqlite3 "${TCC_DB_PATH}" "SELECT service FROM access WHERE ${ALLOWED_SQL_CONDITION} AND client = '${BUNDLE_ID_OR_BINARY_PATH}' AND service = 'kTCCService${ALLOWING_TCC_SERVICE_SHORT_NAME}'")

    if [[ "${TCC_ALLOWED_ACCESS_PRESENT}" ]];then
      print_info_log "${ALLOWING_TCC_SERVICE_SHORT_NAME} of ${BUNDLE_ID_OR_BINARY_PATH} is already allowed."
    else
      print_info_log "There does not seem to be a single prompt for TCC access rights yet."
    fi
  else
    run_as_user sqlite3 "${TCC_DB_PATH}" "UPDATE access SET ${ALLOWED_SQL_CONDITION}, last_modified = '$(date +%s)' WHERE ${DENIED_SQL_CONDITION} AND client = '${BUNDLE_ID_OR_BINARY_PATH}' AND service = 'kTCCService${ALLOWING_TCC_SERVICE_SHORT_NAME}'"

    print_info_log "Successfully allowed for ${ALLOWING_TCC_SERVICE_SHORT_NAME} TCC service of ${BUNDLE_ID_OR_BINARY_PATH}."
  fi
done

exit 0
