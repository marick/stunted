require 'helper'

class FunctionalHashTest < Test::Unit::TestCase
  include Stunted
  include Stunted::FHUtil

  context "mocking out methods via a class" do
    class ClassWithMethods < FunctionalHash
      def my_method; "value of unmocked method"; end
    end

    should "be able to temporarily replace a module's instance methods" do 
      ClassWithMethods.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { ClassWithMethods.new.my_method == "replaced value" }
      end
      assert { ClassWithMethods.new.my_method == "value of unmocked method"  }
    end

    should "undo the replacement no matter what" do
      assert_raises(Exception) do
        ClassWithMethods.with_replacement_methods(my_method: -> { "replaced value" }) do
          raise Exception.new("boom")
        end
      end
      assert { ClassWithMethods.new.my_method == "value of unmocked method"  }
    end

    should "keep the modified instance methods for all versions of the object" do 
      ClassWithMethods.with_replacement_methods(my_method: -> a { merge(value: self.value * a) }) do 
        first_foo = ClassWithMethods.new(value: 1)
        second_foo = first_foo.my_method(5)
        third_foo = second_foo.my_method(10)

        assert { second_foo.value == 5 }
        assert { third_foo.value == 50 }
      end
    end

    should "The overriding of the method ends at the end of the block" do
      initial_foo = Object.new
      ClassWithMethods.with_replacement_methods(my_method: -> a { merge(value: self.value * a)}) do
        initial_foo = ClassWithMethods.new
      end
      assert { initial_foo.my_method == "value of unmocked method"  }
    end

  end

  context "mocking particular objects" do 
    should "be able to apply the mock function to an object, not just a module." do
      foo = ClassWithMethods.new
      foo.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { foo.my_method == "replaced value" }
      end
      assert { foo.my_method == "value of unmocked method"  }
    end
  end

  context "mocking out lambdas attached to a class" do 
    class ClassWithLambdas < FunctionalHash
      extend Stunted::Defn
      defn :my_lambda, -> { "value of unmocked lambda" }
    end

    should_eventually "be able to temporarily replace a module's `defn`ed lambdas" do 
      ClassWithLambdas.with_replacement_methods(my_lambda: -> { "replaced value" }) do
        assert { ClassWithLambdas.new.my_lambda.() == "replaced value" }
      end
      assert { ClassWithLambdas.new.my_lambda.() == "value of unmocked lambda"  }
    end

  end
end
