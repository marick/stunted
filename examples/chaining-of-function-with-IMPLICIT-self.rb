$:.unshift("../lib")
require "stunted"

# A boring class that holds a value and can produce
# new objects with an incremented value
class ValueHolder
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def bumped
    self.class.new(value + 1)
  end
end

puts ValueHolder.new(0).bumped.bumped.value   # 2

# Let's let this object be sent functions as if they were messages.
class ValueHolder
  include Stunted::Chainable
end

puts ValueHolder.new(0).
     bumped.
     defsend(-> { self.class.new(@value + 1000) }).
     defsend(-> { self.class.new(value +   330) }).
     value     # 1331
     

# The need for parentheses above is annoying, but can be avoided with blocks.
puts ValueHolder.new(0).
     bumped.
     defsend { self.class.new(@value + 1000) }.
     defsend { self.class.new(value +   330) }.
     value     # 1331
     

# Here's an example of using higher-order functions

make_adder =
  lambda do | addend |
    -> { self.class.new(@value + addend) }
  end

puts ValueHolder.new(0).
     bumped.
     defsend(make_adder.(33)).
     value     # 34

# You can pass in extra arguments

INCREMENT_VALUE = 200

puts ValueHolder.new(0).
     defsend(-> addend { self.class.new(@value + addend) }, INCREMENT_VALUE).
     defsend(INCREMENT_VALUE) { | addend | self.class.new(value + addend) }.
     value   # 400
