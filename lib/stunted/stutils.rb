module Stunted
  module Stutils
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

  Stutil = Stutils unless defined?(Stutil) # Backward compatibility
  FHUtil = Stutils unless defined?(FHUtil) # Backward compatibility
end
