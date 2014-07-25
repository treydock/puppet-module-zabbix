# == Class: zabbix::server
#
class zabbix::server (
  $db_type                    = $::zabbix::params::db_type,
  $manage_user                = $::zabbix::params::server_manage_user,
  $user_uid                   = $::zabbix::params::server_user_uid,
  $user_home_dir              = $::zabbix::params::server_user_home_dir,
  $group_gid                  = $::zabbix::params::server_group_gid,
  $package_ensure             = 'present',
  $package_name               = $::zabbix::params::server_packages[$db_type],
  $manage_database            = $::zabbix::params::manage_database,
  $database_package_name      = $::zabbix::params::database_packages[$db_type],
  $db_host                    = $::zabbix::params::db_host,
  $db_name                    = $::zabbix::params::db_name,
  $db_user                    = $::zabbix::params::db_user,
  $db_password                = $::zabbix::params::db_password,
  $db_socket                  = $::zabbix::params::db_socket,
  $db_port                    = $::zabbix::params::db_port,
  $schema_sql_path            = $::zabbix::params::schema_sql_paths[$db_type],
  $images_sql_path            = $::zabbix::params::images_sql_paths['mysql'],
  $data_sql_path              = $::zabbix::params::data_sql_paths['mysql'],
  $config_file                = $::zabbix::params::server_config_file,
  $manage_logrotate           = $::zabbix::params::server_manage_logrotate,
  $use_logrotate_rule         = $::zabbix::params::server_use_logrotate_rule,
  $logrotate_every            = $::zabbix::params::server_logrotate_every,
  $listen_port                = $::zabbix::params::server_listen_port,
  $log_dir                    = $::zabbix::params::server_log_dir,
  $log_file                   = $::zabbix::params::server_log_file,
  $pid_dir                    = $::zabbix::params::server_pid_dir,
  $pid_file                   = $::zabbix::params::server_pid_file,
  $alert_scripts_path         = $::zabbix::params::alert_scripts_path,
  $external_scripts           = $::zabbix::params::external_scripts,
  $tmp_dir                    = $::zabbix::params::server_tmp_dir,
  $config_dir                 = $::zabbix::params::server_config_dir,
  $start_pollers              = $::zabbix::params::server_config_defaults['start_pollers'],
  $start_ipmi_pollers         = $::zabbix::params::server_config_defaults['start_ipmi_pollers'],
  $start_pollers_unreachable  = $::zabbix::params::server_config_defaults['start_pollers_unreachable'],
  $start_trappers             = $::zabbix::params::server_config_defaults['start_trappers'],
  $start_pingers              = $::zabbix::params::server_config_defaults['start_pingers'],
  $start_discoverers          = $::zabbix::params::server_config_defaults['start_discoverers'],
  $start_http_pollers         = $::zabbix::params::server_config_defaults['start_http_pollers'],
  $start_timers               = $::zabbix::params::server_config_defaults['start_timers'],
  $start_snmp_trapper         = $::zabbix::params::server_config_defaults['start_snmp_trapper'],
  $housekeeping_frequency     = $::zabbix::params::server_config_defaults['housekeeping_frequency'],
  $max_housekeeper_delete     = $::zabbix::params::server_config_defaults['max_housekeeper_delete'],
  $sender_frequency           = $::zabbix::params::server_config_defaults['sender_frequency'],
  $cache_size                 = $::zabbix::params::server_config_defaults['cache_size'],
  $cache_update_frequency     = $::zabbix::params::server_config_defaults['cache_update_frequency'],
  $start_db_syncers           = $::zabbix::params::server_config_defaults['start_db_syncers'],
  $history_cache_size         = $::zabbix::params::server_config_defaults['history_cache_size'],
  $trend_cache_size           = $::zabbix::params::server_config_defaults['trend_cache_size'],
  $history_text_cache_size    = $::zabbix::params::server_config_defaults['history_text_cache_size'],
  $value_cache_size           = $::zabbix::params::server_config_defaults['value_cache_size'],
  $timeout                    = $::zabbix::params::server_config_defaults['timeout'],
  $trapper_timeout            = $::zabbix::params::server_config_defaults['trapper_timeout'],
  $unreachable_period         = $::zabbix::params::server_config_defaults['unreachable_period'],
  $unavailable_delay          = $::zabbix::params::server_config_defaults['unavailable_delay'],
  $unreachable_delay          = $::zabbix::params::server_config_defaults['unreachable_delay'],
  $service_name               = $::zabbix::params::server_service_name,
  $manage_firewall            = true,
) inherits zabbix::params {

  validate_bool($manage_user)
  validate_bool($manage_database)
  validate_bool($manage_logrotate)
  validate_bool($use_logrotate_rule)
  validate_bool($start_snmp_trapper)
  validate_bool($manage_firewall)

  #validate_re($db_type, ['^mysql$','^pgsql$','^sqlite$'])
  validate_re($db_type, ['^mysql$'])

  if $manage_database {
    class { "zabbix::database::${db_type}":
      package_ensure  => $package_ensure,
      package_name    => $database_package_name,
      zabbix_server   => $db_host,
      db_name         => $db_name,
      db_user         => $db_user,
      db_password     => $db_password,
      schema_sql_path => $schema_sql_path,
      images_sql_path => $images_sql_path,
      data_sql_path   => $data_sql_path,
      before          => Class['zabbix::server::config'],
    }
  }

  anchor { 'zabbix::server::start': }->
  class { 'zabbix::server::user': }->
  class { 'zabbix::server::install': }->
  class { 'zabbix::server::config': }~>
  class { 'zabbix::server::service': }->
  anchor { 'zabbix::server::end': }

  if $manage_firewall {
    firewall { '100 allow zabbix-server':
      ensure  => 'present',
      port    => $listen_port,
      proto   => 'tcp',
      action  => 'accept',
    }
  }

}
