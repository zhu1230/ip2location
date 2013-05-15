class I2lFloatData  < BinData::BasePrimitive
  
  def read_and_return_value(io)
    addr = BinData::Uint32le.read(io)
  end
  
end