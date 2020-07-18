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


# @TODO: docs
check_mk-needrestart-mrpe-needrestart-pkg-installed:
  pkg.installed:
    - name: {{ check_mk.agent.mrpe.needrestart.pkg.name }}


# @TODO: docs
check_mk-restart_required-mrpe-needrestart-file-blockreplace:
  file.blockreplace:
    - name: {{ check_mk.agent.config_dir }}/mrpe.cfg
    - marker_start: '# start-needrestart-include'
    - marker_end: '# end-needrestart-include'
    # -q: be quiet
    # -p: enable Nagios plugin mode
    # -k: check for obsolete kernel only
    - content: |
        Restart%20Required /usr/sbin/needrestart -q -p -k
    - append_if_not_found: true
    - require:
      - pkg: check_mk-needrestart-mrpe-needrestart-pkg-installed
{%- if not check_mk.agent.use_packages_formula %}
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}
      - sls: {{ sls_mrpe }} 


# @TODO: docs      
check_mk-needrestart_apt_hook-mrpe-needrestart-file-absent:
  file.absent:
    - name: {{ check_mk.apt_conf_dir }}/99needrestart
    - require:
      - file: check_mk-restart_required-mrpe-needrestart-file-blockreplace
