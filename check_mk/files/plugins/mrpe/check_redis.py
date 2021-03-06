#!/usr/bin/env python3

#
# NOTE: Customized from upstream, only local monitoring supported.
# https://github.com/filiptepper/nagios-checks/blob/master/check_redis.py
#
# Changed RSS retrieval method to always use local & changed
# graph output metrics to always use same unit.
#
# REQUIREMENTS
# - redis-py

import sys
import os
import socket
import struct
import redis
from optparse import OptionParser

# Constants
EXIT_NAGIOS_OK = 0
EXIT_NAGIOS_WARN = 1
EXIT_NAGIOS_CRITICAL = 2

# Command line options
opt_parser = OptionParser()
opt_parser.add_option(
    "-s", "--server",
    dest="server",
    help="Redis server to connect to."
)
opt_parser.add_option(
    "-p", "--port",
    dest="port",
    default=6379,
    help="Redis port to connect to. (Default: 6379)"
)
opt_parser.add_option(
    "-P", "--password",
    dest="password",
    default=None,
    help="Redis password to use. Defaults to unauthenticated."
)
opt_parser.add_option(
    "-w", "--warn",
    dest="warn_threshold",
    help="Memory utlization (in MB) that triggers a warning status."
)
opt_parser.add_option(
    "-c", "--critical",
    dest="critical_threshold",
    help="Memory utlization (in MB) that triggers a critical status."
)
opt_parser.add_option(
    "-r", "--rss-warn",
    dest="rss_warn",
    default=None,
    help="RSS memory (in MB) that triggers a warning status."
)
opt_parser.add_option(
    "-R", "--rss-critical",
    dest="rss_critical",
    default=None,
    help="RSS memory (in MB) that triggers a critical status."
)
opt_parser.add_option(
    "-L", "--force-local",
    dest="force_local",
    action="store_true",
    help="Force local checks even if not localhost."
)
opt_parser.add_option(
    "-t", "--timeout",
    dest="timeout",
    default=10, type=int,
    help="How many seconds to wait for host to respond."
)
args = opt_parser.parse_args()[0]


if args.server is None:
    print (
        "A Redis server (--server) must be supplied. \
        Please see --help for more details."
    )
    sys.exit(-1)

# can't check /proc unless on local
# (local routable IP addresses not accounted for)
is_local = args.force_local or (args.server in
                                ['127.0.0.1', 'localhost', '::1'])

# only check RSS
check_fields = ["warn_threshold", "critical_threshold"]
if is_local:
    check_fields += ["rss_warn", "rss_critical"]

args_dict = args.__dict__
for option in check_fields:
    if args_dict[option] is None:
        print (
            "A %s %s must be supplied. Please see"
            "--help for more details." % tuple(option.split("_"))
        )
        sys.exit(-1)

    try:
        value = (args.__dict__[option])
        if int(value) < 0:
            raise ValueError
        else:
            globals()[option] = int(value)
    except ValueError as e:
        print (
            "A %s %s must be a positive integer. Please see "
            "--help for more details." % tuple(option.split("_"))
        )
        sys.exit(-1)

# ================
# = Nagios check =
# ================

# Connection
try:
    if args.password is not None:
        redis_connection = redis.Redis(
            host=args.server,
            port=int(args.port),
            password=args.password,
            socket_timeout=args.timeout
        )
    else:
        redis_connection = redis.Redis(
            host=args.server,
            port=int(args.port),
            socket_timeout=args.timeout
        )
    redis_info = redis_connection.info()
except (
        socket.error,
        redis.exceptions.ConnectionError,
        redis.exceptions.ResponseError) as e:
    print (
        "CRIT - Problem establishing connection to "
        "Redis server %s: %s " % (str(args.server), str(repr(e)))
    )
    sys.exit(EXIT_NAGIOS_CRITICAL)


# Do the / 1024 / 1024 calculations once (bytes -> KB -> MB)
# Rounded version with two decimals for perfdata
rss = round(redis_info["used_memory_rss"] / 1024 / 1024, 2)
used_memory = round(redis_info["used_memory"] / 1024 / 1024, 2)
# Round to the nearest integer for check output
rss_round = round(rss)
used_memory_round = round(used_memory)


# Redis VM
if redis_info.get("vm_conf_pages", None) is not None \
        and redis_info.get("vm_stats_used_pages", None) is not None:
    if int(redis_info["vm_conf_pages"]) < \
            int(redis_info["vm_stats_used_pages"]):
        if (float(redis_info["vm_conf_pages"]) /
                float(redis_info["vm_stats_used_pages"])) < 0.5:
            print ("CRIT - Redis is using %d VM pages of %d allowed | "
                   "used_memory=%sMB used_rss=%sMB" %
                   (int(redis_info["vm_stats_used_pages"]),
                    int(redis_info["vm_conf_pages"]),
                    used_memory,
                    rss)
                   )
            sys.exit(EXIT_NAGIOS_CRITICAL)
        else:
            print ("WARN - Redis is using %d VM pages of %d allowed | "
                   "used_memory=%sMB used_rss=%sMB" %
                   (int(redis_info["vm_stats_used_pages"]),
                    int(redis_info["vm_conf_pages"]),
                    used_memory,
                    rss)
                   )
            sys.exit(EXIT_NAGIOS_CRITICAL)


# Redis memory usage
if used_memory >= critical_threshold:
    print ("CRIT - Redis is using %d MB of RAM. | "
           "used_memory=%sMB used_rss=%sMB" %
           (rss_round, used_memory_round, rss)
           )
    sys.exit(EXIT_NAGIOS_CRITICAL)
elif used_memory >= warn_threshold:
    print ("WARN - Redis is using %d MB of RAM. | "
           "used_memory=%sMB used_rss=%sMB" %
           (used_memory_round, used_memory, rss)
           )
    sys.exit(EXIT_NAGIOS_WARN)


# RSS memory usage
if is_local:
    if rss >= rss_critical:
        print ("CRIT - Redis is using %d MB of RAM (RSS) | "
               "used_memory=%sMB used_rss=%sMB" %
               (rss_round, used_memory, rss)
               )
        sys.exit(EXIT_NAGIOS_CRITICAL)
    elif rss >= rss_warn:
        print ("WARN - Redis is using %d MB of RAM (RSS) | "
               "used_memory=%sMB used_rss=%sMB" %
               (rss_round, used_memory, rss)
               )
        sys.exit(EXIT_NAGIOS_WARN)

    print ("OK - Redis is using %d MB of RAM (%s MB RSS) | "
           "used_memory=%sMB used_rss=%sMB" %
           (used_memory_round, rss_round, used_memory, rss)
           )
else:
    print ("OK - Redis is using %d MB of RAM | used_memory=%sMB used_rss=%sMB" %
           (used_memory_round, used_memory, rss)
           )

sys.exit(EXIT_NAGIOS_OK)
