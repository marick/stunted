require '../lib/stunted'

# `defn` can be used to declare functions within modules. They are
# available with `include` or `extend`.


module FunctionProvider
  extend Stunted::Defn

  defn :add, -> a, b { a + b }

  captured = 3
  defn :add_captured, -> a { a + captured }
end

# Here's a local definition of a function:
add_local = -> a, b { a + b }
puts add_local.(1, 2)   # 3

include FunctionProvider

puts add.(1, 2) # 3

puts add_captured.(1)   # 4

some_local = 88
FunctionProvider.defn :captured_value, -> { some_local }

puts captured_value.()  # 88
some_local = 99
puts captured_value.()  # 99

