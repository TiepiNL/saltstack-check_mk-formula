# check_mk-formula
Custom unofficial saltstack formula to manage the check_mk agent.

## General notes
The aim of this formula is to deploy and manage the check_mk agent, including plugins and some mrpe checks. It's based on the saltstack-formula template, but without any automated testing. I'm relatively new to Linux and Saltstack and I currently run the minion [masterless](https://docs.saltstack.com/en/latest/topics/tutorials/quickstart.html#salt-masterless-quickstart), so don't expect anything sophisticated.

### Background
This formula is orginally made to monitor a LAMP server, so the plugin and mrpe focus is on MariaDB/MySQL, apache, and php(-fpm).

### Other formula integration
One of the great things about Saltstack formulas is their independency. To me, this is sometimes a limitation as well because management is decentralized. For example: package installs, cron jobs, repositories, or services. check_mk uses xinetd, which can also be managed with the xinetd-formula. This formula allows integration with the cron, package, and xinetd formulas. If you disable the integrations (the default setting), the check_mk-formula works standalone with separate states to manage dependency installations, and to check the xinetd service.

## Available states

### check_mk (init.sls)
Include the package.sls, config.sls, service.sls, plugins.sls, and mrpe.sls state files.

### check_mk.package
todo

### check_mk.config
todo

### check_mk.service
todo

### check_mk.plugins
todo

### check_mk.mrpe
todo

## Pillar example
todo

## Help
todo
