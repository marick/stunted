class Module
    def with_replacement_methods(hash)
      old_pairs = hash.collect do | key, value |
        old_method = instance_method(key)
        define_method(key, value)      
        [key, old_method]
      end
      yield
    ensure
      old_pairs.each { | pair | define_method(*pair) }
    end
end

module Stunted

  class FunctionalHash
    def with_replacement_methods(hash, &block)
      self.class.with_replacement_methods(hash, &block)
    end
  end
end
