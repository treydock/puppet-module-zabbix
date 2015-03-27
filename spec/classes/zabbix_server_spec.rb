require 'spec_helper'

describe 'zabbix::server' do
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

      it { should create_class('zabbix::server') }
      it { should contain_class('zabbix::params') }

      it { should contain_anchor('zabbix::server::start').that_comes_before('Class[zabbix]') }
      it { should contain_class('zabbix').that_comes_before('Class[zabbix::server::user]') }
      it { should contain_class('zabbix::server::user').that_comes_before('Class[zabbix::server::install]') }
      it { should contain_class('zabbix::server::install').that_comes_before('Class[zabbix::database::mysql]') }
      it { should contain_class('zabbix::database::mysql').that_comes_before('Class[zabbix::server::config]') }
      it { should contain_class('zabbix::server::config').that_notifies('Class[zabbix::server::service]') }
      it { should contain_class('zabbix::server::service').that_comes_before('Anchor[zabbix::server::end]') }
      it { should contain_anchor('zabbix::server::end') }

      it { should contain_class('zabbix::database::mysql').that_comes_before('Class[zabbix::web]') }
      it { should contain_class('zabbix::web').that_comes_before('Class[zabbix::server::config]') }

      it "defines Class[zabbix::database::mysql]" do
        should contain_class('zabbix::database::mysql').only_with({
          :name             => 'Zabbix::Database::Mysql',
          :version          => '2.2',
          :package_ensure   => 'present',
          :package_name     => 'zabbix22-dbfiles-mysql',
          :zabbix_server    => 'localhost',
          :db_name          => 'zabbix',
          :db_user          => 'zabbix',
          :db_password      => 'changeme',
          :schema_sql_path  => '/usr/share/zabbix-mysql/schema.sql',
          :images_sql_path  => '/usr/share/zabbix-mysql/images.sql',
          :data_sql_path    => '/usr/share/zabbix-mysql/data.sql',
          :before           => ['Class[Zabbix::Server::Config]','Class[Zabbix::Web]'],
        })
      end

      it "defines Class[zabbix::web]" do
        should contain_class('zabbix::web').only_with({
          :name                 => 'Zabbix::Web',
          :version              => '2.2',
          :package_ensure       => 'present',
          :db_type              => 'mysql',
          :package_name         => 'zabbix22-web-mysql',
          :db_host              => 'localhost',
          :db_port              => '3306',
          :db_name              => 'zabbix',
          :db_user              => 'zabbix',
          :db_password          => 'changeme',
          :zabbix_server        => '127.0.0.1',
          :zabbix_server_port   => '10051',
          :zabbix_server_name   => 'Zabbix Server',
          :image_format_default => 'IMAGE_FORMAT_PNG',
          :config_dir           => '/etc/zabbix/web',
          :config_file          => '/etc/zabbix/web/zabbix.conf.php',
          :apache_user_name     => 'apache',
          :apache_group_name    => 'apache',
          :before               => 'Class[Zabbix::Server::Config]',
        })
      end

      context "when manage_database => false" do
        let(:params) {{ :manage_database => false }}
        it { should_not contain_class('zabbix::database::mysql') }
        it { should contain_class('zabbix::server::install').that_comes_before('Class[zabbix::web]') }
        it { should contain_class('zabbix::web').that_comes_before('Class[zabbix::server::config]') }
      end

      context "when manage_web => false" do
        let(:params) {{ :manage_web => false }}
        it { should_not contain_class('zabbix::web') }
      end

      include_context 'zabbix::server::user'
      include_context 'zabbix::server::install'
      include_context 'zabbix::server::config', facts
      include_context 'zabbix::server::service'

      it 'manages Firewall for zabbix-server' do
        should contain_firewall('100 allow zabbix-server').with({
          :ensure  => 'present',
          :port    => '10051',
          :proto   => 'tcp',
          :action  => 'accept',
        })
      end

      # Test validate_bool parameters
      [
        :manage_user,
        :manage_database,
        :manage_web,
        :manage_logrotate,
        :use_logrotate_rule,
        :start_snmp_trapper,
        :manage_firewall,
      ].each do |p|
        context "when #{p} => 'foo'" do
          let(:params) {{ p => 'foo' }}
          it 'should raise an error' do
            expect { should compile }.to raise_error(/is not a boolean/)
          end
        end
      end

      # Test validate_hash parameters
      [
        :logrotate_defaults,
      ].each do |p|
        context "when #{p} => 'foo'" do
          let(:params) {{ p => 'foo' }}
          it 'should raise an error' do
            expect { should compile }.to raise_error(/is not a Hash/)
          end
        end
      end

      context 'unsupported version' do
        let(:params) {{ :version => '1.8' }}
        it 'should raise an error' do
          expect { should compile }.to raise_error(/does not match/)
        end
      end

      context 'unsupported db_type' do
        let(:params) {{ :db_type => 'foo' }}
        it 'should raise an error' do
          expect { should compile }.to raise_error(/does not match/)
        end
      end

    end
  end
end
