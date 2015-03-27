require 'spec_helper'

describe 'zabbix::database::mysql' do
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
          :sql          => [
            '/usr/share/zabbix-mysql/schema.sql',
            '/usr/share/zabbix-mysql/images.sql',
            '/usr/share/zabbix-mysql/data.sql',
          ],
        })
      end

      context 'when version is 2.0' do
        let(:params) {{ :version => '2.0' }}

        it 'should not contain dbfiles package' do
          should_not contain_package('zabbix-dbfiles-mysql')
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
