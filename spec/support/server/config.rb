shared_context 'zabbix::server::config' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :root_home                  => '/root',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix::server::config') }
  it { should contain_class('zabbix::server') }

  it 'manage zabbix-server user\'s home directory' do
    should contain_file('/var/lib/zabbixsrv').only_with({
      :ensure   => 'directory',
      :path     => '/var/lib/zabbixsrv',
      :mode     => '0750',
      :owner    => 'zabbixsrv',
      :group    => 'zabbixsrv',
    })
  end

  it 'manage zabbix-server\'s AlertScriptsPath directory' do
    should contain_file('/var/lib/zabbixsrv/alertscripts').only_with({
      :ensure   => 'directory',
      :path     => '/var/lib/zabbixsrv/alertscripts',
      :mode     => '0750',
      :owner    => 'zabbixsrv',
      :group    => 'zabbixsrv',
      :require  => 'File[/var/lib/zabbixsrv]',
    })
  end

  it 'manage zabbix-server\'s ExternalScripts directory' do
    should contain_file('/var/lib/zabbixsrv/externalscripts').only_with({
      :ensure   => 'directory',
      :path     => '/var/lib/zabbixsrv/externalscripts',
      :mode     => '0750',
      :owner    => 'zabbixsrv',
      :group    => 'zabbixsrv',
      :require  => 'File[/var/lib/zabbixsrv]',
    })
  end

  it 'manage zabbix-server\'s TmpDir directory' do
    should contain_file('/var/lib/zabbixsrv/tmp').only_with({
      :ensure   => 'directory',
      :path     => '/var/lib/zabbixsrv/tmp',
      :mode     => '0750',
      :owner    => 'zabbixsrv',
      :group    => 'zabbixsrv',
      :require  => 'File[/var/lib/zabbixsrv]',
    })
  end

  it 'manage zabbix-server\'s log directory' do
    should contain_file('/var/log/zabbixsrv').only_with({
      :ensure   => 'directory',
      :path     => '/var/log/zabbixsrv',
      :mode     => '0775',
      :owner    => 'root',
      :group    => 'zabbixsrv',
    })
  end

  it 'manage zabbix-server\'s pid directory' do
    should contain_file('/var/run/zabbixsrv').only_with({
      :ensure   => 'directory',
      :path     => '/var/run/zabbixsrv',
      :mode     => '0775',
      :owner    => 'root',
      :group    => 'zabbixsrv',
    })
  end

  it 'should set zabbix_server.conf Include value' do
    should contain_file_line('zabbix_server.conf Include').with({
      :path  => '/etc/zabbix_server.conf',
      :line  => 'Include=/etc/zabbix_server.conf.d',
      :match => '^Include=.*',
    })
  end

  it 'should manage zabbix_server.conf' do
    should contain_file('/etc/zabbix_server.conf').only_with({
      :ensure => 'file',
      :path   => '/etc/zabbix_server.conf',
      :owner  => 'root',
      :group  => 'zabbixsrv',
      :mode   => '0640',
    })
  end

  it 'manage zabbix-server conf.d directory' do
    should contain_file('/etc/zabbix_server.conf.d').only_with({
      :ensure   => 'directory',
      :path     => '/etc/zabbix_server.conf.d',
      :mode     => '0750',
      :owner    => 'root',
      :group    => 'zabbixsrv',
      :recurse  => 'true',
      :purge    => 'true',
    })
  end

  it 'should manage zabbix_server_general.conf' do
    should contain_file('zabbix_server_general.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_server.conf.d/zabbix_server_general.conf',
      :owner    => 'root',
      :group    => 'zabbixsrv',
      :mode     => '0640',
      :content  => /.*/,
      :require  => 'File[/etc/zabbix_server.conf.d]',
    })
  end

  it 'File[zabbix_server_general.conf] should have valid contents' do
    verify_contents(catalogue, 'zabbix_server_general.conf', [
      'NodeID=0',
      'ListenPort=10051',
      '# SourceIP=',
      'LogFile=/var/log/zabbixsrv/zabbix_server.log',
      'LogFileSize=0',
      'DebugLevel=3',
      'PidFile=/var/run/zabbixsrv/zabbix_server.pid',
      'DBHost=localhost',
      'DBName=zabbix',
      'DBUser=zabbix',
      'DBPassword=changeme',
      'DBSocket=/var/lib/mysql/mysql.sock',
      'DBPort=3306',
    ])
  end

  it 'should manage zabbix_server_advanced.conf' do
    should contain_file('zabbix_server_advanced.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_server.conf.d/zabbix_server_advanced.conf',
      :owner    => 'root',
      :group    => 'zabbixsrv',
      :mode     => '0640',
      :content  => /.*/,
      :require  => 'File[/etc/zabbix_server.conf.d]',
    })
  end

  it 'File[zabbix_server_advanced.conf] should have valid contents' do
    verify_contents(catalogue, 'zabbix_server_advanced.conf', [
      'StartPollers=5',
      'StartIPMIPollers=0',
      'StartPollersUnreachable=1',
      'StartTrappers=5',
      'StartPingers=1',
      'StartDiscoverers=1',
      'StartHTTPPollers=1',
      'StartTimers=1',
      '# JavaGateway=',
      '# JavaGatewayPort=10052',
      '# StartJavaPollers=0',
      '# StartVMwareCollectors=0',
      '# VMwareFrequency=60',
      '# VMwareCacheSize=8M',
      '# SNMPTrapperFile=/tmp/zabbix_traps.tmp',
      'StartSNMPTrapper=0',
      '# ListenIP=0.0.0.0',
      'HousekeepingFrequency=1',
      'MaxHousekeeperDelete=500',
      'SenderFrequency=30',
      'CacheSize=8M',
      'CacheUpdateFrequency=60',
      'StartDBSyncers=4',
      'HistoryCacheSize=8M',
      'TrendCacheSize=4M',
      'HistoryTextCacheSize=16M',
      'ValueCacheSize=8M',
      '# NodeNoEvents=0',
      '# NodeNoHistory=0',
      'Timeout=3',
      'TrapperTimeout=300',
      'UnreachablePeriod=45',
      'UnavailableDelay=60',
      'UnreachableDelay=15',
      'AlertScriptsPath=/var/lib/zabbixsrv/alertscripts',
      'ExternalScripts=/var/lib/zabbixsrv/externalscripts',
      '# FpingLocation=/usr/sbin/fping',
      '# Fping6Location=/usr/sbin/fping6',
      '# SSHKeyLocation=',
      '# LogSlowQueries=0',
      'TmpDir=/var/lib/zabbixsrv/tmp',
      '# StartProxyPollers=1',
      '# ProxyConfigFrequency=3600',
      '# ProxyDataFrequency=1',
      '# AllowRoot=0',
    ])
  end

  it 'should manage zabbix_server_modules.conf' do
    should contain_file('zabbix_server_modules.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_server.conf.d/zabbix_server_modules.conf',
      :owner    => 'root',
      :group    => 'zabbixsrv',
      :mode     => '0640',
      :content  => /.*/,
      :require  => 'File[/etc/zabbix_server.conf.d]',
    })
  end

  it 'File[zabbix_server_modules.conf] should have valid contents' do
    verify_contents(catalogue, 'zabbix_server_modules.conf', [
      '# LoadModulePath=${libdir}/modules',
      '# LoadModule=',
    ])
  end

  it 'should manage File[/etc/logrotate.d/zabbix-server]' do
    should contain_file('/etc/logrotate.d/zabbix-server').with({
      :ensure  => 'file',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0444',
    })
  end

  it { should_not contain_logrotate__rule('zabbix-server') }

  it 'File[/etc/logrotate.d/zabbix-server] should have valid contents' do
    verify_contents(catalogue, '/etc/logrotate.d/zabbix-server', [
      '/var/log/zabbixsrv/zabbix_server.log {',
      '  compress',
      '  create 0664 zabbixsrv zabbixsrv',
      '  missingok',
      '  monthly',
      '  notifempty',
      '  su zabbixsrv zabbixsrv',
      '}',
    ])
  end

  context 'when use_logrotate_rule => true' do
    let(:params) {{ :use_logrotate_rule => true }}

    it 'should manage logrotate::rule[zabbix-server]' do
      should contain_logrotate__rule('zabbix-server').with({
        :path         => '/var/log/zabbixsrv/zabbix_server.log',
        :missingok    => 'true',
        :rotate_every => 'monthly',
        :ifempty      => 'false',
        :compress     => 'true',
        :create       => 'true',
        :create_mode  => '0664',
        :create_owner => 'zabbixsrv',
        :create_group => 'zabbixsrv',
        :su           => 'true',
        :su_owner     => 'zabbixsrv',
        :su_group     => 'zabbixsrv',
      })
    end

    it 'File[/etc/logrotate.d/zabbix-server] should have valid contents' do
      verify_contents(catalogue, '/etc/logrotate.d/zabbix-server', [
        '/var/log/zabbixsrv/zabbix_server.log {',
        '  compress',
        '  create 0664 zabbixsrv zabbixsrv',
        '  missingok',
        '  monthly',
        '  notifempty',
        '  su zabbixsrv zabbixsrv',
        '}',
      ])
    end
  end

end
