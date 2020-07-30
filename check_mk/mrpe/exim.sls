# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- set sls_mrpe = tplroot ~ '.mrpe' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

include:
  - {{ sls_mrpe }}
  - {{ sls_config_file }}


# The bash script responsible for the monitoring checks, in
# mrpe output format. Script execution is handled in `mrpe.cfg`.
check_mk-exim_mon-mrpe-exim-file-managed:
  file.managed:
    - name: {{ check_mk.agent.mrpe.script_dir }}/exim_mon.sh
    - source: salt://{{ tplroot }}/files/plugins/mrpe/exim_mon.sh
    - makedirs: true
    - mode: 774
    - required_in:
      - check_mk-exim-monitoring-mrpe-exim-file-blockreplace


# Add the exim monitoring checks to the `mrpe.cfg` file.
check_mk-exim-monitoring-mrpe-exim-file-blockreplace:
  file.blockreplace:
    - name: {{ check_mk.agent.config_dir }}/mrpe.cfg
    - marker_start: '# start-exim-monitoring-include'
    - marker_end: '# end-exim-monitoring-include'
    - content: |
        #@TODO: exim_mon.sh loop
    - append_if_not_found: true
    - backup: false
    - require:
      - sls: {{ sls_mrpe }}
