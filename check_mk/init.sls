# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}

include:
{%- if not check_mk.agent.use_packages_formula %}
  - .package
 {%- endif %}
  - .config
{%- if not check_mk.agent.use_xinetd_formula %}
# @TODO: create 'copy' of xinetd formula?
  - .service
{%- endif %}
  - .plugins
  - .mrpe
