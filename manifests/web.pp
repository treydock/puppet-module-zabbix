# == Class: zabbix::web
#
# Public class
#
class zabbix::web (
  $package_ensure       = 'present',
  $manage_database      = $::zabbix::params::web_manage_dabase,
  $export_database      = $::zabbix::params::web_export_database,
  $export_database_tag  = $::zabbix::params::export_database_tag,
  $db_type              = $::zabbix::params::db_type,
  $package_name         = $::zabbix::params::web_packages[$db_type],
  $db_host              = $::zabbix::params::db_host,
  $db_port              = $::zabbix::params::db_port,
  $db_name              = $::zabbix::params::db_name,
  $db_user              = $::zabbix::params::db_user,
  $db_password          = $::zabbix::params::db_password,
  $zabbix_server        = '127.0.0.1',
  $zabbix_server_port   = $::zabbix::params::server_listen_port,
  $zabbix_server_name   = $::zabbix::params::zabbix_server_name,
  $image_format_default = $::zabbix::params::image_format_default,
  $config_dir           = $::zabbix::params::web_config_dir,
  $config_file          = $::zabbix::params::web_config_file,
  $apache_user_name     = $::zabbix::params::apache_user_name,
  $apache_group_name    = $::zabbix::params::apache_group_name,
) inherits zabbix::params {

  validate_bool($manage_database)

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
    ensure  => 'directory',
    path    => $config_dir,
    owner   => $apache_user_name,
    group   => $apache_group_name,
    mode    => '0750',
    before  => File['zabbix.conf.php'],
  }

  file { 'zabbix.conf.php':
    ensure  => 'file',
    path    => $config_file,
    owner   => $apache_user_name,
    group   => $apache_group_name,
    mode    => '0640',
    content => template('zabbix/web/zabbix.conf.php.erb'),
  }

  if $manage_database and ! $export_database {
    include ::mysql::server

    mysql::db { 'zabbix':
      ensure    => 'present',
      user      => $db_user,
      password  => $db_password,
      dbname    => $db_name,
      host      => 'localhost',
      charset   => 'utf8',
      collate   => 'utf8_bin',
      grant     => ['ALL'],
    }
  }

  if $manage_database and $export_database {
    @@mysql::db { "zabbix_${::fqdn}":
      ensure    => 'present',
      user      => $db_user,
      password  => $db_password,
      dbname    => $db_name,
      host      => $::fqdn,
      charset   => 'utf8',
      collate   => 'utf8_bin',
      grant     => ['ALL'],
      tag       => $export_database_tag,
    }
  }

}
