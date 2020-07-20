 # -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

# @TODO: retrieve roles from pillar, pillar based includes
include:
  - .needrestart
  - .mysql


# Create an empty mrpe config file,
# if it doesn't exist yet.
check_mk-mrpe_cfg-mrpe-file-managed:
  file.managed:
    - name: {{ check_mk.agent.mrpe.config }}
    - mode: 0600
    - makedirs: true
    - order: first
    # Other states blockreplace.append to this file,
    # so never replace one in place.
    - replace: false
