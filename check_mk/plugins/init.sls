# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  # Default plugins:
  # (enabled/disabled based on pillar config)
  # * mk_apt
  # * mk_inventory
  # * mk_iptables
  # * mk_logins
  # * mk_sshd_config
  - .defaults
  # Role-specific:
# @TODO: retrieve roles from pillar / grains
  - .mysql
