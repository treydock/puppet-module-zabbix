# == Class: zabbix::server::install
#
# Private class
#
class zabbix::server::install {

  include ::zabbix::server

  case $::osfamily {
    'RedHat': {
      include ::epel
      $package_require = Yumrepo['epel']
    }
    default: {
      # Do nothing
    }
  }

  package { 'zabbix-server':
    ensure  => $::zabbix::server::package_ensure,
    name    => $::zabbix::server::package_name_real,
    require => $package_require,
  }

}
