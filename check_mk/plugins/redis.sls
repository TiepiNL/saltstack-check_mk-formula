# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import redis with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_config_file }}


# 'Installing' the redis plug-in.
check_mk-mk_redis-plugins-redis:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_redis
    - source: salt://{{ tplroot }}/files/plugins/mk_redis
    # The plugin has to be executable.
    - mode: 700
    - require:
      - sls: {{ sls_config_file }}
