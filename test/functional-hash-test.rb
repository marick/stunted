require 'helper'

class FunctionalHashTest < Test::Unit::TestCase
  include Stunted
  include Stunted::FHUtil
  

  context "non-lazy behavior" do
    setup do 
      @sut = FunctionalHash.new(:a => 1, 2 => "two")
    end

    should "lookup like regular hash" do
      assert { @sut[:a] == 1 }
      assert { @sut[2] == "two" }
    end

    should "also allow method-like lookup" do 
      assert { @sut.a == 1 }
    end

    should "be == to other hashes" do
      assert { @sut == {:a => 1, 2 => "two"}}
    end
  end

  context "lazy behavior" do
    should "take procs as arguments and evaluate them on demand" do
      @sut = FunctionalHash.new(:a => lambda { @global })
      @global = 33
      assert { @sut.a == 33 }
      # And the value now remains
      @global = 99999999
      assert { @sut.a == 33 }
    end

    should "give an argument to the lambda if wants access to `self`." do
      @sut = FunctionalHash.new(:a => lambda { |h| h.b + 1 }, :b => 2)
      assert { @sut.a == 3 }
    end
  end

  context "immutable behavior" do
    should "prevent assignment, etc" do
      # todo - more of these to come
      @sut = FunctionalHash.new(:a => 3)
      assert_raises(NoMethodError) { @sut[:a] = 5 }
      assert_raises(NoMethodError) { @sut.clear } 
      assert_raises(NoMethodError) { @sut.delete } 
      assert_raises(NoMethodError) { @sut.delete_if } 
    end

    should "create new object upon addition" do 
      sut = FunctionalHash.new(:a => 1)
      added = sut + {:b => 3}
      assert { added.is_a?(FunctionalHash) }
      assert { added == {:a => 1, :b => 3} }
      assert { added != sut }
      assert { added.object_id != sut.object_id }
    end

    should "you can also use merge" do 
      sut = FunctionalHash.new(:a => 1)
      added = sut.merge(:b => 3)
      assert { added.is_a?(FunctionalHash) }
      assert { added == {:a => 1, :b => 3} }
      assert { added != sut }
      assert { added.object_id != sut.object_id }
    end

    should "create new object upon removal" do 
      sut = FunctionalHash.new(:a => 1, :b => lambda {2}, :c => 3)
      only_c = sut.remove(:a, :b)
      assert { only_c.is_a?(FunctionalHash) }
      assert { only_c == {:c => 3} }
      assert { only_c != sut }
      assert { only_c.object_id != sut.object_id }
    end

    should "can also use `-` with both one argument and an array" do 
      sut = FunctionalHash.new(:a => 1, :b => lambda {2}, :c => 3)
      empty = sut - :a - [:b, :c]
      assert { empty.is_a?(FunctionalHash) }
      assert { empty == {} }
      assert { empty != sut }
      assert { empty.object_id != sut.object_id }
    end

    context "changing within" do
      setup do 
        @hashlike = F(:val => 3,
                      :other => "other",
                      :nested => F(:val => 33,
                                   :other => "other",
                                   :nested => F(:val => 333,
                                                :other => "other")))
      end

      should "act as + at zero level" do
        actual = @hashlike.change_within(val: 4)
        assert { actual.is_a?(FunctionalHash) }
        assert { actual.val == 4 } 
        assert { actual.other == "other" }
      end

      should "allow nesting" do
        actual = @hashlike.change_within(:nested, val => 44)
        assert { actual.is_a?(FunctionalHash) }
        assert { actual.val == 3 }
        assert { actual.nested.val == 44 }
        assert { actual.nested.other == "other" }
      end

      should "allow n levels of nesting" do
        actual = @hashlike.change_within(:nested, :nested, val => 444)
        assert { actual.is_a?(FunctionalHash) }
        assert { actual.val == 3 }
        assert { actual.nested.val == 33 }
        assert { actual.nested.nested.val == 444 } 
        assert { actual.nested.nested.other == "other" }
      end

    end

    context "changing within" do
      setup do 
        @hashlike = F(:val => 3,
                      :other => "other",
                      :nested => F(:val => 33,
                                   :other => "other",
                                   :nested => F(:val => 333,
                                                :other => "other")))
      end

      should "act as - at zero level" do
        actual = @hashlike.remove_within(:val)
        assert { actual.is_a?(FunctionalHash) }
        assert { !actual.has_key?(:val) } 
        assert { actual.other == "other" }
      end

      should "allow nesting" do
        actual = @hashlike.remove_within(:nested, :val)
        assert { actual.is_a?(FunctionalHash) }
        assert { actual.val == 3 }
        assert { ! actual.nested.has_key?(:val) }
        assert { actual.nested.other == "other" }
      end

      should "allow n levels of nesting" do
        actual = @hashlike.remove_within(:nested, :nested, :val)
        assert { actual.is_a?(FunctionalHash) }
        assert { actual.val == 3 }
        assert { actual.nested.val == 33 }
        assert { ! actual.nested.nested.has_key?(:val) }
        assert { actual.nested.nested.other == "other" }
      end

    end

    context "making smaller hashes" do
      should "be done with the `only` method" do
        hashlike = F(:a => 1, :b => 2, :c => 3)
        actual = hashlike.only(:a, :c)
        assert { actual.is_a?(FunctionalHash) }
        assert { actual == {:a => 1, :c => 3} }
      end
    end
  end
end
