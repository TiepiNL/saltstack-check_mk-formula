#!/bin/bash

# ########################################################################
# Script to return MySQL deadlocks in Nagios MRPE format.
#
# Written in the same format as https://github.com/TiepiNL/saltstack-check_mk-formula/blob/master/check_mk/files/plugins/mrpe/mysqltuner.sh
#
# License: GPL License
# ########################################################################

# ########################################################################
# Redirect STDERR to STDOUT; Nagios doesn't handle STDERR.
# ########################################################################
exec 2>&1

# ########################################################################
# Set up constants, etc.
# ########################################################################
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

# ########################################################################
# Run the program.
# ########################################################################
main() {
    # Get options
    for o; do
        case "${o}" in
            -c|--critical)       shift; local OPT_CRIT="${1}"; shift; ;;
            -C|--compare)        shift; local OPT_COMP="${1}"; shift; ;;
			-f|--defaults-file)  shift; local OPT_FILE="${1}"; shift; ;;
            -w|--warning)        shift; local OPT_WARN="${1}"; shift; ;;
            -*)                  echo "Unknown option ${o}."; exit 1; ;;
        esac
    done
    # Set default option values
	local OPT_COMP="${OPT_COMP:->}"
    local OPT_CRIT="${OPT_CRIT:-None}"
	local OPT_WARN="${OPT_WARN:-0}"
	local OPT_FILE="${OPT_FILE:-/etc/check_mk/mysql.cnf}"

    # Validate the options.
    local OPT_ERR=""
	# Only allow compare options that make sense.
    case "${OPT_COMP}" in
        '>'|'>=')
            ;;
        *)
            local OPT_ERR="-C/--compare must be one of: '>=' '>' (provided input: '${OPT_COMP}')"
            ;;
    esac
    case "${OPT_CRIT}" in
        None)
            # `None` is the only excepted non-numeric value.
            ;;
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="-c/--critical must be numeric (provided input: '${OPT_CRIT}')"
            ;;
        *)
            ;;
    esac
    case "${OPT_WARN}" in
        None)
            # `None` is the only excepted non-numeric value.
            ;;
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="-w/--warning must be numeric (provided input: '${OPT_WARN}')"
            ;;
        *)
            ;;
    esac

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi

    # Call the actual deadlock function.
    local CHECK_OUTPUT=$(deadlocks)

    # split the check output based on the delimiter '|'.
    IFS_OLD=$IFS
    IFS="|"
    local CHECK_OUTPUT_ARR=(${CHECK_OUTPUT})
    IFS=$IFS_OLD

    local VAL="${CHECK_OUTPUT_ARR[0]}"
    local DESC="${CHECK_OUTPUT_ARR[1]}"

    # Compare the check value with warning/critical thresholds
    # to define the check state.
    case $(compare_result "${VAL}" "${OPT_CRIT}" "${OPT_WARN}"  "${OPT_COMP}") in
        $STATE_OK)
            local NOTE="OK - $DESC"
            ;;
        $STATE_CRITICAL)
            local NOTE="CRIT - $DESC"
            ;;
        $STATE_WARNING)
            local NOTE="WARN - $DESC"
            ;;
        *)
            # Set default output state and description.
            local NOTE="UNK Could not evaluate the expression. Output: $DESC"
            ;;
    esac

    # Set `None` thresholds to null for the perfdata.
    local PERFDATA="${OPT_CHCK}=${VAL};${OPT_WARN/None/''};${OPT_CRIT/None/''};0"
    local NOTE="${NOTE}|${PERFDATA}"

    echo $NOTE
}

# ########################################################################
# Compares the variable to the thresholds. Arguments: VAR CRIT WARN CMP
# Returns nothing; exits with OK/WARN/CRIT.
# ########################################################################
compare_result() {
    local VAL="${1}"
    local CRIT="${2}"
    local WARN="${3}"
    local COMP="${4}"

    # Possibilities:
    # * CRIT None, WARN None --> OK
    # * CRIT None, WARN set: match --> WARN
    # * CRIT None, WARN set: no match --> OK
    # * CRIT set: match, WARN None (irrelevant) --> CRIT
    # * CRIT set: match, WARN set (irrelevant) --> CRIT
    # * CRIT set: no match, WARN None --> OK
    # * CRIT set: no match, WARN set: match --> WARN
    # * CRIT set: no match, WARN set: no match --> OK
    if [ "${CRIT}" = "None" ] && [ "${WARN}" = "None" ]; then
        # CRIT None, WARN None --> OK
        echo $STATE_OK
    elif [ "${CRIT}" = "None" ] && [ ! "${WARN}" = "None" ]; then
        if (( $(bc -l <<< "${VAL} ${COMP} ${WARN}") )); then
            # CRIT None, WARN set: match --> WARN
            echo $STATE_WARNING
        else
            # CRIT None, WARN set: no match --> OK
            echo $STATE_OK
        fi
    elif [ ! "${CRIT}" = "None" ]; then
        if (( $(bc -l <<< "${VAL} ${COMP} ${CRIT}") )); then	
            # CRIT set: match, WARN None (irrelevant) --> CRIT, or
            # CRIT set: match, WARN set (irrelevant) --> CRIT
            echo $STATE_CRITICAL
        else
            if [ "${WARN}" = "None" ]; then
                # CRIT set: no match, WARN None --> OK
                echo $STATE_OK
            elif (( $(bc -l <<< "${VAL} ${COMP} ${WARN}") )); then
                # CRIT set: no match, WARN set: match --> WARN
                echo $STATE_WARNING
            else
                # CRIT set: no match, WARN set: no match --> OK
                echo $STATE_OK
            fi
        fi
    fi		
}

# ########################################################################
# deadlocks
# ########################################################################
deadlocks() {
    # Query SQL by using the credentials stored in the check_mk
    # mysql config file.
    local DEADLOCKS=$(echo 'SELECT COUNT FROM INNODB_METRICS WHERE name = "lock_deadlocks";' | mysql --defaults-file=${OPT_FILE} INFORMATION_SCHEMA | tail -n 1)

    if [[ ${DEADLOCKS} > 0 ]]; then
       local DESC="Deadlocks detected: ${DEADLOCKS}"
    else
       local DESC="No deadlocks detected - all good!"
    fi
    echo "${DEADLOCKS}|${DESC}"
}

# ########################################################################
# Execute the program if it was not included from another file.
# This makes it possible to include without executing, and thus test.
# ########################################################################
OUTPUT=$(main "$@")
case "${OUTPUT}" in
    UNK*)  EXITSTATUS=$STATE_UNKNOWN;  ;;
    OK*)   EXITSTATUS=$STATE_OK;       ;;
    WARN*) EXITSTATUS=$STATE_WARNING;  ;;
    CRIT*) EXITSTATUS=$STATE_CRITICAL; ;;
    *)     EXITSTATUS=$STATE_UNKNOWN;  ;;
esac
echo "${OUTPUT}"
exit $EXITSTATUS
