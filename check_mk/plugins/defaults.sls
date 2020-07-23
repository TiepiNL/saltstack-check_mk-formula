# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import check_mk with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}


{%- if check_mk.agent.plugins.defaults.mk_apt_enabled %}

# 'Installing' the apt plug-in.
check_mk-mk_apt-plugins-defaults:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_apt
    - source: salt://{{ tplroot }}/files/plugins/defaults/mk_apt.jinja
    - template: jinja
    - defaults:
        upgrade: {{ check_mk.agent.plugins.defaults.apt.upgrade }}
        do_update: {{ check_mk.agent.plugins.defaults.apt.do_update }}
    - makedirs: true
    # The plugin has to be executable.
    - mode: 700

{%- endif %}


{%- if check_mk.agent.plugins.defaults.mk_inventory_enabled %}

# 'Installing' the inventory plug-in.
check_mk-mk_inventory-plugins-defaults:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_inventory
    - source: salt://{{ tplroot }}/files/plugins/defaults/mk_inventory
    - makedirs: true
    # The plugin has to be executable.
    - user: {{ check_mk.agent.user }}
    - mode: 544
    - require:
      - check_mk-mk_inventory_cfg-plugins-defaults-file-managed


# Create a mk_inventory.cfg in the agent configuration directory.
check_mk-mk_inventory_cfg-plugins-defaults-file-managed:
  file.managed:
    - name: {{ check_mk.agent.config_dir }}/mk_inventory.cfg
    - template: jinja
    - contents: |
        INVENTORY_INTERVAL={{ check_mk.agent.plugins.defaults.inventory.interval }}
    - makedirs: true
    # Secure the file against writing.
    - user: {{ check_mk.agent.user }}
    - mode: 444

{%- endif %}


{%- if check_mk.agent.plugins.defaults.mk_iptables_enabled %}

# 'Installing' the iptables plug-in.
check_mk-mk_iptables-plugins-defaults:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_iptables
    - source: salt://{{ tplroot }}/files/plugins/defaults/mk_iptables
    - makedirs: true
    # The plugin has to be executable.
    - user: {{ check_mk.agent.user }}
    - mode: 544

{%- endif %}


{%- if check_mk.agent.plugins.defaults.mk_logins_enabled %}

# 'Installing' the logins plug-in.
check_mk-mk_logins-plugins-defaults:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_logins
    - source: salt://{{ tplroot }}/files/plugins/defaults/mk_logins
    - makedirs: true
    # The plugin has to be executable.
    - user: {{ check_mk.agent.user }}
    - mode: 544

{%- endif %}


{%- if check_mk.agent.plugins.defaults.mk_logwatch_enabled %}

# 'Installing' the logwatch plug-in.
check_mk-mk_logwatch-plugins-defaults:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_logwatch
    - source: salt://{{ tplroot }}/files/plugins/defaults/mk_logwatch
    - makedirs: true
    # The plugin has to be executable.
    - user: {{ check_mk.agent.user }}
    - mode: 544


# Create a mk_logwatch.cfg in the agent configuration directory.
check_mk-mk_logwatch_cfg-plugins-defaults-file-managed:
  file.managed:
    - name: {{ check_mk.agent.config_dir }}/logwatch.cfg
    - source: {{ files_switch(['mk_logwatch.cfg.jinja'],
                              lookup='check_mk-logwatch_cfg-plugins-defaults-file-managed'
                 )
              }}
    - template: jinja
    - defaults:
        plugin_logwatch: {{ check_mk.agent.plugins.logwatch.logfiles | json }}
    - makedirs: true
    # Secure the file against writing.
    - user: {{ check_mk.agent.user }}
    - mode: 444

{%- endif %}


{%- if check_mk.agent.plugins.defaults.mk_sshd_config_enabled %}

# 'Installing' the sshd_config plug-in.
check_mk-mk_sshd_config-plugins-defaults:
  file.managed:
    - name: {{ check_mk.agent.plugins_dir }}/mk_sshd_config
    - source: salt://{{ tplroot }}/files/plugins/defaults/mk_sshd_config
    - makedirs: true
    # The plugin has to be executable.
    - user: {{ check_mk.agent.user }}
    - mode: 544

{%- endif %}
