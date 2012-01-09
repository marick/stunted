require 'helper'

class DefnTest < Test::Unit::TestCase

  module FunctionProvider
    extend Stunted::Defn
    
    defn :add_from_lambda, -> a, b { a + b}
    defn :higher_order_add_2, add_from_lambda.curry.(2)
    
    defn :add_from_proc do | a, b | 
      a + b
    end

    defn(:add_from_proc_alternate_syntax) { | a, b | a + b }

    addend = 3
    defn :add_with_captured_var, -> a { a + addend }
  end

  include FunctionProvider

  should "allow all functions to be called" do
    assert { add_from_lambda.(1, 2) == 3 } 
    assert { higher_order_add_2.(3) == 5 }
    assert { add_from_proc.(3, 4) == 7 }
    assert { add_from_proc_alternate_syntax.(4, 5) == 9 }
    assert { add_with_captured_var.(2) == 5 }
  end
end



