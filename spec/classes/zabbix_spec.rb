require 'spec_helper'

describe 'zabbix' do
  let :facts do
    {
      :fqdn                       => 'foo.example.com',
      :domain                     => 'example.com',
      :osfamily                   => 'RedHat',
      :root_home                  => '/root',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix') }
  it { should contain_class('zabbix::params') }

end
