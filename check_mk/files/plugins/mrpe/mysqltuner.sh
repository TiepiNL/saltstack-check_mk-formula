#!/bin/bash

# ########################################################################
# Script to return mysqltuner json output in Nagios MRPE format.
#
# Checks and default thresholds are based on:
# https://github.com/major/MySQLTuner-perl
# https://github.com/BMDan/tuning-primer.sh/blob/master/tuning-primer.sh
# Parsing the mysqltuner json output is based on:
# https://github.com/sudoanand/bashjson
# Output format (Nagios MRPE) is based on:
# https://www.percona.com/doc/percona-monitoring-plugins/1.1/nagios/pmp-check-mysql-status.html
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

JSON_FILE="/var/log/mysqltuner_output.json"

# ########################################################################
# Run the program.
# ########################################################################
main() {
    # Get options
    for o; do
        case "${o}" in
            -a|--action)         shift; local OPT_CHCK="${1}"; shift; ;;
            -c|--critical)       shift; local OPT_CRIT="${1}"; shift; ;;
            -C|--compare)        shift; local OPT_COMP="${1}"; shift; ;;
            -w|--warning)        shift; local OPT_WARN="${1}"; shift; ;;
            -*)                  echo "Unknown option ${o}."; exit 1; ;;
        esac
    done
    # Set default option values
    local OPT_COMP="${OPT_COMP:->=}"
	local OPT_CHCK="${OPT_CHCK:-recommendations}"
	local OPT_CRIT="${OPT_CRIT:-None}"
	local OPT_WARN="${OPT_WARN:-None}"

    # Validate the options.
    local OPT_ERR=""
    case "${OPT_COMP}" in
        '=='|'<'|'<='|'!='|'>='|'>')
            ;;
        *)
            local OPT_ERR="-C/--compare must be one of: '==', '!=', '>=', '>', '<', '<=' (provided input: '${OPT_COMP}')"
            ;;
    esac

    case "${OPT_CRIT#-}" in
        None)
            # `None` is the only excepted non-numeric value.
            ;;
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="-c/--critical must be numeric (provided input: '${OPT_CRIT}')"
            ;;
        *)
            ;;
    esac
	
    case "${OPT_WARN#-}" in
        None)
            # `None` is the only excepted non-numeric value.
            ;;
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="-w/--warning must be numeric (provided input: '${OPT_WARN}')"
            ;;
        *)
            ;;
    esac
	
    case "${OPT_CHCK}" in
        'pct_slow_queries')
            local CHECK_OUTPUT=$(pct_slow_queries)
            ;;
        'fragmented_tables')
            local CHECK_OUTPUT=$(fragmented_tables)
            ;;
        'pct_connections_used')
            local CHECK_OUTPUT=$(pct_connections_used)
            ;;
        'pct_connections_aborted')
            local CHECK_OUTPUT=$(pct_connections_aborted)
            ;;
        'pct_max_used_memory')
            local CHECK_OUTPUT=$(pct_max_used_memory)
            ;;
        'pct_max_physical_memory')
            local CHECK_OUTPUT=$(pct_max_physical_memory)
            ;;
        'pct_other_processes_memory')
            local CHECK_OUTPUT=$(pct_other_processes_memory)
            ;;
        'pct_temp_sort_table')
            local CHECK_OUTPUT=$(pct_temp_sort_table)
            ;;
        'joins_without_indexes_per_day')
            local CHECK_OUTPUT=$(joins_without_indexes_per_day)
            ;;
        'pct_temp_disk')
            local CHECK_OUTPUT=$(pct_temp_disk)
            ;;
        'thread_cache_hit_rate')
            local CHECK_OUTPUT=$(thread_cache_hit_rate)
            ;;
        'table_cache_hit_rate')
            local CHECK_OUTPUT=$(table_cache_hit_rate)
            ;;
        'pct_files_open')
            local CHECK_OUTPUT=$(pct_files_open)
            ;;
        'pct_table_locks_immediate')
            local CHECK_OUTPUT=$(pct_table_locks_immediate)
            ;;
        'pct_binlog_cache')
            local CHECK_OUTPUT=$(pct_binlog_cache)
            ;;
        'pct_write_queries')
            local CHECK_OUTPUT=$(pct_write_queries)
            ;;
        'performance_metrics')
            local CHECK_OUTPUT=$(performance_metrics)
            ;;
        'pct_keys_from_mem')
            local CHECK_OUTPUT=$(pct_keys_from_mem)
            ;;
        'pct_wkeys_from_mem')
            local CHECK_OUTPUT=$(pct_aria_keys_from_mem)
            ;;
        'pct_aria_keys_from_mem')
            local CHECK_OUTPUT=$(pct_aria_keys_from_mem)
            ;;
        'pct_read_efficiency')
            local CHECK_OUTPUT=$(pct_read_efficiency)
            ;;
        'pct_write_efficiency')
            local CHECK_OUTPUT=$(pct_write_efficiency)
            ;;
        'pct_innodb_buffer_used')
            local CHECK_OUTPUT=$(pct_innodb_buffer_used)
            ;;
        'innodb_log_waits')
            local CHECK_OUTPUT=$(innodb_log_waits)
            ;;
        'recommendations')
            local CHECK_OUTPUT=$(recommendations)
            ;;
        *)
            local OPT_ERR="-a/--action '${OPT_CHCK}' not recognized"
            ;;
    esac

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi

    # split the check output based on the delimiter '|'.
    IFS_OLD=$IFS
    IFS="|"
    local CHECK_OUTPUT_ARR=(${CHECK_OUTPUT})
    IFS=$IFS_OLD

    local VAL="${CHECK_OUTPUT_ARR[0]}"
    local UOM="${CHECK_OUTPUT_ARR[1]}"  # unit of measurement
    local DESC="${CHECK_OUTPUT_ARR[2]}"
	local EXTENDED_OUTPUT="${CHECK_OUTPUT_ARR[3]}"

    # Compare the check value with warning/critical thresholds
    # to define the check state.
    case $(compare_result "${VAL}" "${OPT_CRIT}" "${OPT_WARN}" "${OPT_COMP}") in
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

    # Build the common performance data output for graph trending
    # Expected perfdata format: 'label'=value[UOM];[warn];[crit];[min];[max]
    # https://nagios-plugins.org/doc/guidelines.html#AEN200
    if [ "${UOM}" = "%" ]; then
		local PERFDATA_MAX=100
    fi

    # Set `None` thresholds to null for the perfdata.
    local PERFDATA="${OPT_CHCK}=${VAL}${UOM};${OPT_WARN/None/''};${OPT_CRIT/None/''};0;${PERFDATA_MAX:-''}"
    local NOTE="${NOTE}|${PERFDATA}"
    # Add multiline output, if any.
    if [ ! -z "${EXTENDED_OUTPUT}" ]; then
        local NOTE="${NOTE}\n${EXTENDED_OUTPUT}"
    fi

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
# Calculates the parameter passed in 'human readible' bytes,
# then rounds the GB/MB/KB/B value to two decimal places.
# ########################################################################
hr_bytes() {

    case "${1#-}" in
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="Input must be numeric (input: ${1})"
            ;;
        *)
            ;;
    esac

    if (( $(bc -l <<< "${1} >= (1024*1024*1024)") )); then  # GB
        echo "$(bc -l <<< "scale=2; ${1} / (1024*1024*1024)")GB"
	elif (( $(bc -l <<< "${1} >= (1024*1024)") )); then  # MB
        echo "$(bc -l <<< "scale=2; ${1} / (1024*1024)")MB"
	elif (( $(bc -l <<< "${1} >= 1024") )); then  # KB
        echo "$(bc -l <<< "scale=2; ${1} / 1024")KB"
	else  # B
        echo "${1}B"
	fi

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi
}

# ########################################################################
# Returns values >= 1000 as k, rounded to one decimal place.
# ########################################################################
hr_num() {

    case "${1#-}" in
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="Input must be numeric (input: ${1})"
            ;;
        *)
            ;;
    esac

    if (( $(bc -l <<< "${1} >= (1000*1000*1000)") )); then  # Billions
        echo "$(bc -l <<< "scale=1; ${1} / (1000*1000*1000)")B"
    elif (( $(bc -l <<< "${1} >= (1000*1000)") )); then  # Millions
        echo "$(bc -l <<< "scale=1; ${1} / (1000*1000)")M"
    elif (( $(bc -l <<< "${1} >= 1000") )); then  # Thousands
        echo "$(bc -l <<< "scale=1; ${1} / 1000")k"
	else
        echo "${1}"
	fi

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi
}

# ########################################################################
# Produce human readable time from a duration in seconds.
# ########################################################################
hr_time() {

    case "${1#-}" in
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="Input must be numeric (input: ${1})"
            ;;
        *)
            ;;
    esac
    # Remove and save any fractional component
    local SECS="${1%.*}"
    local DAYS="$(bc -l <<< "scale=0; ${SECS}/86400")"
    local HOURS="$(bc -l <<< "scale=0; (${SECS}-(${DAYS}*86400))/3600")"
    local MINUTES="$(bc -l <<< "scale=0; (${SECS}-(${DAYS}*86400)-(${HOURS}*3600))/60")"
    local SECONDS="$(bc -l <<< "scale=0; (${SECS}-(${DAYS}*86400)-(${HOURS}*3600)-(${MINUTES}*60))")"
    # @TODO: There must be a better way to do the calculations above.
	
    if (( $(bc -l <<< "${DAYS} > 0") )); then
        echo "${DAYS}d ${HOURS}h ${MINUTES}m ${SECONDS}s"
    elif (( $(bc -l <<< "${HOURS} > 0") )); then
        echo "${HOURS}h ${MINUTES}m ${SECONDS}s"
    elif (( $(bc -l <<< "${MINUTES} > 0") )); then
        echo "${MINUTES}m ${SECONDS}s"
    else
        echo "${SECONDS}s"
    fi

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi
}

# ########################################################################
# Function to use jq to parse the json output.
# ########################################################################
process_json() {
    # Get options
    for o; do
        case "${o}" in
            -f|--file)       shift; local OPT_FILE="${1}"; shift; ;;
            -k|--key)        shift; local OPT_KEY="${1}"; shift; ;;
            -n|--null)       shift; local OPT_NULL="${1}"; shift; ;;
            -*)              echo "Unknown option ${o}."; exit 1; ;;
        esac
    done
    # If variable not set or null, use default.
    local OPT_FILE="${OPT_FILE:-${JSON_FILE}}"

    # Validate the options.
    local OPT_ERR=""
    if [ -z "${OPT_KEY}" ]; then
        local OPT_ERR="you must specify -k or --key"
    else
        case "${OPT_KEY#.}" in
            ''|*..*|*.|*\"\"*)
                # Some general error checking
                local OPT_ERR="-k/--key must be in [parent.]child_key format"
                ;;
            \"[!.]*[!.]" "[!.]*[!.]\"|*.\"[!.]*[!.]" "[!.]*[!.]\"|\"[!.]*[!.]" "[!.]*[!.]\".*|*.\"[!.]*[!.]" "[!.]*[!.]\".*)
                # Spaced, but OK: 
                # a) enclosed correctly, no parent or child keys (no dots)
                # b) enclosed correctly, parent key, no child (only dot on the left)
                # c) enclosed correctly, child key, no parent (only dot on the right)
                # d) enclosed correctly, child and parent keys (dots on both sides)
                ;;
            *" "*)
                # Spaced, not OK
                local OPT_ERR="1 -k/--keys with spaces have to be enclosed in double quotes, e.g. 'parent.\"child with spaces\"' (input: ${OPT_KEY#.})"
                ;;
            *)
                # No spaces
                ;;
        esac
    fi

    # Make sure the JSON file is loaded only once per script run.
    if [ "${LOAD_JSON_FILE}" = true ]; then
        JSON=$(cat "${OPT_FILE}")
	    LOAD_JSON_FILE=false
    fi
    # Retrieve the json key by using jq.
    local val=$(echo "${JSON}" | jq ". | .${OPT_KEY#.}")
    # If the key doesn't exist, val will be "null" (string, not NULL).
    if [ "$val" = "null" ] && [ "${OPT_NULL}" ]; then
        echo "${OPT_NULL}"
    else
        # Remove the suffix ".
        local val="${val%\"}"
        # Remove the prefix ".
        local val="${val#\"}"
        # Return the stripped value.
        echo "${val}"
    fi

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi
}

# ########################################################################
# Function to return a percentage with two decimal places, including
# `division by zero` protection.
# ########################################################################
pct() {
    # Get options
    for o; do
        case "${o}" in
            -i|--item)          shift; local OPT_ITEM="${1}"; shift; ;;
            -t|--total)         shift; local OPT_TOTAL="${1}"; shift; ;;
            -*|--*)             echo "Unknown option ${o}."; exit 1; ;;
        esac
    done
    # If variable not set or null, use default.
    local OPT_ZERO="${OPT_ZERO:-0}"

    # Validate the options.
    local OPT_ERR=""
    if [ -z "${OPT_ITEM}${OPT_TOTAL}" ]; then
        local OPT_ERR="you must specify both -i and -t"
    elif [ "${OPT_ITEM}" -a -z "${OPT_TOTAL}" ]; then
        local OPT_ERR="you specified -i but not -t"
    elif [ "${OPT_TOTAL}" -a -z "${OPT_ITEM}" ]; then
        local OPT_ERR="you specified -t but not -i"
    elif [ "${OPT_ITEM}" ]; then
        # Reject empty strings and strings containing non-digits
        # (single dot excluded), accepting everything else.
        # Accept negative integers by removing the - prefix
        # (if any) before testing.
        case "${OPT_ITEM}" in
            '.'|*.*.*|''|*[!0-9.]*)
                local OPT_ERR="-i/--item must be numeric and >= 0 (input: ${OPT_ITEM})"
                ;;
            *)
                ;;
        esac
    fi
    case "${OPT_TOTAL}" in
        '.'|*.*.*|''|*[!0-9.]*)
            local OPT_ERR="-t/--total must be numeric and >= 0 (input: ${OPT_TOTAL})"
            ;;
        *)
            ;;
    esac

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi

    if (( $(bc -l <<< "${OPT_TOTAL} == 0") )); then
	    # Divide-by-zero protection; make the result simply 0.
        echo 0
    else
        awk -v item=${OPT_ITEM} -v total=${OPT_TOTAL} 'BEGIN { printf "%.2f\n", 100 * item / total }'
    fi
}

# ########################################################################
# Top 5 memory processes (get_top_memory_procs)
#
# Get the top 5 Most Memory consuming processes. 
# Used to provide detailed information in case of high 'other processes'
# mememory usage. Not part of the mysqltuner script.
# Based on:
# - https://stackoverflow.com/a/58014293
# - https://stackoverflow.com/a/32931403
# ########################################################################
get_top_memory_procs() {
    # Get options
    for o; do
        case "${o}" in
            -h|--head)          shift; local OPT_HEAD="${1}"; shift; ;;
            -*|--*)             echo "Unknown option ${o}."; exit 1; ;;
        esac
    done
    # If head variable not set or null, use a default of 3.
    local OPT_HEAD="${OPT_HEAD:-3}"

    # Validate the options.
    local OPT_ERR=""
    # Reject empty strings and strings containing non-digits,
    # accepting everything else.
    case "${OPT_HEAD}" in
        ''|*[!0-9]*)
            local OPT_ERR="-h/--head must be numeric"
            ;;
        *)
            ;;
    esac

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi

    local OUTPUT="Top ${OPT_HEAD} memory processes: "

    #  Use awk to sum up the total memory used by processes of the same name.
    local PS_COMMAND="ps -e orss,comm | awk '{print $1 \" \" $2 }' | awk '{tot[$2]+=$1;count[$2]++} END {for (i in tot) {print tot[i],i,count[i]}}' | sort -nr | head -${OPT_HEAD}"

    # @TODO: the above command works on cli, but no clue how to make the pipes work in script.
}

# ========================================================================
#                        CHECK FUNCTIONS - BEGIN
# ========================================================================
# ########################################################################
# Slow queries (pct_slow_queries)
# ########################################################################
pct_slow_queries() {
    # Vars
    local STATUS_SLOW_QUERIES=$(process_json -k "Status.Slow_queries")
    local STATUS_QUESTIONS=$(process_json -k "Status.Questions")
	local PCT_SLOW_QUERIES=$(pct -i ${STATUS_SLOW_QUERIES} -t ${STATUS_QUESTIONS})
    # Logic & calculations
    if (( $(bc -l <<< "${PCT_SLOW_QUERIES} > 0") )); then
        local DESC="Slow queries: ${PCT_SLOW_QUERIES}% ($(hr_num ${STATUS_SLOW_QUERIES}) slow / $(hr_num ${STATUS_QUESTIONS}) queries)"
    else
        local DESC="No slow queries detected - all good!"
    fi
	echo "${PCT_SLOW_QUERIES}|%|${DESC}"
}

# ########################################################################
# Fragmented tables (fragmented_tables)
# ########################################################################
fragmented_tables() {
    # Vars
    local TABLES_FRAGMENTED=$(process_json -k 'Tables."Fragmented tables"')
    # The json data (strings) can't be processed as an array.
    # We strip the brackets ([]), and (mis?)use xargs to get rid of
	# newlines, multiple spaces, and the double quotes.
    local TABLES_FRAGMENTED="${TABLES_FRAGMENTED#\[}"
    local TABLES_FRAGMENTED="${TABLES_FRAGMENTED%\]}"
    local TABLES_FRAGMENTED=$(echo "${TABLES_FRAGMENTED}" | xargs)
    # A little trick to retrieve the 'array' length. Will do the job
    # as long as table names don't have commas.
	# First, check if the remaining 'xargs-ed' string contains any characters.
	if (( ${#TABLES_FRAGMENTED} > 0 )); then
        # Remove all non-comma chars. The amount of tables is the 
		# amount of commas + one (there's always one separator less
		# than there are values.
	    local COMMAS_ONLY="${TABLES_FRAGMENTED//[^,]}"
        local TABLES_FRAGMENTED_COUNT=$(( ${#COMMAS_ONLY}+1 ))

        local DESC="Fragmented tables (TABLES_FRAGMENTED_COUNT): ${TABLES_FRAGMENTED}"
	else
        # An empty original string means no fragmented tables.
	    local TABLES_FRAGMENTED_COUNT=0

        local DESC="No fragmented tables - all good!"
    fi

	echo "${TABLES_FRAGMENTED_COUNT}||${DESC}"
}

# ########################################################################
# Maximum connections (pct_connections_used)
# ########################################################################
pct_connections_used() {
    # Vars
    local VARIABLES_MAX_CONNECTIONS=$(process_json -k "Variables.max_connections")
    local STATUS_MAX_USED_CONNECTIONS=$(process_json -k "Status.Max_used_connections")
    # Logic & calculations
	local PCT_CONNECTIONS_USED=$(pct -i ${STATUS_MAX_USED_CONNECTIONS} -t ${VARIABLES_MAX_CONNECTIONS})
    if (( $(bc -l <<< "${PCT_CONNECTIONS_USED} > 100") )); then
        local PCT_CONNECTIONS_USED="100.00"
    fi	
    if (( ${VARIABLES_MAX_CONNECTIONS} > 0 )); then
        local DESC="Highest usage of available connections: ${PCT_CONNECTIONS_USED}% ($(hr_num ${STATUS_MAX_USED_CONNECTIONS}) max used / $(hr_num ${VARIABLES_MAX_CONNECTIONS}) available)"
    else
        local DESC="No maximum connection limit configured. Max used connections: $(hr_num ${STATUS_MAX_USED_CONNECTIONS})"
    fi
	echo "${PCT_CONNECTIONS_USED}|%|${DESC}"
}

# ########################################################################
# Aborted connections (pct_connections_aborted)
# ########################################################################
pct_connections_aborted() {
    # Vars
    local STATUS_CONNECTIONS=$(process_json -k "Status.Connections")
    local STATUS_ABORTED_CONNECTS=$(process_json -k "Status.Aborted_connects")
    # Logic & calculations
    local PCT_CONNECTIONS_ABORTED=$(pct -i ${STATUS_ABORTED_CONNECTS} -t ${STATUS_CONNECTIONS})
    if (( ${STATUS_CONNECTIONS} > 0 )); then
        if (( ${STATUS_ABORTED_CONNECTS} == 0 )); then
            local DESC="No aborted connections - all good! ($(hr_num ${STATUS_CONNECTIONS}) total connections)"
        else
            local DESC="Aborted connections: ${PCT_CONNECTIONS_ABORTED}% ($(hr_num ${STATUS_ABORTED_CONNECTS}) aborted / $(hr_num ${STATUS_CONNECTIONS}) total)"
        fi
    else
        # This should be impossible?
        local DESC="No connections at all yet - nothing to check!"
    fi
	echo "${STATUS_ABORTED_CONNECTS}|%|${DESC}"
}

# ########################################################################
# === Memory usage ===
# ########################################################################
# Max used memory (pct_max_used_memory)
# ########################################################################
# `Max used memory` is memory used by MySQL based on `Max_used_connections`.
# This is the max memory used theoretically calculated with the max 
# concurrent connection number reached by mysql.
pct_max_used_memory() {
    # Vars
    local GALERA_GCACHE_MEMORY=$(process_json -k "Galera.GCache.memory" -n 0)
    local OS_PHYSICAL_MEMORY_BYTES=$(process_json -k 'OS."Physical Memory".bytes')
    local P_S_MEMORY=$(process_json -k "P_S.memory")
    local STATUS_MAX_USED_CONNECTIONS=$(process_json -k "Status.Max_used_connections")
    local VARIABLES_ARIA_PAGECACHE_BUFFER_SIZE=$(process_json -k "Variables.aria_pagecache_buffer_size" -n 0)
    local VARIABLES_INNODB_ADDITIONAL_MEM_POOL_SIZE=$(process_json -k "Variables.innodb_additional_mem_pool_size" -n 0)
    local VARIABLES_INNODB_BUFFER_POOL_SIZE=$(process_json -k "Variables.innodb_buffer_pool_size" -n 0)
    local VARIABLES_INNODB_LOG_BUFFER_SIZE=$(process_json -k "Variables.innodb_log_buffer_size" -n 0)
    local VARIABLES_JOIN_BUFFER_SIZE=$(process_json -k "Variables.join_buffer_size")
    local VARIABLES_KEY_BUFFER_SIZE=$(process_json -k "Variables.key_buffer_size")
    local VARIABLES_MAX_ALLOWED_PACKET=$(process_json -k "Variables.max_allowed_packet")
    local VARIABLES_MAX_HEAP_TABLE_SIZE=$(process_json -k "Variables.max_heap_table_size")
    local VARIABLES_QUERY_CACHE_SIZE=$(process_json -k "Variables.query_cache_size" -n 0)
    local VARIABLES_READ_BUFFER_SIZE=$(process_json -k "Variables.read_buffer_size")
    local VARIABLES_READ_RND_BUFFER_SIZE=$(process_json -k "Variables.read_rnd_buffer_size")
    local VARIABLES_SORT_BUFFER_SIZE=$(process_json -k "Variables.sort_buffer_size")
    local VARIABLES_THREAD_STACK=$(process_json -k "Variables.thread_stack")
    local VARIABLES_TMP_TABLE_SIZE=$(process_json -k "Variables.tmp_table_size")
    # Logic & calculations
    if (( $(bc -l <<< "${VARIABLES_TMP_TABLE_SIZE} > ${VARIABLES_MAX_HEAP_TABLE_SIZE}") )); then
        local MAX_TMP_TABLE_SIZE=${VARIABLES_MAX_HEAP_TABLE_SIZE}
    else
        local MAX_TMP_TABLE_SIZE=${VARIABLES_TMP_TABLE_SIZE}
    fi
    # Per-thread memory
    local PER_THREAD_BUFFERS=$(( ${VARIABLES_READ_BUFFER_SIZE}+${VARIABLES_READ_RND_BUFFER_SIZE}+${VARIABLES_SORT_BUFFER_SIZE}+${VARIABLES_THREAD_STACK}+${VARIABLES_MAX_ALLOWED_PACKET}+${VARIABLES_JOIN_BUFFER_SIZE} ))
    local MAX_TOTAL_PER_THREAD_BUFFERS=$(( ${PER_THREAD_BUFFERS}*${STATUS_MAX_USED_CONNECTIONS} ))  
    # Server-wide memory
    local SERVER_BUFFERS=$(( ${VARIABLES_KEY_BUFFER_SIZE}+${MAX_TMP_TABLE_SIZE}+${VARIABLES_INNODB_BUFFER_POOL_SIZE}+${VARIABLES_INNODB_ADDITIONAL_MEM_POOL_SIZE}+${VARIABLES_INNODB_LOG_BUFFER_SIZE}+${VARIABLES_QUERY_CACHE_SIZE}+${VARIABLES_ARIA_PAGECACHE_BUFFER_SIZE} ))
    local MAX_USED_MEMORY=$(( ${SERVER_BUFFERS}+${MAX_TOTAL_PER_THREAD_BUFFERS}+${P_S_MEMORY}+${GALERA_GCACHE_MEMORY} ))
    local PCT_MAX_USED_MEMORY=$(pct -i ${MAX_USED_MEMORY} -t ${OS_PHYSICAL_MEMORY_BYTES})
    local DESC="Maximum reached mysqld RAM usage: ${PCT_MAX_USED_MEMORY}% ($(hr_bytes ${MAX_USED_MEMORY}) used / $(hr_bytes ${OS_PHYSICAL_MEMORY_BYTES}) installed)"
	
	echo "${PCT_MAX_USED_MEMORY}|%|${DESC}"
}

# ########################################################################
# Max peak memory (pct_max_physical_memory)
# ########################################################################
# Total possible memory is memory needed by MySQL based on max_connections.
# This is the max memory MySQL can theoretically used if all connections
# allowed has opened by mysql.
pct_max_physical_memory() {
    # Get options
    for o; do
        case "${o}" in
            -d|--datatype)   shift; local OPT_DATATYPE="${1}"; shift; ;;
            -*)              echo "Unknown option ${o}."; exit 1; ;;
        esac
    done
    # If variable not set or null, use default.
    local OPT_DATATYPE="${OPT_DATATYPE:-mon}"

    case "${OPT_DATATYPE}" in
        'mon'|'pct'|'val')
            ;;
        *)
            OPT_ERR="-d/--datatype must be one of: 'mon' (monitoring), 'pct' (percent), or 'val' (value)"
            ;;
    esac

    if [ "${OPT_ERR}" ]; then
        echo "Error: $OPT_ERR."
        exit 1
    fi

    # Vars
    local GALERA_GCACHE_MEMORY=$(process_json -k "Galera.GCache.memory" -n 0)
    local OS_OTHER_PROCESSES_BYTES=$(process_json -k 'OS."Other Processes".bytes')
    local OS_PHYSICAL_MEMORY_BYTES=$(process_json -k 'OS."Physical Memory".bytes')
    local P_S_MEMORY=$(process_json -k "P_S.memory")
    local VARIABLES_ARIA_PAGECACHE_BUFFER_SIZE=$(process_json -k "Variables.aria_pagecache_buffer_size" -n 0)
    local VARIABLES_INNODB_ADDITIONAL_MEM_POOL_SIZE=$(process_json -k "Variables.innodb_additional_mem_pool_size" -n 0)
    local VARIABLES_INNODB_BUFFER_POOL_SIZE=$(process_json -k "Variables.innodb_buffer_pool_size" -n 0)
    local VARIABLES_INNODB_LOG_BUFFER_SIZE=$(process_json -k "Variables.innodb_log_buffer_size" -n 0)
    local VARIABLES_JOIN_BUFFER_SIZE=$(process_json -k "Variables.join_buffer_size")
    local VARIABLES_KEY_BUFFER_SIZE=$(process_json -k "Variables.key_buffer_size")
    local VARIABLES_MAX_ALLOWED_PACKET=$(process_json -k "Variables.max_allowed_packet")
    local VARIABLES_MAX_CONNECTIONS=$(process_json -k "Variables.max_connections")
    local VARIABLES_MAX_HEAP_TABLE_SIZE=$(process_json -k "Variables.max_heap_table_size")
    local VARIABLES_QUERY_CACHE_SIZE=$(process_json -k "Variables.query_cache_size" -n 0)
    local VARIABLES_READ_BUFFER_SIZE=$(process_json -k "Variables.read_buffer_size")
    local VARIABLES_READ_RND_BUFFER_SIZE=$(process_json -k "Variables.read_rnd_buffer_size")
    local VARIABLES_SORT_BUFFER_SIZE=$(process_json -k "Variables.sort_buffer_size")
    local VARIABLES_THREAD_STACK=$(process_json -k "Variables.thread_stack")
    local VARIABLES_TMP_TABLE_SIZE=$(process_json -k "Variables.tmp_table_size")
    # Logic & calculations
    if (( $(bc -l <<< "${VARIABLES_TMP_TABLE_SIZE} > ${VARIABLES_MAX_HEAP_TABLE_SIZE}") )); then
        MAX_TMP_TABLE_SIZE=${VARIABLES_MAX_HEAP_TABLE_SIZE}
    else
        MAX_TMP_TABLE_SIZE=${VARIABLES_TMP_TABLE_SIZE}
    fi
    # Server-wide memory
    local SERVER_BUFFERS=$(( ${VARIABLES_KEY_BUFFER_SIZE}+${MAX_TMP_TABLE_SIZE}+${VARIABLES_INNODB_BUFFER_POOL_SIZE}+${VARIABLES_INNODB_ADDITIONAL_MEM_POOL_SIZE}+${VARIABLES_INNODB_LOG_BUFFER_SIZE}+${VARIABLES_QUERY_CACHE_SIZE}+${VARIABLES_ARIA_PAGECACHE_BUFFER_SIZE} ))
    # Per-thread memory
    local PER_THREAD_BUFFERS=$(( ${VARIABLES_READ_BUFFER_SIZE}+${VARIABLES_READ_RND_BUFFER_SIZE}+${VARIABLES_SORT_BUFFER_SIZE}+${VARIABLES_THREAD_STACK}+${VARIABLES_MAX_ALLOWED_PACKET}+${VARIABLES_JOIN_BUFFER_SIZE} ))
    local TOTAL_PER_THREAD_BUFFERS=$(( ${PER_THREAD_BUFFERS}*${VARIABLES_MAX_CONNECTIONS} ))
    local MAX_PEAK_MEMORY=$(( ${SERVER_BUFFERS}+${TOTAL_PER_THREAD_BUFFERS}+${P_S_MEMORY}+${GALERA_GCACHE_MEMORY} ))
    local PCT_MAX_PHYSICAL_MEMORY=$(pct -i ${MAX_PEAK_MEMORY} -t ${OS_PHYSICAL_MEMORY_BYTES})
	
    if [ "${OPT_DATATYPE}" = "val" ]; then
        echo "${MAX_PEAK_MEMORY}"
	elif  [ "${OPT_DATATYPE}" = "pct" ]; then
        echo "${PCT_MAX_PHYSICAL_MEMORY}"
	else  # assume 'mon'
        local DESC="Maximum possible mysqld peak RAM usage: ${PCT_MAX_PHYSICAL_MEMORY}% ($(hr_bytes ${MAX_PEAK_MEMORY}) peak / $(hr_bytes ${OS_PHYSICAL_MEMORY_BYTES}) installed)"

        if (( $(bc -l <<< "${OS_PHYSICAL_MEMORY_BYTES} < ${MAX_PEAK_MEMORY}") )); then
            local DESC="${DESC}. Overall ***possible*** mysqld memory usage exceeded available physical memory!"
        fi
        echo "${PCT_MAX_PHYSICAL_MEMORY}|%|${DESC}"
    fi
}

# ########################################################################
# Other processes memory (pct_other_processes_memory)
# ########################################################################
pct_other_processes_memory() {
    # Vars
    local OS_OTHER_PROCESSES_BYTES=$(process_json -k 'OS."Other Processes".bytes')
    local OS_PHYSICAL_MEMORY_BYTES=$(process_json -k 'OS."Physical Memory".bytes')
    # Get max peak memory by calling the 'pct_max_physical_memory' function with
    # the '-d "val"' option to only retrieve the value.
    local MAX_PEAK_MEMORY=$(pct_max_physical_memory -d "val")
    # Logic & calculations
    local PCT_OTHER_PROCESSES_MEMORY=$(pct -i ${OS_OTHER_PROCESSES_BYTES} -t ${OS_PHYSICAL_MEMORY_BYTES})
    
	local DESC="Non-mysqld processes use ${PCT_OTHER_PROCESSES_MEMORY}% of total physical memory ($(hr_bytes ${OS_OTHER_PROCESSES_BYTES}) / $(hr_bytes ${OS_PHYSICAL_MEMORY_BYTES}))"
    if (( $(bc -l <<< "${OS_PHYSICAL_MEMORY_BYTES} < $(( ${MAX_PEAK_MEMORY}+${OS_OTHER_PROCESSES_BYTES} ))") )); then
        local DESC="${DESC}. Overall ***possible*** memory usage including non-mysqld processes exceeded available physical memory!"
# @TODO: extend DESC with $(get_top_memory_procs), once the function is fixed.
    fi
	echo "${PCT_OTHER_PROCESSES_MEMORY}|%|${DESC}"
}

# ########################################################################
# Sorting (pct_temp_sort_table)
# ########################################################################
pct_temp_sort_table() {
    # Vars
    local STATUS_SORT_MERGE_PASSES=$(process_json -k "Status.Sort_merge_passes")
    local STATUS_SORT_RANGE=$(process_json -k "Status.Sort_range")
    local STATUS_SORT_SCAN=$(process_json -k "Status.Sort_scan")
    # Logic & calculations
    local TOTAL_SORTS=$(( ${STATUS_SORT_SCAN}+${STATUS_SORT_RANGE} ))
    local PCT_TEMP_SORT_TABLE=$(pct -i ${STATUS_SORT_MERGE_PASSES} -t ${TOTAL_SORTS})

    if (( ${TOTAL_SORTS} > 0 )); then

        if (( ${STATUS_SORT_MERGE_PASSES} == 0 )); then
            local DESC="No sorts requiring temporary tables - all good! ($(hr_num ${TOTAL_SORTS}) total sorts)"
        else
            local DESC="Sorts requiring temporary tables: ${PCT_TEMP_SORT_TABLE}% ($(hr_num ${STATUS_SORT_MERGE_PASSES}) temp sorts / $(hr_num ${TOTAL_SORTS}) sorts)"
        fi
    else
        local DESC="No sorts yet - nothing to check!"
    fi
	echo "${PCT_TEMP_SORT_TABLE}|%|${DESC}"
}

# ########################################################################
# Joins without indexes (joins_without_indexes_per_day)
# ########################################################################
joins_without_indexes_per_day() {
    # Vars
    local STATUS_SELECT_FULL_JOIN=$(process_json -k "Status.Select_full_join")
    local STATUS_SELECT_RANGE_CHECK=$(process_json -k "Status.Select_range_check")
    local STATUS_UPTIME=$(process_json -k "Status.Uptime")
    # Logic & calculations
    local JOINS_WITHOUT_INDEXES=$(( ${STATUS_SELECT_RANGE_CHECK}+${STATUS_SELECT_FULL_JOIN} ))
	local JOINS_WITHOUT_INDEXES_PER_DAY=$(( ${JOINS_WITHOUT_INDEXES}/(${STATUS_UPTIME}/86400) ))

    if (( ${JOINS_WITHOUT_INDEXES} > 0 )); then
        local DESC="Joins performed without indexes: $(hr_num ${JOINS_WITHOUT_INDEXES}) ($(hr_num ${JOINS_WITHOUT_INDEXES_PER_DAY}) per day)"
    else
        local DESC="No joins without indexes - all good!"
    fi
	echo "${JOINS_WITHOUT_INDEXES_PER_DAY}||${DESC}"
}

# ########################################################################
# Temporary tables (pct_temp_disk)
# ########################################################################
pct_temp_disk() {
    # Vars
    local STATUS_CREATED_TMP_DISK_TABLES=$(process_json -k "Status.Created_tmp_disk_tables")
    local STATUS_CREATED_TMP_TABLES=$(process_json -k "Status.Created_tmp_tables")
    # Logic & calculations
    local PCT_TEMP_DISK=$(pct -i ${STATUS_CREATED_TMP_DISK_TABLES} -t ${STATUS_CREATED_TMP_TABLES})
    
    if (( ${STATUS_CREATED_TMP_TABLES} > 0 )); then
        local DESC="Temporary tables created on disk: ${PCT_TEMP_DISK}% ($(hr_num ${STATUS_CREATED_TMP_DISK_TABLES}) on disk / $(hr_num ${STATUS_CREATED_TMP_TABLES}) total)"
    else
        local DESC="No tmp tables created on disk"
    fi
	echo "${PCT_TEMP_DISK}|%|${DESC}"
}

# ########################################################################
# Thread cache hit rate (thread_cache_hit_rate)
# ########################################################################
thread_cache_hit_rate() {
    # Vars
    local STATUS_CONNECTIONS=$(process_json -k "Status.Connections")
    local STATUS_THREADS_CREATED=$(process_json -k "Status.Threads_created")
    local VARIABLES_THREAD_CACHE_SIZE=$(process_json -k "Variables.thread_cache_size")
    local VARIABLES_THREAD_HANDLING=$(process_json -k "Variables.thread_handling")
    # Logic & calculations
    local THREAD_CACHE_HIT_RATE=$(pct -i ${STATUS_THREADS_CREATED} -t ${STATUS_CONNECTIONS} )
    local THREAD_CACHE_HIT_RATE=$(bc -l <<< "scale=2; 100 - ${THREAD_CACHE_HIT_RATE}")
			
    # https://www.percona.com/doc/percona-server/LATEST/performance/threadpool.html
    # When thread pool is enabled, the value of the thread_cache_size variable
    # is ignored. The Threads_cached status variable contains 0 in this case.	
    if [ "${VARIABLES_THREAD_HANDLING}" = "pool-of-threads" ]; then
        local DESC="Thread cache not used with thread_handling=pool-of-threads - nothing to check!"
    elif (( ${VARIABLES_THREAD_CACHE_SIZE} > 0 )); then
        local DESC="Thread cache hit rate: ${THREAD_CACHE_HIT_RATE}% ($(hr_num ${STATUS_THREADS_CREATED}) threads created / $(hr_num ${STATUS_CONNECTIONS}) connections)"
    else
        local DESC="Thread cache seems disabled"
    fi
	echo "${THREAD_CACHE_HIT_RATE}|%|${DESC}"
}

# ########################################################################
# Table cache hit rate (table_cache_hit_rate)
# ########################################################################
table_cache_hit_rate() {
    # Vars
    local STATUS_OPEN_TABLES=$(process_json -k "Status.Open_tables")
    local STATUS_OPENED_TABLES=$(process_json -k "Status.Opened_tables")
    # Logic & calculations
    if (( ${STATUS_OPEN_TABLES} > 0 )); then
        local TABLE_CACHE_HIT_RATE=$(pct -i ${STATUS_OPEN_TABLES} -t ${STATUS_OPENED_TABLES})
        local DESC="Table cache hit rate: ${TABLE_CACHE_HIT_RATE}% ($(hr_num ${STATUS_OPEN_TABLES}) open / $(hr_num ${STATUS_OPENED_TABLES}) opened)"
    else
        local TABLE_CACHE_HIT_RATE=100
        local DESC="No open tables - nothing to check!"
    fi
	echo "${TABLE_CACHE_HIT_RATE}|%|${DESC}"
}

# ########################################################################
# Open files (pct_files_open)
# ########################################################################
pct_files_open() {
    # Vars
    local STATUS_OPEN_FILES=$(process_json -k "Status.Open_files")
    local VARIABLES_OPEN_FILES_LIMIT=$(process_json -k "Variables.open_files_limit")
    # Logic & calculations
    local PCT_FILES_OPEN=$(pct -i ${STATUS_OPEN_FILES} -t ${VARIABLES_OPEN_FILES_LIMIT})

    if (( ${VARIABLES_OPEN_FILES_LIMIT} > 0 )); then
        local DESC="Open file limit used: ${PCT_FILES_OPEN}% ($(hr_num ${STATUS_OPEN_FILES}) / $(hr_num ${VARIABLES_OPEN_FILES_LIMIT}))"
    else
        local DESC="No open file limit configured - nothing to check!"
    fi
	echo "${PCT_FILES_OPEN}|%|${DESC}"
}

# ########################################################################
# Table locks (pct_table_locks_immediate)
# ########################################################################
pct_table_locks_immediate() {
    # Vars
    local STATUS_TABLE_LOCKS_IMMEDIATE=$(process_json -k "Status.Table_locks_immediate")
    local STATUS_TABLE_LOCKS_WAITED=$(process_json -k "Status.Table_locks_waited")
    # Logic & calculations	
    if (( ${STATUS_TABLE_LOCKS_IMMEDIATE} > 0 )); then
        local PCT_TABLE_LOCKS_IMMEDIATE=$(pct -i ${STATUS_TABLE_LOCKS_IMMEDIATE} -t $(bc -l <<< " ${STATUS_TABLE_LOCKS_WAITED}+${STATUS_TABLE_LOCKS_IMMEDIATE}"))
        local DESC="Table locks acquired immediately: ${PCT_TABLE_LOCKS_IMMEDIATE}% ($(hr_num ${STATUS_TABLE_LOCKS_IMMEDIATE}) immediate / $(hr_num $(( ${STATUS_TABLE_LOCKS_WAITED}+${STATUS_TABLE_LOCKS_IMMEDIATE} ))) total locks)"
    else
        local PCT_TABLE_LOCKS_IMMEDIATE=100
        local DESC="No table lock requests - nothing to check!"
    fi
    # Return check value & description
	echo "${PCT_TABLE_LOCKS_IMMEDIATE}|%|${DESC}"
}

# ########################################################################
# Binlog cache (pct_binlog_cache)
# ########################################################################
pct_binlog_cache() {
    # Vars
    local STATUS_BINLOG_CACHE_DISK_USE=$(process_json -k "Status.Binlog_cache_disk_use")
    local STATUS_BINLOG_CACHE_USE=$(process_json -k "Status.Binlog_cache_use")
    local VARIABLES_LOG_BIN=$(process_json -k "Variables.log_bin")
    # Logic & calculations
    if ! [ "${VARIABLES_LOG_BIN}" = "OFF" ]; then
        if (( ${STATUS_BINLOG_CACHE_USE} > 0 )); then
            local PCT_BINLOG_CACHE=$(pct -i $(bc -l <<< "{STATUS_BINLOG_CACHE_USE}-${STATUS_BINLOG_CACHE_DISK_USE}") -t ${STATUS_BINLOG_CACHE_USE})
            local DESC="Binlog cache memory access: ${PCT_BINLOG_CACHE}% ($(hr_num $(( ${STATUS_BINLOG_CACHE_USE} - ${STATUS_BINLOG_CACHE_DISK_USE} ))) memory / $(hr_num ${STATUS_BINLOG_CACHE_USE}) total)"
        else
	        local PCT_BINLOG_CACHE=100
            local DESC="No binlog cache usage yet - nothing to check!"
        fi
    else
	    local PCT_BINLOG_CACHE=100
        local DESC="Log bin not enabled - nothing to check!"	
    fi
    # Return check value & description
	echo "${PCT_BINLOG_CACHE}|%|${DESC}"
}

# ########################################################################
# === Performance Metrics ===	
# ########################################################################
# Read / write query ratio (pct_write_queries)
# ########################################################################
pct_write_queries() {
    # Vars
    local STATUS_COM_DELETE=$(process_json -k "Status.Com_delete")
    local STATUS_COM_INSERT=$(process_json -k "Status.Com_insert")
    local STATUS_COM_REPLACE=$(process_json -k "Status.Com_replace")
    local STATUS_COM_SELECT=$(process_json -k "Status.Com_select")
    local STATUS_COM_UPDATE=$(process_json -k "Status.Com_update")
    local STATUS_QUESTIONS=$(process_json -k "Status.Questions")
    # Logic & calculations
    if (( ${STATUS_QUESTIONS} > 0 )); then

        local TOTAL_READS=${STATUS_COM_SELECT}
        local TOTAL_WRITES=$(( ${STATUS_COM_DELETE}+${STATUS_COM_INSERT}+${STATUS_COM_UPDATE}+${STATUS_COM_REPLACE} ))

        if (( ${TOTAL_READS} == 0 )); then

            local PCT_READS=0
			local PCT_WRITES=100

        else
            local PCT_READS=$(pct -i ${TOTAL_READS} -t $(( ${TOTAL_READS}+${TOTAL_WRITES} )) )
            local PCT_WRITES=$(bc -l <<< "scale=2; 100 - ${PCT_READS}")			
        fi
        local DESC="Reads: ${PCT_READS}%, writes: ${PCT_WRITES}% (from $(hr_num $(( ${TOTAL_READS}+${TOTAL_WRITES} ))) total queries)"
    else
        local DESC="No queries at all - nothing to check!"
    fi
	echo "${PCT_WRITES}|%|${DESC}"
}

# ########################################################################
# Performance metrics (performance_metrics)
# ########################################################################
# uptime, queries per second, connections, traffic stats are already
# covered by the check_mk mk_mysql plugin and the proc_MySQL process check.
# No need to call this function :)
performance_metrics() {
    # Vars
    local STATUS_BYTES_RECEIVED=$(process_json -k "Status.Bytes_received")
    local STATUS_BYTES_RECEIVED_PRETTY=$(hr_bytes ${STATUS_BYTES_RECEIVED})
    local STATUS_BYTES_SENT=$(process_json -k "Status.Bytes_sent")
    local STATUS_BYTES_SENT_PRETTY=$(hr_bytes ${STATUS_BYTES_SENT})
    local STATUS_CONNECTIONS=$(process_json -k "Status.Connections")
    local STATUS_QUESTIONS=$(process_json -k "Status.Questions")
    local STATUS_UPTIME=$(process_json -k "Status.Uptime")
    # Logic & calculations
    if (( ${STATUS_UPTIME} > 0 )); then
        local QPS=$(bc -l <<< "scale=2; ${STATUS_QUESTIONS} / ${STATUS_UPTIME}")
        local DESC="Up for: $(hr_time ${STATUS_UPTIME}), $(hr_num ${STATUS_QUESTIONS}) q [${QPS} q/s], $(hr_num ${STATUS_CONNECTIONS}) conn, TX: ${STATUS_BYTES_SENT_PRETTY}, RX: ${STATUS_BYTES_RECEIVED_PRETTY}"
    else
	    # Impossible?
        local DESC="Not enough uptime for calculations"
    fi
	echo "${QPS}||${DESC}"
}

# ########################################################################
# === MyISAM Metrics ===
# ########################################################################
# Key buffer - read (pct_keys_from_mem)
# ########################################################################
pct_keys_from_mem() {
    # Vars
    local STATUS_KEY_READ_REQUESTS=$(process_json -k "Status.Key_read_requests")
    local STATUS_KEY_READS=$(process_json -k "Status.Key_reads")
    # Logic & calculations
    if (( ${STATUS_KEY_READ_REQUESTS} > 0 )); then
        local PCT_KEYS_FROM_MEM=$(pct -i ${STATUS_KEY_READS} -t ${STATUS_KEY_READ_REQUESTS})
        local PCT_KEYS_FROM_MEM=$(bc -l <<< "100-${PCT_KEYS_FROM_MEM}")
        local DESC="Read Key buffer hit rate: ${PCT_KEYS_FROM_MEM}% ($(hr_num ${STATUS_KEY_READ_REQUESTS}) cached / $(hr_num ${STATUS_KEY_READS}) reads)"
    else
	    local PCT_KEYS_FROM_MEM=100
        local DESC="No read queries have run yet that would use keys - nothing to check!"
    fi
	echo "${PCT_KEYS_FROM_MEM}|%|${DESC}"
}

# ########################################################################
# Key buffer - write (pct_wkeys_from_mem)
# ########################################################################
pct_wkeys_from_mem() {
    # Vars
    local STATUS_KEY_WRITE_REQUESTS=$(process_json -k "Status.Key_write_requests")
    local STATUS_KEY_WRITES=$(process_json -k "Status.Key_writes")
    # Logic & calculations
    if (( ${STATUS_KEY_WRITE_REQUESTS} > 0 )); then
        local PCT_WKEYS_FROM_MEM=$(pct -i ${STATUS_KEY_WRITES} -t ${STATUS_KEY_WRITE_REQUESTS})
        local DESC="Write Key buffer hit rate: ${PCT_WKEYS_FROM_MEM}% ($(hr_num ${STATUS_KEY_WRITE_REQUESTS}) cached / $(hr_num ${STATUS_KEY_WRITES}) writes)"
    else
		local PCT_WKEYS_FROM_MEM=100
        local DESC="No write queries have run yet that would use keys - nothing to check!"
    fi
	echo "${PCT_WKEYS_FROM_MEM}|%|${DESC}"
}

# ########################################################################
# === AriaDB Metrics ===
# ########################################################################
# Aria pagecache (pct_aria_keys_from_mem)
# ########################################################################
pct_aria_keys_from_mem() {
    # Vars
    local VARIABLES_HAVE_AREA=$(process_json -k "Variables.have_aria")
    local STATUS_ARIA_PAGECACHE_READ_REQUESTS=$(process_json -k "Status.Aria_pagecache_read_requests" -n 0)
    local STATUS_ARIA_PAGECACHE_READS=$(process_json -k "Status.Aria_pagecache_reads" -n 0)
    # Logic & calculations
    if [ "${VARIABLES_HAVE_AREA}" = "YES" ]; then
        if (( ${STATUS_ARIA_PAGECACHE_READ_REQUESTS} > 0 )); then
            local PCT_ARIA_KEYS_FROM_MEM=$(pct -i ${STATUS_ARIA_PAGECACHE_READS} -t ${STATUS_ARIA_PAGECACHE_READ_REQUESTS})
            local PCT_ARIA_KEYS_FROM_MEM=$(bc -l <<< "100-${PCT_ARIA_KEYS_FROM_MEM}")
            local DESC="Aria pagecache hit rate: ${PCT_ARIA_KEYS_FROM_MEM}% $(hr_num ${STATUS_ARIA_PAGECACHE_READ_REQUESTS}) cached / $(hr_num ${STATUS_ARIA_PAGECACHE_READS}) reads)"
        else
            local PCT_ARIA_KEYS_FROM_MEM=100
            local DESC="No queries have run yet that would use keys - nothing to check!"
        fi
    else
        local PCT_ARIA_KEYS_FROM_MEM=100
        local DESC="AriaDB is disabled - nothing to check!"
    fi
	echo "${PCT_ARIA_KEYS_FROM_MEM}|%|${DESC}"
}

# ########################################################################
# === InnoDB Metrics ===
# ########################################################################
# InnoDB Read efficiency (pct_read_efficiency)
# ########################################################################
pct_read_efficiency() {
    # Vars
    local STATUS_INNODB_BUFFER_POOL_READ_REQUESTS=$(process_json -k "Status.Innodb_buffer_pool_read_requests")
    local STATUS_INNODB_BUFFER_POOL_READS=$(process_json -k "Status.Innodb_buffer_pool_reads")
    # Logic & calculations
    if (( ${STATUS_INNODB_BUFFER_POOL_READ_REQUESTS} > 0 )); then
        local HITS=$(bc -l <<< "${STATUS_INNODB_BUFFER_POOL_READ_REQUESTS}-${STATUS_INNODB_BUFFER_POOL_READS}")
        local PCT_READ_EFFICIENCY=$(pct -i ${HITS} -t ${STATUS_INNODB_BUFFER_POOL_READ_REQUESTS})
        local DESC="InnoDB Read buffer efficiency: ${PCT_READ_EFFICIENCY}% ($(hr_num ${HITS}) hits / $(hr_num ${STATUS_INNODB_BUFFER_POOL_READ_REQUESTS}) total)"
    else
        local PCT_READ_EFFICIENCY=100
        local DESC="No InnoDB log read requests yet - nothing to check!"
    fi
	echo "${PCT_READ_EFFICIENCY}|%|${DESC}"
}

# ########################################################################
# InnoDB Write efficiency (pct_write_efficiency)
# ########################################################################
pct_write_efficiency() {
    # Vars
    local STATUS_INNODB_LOG_WRITE_REQUESTS=$(process_json -k "Status.Innodb_log_write_requests")
    local STATUS_INNODB_LOG_WRITES=$(process_json -k "Status.Innodb_log_writes")
    # Logic & calculations
    if (( ${STATUS_INNODB_LOG_WRITE_REQUESTS} > 0 )); then
        local HITS=$(bc -l <<< "${STATUS_INNODB_LOG_WRITE_REQUESTS}-${STATUS_INNODB_LOG_WRITES}")
        local PCT_WRITE_EFFICIENCY=$(pct -i ${HITS} -t ${STATUS_INNODB_LOG_WRITE_REQUESTS})
        local DESC="InnoDB Write Log efficiency: ${PCT_WRITE_EFFICIENCY}% ($(hr_num ${HITS}) hits / $(hr_num ${STATUS_INNODB_LOG_WRITE_REQUESTS}) total)"
    else
        local PCT_WRITE_EFFICIENCY=100
        local DESC="No InnoDB log writes requests yet - nothing to check!"
    fi
	echo "${PCT_WRITE_EFFICIENCY}|%|${DESC}"
}

# ########################################################################
# InnoDB buffer usage (pct_innodb_buffer_used)
# ########################################################################
pct_innodb_buffer_used() {
    # The `pct_innodb_buffer_used` calculation is part of the mysqltuner script,
    # but it doesn't generate any recommendation or other output. We give our
	# own interpretation here.

    # Vars
    local STATUS_INNODB_BUFFER_POOL_PAGES_TOTAL=$(process_json -k "Status.Innodb_buffer_pool_pages_total")
    local STATUS_INNODB_BUFFER_POOL_PAGES_FREE=$(process_json -k "Status.Innodb_buffer_pool_pages_free")
    # Logic & calculations
    local BUFFER_USED=$(bc -l <<< "${STATUS_INNODB_BUFFER_POOL_PAGES_TOTAL}-${STATUS_INNODB_BUFFER_POOL_PAGES_FREE}")
    local PCT_INNODB_BUFFER_USED=$(pct -i ${BUFFER_USED} -t ${STATUS_INNODB_BUFFER_POOL_PAGES_TOTAL})
    if (( ${STATUS_INNODB_BUFFER_POOL_PAGES_TOTAL} > 0 )); then
        local DESC="InnoDB buffer pool page usage: ${PCT_INNODB_BUFFER_USED}% ($(hr_num ${BUFFER_USED}) used / $(hr_num ${STATUS_INNODB_BUFFER_POOL_PAGES_TOTAL}) total)"
    else
        local DESC="No InnoDB buffer pool pages at all - nothing to check!"
    fi
	echo "${PCT_INNODB_BUFFER_USED}|%|${DESC}"
}

# ########################################################################
# InnoDB log waits (innodb_log_waits)
# ########################################################################
innodb_log_waits() {
    # Vars
    local STATUS_INNODB_LOG_WAITS=$(process_json -k "Status.Innodb_log_waits" -n 0)
    local STATUS_INNODB_LOG_WRITES=$(process_json -k "Status.Innodb_log_writes")
    # Logic & calculations
    local PCT_INNODB_LOG_WAITS=$(pct -i ${STATUS_INNODB_LOG_WAITS} -t ${STATUS_INNODB_LOG_WRITES})

    if (( ${STATUS_INNODB_LOG_WRITES} > 0 )); then
        local DESC="InnoDB log waits: ${PCT_INNODB_LOG_WAITS}% ($(hr_num ${STATUS_INNODB_LOG_WAITS}) waits / $(hr_num ${STATUS_INNODB_LOG_WRITES}) writes)"
    else
        local DESC="No InnoDB log writes requests yet - nothing to check!"
    fi
	echo "${PCT_INNODB_LOG_WAITS}|%|${DESC}"
}

# ########################################################################
# Make recommendations (recommendations)
# ########################################################################
recommendations() {
    # Vars
    local RECOMMENDATIONS=$(process_json -k "Recommendations")
    local ADJUST_VARIABLES=$(process_json -k '"Adjust variables"')
    # Logic & calculations
    # The json data (strings) can't be processed as an array.
    # We strip the brackets ([]), and (mis?)use xargs to get rid of
	# newlines, multiple spaces, and the double quotes.
    local RECOMMENDATIONS="${RECOMMENDATIONS#\[}"
    local RECOMMENDATIONS="${RECOMMENDATIONS%\]}"
    local RECOMMENDATIONS=$(echo "${RECOMMENDATIONS}" | xargs)
    if (( ${#RECOMMENDATIONS} > 0 )); then
        # Remove all non-comma chars. The amount of values is the 
		# amount of commas + one (there's always one separator less
		# than there are values).
# @TODO: @BUG: this counter will return an incorrect result if the strings in
# the 'array' contain commas (and they do). If this is fixed - by only looking
# for commas with a leading double quote - then the multiline output can have a
# @REFACTOR: to a list instead of a single string.
	    local COMMAS_ONLY="${RECOMMENDATIONS//[^,]}"
        local RECOMMENDATIONS_COUNT=$(( ${#COMMAS_ONLY}+1 ))
        local RECOMMENDATIONS_STATUS="General recommendations available: ${RECOMMENDATIONS_COUNT}."
		local RECOMMENDATIONS_DETAILS="Recommendations: ${RECOMMENDATIONS}"
    else
        # No recommendations - all good!
        RECOMMENDATIONS_COUNT=0
    fi
	
    # Repeat logic for adjustments.
    local ADJUST_VARIABLES="${ADJUST_VARIABLES#\[}"
    local ADJUST_VARIABLES="${ADJUST_VARIABLES%\]}"
    local ADJUST_VARIABLES=$(echo "${ADJUST_VARIABLES}" | xargs)
    if (( ${#ADJUST_VARIABLES} > 0 )); then
        # Remove all non-comma chars. The amount of values is the 
		# amount of commas + one (there's always one separator less
		# than there are values).
	    local COMMAS_ONLY="${ADJUST_VARIABLES//[^,]}"
        local ADJUST_VARIABLES_COUNT=$(( ${#COMMAS_ONLY}+1 ))
        local ADJUST_VARIABLES_STATUS="Variable adjustments recommended: ${ADJUST_VARIABLES_COUNT}."
		local ADJUST_VARIABLES_DETAILS="Recommended variables to adjust: ${ADJUST_VARIABLES}."

    # else: No recommended variables to adjust - all good!
    fi
	
	local 
    if (( ${#RECOMMENDATIONS} == 0 )) && (( ${#ADJUST_VARIABLES} == 0 )); then
        local DESC="No additional performance recommendations are available - well done!"
    else
        # Get max peak memory by calling the 'pct_max_physical_memory' function with
        # the '-d "val"' option to only retrieve the value.
        local MAX_PEAK_MEMORY=$(pct_max_physical_memory -d "val")

        if (( $(bc -l <<< "${MAX_PEAK_MEMORY} < 90") )); then
            local ADJUST_VARIABLES="${ADJUST_VARIABLES} *** MySQL's maximum potential memory usage is dangerously high (${MAX_PEAK_MEMORY}%)! add RAM before increasing MySQL buffer variables ***."
        fi
        local DESC="${RECOMMENDATIONS_STATUS} ${ADJUST_VARIABLES_STATUS}"
		local EXTENDED_OUTPUT="${RECOMMENDATIONS_DETAILS}\n${ADJUST_VARIABLES_DETAILS}"
    fi
	echo "${RECOMMENDATIONS_COUNT}||${DESC}|${EXTENDED_OUTPUT}"
}

# ========================================================================
#                        CHECK FUNCTIONS - END
# ========================================================================

# ########################################################################
# Execute the program if it was not included from another file.
# This makes it possible to include without executing, and thus test.
# ########################################################################

# The first time  the `process_json` function is called, it loads the
# json file into a variable. The LOAD_JSON_FILE boolean makes sure 
# the file is loaded only once.
LOAD_JSON_FILE=true

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
