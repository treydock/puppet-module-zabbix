require 'spec_helper'

describe 'zabbix::server' do
  let :facts do
    {
      :fqdn                       => 'foo.example.com',
      :domain                     => 'example.com',
      :osfamily                   => 'RedHat',
      :root_home                  => '/root',
      :operatingsystemmajrelease  => '6',
    }
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

  it "defines Class[zabbix::database::mysql]" do
    should contain_class('zabbix::database::mysql').only_with({
      :name             => 'Zabbix::Database::Mysql',
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
      :package_ensure       => 'present',
      :manage_database      => 'false',
      :export_database      => 'false',
      :export_database_tag  => 'example.com',
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

  context "when manage_web => false" do
    let(:params) {{ :manage_web => false }}
    it { should_not contain_class('zabbix::web') }
  end

  include_context 'zabbix::server::user'
  include_context 'zabbix::server::install'
  include_context 'zabbix::server::config'
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
      it { expect { should create_class('zabbix::server') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end

end
