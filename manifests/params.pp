# == Class: zabbix::params
#
# The zabbix default configuration settings.
#
class zabbix::params {

  # User / Group defaults
  $agent_manage_user  = true
  $agent_user_uid     = undef
  $agent_group_gid    = undef
  $server_manage_user = true
  $server_user_uid    = undef
  $server_group_gid   = undef

  # Database defaults
  $manage_database      = true
  $web_manage_dabase    = false
  $web_export_database  = false
  $export_database_tag  = $::domain
  $db_type              = 'mysql'
  $db_host              = 'localhost'
  $db_name              = 'zabbix'
  $db_user              = 'zabbix'
  $db_password          = 'changeme'
  $db_socket            = '/var/lib/mysql/mysql.sock'
  $db_port              = '3306'

  # Web defaults
  $manage_web           = true
  $zabbix_server_name   = 'Zabbix Server'
  $image_format_default = 'IMAGE_FORMAT_PNG'

  # Logrotate defaults
  $agent_manage_logrotate     = true
  $agent_use_logrotate_rule   = false
  $agent_logrotate_every      = 'monthly'
  $server_manage_logrotate    = true
  $server_use_logrotate_rule  = false
  $server_logrotate_every     = 'monthly'

  # Agent configuration defaults
  $servers                = ['127.0.0.1']
  $agent_listen_port      = 10050
  $agent_config_defaults  = {
    'enable_remote_commands'  => false,
    'log_remote_commands'     => false,
    'listen_ip'               => ['0.0.0.0'],
    'start_agents'            => 3,
    'host_metadata'           => '',
    'refresh_active_checks'   => 120,
    'buffer_send'             => 5,
    'buffer_size'             => 100,
    'max_lines_per_second'    => 100,
    'timeout'                 => 3,
    'allow_root'              => false,
    'unsafe_user_parameters'  => false,
  }

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
      $agent_config_file          = '/etc/zabbix_agentd.conf'
      $agent_config_d_dir         = '/etc/zabbix_agentd.conf.d'
      $agent_user_home_dir        = '/var/lib/zabbix'
      $agent_scripts_dir          = "${agent_user_home_dir}/bin"
      $agent_log_dir              = '/var/log/zabbix'
      $agent_log_file             = "${agent_log_dir}/zabbix_agentd.log"
      $agent_pid_dir              = '/var/run/zabbix'
      $agent_pid_file             = "${agent_pid_dir}/zabbix_agentd.pid"
      $agent_package_name         = 'zabbix22-agent'
      $agent_service_name         = 'zabbix-agent'

      # server defaults
      $server_config_file         = '/etc/zabbix_server.conf'
      $server_config_d_dir        = '/etc/zabbix_server.conf.d'
      $server_user_home_dir       = '/var/lib/zabbixsrv'
      $server_log_dir             = '/var/log/zabbixsrv'
      $server_log_file            = "${server_log_dir}/zabbix_server.log"
      $server_pid_dir             = '/var/run/zabbixsrv'
      $server_pid_file            = "${server_pid_dir}/zabbix_server.pid"
      $alert_scripts_path         = "${server_user_home_dir}/alertscripts"
      $external_scripts           = "${server_user_home_dir}/externalscripts"
      $server_tmp_dir             = "${server_user_home_dir}/tmp"
      $server_service_name        = 'zabbix-server'

      # Web defaults
      $web_config_dir             = '/etc/zabbix/web'
      $web_config_file            = "${web_config_dir}/zabbix.conf.php"
      $apache_user_name           = 'apache'
      $apache_group_name          = 'apache'

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
      $web_packages               = {
        'mysql'   => 'zabbix22-web-mysql',
      }

      if $::operatingsystemmajrelease >= 7 {
        $agent_logrotate_defaults   = {
          'missingok'     => true,
          'ifempty'       => false,
          'compress'      => true,
          'create'        => true,
          'create_mode'   => '0664',
          'create_owner'  => 'zabbix',
          'create_group'  => 'zabbix',
          'su'            => true,
          'su_owner'      => 'zabbix',
          'su_group'      => 'zabbix',
        }
        $server_logrotate_defaults  = {
          'missingok'     => true,
          'ifempty'       => false,
          'compress'      => true,
          'create'        => true,
          'create_mode'   => '0664',
          'create_owner'  => 'zabbixsrv',
          'create_group'  => 'zabbixsrv',
          'su'            => true,
          'su_owner'      => 'zabbixsrv',
          'su_group'      => 'zabbixsrv',
        }
      } else {
        $agent_logrotate_defaults = {
          'missingok'     => true,
          'ifempty'       => false,
          'compress'      => true,
          'create'        => true,
          'create_mode'   => '0664',
          'create_owner'  => 'zabbix',
          'create_group'  => 'zabbix',
          'su'            => false,
        }
        $server_logrotate_defaults = {
          'missingok'     => true,
          'ifempty'       => false,
          'compress'      => true,
          'create'        => true,
          'create_mode'   => '0664',
          'create_owner'  => 'zabbixsrv',
          'create_group'  => 'zabbixsrv',
          'su'            => false,
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
