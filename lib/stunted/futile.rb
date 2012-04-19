module Stunted
  module FUtil
    def F(hash = {})
      FunctionalHash.new(hash)
    end

    def Fonly(tuples)
      F(tuples.first)
    end

    def Fall(tuples)
      HashArray.new(tuples.map { | row | F(row) })
    end
  end

  FUtils = FUtil unless defined?(FUtils)
  FUtile = FUtil unless defined?(FUtile) # Ha ha!
  FHUtil = FUtil unless defined?(FHUtil) # Backward compatibility
end
