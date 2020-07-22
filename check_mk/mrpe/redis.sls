# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- set sls_mrpe = tplroot ~ '.mrpe' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

{%- set mrpe_check_details = check_mk.agent.mrpe.redis.check %}

include:
{%- if not check_mk.agent.use_packages_formula %}
  - {{ sls_package_install }}
{%- else %}
  - packages.pkgs
{%- endif %}
  - {{ sls_mrpe }}
  - {{ sls_config_file }}


{%- if not check_mk.agent.use_packages_formula %}
# Install dependency packages, required by check_redis.py.
check_mk-python_redis-mrpe-redis-pip-installed:
  pip.installed:
    - name: {{ check_mk.agent.mrpe.redis.pip.python_redis }}
{%- endif  %}


# 'Installing' the redis mrpe plug-in python script.
# Script execution is handled in `mrpe.cfg`.
check_mk-check_redis_py-mrpe-redis-file-managed:
  file.managed:
    - name: {{ check_mk.agent.mrpe.script_dir }}/check_redis.py
    - source: salt://{{ tplroot }}/files/plugins/mrpe/check_redis.py
    - makedirs: true
    - mode: 774
    - required_in:
      - check_mk-redis-monitoring-mrpe-redis-file-blockreplace


# Add the redis checks to the `mrpe.cfg` file.
check_mk-redis-monitoring-mrpe-redis-file-blockreplace:
  file.blockreplace:
    - name: {{ check_mk.agent.config_dir }}/mrpe.cfg
    - marker_start: '# start-redis-monitoring-include'
    - marker_end: '# end-redis-monitoring-include'
    - content: |
        Redis {{ check_mk.agent.mrpe.script_dir ~ "/check_redis.py -w " ~ mrpe_check_details.warn ~ " -c " ~ mrpe_check_details.crit ~ " -r " ~ mrpe_check_details.rss_warn ~ " -R " ~ mrpe_check_details.rss_crit ~ " -s " ~ mrpe_check_details.get('server', 'localhost') ~ " -p " ~ mrpe_check_details.get('port', '6379') ~ " -P " ~ check_mk.agent.plugins.redis.get('pass', 'no-access-to-redis-credentials') ~ " -t " ~ mrpe_check_details.get('timeout', '10') }}
    - append_if_not_found: true
    - backup: false
    - require:
{%- if not check_mk.agent.use_packages_formula %}
      - pkg: check_mk-mysqltuner-mrpe-mysql-pkg-installed
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}
      - sls: {{ sls_mrpe }}
