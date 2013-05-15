# encoding: utf-8
require 'bundler'
Bundler.require
require 'awesome_print'
require 'bindata'
require 'ipaddr'
require 'libs/ip2location_config'
require 'libs/database_config'
require 'libs/i2l_float_data'
require 'libs/i2l_string_data'
require 'libs/i2l_ip_data'
require 'libs/ip2location_record'

class Ip2location
  attr_accessor :v4, :file, :db_index, :count, :base_addr, :ipno, :count, :record, :database, :columns, :ip_version
  
  def open(url)
    self.file = File.open(File.expand_path url, 'rb')
    i2l = Ip2locationConfig.read(file)
    self.db_index = i2l.databasetype
    self.count = i2l.databasecount + 0
    self.base_addr = i2l.databaseaddr - 1
    self.columns = i2l.databasecolumn + 0
    self.database = DbConfig.setup_database(self.db_index)
    self.ip_version = (i2l.ipversion == 0 ? 4 : 6)
    Ip2LocationRecord.init database, self.ip_version
    self
  end
  
  def get_all(ip)
    ipno = IPAddr.new(ip, Socket::AF_UNSPEC)
    self.v4 = ipno.ipv4? && self.ip_version == 4
    ipnum = ipno.to_i + 0
    mid =  self.count/2
    col_length = columns * 4
    low = 0
    high = count
    return self.record = bsearch(low, high, ipnum, self.base_addr, col_length)
  end
  
  def get_from_to(mid, base_addr, col_length)
    if v4
      from_base = ( base_addr + mid * col_length)
    else
      from_base = ( base_addr + mid * (col_length + 12))
    end
    
    file.seek(from_base)
    ip_from =  file.read(4).unpack('L')[0]
    file.seek(from_base + col_length)
    ip_to = file.read(4).unpack('L')[0]
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
      from_base = ( base_addr + mid * col_length)
      file.seek(from_base)  
      return Ip2LocationRecord.read(file)
    end
  end
    
end





