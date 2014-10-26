shared_context 'zabbix::agent::install' do
  it { should create_class('zabbix::agent::install') }
  it { should contain_class('zabbix::agent') }
  it { should contain_class('epel') }

  it do
    should contain_package('zabbix::agent').only_with({
      :ensure   => 'present',
      :name     => 'zabbix22-agent',
      :require  => 'Yumrepo[epel]',
    })
  end
end
