require 'helper'

class StutilsTest < Test::Unit::TestCase
  include Stunted
  include Stunted::Stutils

  module Upable
    def up; "up!"; end
  end

  module Downable
    def down; "down!"; end
  end

  context "F" do
    should "create a functional hash" do
      # Only is a function that's not on the real Hash
      assert { F(:a => 1, :b => 2).only(:a).is_a? FunctionalHash }
    end

    should "allow shape to be specified" do
      h = F({}, Upable, Downable)
      assert { h.up == "up!" }
      assert { h.down == "down!" }
    end
  end

  context "Fonly" do 
    should "create a functional hash from within an array" do
      h = Fonly([{}], Upable, Downable)
      assert { h.is_a? FunctionalHash }
      assert { h.up == "up!" }
      assert { h.down == "down!" }
    end
  end

  context "Fall" do 
    should "create a HashArray wrapping Functional Hashes" do
      a = Fall([{}])
      assert { a.is_a?(HashArray) }
      assert { a.first.is_a?(FunctionalHash) }
    end

    should "shape the hash entries if given one or more arguments" do
      a = Fall([{}], Upable)
      assert {a.first.respond_to?(:up) }
      deny {a.first.respond_to?(:down) }

      a = Fall([{}], Upable, Downable)
      assert {a.first.respond_to?(:up) }
      assert {a.first.respond_to?(:down) }
    end

    should "allow the shape of the array to be given" do
      a = Fall([{}], :array => Upable)
      assert {a.up == "up!" }
      deny   {a.first.respond_to?(:up) }
    end

    should "allow more than one shape for the array" do 
      a = Fall([{}], :array => [Upable, Downable])
      assert {a.up == "up!" }
      assert {a.down == "down!" }
    end

    should "allow both array and hash to be shaped" do 
      a = Fall([{}], :array => Upable, :hash => Downable)
      assert {a.respond_to?(:up) }
      deny   {a.respond_to?(:down) }
      assert {a.first.respond_to?(:down) }
      deny   {a.first.respond_to?(:up) }
    end

    should "allow both array and hash to be shaped with multiple shapes" do 
      a = Fall([{}], :array => [Upable, Downable], :hash => [Upable, Downable])
      assert {a.respond_to?(:up) }
      assert {a.respond_to?(:down) }
      assert {a.first.respond_to?(:down) }
      assert {a.first.respond_to?(:up) }
    end
  end
end

