require 'spec_helper'

describe 'zabbix_agent_version fact' do
  before :each do
    Facter::Util::Resolution.stubs(:which).with("zabbix_agentd").returns("/usr/sbin/zabbix_agentd")
    Facter.clear
  end

  it "should return 2.2.5" do
    expected = "2.2.5"
    Facter::Util::Resolution.stubs(:exec).with("zabbix_agentd -V").returns(my_fixture_read("zabbix_agentd-#{expected}"))
    Facter.fact(:zabbix_agent_version).value.should == expected
  end

  it "should return 2.2.1" do
    expected = "2.2.1"
    Facter::Util::Resolution.stubs(:exec).with("zabbix_agentd -V").returns(my_fixture_read("zabbix_agentd-#{expected}"))
    Facter.fact(:zabbix_agent_version).value.should == expected
  end

  it "should return 2.0.3" do
    expected = "2.0.3"
    Facter::Util::Resolution.stubs(:exec).with("zabbix_agentd -V").returns(my_fixture_read("zabbix_agentd-#{expected}"))
    Facter.fact(:zabbix_agent_version).value.should == expected
  end

  it "should be nil if zabbix_agentd -V returns unexpected output" do
    Facter::Util::Resolution.stubs(:exec).with("zabbix_agentd -V").returns("foo")
    Facter.fact(:zabbix_agent_version).value.should == nil
  end

  it "should be nil if zabbix_agentd not found" do
    Facter::Util::Resolution.stubs(:which).with("zabbix_agentd").returns(nil)
    Facter.fact(:zabbix_agent_version).value.should == nil
  end
end
