module Stunted
  module ShapeableClassMethods
    def shaped_class(*shapes)
      klass = Class.new(self)
      shapes.each do | mod | 
        klass.send(:include, mod)
      end
      klass
    end
  end

  module Shapeable
    def become(*shapes)
      return self if shapes.empty?
      self.class.shaped_class(*shapes).new(self)
    end
  end
end
