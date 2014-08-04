require 'spec_helper'

describe 'zabbix::web' do
  include_context :defaults
  let(:facts) { default_facts }

  it { should create_class('zabbix::web') }
  it { should contain_class('zabbix::params') }

  it "should install zabbix-web" do
    should contain_package('zabbix-web').only_with({
      :ensure   => 'present',
      :name     => 'zabbix22-web-mysql',
      :require  => 'Yumrepo[epel]',
      :before   => 'File[/etc/zabbix/web]',
    })
  end

  it "should create /etc/zabbix/web" do
    should contain_file('/etc/zabbix/web').only_with({
      :ensure => 'directory',
      :path   => '/etc/zabbix/web',
      :owner  => 'apache',
      :group  => 'apache',
      :mode   => '0750',
      :before => 'File[zabbix.conf.php]',
    })
  end

  it "should create zabbix.conf.php" do
    should contain_file('zabbix.conf.php').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix/web/zabbix.conf.php',
      :owner    => 'apache',
      :group    => 'apache',
      :mode     => '0640',
      :content  => /.*/,
    })
  end

  it "should create valid contents for zabbix.conf.php" do
    verify_contents(catalogue, 'zabbix.conf.php', [
      '<?php',
      'global $DB;',
      '$DB[\'TYPE\']     = \'MYSQL\';',
      '$DB[\'SERVER\']   = \'localhost\';',
      '$DB[\'PORT\']     = \'3306\';',
      '$DB[\'DATABASE\'] = \'zabbix\';',
      '$DB[\'USER\']     = \'zabbix\';',
      '$DB[\'PASSWORD\'] = \'changeme\';',
      '$DB[\'SCHEMA\'] = \'\';',
      '$ZBX_SERVER      = \'127.0.0.1\';',
      '$ZBX_SERVER_PORT = \'10051\';',
      '$ZBX_SERVER_NAME = \'Zabbix Server\';',
      '$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;',
      '?>',
    ])
  end

  it { should_not contain_class('mysql::server') }
  it { should have_mysql__db_resource_count(0) }
  it { should_not contain_mysql__db('zabbix') }

  context "when manage_database => true" do
    let(:params) {{ :manage_database => true }}

    it { should contain_class('mysql::server') }

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
      })
    end
  end

  context 'when using remote zabbix and database' do
    let(:params) do
      {
        :export_database => true,
        :db_host => 'db.example.com',
        :zabbix_server => 'zabbix.example.com',
      }
    end

    it { should_not contain_class('mysql::server') }

    it { should have_mysql__db_resource_count(0) }

    it "should export mysql::db" do
      skip("Can not test exported resources")
      should contain_mysql__db('zabbix_foo.example.com').with({
        :ensure       => 'present',
        :user         => 'zabbix',
        :password     => 'changeme',
        :dbname       => 'zabbix',
        :host         => 'foo.example.com',
        :charset      => 'utf8',
        :collate      => 'utf8_bin',
        :grant        => ['ALL'],
        :tag          => 'example.com',
      })
    end

    it "should create valid contents for zabbix.conf.php" do
      verify_contents(catalogue, 'zabbix.conf.php', [
        '<?php',
        'global $DB;',
        '$DB[\'TYPE\']     = \'MYSQL\';',
        '$DB[\'SERVER\']   = \'db.example.com\';',
        '$DB[\'PORT\']     = \'3306\';',
        '$DB[\'DATABASE\'] = \'zabbix\';',
        '$DB[\'USER\']     = \'zabbix\';',
        '$DB[\'PASSWORD\'] = \'changeme\';',
        '$DB[\'SCHEMA\'] = \'\';',
        '$ZBX_SERVER      = \'zabbix.example.com\';',
        '$ZBX_SERVER_PORT = \'10051\';',
        '$ZBX_SERVER_NAME = \'Zabbix Server\';',
        '$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;',
        '?>',
      ])
    end
  end

end
