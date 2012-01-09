require 'helper'

class TestChaining  < Test::Unit::TestCase
  extend Stunted::Defn

  class ChainableValueHolder
    extend Stunted::Defn
    include Stunted::Chainable
    def initialize(value)
      @value = value
    end

    defn :some_function_that_refers_to_self, -> { @value }

    attr_reader :value
  end

  def setup 
    @contains_three = ChainableValueHolder.new(3)
  end

  context "pass_to passes self as an explicit argument" do 
    should "to blocks" do
      captured_addend = 33
      result = @contains_three.pass_to { | _ | _.value + captured_addend }
      assert { result == 36 }
    end

    should "to lambdas" do
      captured_addend = 33
      result = @contains_three.pass_to -> _ { _.value + captured_addend }
      assert { result == 36 }
    end

    should "even with newly-generated functions" do 
      self.class.defn :add_maker do | addend | 
        -> _ { _.value + addend } 
      end

      result = @contains_three.pass_to add_maker.(3)
      assert { result == 6 }
    end
  end

  context "defsend is like defining a temporary method and then sending to it" do 
    should "allow method defined with block" do
      captured_addend = 33
      assert { 36 == @contains_three.defsend { self.value + captured_addend } }
    end

    should "allow method defined with lambda" do
      captured_addend = 33
      result = @contains_three.defsend(-> {@value + captured_addend })
      assert { result == 36 }
    end

    should "allow method to be defined elsewhere" do 
      captured_addend = 33
      result = @contains_three.defsend(@contains_three.some_function_that_refers_to_self)
      assert { result == 3 }
    end
  end

end
