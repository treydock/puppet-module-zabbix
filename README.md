# puppet-module-zabbix

[![Build Status](https://travis-ci.org/treydock/puppet-module-zabbix.png)](https://travis-ci.org/treydock/puppet-module-zabbix)

####Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)
6. [TODO](#todo)
7. [Additional Information](#additional-information)

## Overview

This module manages Zabbix agents and servers.

## Usage

### zabbix

## Reference

### Classes

#### Public classes

* `zabbix::agent`: Installs and configures a Zabbix agent.
* `zabbix::server`: Installs and configures a Zabbix server.
* `zabbix::database::mysql`: Configures MySQL for a Zabbix server.

#### Private classes

* `zabbix::server::install`: Installs zabbix server packages.
* `zabbix::server::config`: Configures zabbix server.
* `zabbix::server::service`: Manages the zabbix-server service.
* `zabbix::params`: Sets parameter defaults based on fact values.

### Parameters

#### zabbix::agent

TODO

#### zabbix::server

TODO

#### zabbix::database::mysql

TODO

## Limitations

This module has been tested on:

* CentOS 6.5 x86_64
* CentOS 7.0 x86_64

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake test

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake beaker

## TODO

## Further Information

* https://www.zabbix.com/documentation/2.2/manual/appendix/config/zabbix_server
* http://pkgs.fedoraproject.org/cgit/zabbix22.git/plain/zabbix-fedora-epel.README?h=el6
