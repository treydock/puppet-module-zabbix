# == Class: zabbix::params
#
# The zabbix default configuration settings.
#
#
class zabbix::params {

  # User / Group defaults
  $server_manage_user = true
  $server_user_uid    = undef
  $server_group_gid   = undef

  # Database defaults
  $manage_database  = true
  $db_type          = 'mysql'
  $db_host          = 'localhost'
  $db_name          = 'zabbix'
  $db_user          = 'zabbix'
  $db_password      = 'changeme'
  $db_socket        = '/var/lib/mysql/mysql.sock'
  $db_port          = '3306'

  # Logrotate defaults
  $server_manage_logrotate    = true
  $server_use_logrotate_rule  = false
  $server_logrotate_every     = 'monthly'

  # Server configuration defaults
  $server_listen_port     = 10051
  $server_config_defaults = {
    'start_pollers'             => 5,
    'start_ipmi_pollers'        => 0,
    'start_pollers_unreachable' => 1,
    'start_trappers'            => 5,
    'start_pingers'             => 1,
    'start_discoverers'         => 1,
    'start_http_pollers'        => 1,
    'start_timers'              => 1,
    'start_snmp_trapper'        => false,
    'housekeeping_frequency'    => 1,
    'max_housekeeper_delete'    => 500,
    'sender_frequency'          => 30,
    'cache_size'                => '8M',
    'cache_update_frequency'    => 60,
    'start_db_syncers'          => 4,
    'history_cache_size'        => '8M',
    'trend_cache_size'          => '4M',
    'history_text_cache_size'   => '16M',
    'value_cache_size'          => '8M',
    'timeout'                   => 3,
    'trapper_timeout'           => 300,
    'unreachable_period'        => 45,
    'unavailable_delay'         => 60,
    'unreachable_delay'         => 15,
  }

  case $::osfamily {
    'RedHat': {
      # agent defaults
      $agent_package_name         = 'zabbix-agent'
      $agent_service_name         = 'zabbix-agent'
      $agent_service_hasstatus    = true
      $agent_service_hasrestart   = true
      $agent_config_path          = '/etc/zabbix_agentd.conf'
      $agent_include_dir          = '/etc/zabbix/zabbix_agentd.d/'
      $agent_logrotate_path       = '/etc/logrotate.d/zabbix-agent'
      $agent_pid_dir              = '/var/run/zabbix'
      $agent_pid_file             = "${agent_pid_dir}/zabbix_agentd.pid"
      $agent_log_dir              = '/var/log/zabbix'
      $agent_log_file             = "${agent_log_dir}/zabbix_agentd.log"

      # server defaults
      $server_config_file         = '/etc/zabbix_server.conf'
      $server_config_dir          = '/etc/zabbix_server.conf.d'
      $server_user_home_dir       = '/var/lib/zabbixsrv'
      $server_log_dir             = '/var/log/zabbixsrv'
      $server_log_file            = "${server_log_dir}/zabbix_server.log"
      $server_pid_dir             = '/var/run/zabbixsrv'
      $server_pid_file            = "${server_pid_dir}/zabbix_server.pid"
      $alert_scripts_path         = "${server_user_home_dir}/alertscripts"
      $external_scripts           = "${server_user_home_dir}/externalscripts"
      $server_tmp_dir             = "${server_user_home_dir}/tmp"
      # Defaults that depend on db_type
      $server_packages            = {
        'mysql'   => 'zabbix22-server-mysql',
        #'pgsql'   => 'zabbix22-server-pgsql',
        #'sqlite'  => 'zabbix22-server-sqlite3',
      }
      $database_packages          = {
        'mysql'   => 'zabbix22-dbfiles-mysql',
        #'pgsql'   => 'zabbix22-dbfiles-pgsql',
        #'sqlite'  => 'zabbix22-dbfiles-sqlite3',
      }
      $schema_sql_paths           = {
        'mysql'   => '/usr/share/zabbix-mysql/schema.sql',
      }
      $images_sql_paths           = {
        'mysql'   => '/usr/share/zabbix-mysql/images.sql',
      }
      $data_sql_paths             = {
        'mysql'   => '/usr/share/zabbix-mysql/data.sql',
      }
      $server_service_name        = 'zabbix-server'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
