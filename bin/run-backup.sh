#!/bin/bash

# The purpose of this script is to demonstrate the use of the library functions.
#
# The function of this script is to backup local directories to a remote
#   machine. The user provides necessary configurations through a config file
#   which can be provided as the first argument to this script or, if not
#   provided, defaults to the ../conf/backup.conf file.
#
#   ./runbackup.sh [path/to/config/file]

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

BackupDirectory() {
    local directory="${1}"; shift 1
    local rsyncOpts="$*"

    $InfoMessage "Backing up ${directory}"

    rsync -e "ssh -p ${PORT} -i ~/.ssh/id_rsa" ${rsyncOpts} \
            "${directory}" "${USER}@${HOST}:${REMOTE_DIR}" 2>> "${ERROR_LOG}"

    return $?
}

Main() {
    local confFile="${1:-"$(dirname "${0}")"/../conf/backup.conf}"

    [[ -f "${confFile}" ]] \
        && source "${confFile}" \
        && $InfoMessage "Sourced configuration from ${confFile}" \
        || $WarnMessage "Failed sourcing configuration from ${confFile}"

    ReqsCheck "nslookup" "ping" "rsync" \
        && EnvCheck "USER" "HOST" "PORT" "ERROR_LOG" "LOCAL_DIRS" "REMOTE_DIR"
    [[ $? -ne 0 ]] && $ErrMessage "Script requirements not met." && return 1

    IsRemoteAvailable "${HOST}"
    [[ $? -ne 0 ]] && return 1

    $InfoMessage "Removing error log from previous run."
    rm -f "${ERROR_LOG}"

    ForEachElement LOCAL_DIRS BackupDirectory \
        '-aPR' '--exclude=".Trash*"' '--exclude="*LocalStorage*"'

    cat "${ERROR_LOG}"

    $SuccessMessage "Backup finished successfully."
    return 0
}

Main "$@"
exit $?

