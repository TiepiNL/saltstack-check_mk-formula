# -*- coding: utf-8 -*-
# vim: ft=sls

# Get the `tplroot` from `tpldir`
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- set sls_mrpe = tplroot ~ '.mrpe' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

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
{%- set mrpe_check_defaults = check_mk.agent.mrpe.redis.check %}

{% for instance, props in check_mk.agent.plugins.redis.get('instances', {}).items() %}
  
    {%- set mrpe_check_warn_lvl = props.get('warn', mrpe_check_defaults.default_thresholds.warn) %}
    {%- set mrpe_check_crit_lvl = props.get('crit', mrpe_check_defaults.default_thresholds.crit) %}
    {%- set mrpe_check_rss_warn_lvl = props.get('rss_warn', mrpe_check_defaults.default_thresholds.rss_warn) %}
    {%- set mrpe_check_rss_crit_lvl = props.get('rss_crit', mrpe_check_defaults.default_thresholds.rss_crit) %}
    {%- set mrpe_check_timeout = props.get('timeout', mrpe_check_defaults.timeout) %}
    
    {%- set redis_server = props.get('server', 'localhost') %}
    {%- set redis_port = props.get('port', '6379') %}
    {%- set redis_pass = props.get('pass', 'no-access-to-redis-credentials') %}

check_mk-{{instance}}-monitoring-mrpe-redis-file-blockreplace:
  file.blockreplace:
    - name: {{ check_mk.agent.config_dir }}/mrpe.cfg
    - marker_start: '# start-{{ instance }}-monitoring-include'
    - marker_end: '# end-{{ instance }}-monitoring-include'
    - content: |
        {{ instance ~ "%20memory%20usage " ~ check_mk.agent.mrpe.script_dir ~ "/check_redis.py -w " ~ mrpe_check_warn_lvl ~ " -c " ~ mrpe_check_crit_lvl ~ " -r " ~ mrpe_check_rss_warn_lvl ~ " -R " ~ mrpe_check_rss_crit_lvl ~ " -s " ~ redis_server ~ " -p " ~ redis_port ~ " -P " ~ redis_pass ~ " -t " ~ mrpe_check_timeout }}
    - append_if_not_found: true
    - backup: false
    - require:
{%- if not check_mk.agent.use_packages_formula %}
      - pkg: check_mk-python_redis-mrpe-redis-pip-installed
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}
      - sls: {{ sls_mrpe }}

{%- endfor %}
