# encoding: utf-8
require 'bindata'
require 'ipaddr'
require 'ip2location_ruby/ip2location_config'
require 'ip2location_ruby/database_config'
require 'ip2location_ruby/i2l_float_data'
require 'ip2location_ruby/i2l_string_data'
require 'ip2location_ruby/i2l_ip_data'
require 'ip2location_ruby/ip2location_record'

class Ip2location
  attr_accessor :record_class, :v4, :file, :db_index, :count, :base_addr, :ipno, :count, :record, :database, :columns, :ip_version, :ipv4databasecount, :ipv4databaseaddr, :ipv6databasecount, :ipv6databaseaddr
  
  def open(url)
    self.file = File.open(File.expand_path url, 'rb')
    i2l = Ip2locationConfig.read(file)
    self.db_index = i2l.databasetype
    self.columns = i2l.databasecolumn + 0
    self.database = DbConfig.setup_database(self.db_index)
    self.ipv4databasecount = i2l.ipv4databasecount
    self.ipv4databaseaddr = i2l.ipv4databaseaddr
    self.ipv6databasecount = i2l.ipv6databasecount
    self.ipv6databaseaddr = i2l.ipv6databaseaddr
    self
  end
  
  def get_all(ip)
    ipno = IPAddr.new(ip, Socket::AF_UNSPEC)
    self.ip_version = ipno.ipv4? ? 4 : 6
    self.v4 = ipno.ipv4?
    self.count = ipno.ipv4? ? self.ipv4databasecount + 0 : self.ipv6databasecount + 0
    self.base_addr = (ipno.ipv4? ? self.ipv4databaseaddr - 1 : self.ipv6databaseaddr - 1)
    self.record_class = (Ip2LocationRecord.init database, self.ip_version)
    
    ipnum = ipno.to_i + 0
    col_length = columns * 4

    return self.record = bsearch(0, self.count, ipnum, self.base_addr, col_length)
  end
  
  def get_from_to(mid, base_addr, col_length)
    from_base = ( base_addr + mid * (col_length + (v4 ? 0 : 12)))
    file.seek(from_base)
    ip_from =  v4 ? BinData::Uint32le.read(file) : BinData::Uint128le.read(file)
    file.seek(from_base + col_length + (v4 ? 0 : 12))
    ip_to = v4 ? BinData::Uint32le.read(file) : BinData::Uint128le.read(file)
    [ip_from, ip_to]
  end
  
  def bsearch(low, high, ipnum, base_addr, col_length) 
    mid = (high + low)/2
    return nil if low == mid
    ip_from, ip_to = get_from_to(mid, base_addr, col_length)
    if ipnum < ip_from
      low = low
      high = mid
      return bsearch(low, high, ipnum, base_addr, col_length)
    elsif ipnum >= ip_to
      low = mid
      high = high
      return bsearch(low, high, ipnum, base_addr, col_length) 
    else
      from_base = ( base_addr + mid * (col_length + (self.v4 ? 0 : 12)))
      file.seek(from_base)  
      return self.record_class.read(file)
    end
  end
    
end





