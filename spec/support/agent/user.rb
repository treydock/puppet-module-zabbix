shared_context 'zabbix::agent::user' do
  let(:facts) { default_facts }

  it { should create_class('zabbix::agent::user') }
  it { should contain_class('zabbix::agent') }

  it 'manage User[zabbix]' do
    should contain_user('zabbix').with({
      :ensure     => 'present',
      :comment    => 'Zabbix Monitoring System',
      :gid        => 'zabbix',
      :home       => '/var/lib/zabbix',
      :shell      => '/sbin/nologin',
      :uid        => nil,
      :system     => 'true',
      :forcelocal => 'true',
    })
  end

  it 'manage Group[zabbix]' do
    should contain_group('zabbix').with({
      :ensure     => 'present',
      :gid        => nil,
      :system     => 'true',
      :forcelocal => 'true',
    })
  end
end
