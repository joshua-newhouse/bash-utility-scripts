[[ "${LOGGING_SOURCE_GUARD}" == "INCLUDED" ]] && return
export LOGGING_SOURCE_GUARD="INCLUDED"

# Example usage in client script:
#   $ErrMessage "Some error with message ${some message}" "and output $(cat out.txt)"
#   $WarnMessage "Some warning with message ${some_message}" "and output $(cat out.txt)"
#   $InfoMessage "Some info with message ${some message}" "and output $(cat out.txt)"
#   $SuccessMessage "Some success message ${some message}" "and output $(cat out.txt)"


# If the output device does not support colors then setup logging without colors
if [[ -z "$(which tput)" ]] \
    || [[ ! -t 1 ]] \
    || [[ "$(tput colors 2>/dev/null)" -lt 9 ]]; then

    ErrMessage='eval echo -e "$(date +%F\ %T) [ERROR]\t$(basename "${0}")/${FUNCNAME[0]}/${LINENO}"'
    WarnMessage='eval echo -e "$(date +%F\ %T) [WARNING]\t$(basename "${0}")/${FUNCNAME[0]}/${LINENO}"'
    InfoMessage='eval echo -e "$(date +%F\ %T) [INFO]\t$(basename "${0}")/${FUNCNAME[0]}/${LINENO}"'
    SuccessMessage='eval echo -e "$(date +%F\ %T) [SUCCESS]\t$(basename "${0}")/${FUNCNAME[0]}/${LINENO}"'

    return
fi


# Setup colored logging
NO_COLOR='\033[0m'

Log() {
    local lineID="${1}"
    local msg="${2}"
    local type="${3}"
    local color="${4}"

    echo -e "${color}$(date +%F\ %T) [${type}]\t${lineID} ${msg} ${NO_COLOR}"
}

LogError() {
    Log "${1}" "${*:2}" "ERROR" "\033[1;31m"
}
export -f LogError
ErrMessage='eval LogError "$(echo -e $(basename "${0}")/${FUNCNAME[0]}/${LINENO})"'

LogWarn() {
    Log "${1}" "${*:2}" "WARNING" "\033[1;33m"
}
export -f LogWarn
WarnMessage='eval LogWarn "$(echo -e $(basename "${0}")/${FUNCNAME[0]}/${LINENO})"'

LogInfo() {
    Log "${1}" "${*:2}" "INFO" "\033[1;37m"
}
export -f LogInfo
InfoMessage='eval LogInfo "$(echo -e $(basename "${0}")/${FUNCNAME[0]}/${LINENO})"'

LogSuccess() {
    Log "${1}" "${*:2}" "SUCCESS" "\033[1;32m"
}
export -f LogSuccess
SuccessMessage='eval LogSuccess "$(echo -e $(basename "${0}")/${FUNCNAME[0]}/${LINENO})"'

