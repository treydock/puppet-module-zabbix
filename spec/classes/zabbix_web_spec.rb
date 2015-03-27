require 'spec_helper'

describe 'zabbix::web' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :root_home => '/root',
        })
      end

      it { should compile.with_all_deps }
    end
  end

  on_supported_os({
    :hardwaremodels => ['x86_64'],
    :supported_os   => [
      {
        "operatingsystem" => "CentOS",
        "operatingsystemrelease" => [
          "6",
          "7"
        ]
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :root_home => '/root',
        })
      end

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

      context 'when using remote zabbix and database' do
        let(:params) do
          {
            :db_host => 'db.example.com',
            :zabbix_server => 'zabbix.example.com',
          }
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

      context 'when version is 2.0' do
        let(:params) {{ :version => '2.0' }}

        it 'should install zabbix20-web-mysql' do
          should contain_package('zabbix-web').with_name('zabbix20-web-mysql')
        end
      end

      context 'unsupported version' do
        let(:params) {{ :version => '1.8' }}
        it 'should raise an error' do
          expect { should compile }.to raise_error(/does not match/)
        end
      end
    end
  end
end
