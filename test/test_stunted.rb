require 'helper'

class FunctionalDefsTest__DeclaringWithinModules < Test::Unit::TestCase

  module FunctionProvider
    extend FunctionalDefs
    
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

class FunctionalDefsTest__ChainingWithExplicitSelfArgument  < Test::Unit::TestCase

  class ChainableValueHolder
    include FunctionalDefs
    extend FunctionalDefs
    def initialize
      @value = 3
    end

    defn :self_using_function, -> { @value }

    attr_reader :value
  end

  def setup 
    @sut = ChainableValueHolder.new
  end

  should "be able to attach and call a block with explicit self argument" do
    captured_addend = 33
    result = @sut.pass_to { | _ | _.value + captured_addend }
    assert { result == 36 }
  end

  should "be able to attach and call a lambda with explicit self argument" do
    captured_addend = 33
    result = @sut.pass_to -> _ { _.value + captured_addend }
    assert { result == 36 }
  end

  should "be able to attach and call a block with IMPLICIT self argument" do
    captured_addend = 33
    assert { 36 == @sut.defsend { self.value + captured_addend } }
  end

  should "be able to attach and call a lambda with IMPLICIT self argument" do
    captured_addend = 33
    result = @sut.defsend(-> {@value + captured_addend })
    assert { result == 36 }
  end

  should "even work with self-referring function defined elsewhere" do
    captured_addend = 33
    result = @sut.defsend(@sut.self_using_function)
    assert { result == 3 }
  end

  extend FunctionalDefs
  
  defn :add_maker do | addend | 
    -> _ { _.value + addend } 
  end

  should "be able to generate new functions" do
    result = @sut.pass_to add_maker.(3)
  end    


  puts "============ variant for defsend?"
    
end


