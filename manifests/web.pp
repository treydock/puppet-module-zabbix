# == Class: zabbix::web
#
# Public class
#
class zabbix::web (
  # Package
  $package_ensure       = 'present',
  $package_name         = $::zabbix::params::web_packages[$db_type],
  # Database
  $db_type              = $::zabbix::params::db_type,
  $db_host              = $::zabbix::params::db_host,
  $db_port              = $::zabbix::params::db_port,
  $db_name              = $::zabbix::params::db_name,
  $db_user              = $::zabbix::params::db_user,
  $db_password          = $::zabbix::params::db_password,
  # Config values
  $zabbix_server        = '127.0.0.1',
  $zabbix_server_port   = $::zabbix::params::server_listen_port,
  $zabbix_server_name   = $::zabbix::params::zabbix_server_name,
  $image_format_default = $::zabbix::params::image_format_default,
  # Config locations
  $config_dir           = $::zabbix::params::web_config_dir,
  $config_file          = $::zabbix::params::web_config_file,
  # Apache
  $apache_user_name     = $::zabbix::params::apache_user_name,
  $apache_group_name    = $::zabbix::params::apache_group_name,
) inherits zabbix::params {

  case $::osfamily {
    'RedHat': {
      include ::epel
      $package_require = Yumrepo['epel']
    }
    default: {
      # Do nothing
    }
  }

  package { 'zabbix-web':
    ensure  => $package_ensure,
    name    => $package_name,
    require => $package_require,
    before  => File['/etc/zabbix/web'],
  }

  file { '/etc/zabbix/web':
    ensure => 'directory',
    path   => $config_dir,
    owner  => $apache_user_name,
    group  => $apache_group_name,
    mode   => '0750',
    before => File['zabbix.conf.php'],
  }

  file { 'zabbix.conf.php':
    ensure  => 'file',
    path    => $config_file,
    owner   => $apache_user_name,
    group   => $apache_group_name,
    mode    => '0640',
    content => template('zabbix/web/zabbix.conf.php.erb'),
  }

}
