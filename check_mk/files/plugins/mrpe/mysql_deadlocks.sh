#!/bin/bash
DEADLOCKS=$(echo 'SELECT COUNT FROM INNODB_METRICS WHERE name = "lock_deadlocks";' | mysql --defaults-file=/etc/check_mk/mysql.cnf INFORMATION_SCHEMA | tail -n 1)

STATE=0
MSG="OK - no deadlocks detected | deadlocks=$DEADLOCKS;;;;"

if [ $DEADLOCKS -gt 0 ]; then
    STATE=1
    MSG="WARN - $DEADLOCKS deadlocks detected | deadlocks=$DEADLOCKS;;;;"
fi

echo "$MSG"
exit $STATE
