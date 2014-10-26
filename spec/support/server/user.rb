shared_context 'zabbix::server::user' do
  it { should create_class('zabbix::server::user') }
  it { should contain_class('zabbix::server') }

  it 'manage User[zabbixsrv]' do
    should contain_user('zabbixsrv').with({
      :ensure    => 'present',
      :comment   => 'Zabbix Monitoring System -- Proxy or server',
      :gid       => 'zabbixsrv',
      :home      => '/var/lib/zabbixsrv',
      :shell     => '/sbin/nologin',
      :uid       => nil,
      :system    => 'true',
    })
  end

  it 'manage Group[zabbixsrv]' do
    should contain_group('zabbixsrv').with({
      :ensure  => 'present',
      :gid     => nil,
      :system  => 'true',
    })
  end
end
