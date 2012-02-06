require 'helper'

class FunctionalHashTest < Test::Unit::TestCase
  include Stunted
  include Stunted::FHUtil
  

  context "mocking out functions" do
    class Foo < FunctionalHash
      extend Stunted::Defn

      def my_method
        "value of unmocked method"
      end

      defn :my_lambda, -> { "value of unmocked lambda" }
    end

    should "be able to temporarily replace a module's instance methods" do 
      Foo.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { Foo.new.my_method == "replaced value" }
      end
      assert { Foo.new.my_method == "value of unmocked method"  }
    end

    should "undo the replacement no matter what" do
      assert_raises(Exception) do
        Foo.with_replacement_methods(my_method: -> { "replaced value" }) do
          raise Exception.new("boom")
        end
      end
      assert { Foo.new.my_method == "value of unmocked method"  }
    end

    should_eventually "be able to temporarily replace a module's `defn`ed lambdas" do 
      Foo.with_replacement_methods(my_lambda: -> { "replaced value" }) do
        assert { Foo.new.my_lambda.() == "replaced value" }
      end
      assert { Foo.new.my_lambda.() == "value of unmocked lambda"  }
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

    should "be able to apply the mock function to an object, not just a module." do
      foo = Foo.new
      foo.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { foo.my_method == "replaced value" }
      end
      assert { foo.my_method == "value of unmocked method"  }
    end
  end
end
