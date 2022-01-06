[[ "${REQUIREMENTS_CHECK_SOURCE_GUARD}" == "INCLUDED" ]] && return
export REQUIREMENTS_CHECK_SOURCE_GUARD="INCLUDED"

# Example usage in a client script that requires docker, yum, and curl:
#   ReqsCheck "docker" "yum" "curl"
#   [[ $? -ne 0 ]] && $ErrMessage "Script requirements not met"

LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source ${LIB_DIR}/logging.sh

ReqsCheck() {
    local rc=0

    for req in "$@"; do
        which "${req}" 2>&1 > /dev/null
        [[ $? -ne 0 ]] \
            && $WarnMessage "Requirement \'${req}\' is not met." \
            && rc=1
    done

    return ${rc}
}

EnvCheck() {
    local rc=0

    for envVar in "$@"; do
        [[ -z "${!envVar}" ]] \
            && $WarnMessage "Variable ${envVar} is not set in the environment." \
            && rc=1
    done

    return ${rc}
}

