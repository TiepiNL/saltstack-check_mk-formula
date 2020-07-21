# -*- coding: utf-8 -*-
# vim: ft=sls

# References:
# https://checkmk.com/cms_agent_linux.html
# https://github.com/tribe29/checkmk/tree/master/agents/plugins

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
# @TODO: docs
{%- if check_mk.agent.use_xinetd_formula %}
  - xinetd
{%- endif %}
{%- if not check_mk.agent.use_packages_formula %}
  - {{ sls_package_install }}
{%- else %}
  - packages.pkgs
{%- endif %}


# @TODO: docs
{%- if check_mk.agent.encrypted %}
check_mk-encryption_cfg-config-file-file-managed:
  file.managed:
    - name: {{ check_mk.agent.config.encryption }}
    - makedirs: true
    - template: jinja
    - contents: |
        ENCRYPTED=yes
        PASSPHRASE={{ check_mk.agent.encryption_passphrase }}
    # Secure the file against reading by other users.
    - mode: 400
    - require:
{%- if not check_mk.agent.use_packages_formula %}
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}
{%-   if check_mk.agent.use_xinetd_formula %}
    - watch_in:
      - module: xinetd-restart
{%-   endif %}
{%- endif %}


# Configuration for the xinetd, which connects the agent's output to TCP-Port 6556.
check_mk-xinetd-config-file-file-managed:
  file.managed:
    - name: {{ check_mk.agent.config.xinetd }}
    - source: {{ files_switch(['xinetd.jinja'],
                              lookup='check_mk-xinetd-config-file-file-managed'
                 )
              }}
    - makedirs: true
    - template: jinja
    - defaults:
        only_from_server_ips: {{ check_mk.agent.only_from_server_ips }}
    - require:
{%- if not check_mk.agent.use_packages_formula %}
      - sls: {{ sls_package_install }}
{%- else %}
      - sls: packages.pkgs
{%- endif %}
{%-   if check_mk.agent.use_xinetd_formula %}
    - watch_in:
      - module: xinetd-restart
{%-   endif %}


# Create an empty fileinfo config file,
# if it doesn't exist yet.
check_mk-fileinfo_cfg-config-file-managed:
  file.managed:
    - name: {{ check_mk.agent.config.fileinfo }}
    - makedirs: true
    - mode: 0600
    # Other states blockreplace.append to this file,
    # so never replace one in place.
    - replace: false


# Cleanup SystemD
check_mk-systemd_socket_file-config-file-file-absent:
  file.absent:
    - name: {{ check_mk.systemd_system_dir }}/check-mk-agent.socket

check_mk-systemd_service_file-config-file-file-absent:
  file.absent:
    - name: {{ check_mk.systemd_system_dir }}/check-mk-agent@.service

check_mk-restart_xinetd-config-file-cmd-wait:
  cmd.wait:
    - name: systemctl daemon-reload && systemctl restart xinetd
    - watch:
      - file: check_mk-systemd_socket_file-config-file-file-absent
      - file: check_mk-systemd_service_file-config-file-file-absent
