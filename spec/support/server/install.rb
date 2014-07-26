shared_context 'zabbix::server::install' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :root_home                  => '/root',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix::server::install') }
  it { should contain_class('zabbix::server') }
  it { should contain_class('epel') }

  it do
    should contain_package('zabbix-server').only_with({
      :ensure   => 'present',
      :name     => 'zabbix22-server-mysql',
      :require  => 'Yumrepo[epel]',
    })
  end
end
