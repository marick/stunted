module Stunted

  class FunctionalHash < Hash

    def initialize(hash = {})
      hash.each do | k, v |
        self[k] = v
        if k.is_a?(Symbol)
          if self.respond_to?(k)
            $stderr.puts("Warning: #{k.inspect} overrides existing Hash method.")
          end
          instance_eval("def #{k}; self[#{k.inspect}]; end")
        end
      end
    end

    def fetch(key, *args, &block)
      current = super(key, *args, &block)
      if current.is_a?(Proc)
        if current.arity == 0
          self[key] = current.()
        else
          self[key] = current.(self)
        end
      else
        current
      end
    end

    def merge(hash)
      self.class.new(super(hash))
    end
    alias_method :+, :merge

    def transform(symbol)
      merge(symbol => yield(self[symbol]))
    end

    def change_within(*args)
      if (args.first.is_a? Hash)
        merge(args.first)
      else
        key = args.first
        rest = args[1..-1]
        merge(key => fetch(key).change_within(*rest))
      end
    end

    def remove(*keys)
      new_hash = dup
      keys.each { | key | new_hash.send(:delete, key) }
      self.class.new(new_hash)
    end

    def remove_within(*args)
      key = args.first
      rest = args[1..-1]
      if (args.count <= 1)
        remove(key)
      else
        merge(key => fetch(key).remove_within(*rest))
      end
    end

    def -(keys)
      keys = [keys] unless keys.respond_to?(:first)
      remove(*keys)
    end

    def [](key)
      fetch(key, nil)
    end

    def only(*keys)
      self.class[*keys.zip(self.values_at(*keys)).flatten(1)]
    end

    def self.shaped_class(*shapes)
      klass = Class.new(self)
      shapes.each do | mod | 
        klass.send(:include, mod)
      end
      klass
    end

    def self.make_maker(*shapes)
      klass = shaped_class(*shapes)
      ->(inits={}) { klass.new(inits) }
    end

    def become(*shapes)
      self.class.shaped_class(*shapes).new(self)
    end

    def component(hash)   # For now, just one pair
      field = hash.keys.first
      shape = hash.values.first
      secondary_module = Module.new
      shape.instance_methods.each do | meth |
        defn = "def #{meth}(*args)
                  merge(#{field.inspect} => self.#{field}.#{meth}(*args))
                end"
        secondary_module.module_eval(defn)
      end
      merge(field => self[field].become(shape)).become(secondary_module)
    end

    private :[]=, :clear, :delete, :delete_if
  end


  module FHUtil
    def F(hash = {})
      FunctionalHash.new(hash)
    end

    def Fonly(tuples)
      F(tuples.first)
    end

    def Fall(tuples)
      tuples.map { | row | F(row) }
    end
  end
end
