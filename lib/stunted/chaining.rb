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

    def pass_to(*args, &block)
      if block_given? 
        lambda(&block).(self, *args)
      else
        fn = args.shift
        fn.(self, *args)
      end
    end

    def defsend(*args, &block)
      if block_given? 
        instance_exec(*args, &block)
      else
        fn = args.shift
        instance_exec(*args, &fn)
      end
    end
  end

end
