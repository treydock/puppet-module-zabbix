shared_context 'zabbix::agent::config' do
  let(:facts) { default_facts }

  it { should create_class('zabbix::agent::config') }
  it { should contain_class('zabbix::agent') }

  it 'manage zabbix-agent user\'s home directory' do
    should contain_file('/var/lib/zabbix').only_with({
      :ensure   => 'directory',
      :path     => '/var/lib/zabbix',
      :mode     => '0750',
      :owner    => 'zabbix',
      :group    => 'zabbix',
    })
  end

  it 'manage zabbix-agent script directory' do
    should contain_file('/var/lib/zabbix/bin').only_with({
      :ensure   => 'directory',
      :path     => '/var/lib/zabbix/bin',
      :mode     => '0750',
      :owner    => 'zabbix',
      :group    => 'zabbix',
    })
  end

  it 'manage zabbix-agent\'s log directory' do
    should contain_file('/var/log/zabbix').only_with({
      :ensure   => 'directory',
      :path     => '/var/log/zabbix',
      :mode     => '0775',
      :owner    => 'root',
      :group    => 'zabbix',
    })
  end

  it 'manage zabbix-agent\'s pid directory' do
    should contain_file('/var/run/zabbix').only_with({
      :ensure   => 'directory',
      :path     => '/var/run/zabbix',
      :mode     => '0755',
      :owner    => 'zabbix',
      :group    => 'zabbix',
    })
  end

  it 'should manage zabbix_agentd.conf' do
    should contain_file('/etc/zabbix_agentd.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_agentd.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :content  => /.*/,
    })
  end


  it 'should have valid contents for zabbix_agentd.conf' do
    verify_contents(catalogue, '/etc/zabbix_agentd.conf', [
      'PidFile=/var/run/zabbix/zabbix_agentd.pid',
      'LogFile=/var/log/zabbix/zabbix_agentd.log',
      'LogFileSize=0',
      '# DebugLevel=3',
      '# SourceIP=',
      'EnableRemoteCommands=0',
      'LogRemoteCommands=0',
      'Server=127.0.0.1',
      'ListenPort=10050',
      'ListenIP=0.0.0.0',
      'StartAgents=3',
      'ServerActive=127.0.0.1',
      'Hostname=foo.example.com',
      '# HostnameItem=system.hostname',
      'HostMetadata=',
      '# HostMetadataItem=',
      'RefreshActiveChecks=120',
      'BufferSend=5',
      'BufferSize=100',
      'MaxLinesPerSecond=100',
      '# Alias=',
      'Timeout=3',
      'AllowRoot=0',
      'Include=/etc/zabbix_agentd.conf.d',
      'UnsafeUserParameters=0',
      '# UserParameter=',
      '# LoadModulePath=${libdir}/modules',
      '# LoadModule=',
    ])
  end

  it 'manage zabbix-agent conf.d directory' do
    should contain_file('/etc/zabbix_agentd.conf.d').only_with({
      :ensure   => 'directory',
      :path     => '/etc/zabbix_agentd.conf.d',
      :mode     => '0755',
      :owner    => 'root',
      :group    => 'root',
      :recurse  => 'true',
      :purge    => 'true',
    })
  end

  context "when servers => ['192.168.1.1','192.168.1.2']" do
    let(:params) {{ :servers => ['192.168.1.1','192.168.1.2'] }}
    it "should set Server and ServerActive to 192.168.1.1,192.168.1.2" do
      verify_contents(catalogue, '/etc/zabbix_agentd.conf', [
        'Server=192.168.1.1,192.168.1.2',
        'ServerActive=192.168.1.1,192.168.1.2',
      ])
    end
  end

  # Test boolean configuration options
  [
    :enable_remote_commands,
    :log_remote_commands,
    :allow_root,
    :unsafe_user_parameters,
  ].each do |p|
    context "when #{p} => true" do
      config_name = p.to_s.camel_case
      let(:params) {{ p => true }}
      it "should set #{config_name}=1" do
        verify_contents(catalogue, '/etc/zabbix_agentd.conf', ["#{config_name}=1"])
      end
    end
  end

  # Test integer configuration options
  [
    :start_agents,
    :refresh_active_checks,
    :buffer_send,
    :buffer_size,
    :max_lines_per_second,
    :timeout,
  ].each do |p|
    context "when #{p} => 10" do
      config_name = p.to_s.camel_case
      let(:params) {{ p => 10 }}
      it "should set #{config_name}=10" do
        verify_contents(catalogue, '/etc/zabbix_agentd.conf', ["#{config_name}=10"])
      end
    end
  end

  # Test Array configuration options
  context "when listen_ip => ['192.168.1.1','127.0.0.1']" do
    let(:params) {{ :listen_ip => ['192.168.1.1','127.0.0.1'] }}
    it "should set ListenIP=192.168.1.1,127.0.0.1" do
      verify_contents(catalogue, '/etc/zabbix_agentd.conf', ["ListenIP=192.168.1.1,127.0.0.1"])
    end
  end

  # Test string configuration options
  [
    :host_metadata,
  ].each do |p|
    context "when #{p} => 'foo'" do
      config_name = p.to_s.camel_case
      let(:params) {{ p => 'foo' }}
      it "should set #{config_name}=foo" do
        verify_contents(catalogue, '/etc/zabbix_agentd.conf', ["#{config_name}=foo"])
      end
    end
  end

  it 'should manage File[/etc/logrotate.d/zabbix-agent]' do
    should contain_file('/etc/logrotate.d/zabbix-agent').with({
      :ensure  => 'file',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0444',
    })
  end

  it { should_not contain_logrotate__rule('zabbix-agent') }

  it 'File[/etc/logrotate.d/zabbix-agent] should have valid contents' do
    verify_contents(catalogue, '/etc/logrotate.d/zabbix-agent', [
      '/var/log/zabbix/zabbix_agentd.log {',
      '  compress',
      '  create 0664 zabbix zabbix',
      '  missingok',
      '  monthly',
      '  notifempty',
      '}',
    ])
  end

  context 'when use_logrotate_rule => true' do
    let(:params) {{ :use_logrotate_rule => true }}

    it 'should manage logrotate::rule[zabbix-agent]' do
      should contain_logrotate__rule('zabbix-agent').with({
        :path         => '/var/log/zabbix/zabbix_agentd.log',
        :missingok    => 'true',
        :rotate_every => 'monthly',
        :ifempty      => 'false',
        :compress     => 'true',
        :create       => 'true',
        :create_mode  => '0664',
        :create_owner => 'zabbix',
        :create_group => 'zabbix',
        :su           => 'false',
      })
    end

    it 'File[/etc/logrotate.d/zabbix-agent] should have valid contents' do
      verify_contents(catalogue, '/etc/logrotate.d/zabbix-agent', [
        '/var/log/zabbix/zabbix_agentd.log {',
        '  compress',
        '  create 0664 zabbix zabbix',
        '  missingok',
        '  monthly',
        '  notifempty',
        '}',
      ])
    end
  end

  it "should create datacat resource" do
    should contain_datacat('zabbix-agent-sudo').with({
      :ensure   => 'file',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0440',
      :path     => '/etc/sudoers.d/10_zabbix-agent',
      :template => 'zabbix/agent/sudo.erb',
    })
  end

  context 'when manage_sudo => false' do
    let(:params) {{ :manage_sudo => false }}
    it { should_not contain_datacat('zabbix-agent-sudo') }
  end

  context 'when sudo_ensure => "absent"' do
    let(:params) {{ :sudo_ensure => "absent" }}
    it { should contain_datacat('zabbix-agent-sudo').with_ensure('absent') }
  end

  context "when operatingsystemmajrelease == 7" do
    let(:facts) { default_facts.merge({:operatingsystemmajrelease => '7'}) }

    it 'File[/etc/logrotate.d/zabbix-agent] should have valid contents' do
      verify_contents(catalogue, '/etc/logrotate.d/zabbix-agent', [
        '/var/log/zabbix/zabbix_agentd.log {',
        '  compress',
        '  create 0664 zabbix zabbix',
        '  missingok',
        '  monthly',
        '  notifempty',
        '  su zabbix zabbix',
        '}',
      ])
    end

    it { should_not contain_logrotate__rule('zabbix-agent') }

    context 'when use_logrotate_rule => true' do
      let(:params) {{ :use_logrotate_rule => true }}

      it 'should manage logrotate::rule[zabbix-agent]' do
        should contain_logrotate__rule('zabbix-agent').with({
          :path         => '/var/log/zabbix/zabbix_agentd.log',
          :missingok    => 'true',
          :rotate_every => 'monthly',
          :ifempty      => 'false',
          :compress     => 'true',
          :create       => 'true',
          :create_mode  => '0664',
          :create_owner => 'zabbix',
          :create_group => 'zabbix',
          :su           => 'true',
          :su_owner     => 'zabbix',
          :su_group     => 'zabbix',
        })
      end

      it 'File[/etc/logrotate.d/zabbix-agent] should have valid contents' do
        verify_contents(catalogue, '/etc/logrotate.d/zabbix-agent', [
          '/var/log/zabbix/zabbix_agentd.log {',
          '  compress',
          '  create 0664 zabbix zabbix',
          '  missingok',
          '  monthly',
          '  notifempty',
          '  su zabbix zabbix',
          '}',
        ])
      end
    end
  end
end
