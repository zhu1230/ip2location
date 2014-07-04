require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ip2location" do
  it "work correctly with ipv4" do
    i2l = Ip2location.new.open(File.dirname(__FILE__) + "/assets/IP-COUNTRY-SAMPLE.bin")
    record = i2l.get_all('13.5.10.6')
    record.should_not be_nil
    record.country_short.should == 'US'
  end

  # this need spec/assets/IP2LOCATION-LITE-DB5.bin file which too big to include in this test.

  # it "should get float value of attitude" do
  #   i2l = Ip2location.new.open(File.dirname(__FILE__) + "/assets/IP2LOCATION-LITE-DB5.bin")
  #   record = i2l.get_all('192.110.164.88')
  #   record['latitude'].should eq(33.44837951660156)
  # end
end
