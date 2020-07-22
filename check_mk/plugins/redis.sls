# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_config_file }}


# @TODO: docs
check_mk-mk_redis_cfg-plugins-redis-file-managed:
  file.managed:
    - name: {{ check_mk.agent.config_dir }}/mk_redis.cfg
    - source: {{ files_switch(['mk_redis.cfg.jinja'],
                              lookup='check_mk-mk_redis_cfg-plugins-mysql-file-managed'
                 )
              }}
    - template: jinja
    - defaults:
        plugin_redis: {{ check_mk.agent.plugins.redis | json }}
    # This file contains credentials. Therefore, access is set to 400.
    - user: {{ check_mk.agent.user }}
    - mode: 400
    - require:
{%- if not check_mk.agent.use_packages_formula %}
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}


# 'Installing' the check_mk redis plug-in.
check_mk-mk_redis-plugins-redis-file-managed:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_redis
    - source: salt://{{ tplroot }}/files/plugins/mk_redis
    # The plugin has to be executable.
    - mode: 700
    - require:
      - file: check_mk-mk_redis_cfg-plugins-redis-file-managed
      - sls: {{ sls_config_file }}
