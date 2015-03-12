# == Class: zabbix::database::mysql
#
# Public class
#
class zabbix::database::mysql (
  # Package
  $package_ensure   = 'present',
  $package_name     = $::zabbix::params::database_packages['mysql'],
  # Config values
  $zabbix_server    = $::zabbix::params::db_host,
  $db_name          = $::zabbix::params::db_name,
  $db_user          = $::zabbix::params::db_user,
  $db_password      = $::zabbix::params::db_password,
  # Config locations
  $schema_sql_path  = $::zabbix::params::schema_sql_paths['mysql'],
  $images_sql_path  = $::zabbix::params::images_sql_paths['mysql'],
  $data_sql_path    = $::zabbix::params::data_sql_paths['mysql'],
) inherits zabbix::params {

  include ::mysql::server

  case $::osfamily {
    'RedHat': {
      include ::epel
      $package_require = Yumrepo['epel']
    }
    default: {
      # Do nothing
    }
  }

  $sql_imports = [
    $schema_sql_path,
    $images_sql_path,
    $data_sql_path,
  ]

  package { 'zabbix-dbfiles-mysql':
    ensure  => $package_ensure,
    name    => $package_name,
    require => $package_require,
    before  => Mysql::Db['zabbix'],
  }

  mysql::db { 'zabbix':
    ensure   => 'present',
    user     => $db_user,
    password => $db_password,
    dbname   => $db_name,
    host     => $zabbix_server,
    charset  => 'utf8',
    collate  => 'utf8_bin',
    grant    => ['ALL'],
    sql      => $sql_imports,
  }

}
