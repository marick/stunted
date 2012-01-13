

class FunctionalHash < Hash

  def initialize(hash = {})
    hash.each do | k, v |
      self[k] = v
      # Not important for this example
    end
  end

  def merge(hash)
    self.class.new(super(hash))
  end


  def become(mod)
    klass = Class.new(FunctionalHash)
    klass.send(:include, mod)
    klass.new(self)
  end

end


module TimesliceShaped
  def timeslice_fun; "timeslice_fun!"; end
end

puts FunctionalHash.new.become(TimesliceShaped).timeslice_fun


data_full = FunctionalHash.new(id: 33, name: "Dawn")
function_full = data_full.become(TimesliceShaped)


puts FunctionalHash.new.become(TimesliceShaped).merge(:a => 3)
puts FunctionalHash.new.become(TimesliceShaped).merge(:a => 3).timeslice_fun


