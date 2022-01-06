#!/bin/bash

source "$(dirname "${0}")"/../lib/logging.sh
source "$(dirname "${0}")"/../lib/array-iterator.sh
source "$(dirname "${0}")"/../lib/requirements-check.sh

IsRemoteAvailable() {
    local host="${1}"

    nslookup "${host}" > /dev/null \
        && ping -c 4 "${host}" 2>&1 > /dev/null
    [[ $? -ne 0 ]] && $ErrMessage "Host ${host} is not available." && return 1

    return 0
}

#Refactor to capture env and only take additional args as param
BackupDirectory() {
    local directory="${1}"
    local port="${2}"
    local user="${3}"
    local host="${4}"
    local remoteDir="${5}"
    local logFile="${6}"

    $InfoMessage "Backing up ${directory}"

    rsync -e "ssh -p ${port} -i ~/.ssh/id_rsa" \
            -aPR \
            --exclude=".Trash*" \
            --exclude="*LocalStorage*" \
            "${directory}" "${user}@${host}:${remoteDir}" 2>> "${logFile}"

    return $?
}

Main() {
#    local confFile="${1:-"$(dirname "${0}")"/../conf/backup.conf}"

#    source "${confFile}"
    [[ -f "${1}" ]] && source "${1}" \
        || source "$(dirname "${0}")"/../conf/backup.conf

    ReqsCheck "nslookup" "ping" "rsync" \
        && EnvCheck "USER" "HOST" "PORT" "ERROR_LOG" "LOCAL_DIRS" "REMOTE_DIR"
    [[ $? -ne 0 ]] && $ErrMessage "Script requirements not met." && return 1

    IsRemoteAvailable "${HOST}"
    [[ $? -ne 0 ]] && return 1

    $InfoMessage "Removing error log from previous run."
    rm -f "${ERROR_LOG}"

    ForEachElement LOCAL_DIRS BackupDirectory \
        "${PORT}" "${USER}" "${HOST}" "${REMOTE_DIR}" "${ERROR_LOG}"

    cat "${ERROR_LOG}"

    $SuccessMessage "Backup finished successfully."
    return 0
}

Main "$@"
exit $?

