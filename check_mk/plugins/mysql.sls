# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
{%- if not check_mk.agent.use_packages_formula %}
  - {{ sls_package_install }}
{%- else %}
  - packages.pkgs
{%- endif %}
  - {{ sls_config_file }}


# @TODO: docs
check_mk-mysql_cfg-plugins-mysql-file-managed:
  file.managed:
    - name: {{ check_mk.agent.config_dir }}/mysql.cfg
    - source: {{ files_switch(['mysql.cfg.jinja'],
                              lookup='check_mk-mysql_cfg-plugins-mysql-file-managed'
                 )
              }}
    - defaults:
        sql_monitoring_user: {{ check_mk.agent.plugins.mysql.monitoring_user }}
        sql_monitoring_password: {{ check_mk.agent.plugins.mysql.monitoring_password }}
    - template: jinja
    - require:
{%- if not check_mk.agent.use_packages_formula %}
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}


# @TODO: docs
check_mk-agent_mysql_plugin:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_mysql
    - source: salt://{{ tplroot }}/files/plugins/mk_mysql
    - require:
      - sls: {{ sls_config_file }}
# @TODO: xinetd restart required?
