module Stunted

  module Defn

    def defn(name, fn = nil, &block)
      if fn
        define_method(name) { fn }
      else
        define_method(name) { lambda(&block) }  # to get return operator right.
      end
      module_function name if respond_to?(:module_function, true) 
    end
    module_function :defn
    public :defn
  end

  module Chainable

    def pass_to(fn = nil, &block)
      if fn
        fn.(self)
      else
        lambda(&block).(self)
      end
    end

    def defsend(fn = nil, &block)
      if fn
        instance_exec(&fn)
      else
        instance_exec(&block)
      end
    end
  end

end
