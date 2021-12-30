[[ "${ARRAY_ITERATOR_SOURCE_GUARD}" == "INCLUDED" ]] && return
export ARRAY_ITERATOR_SOURCE_GUARD="INCLUDED"

# Iterates over every element in an array and performs the specified action
#   on each element.
#   Returns 0 if the action is successful on all elements
#       Otherwise returns the number of failed elements
#
# Example usage in a client script
#   testArray=("file1" "file2" "file3")
#
#   SomeFuntion -> a function that takes a single element of the array as the
#       first parameter
#       and then optionally other parameters (sf1, sf2, ..., sfN).
#       Must return 0 on success or non-zero on failure
#
#   ForEachElement testArray SomeFunction sf1, sf2, ..., sfN
#   [[ $? -ne 0 ]] && do something on failure

LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source ${LIB_DIR}/logging.sh

ForEachElement() {
    local thisArray="${1}[@]"
    local action="${2}"; shift 2
    local actionArgs="$*"

    thisArray=( "${!thisArray}" )
    local withMessage=${actionArgs:+" with args: ${actionArgs}"}

    local rc=0

    for element in "${thisArray[@]}"; do
        echo "Executing action ${action} on element ${element}${withMessage}."

        $action "${element}" ${actionArgs}
        [[ $? -ne 0 ]] \
            && $WarnMessage "${action} failed on ${element}" \
            && ((rc++))
    done

    return ${rc}
}

