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
    puts "==== What is the behavior with procs good for?"
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

    should "allow transformations of particular key values" do
      sut = FunctionalHash.new(value: 5)
      new_sut = sut.transform(:value) { | value | value * 3 }
      assert { new_sut.value == 15 }

      sut = FunctionalHash.new("string-key" => 1)
      new_sut = sut.transform("string-key") { | value | value * 3 }
      assert { new_sut["string-key"] == 3 }
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

    context "shapes" do
      context "becoming a particular shape" do

        module OddShaped
          def oddly
            self.merge(:odd => "once")
          end
        end

        module EvenShaped
          def evenly
            self.merge(:even => "once")
          end
        end

        should "allow module methods to be called" do 
          hashlike = FunctionalHash.new.become(OddShaped, EvenShaped)
          assert { hashlike.oddly.odd == "once" }
        end

        should "cause a copy of the extended object to contain the same functions" do 
          hashlike = FunctionalHash.new.become(OddShaped, EvenShaped)
          assert { hashlike.oddly.evenly == {:odd => "once", :even => "once" } }
        end

        should "accumulate the functions from multiple `become` calls." do
          hashlike = FunctionalHash.new.become(OddShaped).become(EvenShaped)
          assert { hashlike.oddly.evenly == {:odd => "once", :even => "once" } }
        end
      end
    end

    context "containing a particular shape" do

      module Timesliced
        def shift_timeslice(days)
          merge(:first_date => first_date + days,
                :last_date => last_date + days)
        end
      end

      class ::Fixnum
        def days
          self
        end

        def week
          self * 7
        end
      end

      should "allow spaces of subcomponents to be described" do
        original =
          F(name: "fred", 
            timeslice: F(first_date: Date.new(2001, 1, 1),
                         last_date: Date.new(2001, 2, 2))).
          component(:timeslice => Timesliced)

        shifted =
          original.
          shift_timeslice(1.week).
          shift_timeslice(2.days)

        assert { shifted.timeslice.first_date == original.timeslice.first_date + 9 }
        assert { shifted.timeslice.last_date == original.timeslice.last_date + 9 }
      end
    end

    context "maker functions" do
      module Round
        def round; "round!"; end
      end

      module Cylindrical
        def cylindrical; "cylinder"; end
      end

      reservation_maker = FunctionalHash.make_maker(Round, Cylindrical)
      reservation = reservation_maker.(a: 1, b: 2)

      should "make regular immutable hash" do
        assert { reservation.a == 1 }
      end

      should "include shape functions" do 
        assert { reservation.round == "round!" }
        assert { reservation.cylindrical == "cylinder" }
      end

      should "include shape functions in hashes created from this hash" do 
        assert { reservation.merge(c: 3).round == "round!" }
      end
        
    end


    context "mocking out functions" do
      class Foo < FunctionalHash
        def my_method
          "value of unmocked method"
        end
      end

      should "be able to temporarily replace a module's instance methods" do 
        Foo.with_replacement_methods(my_method: -> { "replaced value" }) do
          assert { Foo.new.my_method == "replaced value" }
        end
        assert { Foo.new.my_method == "value of unmocked method"  }
      end

      should "keep the modified instance methods for all versions of the object" do 
        Foo.with_replacement_methods(my_method: -> a { merge(value: self.value * a) }) do 
          first_foo = Foo.new(value: 1)
          second_foo = first_foo.my_method(5)
          third_foo = second_foo.my_method(10)

          assert { second_foo.value == 5 }
          assert { third_foo.value == 50 }
        end
      end

      should "The overriding of the method ends at the end of the block" do
        initial_foo = Object.new
        Foo.with_replacement_methods(my_method: -> a { merge(value: self.value * a)}) do
          initial_foo = Foo.new
        end
        assert { initial_foo.my_method == "value of unmocked method"  }
      end
    end
  end
end


