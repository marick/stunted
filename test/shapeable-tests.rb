require 'helper'

class ShapeableTests < Test::Unit::TestCase
  include Stunted
  include Stunted::Stutils

  # Mostly tested through use in including classes

  module Shapely
  end
  
  should "normally return a new class" do
    # For some reason, putting this inside an `assert` makes test hang.
    klass = FunctionalHash.new.become(Shapely).class
    # The test library hangs if it tries to print a class created by
    # Class.new
    test = (klass == FunctionalHash);                deny { test }
    test = klass.ancestors.include?(FunctionalHash); assert { test } 
  end

  should "not return a new class if there is nothing to become" do
    # For some reason, putting this inside an `assert` makes test hang.
    klass = FunctionalHash.new.become().class
    test = (klass == FunctionalHash);                assert { test }
  end

end

