# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set sls_mrpe = tplroot ~ '.mrpe' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

include:
{%- if not check_mk.agent.use_packages_formula %}
  - {{ sls_package_install }}
{%- else %}
  - packages.pkgs
{%- endif %}
  - {{ sls_mrpe }}


{%- if not check_mk.agent.use_packages_formula %}
# Install mysqltuner, a high-performance MySQL tuning script.
check_mk-mysqltuner-mrpe-mysql-pkg-installed:
  pkg.installed:
    - name: {{ check_mk.agent.mrpe.mysql.mysqltuner.pkg.name }}
{%- endif  %}

{%- if not check_mk.agent.use_packages_formula %}
# Install dependency packages, required by the mysqltuner script.
check_mk-dependencies-mrpe-mysql-pkg-installed:
  pkg.installed:
    - pkgs: {{ check_mk.agent.mrpe.mysql.mysqltuner.pkg.dependencies | json }}
{%- endif  %}


# The `mysqltuner` runs asynchronous to reduce socket connection time. 
# The script can be executed via this is state, or alternatively via a 
# cron job managed in the cron-formula (preferred method). 
{%- if not check_mk.agent.use_cron_formula %}
check_mk-mysqltuner-mrpe-mysql-cmd-run:
  cmd.run:
    - name: mysqltuner --silent --defaults-file {{ check_mk.agent.config_dir }}/mysql.cfg --json --outputfile {{ check_mk.agent.mrpe.mysql.mysqltuner.output_file }}
    # run command in background and do not await or deliver its results.
    - bg: true
    - require:
{%-   if not check_mk.agent.use_packages_formula %}
      - pkg: check_mk-mysqltuner-mrpe-mysql-pkg-installed
      - pkg: check_mk-dependencies-mrpe-mysql-pkg-installed
{%-   else  %}
      - sls: packages.pkgs
{%-   endif %}
{%- endif  %}


# The bash script responsible for converting the mysqltuner json output to
# mrpe output. Script execution is handled in `mrpe.cfg`.
check_mk-mysqltuner-mrpe-mysql-file-managed:
  file.managed:
    - name: {{ check_mk.agent.mrpe.script_dir }}/mysqltuner.sh
    - source: salt://{{ tplroot }}/files/plugins/mrpe/mysqltuner.sh
    - makedirs: true
    - mode: 774


# Bash script to monitor deadlocks. Script execution is handled in `mrpe.cfg`.
check_mk-deadlocks-mrpe-mysql-file-managed:
  file.managed:
    - name: {{ check_mk.agent.mrpe.script_dir }}/mysql_deadlocks.sh
    - source: salt://{{ tplroot }}/files/plugins/mrpe/mysql_deadlocks.sh
    - makedirs: true
    - mode: 774


# Loop through the mysqltuner mrpe check config (see defaults.yaml,
# setings can be overwritten in pillar config). Create the correct syntax
# in mrpe format to call `mysqltuner.sh` with arguments.
#
# `mysqltuner.sh` options documentation:
#
# -a ACTION       The check to perform. Current mysqltuner 
#                 mrpe checks (alphabetical):
#                 * fragmented_tables
#                 * innodb_log_waits
#                 * joins_without_indexes_per_day
#                 * pct_aria_keys_from_mem
#                 * pct_binlog_cache
#                 * pct_connections_aborted
#                 * pct_connections_used
#                 * pct_files_open
#                 * pct_keys_from_mem
#                 * pct_max_physical_memory
#                 * pct_max_used_memory
#                 * pct_other_processes_memory
#                 * pct_read_efficiency
#                 * pct_slow_queries
#                 * pct_table_locks_immediate
#                 * pct_temp_disk
#                 * pct_temp_sort_table
#                 * pct_wkeys_from_mem
#                 * pct_write_efficiency
#                 * pct_write_queries
#                 * performance_metrics
#                 * recommendations
#                 * table_cache_hit_rate
#                 * thread_cache_hit_rate
#
# -c CRIT         Critical threshold.
# -C COMPARE      Comparison operator to apply to -c and -w.
#                 Possible values: == != >= > < <=. Default >=.
# -w WARN         Warning threshold.

# Add the deadlock check and mysqltuner checks to the `mrpe.cfg` file by looping through the checks.
# Output format:
# MySQL%20<friendly>%20<name> <script_path>/mysqltuner.sh -a <check> -c <critical> -w <warning> -C '<compare>'
check_mk-restart_required-mrpe-mysql-file-blockreplace:
  file.blockreplace:
    - name: {{ check_mk.agent.config_dir }}/mrpe.cfg
    - marker_start: '# start-mysql-monitoring-include'
    - marker_end: '# end-mysql-monitoring-include'
    - content: |
        MySQL%20deadLocks {{ check_mk.agent.mrpe.script_dir }}/mysql_deadlocks.sh
{%- set mrpe_checks = check_mk.agent.mrpe.mysql.mysqltuner.checks %}
{%- for check, check_details in mrpe_checks.items() %}
{%-   if check_details.get('enabled', true) %}
        MySQL%20{{ check_details.pretty_name.replace(" ", "%20") ~ " " ~ check_mk.agent.mrpe.script_dir ~ "/mysqltuner.sh -a " ~ check ~ " -c " ~ check_details.get('crit', 'None') ~ " -w " ~ check_details.get('warn', 'None') ~ " -C '" ~ check_details.get('compare', '>=') ~ "'" }}
{%-   endif %}
{%- endfor %}
    - append_if_not_found: true
    - backup: false
    - require:
      - file: check_mk-mrpe_checks-mrpe-mysql-file-managed
{%- if not check_mk.agent.use_packages_formula %}
      - pkg: check_mk-mysqltuner-mrpe-mysql-pkg-installed
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}
      - sls: {{ sls_mrpe }}

# @TODO: add check to monitor json file timestamp
