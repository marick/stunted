module Stunted

  module Defn

    # Note: if you use a block with defn, you get block semantics. In particular,
    # don't try to return from such a block.
    def defn(name, fn = nil, &block)
      if fn
        define_method(name) { fn }
      else
        puts "Lambda rigamarole could be just { block }"
        define_method(name) { lambda(&block) }  # Todo: why is this lambda rigamarole required?
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
