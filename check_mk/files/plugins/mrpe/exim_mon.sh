#!/bin/bash

# ########################################################################
# Script to return EXIM .... @TODO: in Nagios MRPE format.
#
# Loosely based on:
# @TODO: urls
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
readonly STATE_OK; readonly STATE_WARNING; readonly STATE_CRITICAL;readonly STATE_UNKNOWN

# ########################################################################
# Run the program.
# ########################################################################
main() {
    # Declare local variables.
    local OPT_COMP; local OPT_CHCK; local OPT_CRIT; local OPT_WARN
	local OPT_ERR
    local CHECK_OUTPUT
    local VAL; local UOM; local STATUS_OUTPUT; local LONG_OUTPUT
    local STATE_OUTPUT
    local PERFDATA_MAX; local PERFDATA
    # Get options.
    for o; do
        case "${o}" in
            -a|--action)         shift; OPT_CHCK="${1}"; shift; ;;
            -c|--critical)       shift; OPT_CRIT="${1}"; shift; ;;
            -C|--compare)        shift; OPT_COMP="${1}"; shift; ;;
            -w|--warning)        shift; OPT_WARN="${1}"; shift; ;;
            -*)                  echo "Unknown option ${o}."; exit 1; ;;
        esac
    done
    # Set default option values.
    OPT_COMP="${OPT_COMP:->=}"
    OPT_CHCK="${OPT_CHCK:-recommendations}"
    OPT_CRIT="${OPT_CRIT:-None}"
    OPT_WARN="${OPT_WARN:-None}"

    # Validate the options.
    case "${OPT_COMP}" in
        '=='|'<'|'<='|'!='|'>='|'>')
            ;;
        *)
            OPT_ERR="-C/--compare must be one of: '==', '!=', '>=', '>', '<', '<=' (provided input: '${OPT_COMP}')"
            ;;
    esac

    case "${OPT_CRIT#-}" in
        None)
            # `None` is the only excepted non-numeric value.
            ;;
        '.'|*.*.*|''|*[!0-9.]*)
            OPT_ERR="-c/--critical must be numeric (provided input: '${OPT_CRIT}')"
            ;;
        *)
            ;;
    esac
	
    case "${OPT_WARN#-}" in
        None)
            # `None` is the only excepted non-numeric value.
            ;;
        '.'|*.*.*|''|*[!0-9.]*)
            OPT_ERR="-w/--warning must be numeric (provided input: '${OPT_WARN}')"
            ;;
        *)
            ;;
    esac
	
    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi

    case "${OPT_CHCK}" in
        'mail_queue_length')
            CHECK_OUTPUT=$(mail_queue_length)
            ;;
        *)
            echo "Error: -a/--action '${OPT_CHCK}' not recognized"
			exit 1
            ;;
    esac

    # split the check output based on the delimiter '|'.
    IFS_OLD=$IFS
    IFS="|"
	read -r -a CHECK_OUTPUT_ARR <<< "${CHECK_OUTPUT}"
    IFS=$IFS_OLD

    VAL="${CHECK_OUTPUT_ARR[0]}"
    UOM="${CHECK_OUTPUT_ARR[1]}"  # unit of measurement
    STATUS_OUTPUT="${CHECK_OUTPUT_ARR[2]}"
	LONG_OUTPUT="${CHECK_OUTPUT_ARR[3]}"

    # Compare the check value with warning/critical thresholds
    # to define the check state.
    case $(compare_result "${VAL}" "${OPT_CRIT}" "${OPT_WARN}" "${OPT_COMP}") in
        "${STATE_OK}")
            STATE_OUTPUT="OK - ${STATUS_OUTPUT}"
            ;;
        "${STATE_CRITICAL}")
            STATE_OUTPUT="CRIT - ${STATUS_OUTPUT}"
            ;;
        "${STATE_WARNING}")
            STATE_OUTPUT="WARN - ${STATUS_OUTPUT}"
            ;;
        *)
            # Set default output state and description.
            STATE_OUTPUT="UNK Could not evaluate the expression. Output: ${OUTPUT}"
            ;;
    esac

    # Build the common performance data output for graph trending
    # Expected perfdata format: 'label'=value[UOM];[warn];[crit];[min];[max]
    # https://nagios-plugins.org/doc/guidelines.html#AEN200
    if [ "${UOM}" = "%" ]; then
		PERFDATA_MAX=100
    fi

    # Set `None` thresholds to null for the perfdata.
	PERFDATA="${OPT_CHCK}=${VAL}${UOM};${OPT_WARN/None/''};${OPT_CRIT/None/''};0;${PERFDATA_MAX}"
	echo "${STATE_OUTPUT}|${PERFDATA}"
    # Add specific extended/multiline output, if any.
    if [ -n "${LONG_OUTPUT}" ]; then
        echo "${LONG_OUTPUT}"
		echo ""
    fi
    # We'll print the threshold values in the long (multiline) output.
    echo "Thresholds - critical: ${OPT_COMP}${OPT_CRIT}, warning: ${OPT_COMP}${OPT_WARN}."
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
# @TODO:
# ########################################################################
mail_queue_length() {
    # Declare local variables.
    local QUEUE_LENGTH; local OUTPUT
    # Set variables with exim data.
    QUEUE_LENGTH=$(exim -bpc)
    # Logic & calculations	
    if (( QUEUE_LENGTH > 0 )); then
        OUTPUT="Mail is queing up: ${QUEUE_LENGTH} emails queued for delivery"
        # Export a summary of messages in the queue
        # (count, volume, oldest, newest, domain, and totals).
        exim -bp | exiqsumm > /var/log/exiqsumm.log
    else
        OUTPUT="Mail queue is empty - all good!"
    fi
    # Return check value & description
	echo "${QUEUE_LENGTH}||${OUTPUT}"
}

# ========================================================================
#                        CHECK FUNCTIONS - END
# ========================================================================

# ########################################################################
# Execute the program if it was not included from another file.
# This makes it possible to include without executing, and thus test.
# ########################################################################

MRPE_OUTPUT=$(main "$@")
case "${MRPE_OUTPUT}" in
    UNK*)  EXITSTATUS=$STATE_UNKNOWN;  ;;
    OK*)   EXITSTATUS=$STATE_OK;       ;;
    WARN*) EXITSTATUS=$STATE_WARNING;  ;;
    CRIT*) EXITSTATUS=$STATE_CRITICAL; ;;
    *)     EXITSTATUS=$STATE_UNKNOWN;  ;;
esac
echo "${MRPE_OUTPUT}"
exit $EXITSTATUS
