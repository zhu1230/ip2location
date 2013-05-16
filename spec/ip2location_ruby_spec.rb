require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ip2location" do
  it "work correctly with ipv4" do
    i2l = Ip2location.new.open(File.dirname(__FILE__) + "/assets/IP-COUNTRY-SAMPLE.bin")
    record = i2l.get_all('13.5.10.6')
    record.should_not be_nil
    record.country_short.should == 'US'
  end
end
