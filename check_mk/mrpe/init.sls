# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

# @TODO: retrieve roles from pillar, pillar based includes
include:
  - .needrestart
  - .mysql


# Empty the mrpe config.
check_mk-mrpe_cfg-mrpe-file-managed:
  file.managed:
    - name: {{ check_mk.agent.mrpe.config }}
    - mode: 0600
    - backup: None
    - makedirs: true
    - order: first
    # `False` is implied but added for clarity - other states
    # blockreplace.append to this file, so never replace
    # one in place.
    - replace: false
