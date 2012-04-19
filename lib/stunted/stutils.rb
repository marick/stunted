module Stunted
  module Stutils
    def F(hash = {}, *shapes)
      FunctionalHash.new(hash).become(*shapes)
    end

    def Fonly(tuples, *shapes)
      F(tuples.first, *shapes)
    end

    def Fall(tuples, *args)
      first = args.first
      if first.is_a?(Hash)
        array_shapes = first[:array] || []
        hash_shapes = first[:hash] || []
      else
        hash_shapes = args
        array_shapes = []
      end
      HashArray.new(tuples.map { | row | F(row, *hash_shapes) }).
                become(*array_shapes)
    end
  end

  Stutil = Stutils unless defined?(Stutil) # Backward compatibility
  FHUtil = Stutils unless defined?(FHUtil) # Backward compatibility
end
