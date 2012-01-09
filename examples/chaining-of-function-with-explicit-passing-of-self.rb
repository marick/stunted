require '../lib/stunted'

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
     pass_to(-> _ { _.value + 1000 }).     # I'm using _ to represent "self"
     succ     # 1002
     
# The need for parentheses above is annoying, but can be avoided with blocks.
puts ValueHolder.new(0).
     bumped.
     pass_to { | _ | _.value + 500 }.
     succ     # 502


# Here's an example of using higher-order functions

make_adder =
  lambda do | addend |
    -> _ { _.value + addend }
  end

puts ValueHolder.new(0).
     bumped.
     pass_to(make_adder.(33)).
     succ     # 35


# You can pass in extra arguments

INCREMENT_VALUE = 200

puts ValueHolder.new(0).
     pass_to(-> _, addend { _.class.new(_.value + addend) }, INCREMENT_VALUE).
     pass_to(INCREMENT_VALUE) { | _, addend | _.class.new(_.value + addend) }.
     value   # 400
