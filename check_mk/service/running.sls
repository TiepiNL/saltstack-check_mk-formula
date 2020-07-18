# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

include:
  - {{ sls_config_file }}

check_mk-xinetd-running-service-running:
  service.running:
    - name: {{ check_mk.service.name }}
    - enable: true
    - watch:
      - sls: {{ sls_config_file }}
