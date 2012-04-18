module Stunted
  class HashArray < Array

    def collapse_and_aggregate(*keys)
      keys.reduce(first) do | accumulator, key |
        collection = collect(&key)
        collection = yield(collection) if block_given?
        accumulator.merge(key => collection)
      end
    end

    def segregate_by_key(key)
      group_by(&key).values.collect do | inner | 
        self.class.new(inner)
      end
    end
  end
end
