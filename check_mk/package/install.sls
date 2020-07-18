# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

# @TODO: docs
{%- if check_mk.agent.use_xinetd_formula %}
include:
  - xinetd
{%- endif %}

# @TODO: docs
{%- if not check_mk.agent.use_packages_formula %}
check_mk-check-mk-agent-install-pkg-installed:
  pkg.installed:
    - name: {{ check_mk.agent.pkg.name }}
    # don't need to run apt-get update for installing a deb file.
    - refresh: False
    - sources: 
      - check-mk-agent: {{ check_mk.agent.pkg.source }}
{%-   if check_mk.agent.use_xinetd_formula %}
    - watch_in:
      - service: xinetd
{%-   endif %}
{%- endif %}
