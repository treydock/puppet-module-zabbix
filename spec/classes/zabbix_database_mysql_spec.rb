require 'spec_helper'

describe 'zabbix::database::mysql' do
  let :facts do
    {
      :osfamily   => 'RedHat',
      :root_home  => '/root',
    }
  end

  it { should create_class('zabbix::database::mysql') }
  it { should contain_class('zabbix::params') }
  it { should contain_class('mysql::server') }

  it "should install zabbix-dbfiles-mysql" do
    should contain_package('zabbix-dbfiles-mysql').only_with({
      :ensure   => 'present',
      :name     => 'zabbix22-dbfiles-mysql',
      :require  => 'Yumrepo[epel]',
      :before   => 'Mysql::Db[zabbix]',
    })
  end

  it "should create mysql::db" do
    should contain_mysql__db('zabbix').with({
      :ensure       => 'present',
      :user         => 'zabbix',
      :password     => 'changeme',
      :dbname       => 'zabbix',
      :host         => 'localhost',
      :charset      => 'utf8',
      :collate      => 'utf8_bin',
      :grant        => ['ALL'],
      :notify       => 'Exec[zabbix-schema-import]',
    })
  end

  it "should import schema.sql" do
    should contain_exec('zabbix-schema-import').with({
      :command      => '/usr/bin/mysql zabbix < /usr/share/zabbix-mysql/schema.sql',
      :logoutput    => 'true',
      :environment  => 'HOME=/root',
      :refreshonly  => 'true',
      :notify       => 'Exec[zabbix-images-import]',
    })
  end

  it "should import images.sql" do
    should contain_exec('zabbix-images-import').with({
      :command      => '/usr/bin/mysql zabbix < /usr/share/zabbix-mysql/images.sql',
      :logoutput    => 'true',
      :environment  => 'HOME=/root',
      :refreshonly  => 'true',
      :notify       => 'Exec[zabbix-data-import]',
    })
  end

  it "should import data.sql" do
    should contain_exec('zabbix-data-import').with({
      :command      => '/usr/bin/mysql zabbix < /usr/share/zabbix-mysql/data.sql',
      :logoutput    => 'true',
      :environment  => 'HOME=/root',
      :refreshonly  => 'true',
    })
  end

end
