require 'helper'

class HashArrayTest < Test::Unit::TestCase
  include Stunted
  include Stunted::Stutils
  
  context "collapsing a hash-array into one hash" do
    should "aggregate named key values into an array" do
      input = Fall([ {:id => 33, :name => "fred"},
                     {:id => 33, :name => "betsy"} ])
      
      actual = input.collapse_and_aggregate(:name)
      expected = {:id => 33, :name => ["fred", "betsy"]}
      assert { actual == expected }
    end

    should "aggregate allow multiple keys" do
      input = Fall([ {:id => 33, :name => "fred", :hair => 3},
                     {:id => 33, :name => "betsy", :hair => 44} ])
      
      actual = input.collapse_and_aggregate(:name, :hair)
      expected = {:id => 33, :name => ["fred", "betsy"], :hair => [3, 44]}
      assert { actual == expected }
    end

    should "silently do the wrong thing if non-constant keys are not named" do 
      input = Fall([ {:id => 33, :name => "fred", :hair => 3},
                     {:id => 33, :name => "betsy", :hair => 44} ])
      actual = input.collapse_and_aggregate(:name)
      deny { actual.hair == [3, 44] }
    end

    should "take a block that can be used to process the arrays" do 
      input = Fall([ {:id => 33, :name => "fred", :hair => 3},
                     {:id => 33, :name => "betsy", :hair => 44},
                     {:id => 33, :name => "fred", :hair => 44},
                     {:id => 33, :name => "betsy", :hair => 3}])
      actual = input.collapse_and_aggregate(:name, :hair) { | a | a.sort.uniq }
      expected = {:id => 33, :name => ["betsy", "fred"], :hair => [3, 44]}
      assert { actual == expected }
    end
  end

  context "segregation by keys" do 
    setup do 
      @input = Fall([ {:id => 1, :name => "fred"},
                      {:id => 2, :name => "betsy"},
                      {:id => 1, :name => "dawn"} ])

      @actual = @input.segregate_by_key(:id)
      @expected = [ [ {:id => 1, :name => "fred"},
                      {:id => 1, :name => "dawn"} ],
                    [ {:id => 2, :name => "betsy"} ] ]
    end

    should "produce an array of arrays" do 
      assert { @actual == @expected }
    end

    should "make the inner arrays HashArrays" do 
      assert { @actual.first.is_a?(Stunted::HashArray) } 
    end
  end

  context "shapeability" do 
    module ArrayShaped
      def neg_count; -count; end
    end

    should "also apply to hash arrays" do 
      assert { Fall([ {:a => 1}]).become(ArrayShaped).neg_count == -1 }
    end
  end
end
