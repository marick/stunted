require 'helper'

class FunctionalHashTest < Test::Unit::TestCase
  include Stunted
  include Stunted::Stutils

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
        first = ClassWithMethods.new(value: 1)
        second = first.my_method(5)
        third = second.my_method(10)

        assert { second.value == 5 }
        assert { third.value == 50 }
      end
    end

    should "The overriding of the method ends at the end of the block" do
      initial = "declared local"
      ClassWithMethods.with_replacement_methods(my_method: -> a { merge(value: self.value * a)}) do
        initial = ClassWithMethods.new
      end
      assert { initial.my_method == "value of unmocked method"  }
    end

  end

  module ModuleWithMethods
    def my_method; "value of unmocked method"; end
  end

  context "mocking out methods on a module" do
    class ClassWithIncludedMethods < FunctionalHash
      include ModuleWithMethods
    end

    should "be able to temporarily replace a module's instance methods" do 
      ModuleWithMethods.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { ClassWithIncludedMethods.new.my_method == "replaced value" }
      end
      assert { ClassWithIncludedMethods.new.my_method == "value of unmocked method"  }
    end
  end

  context 'mocking out methods for a "made" class' do
    maker = FunctionalHash.make_maker(ModuleWithMethods)

    should "be able to temporarily replace a made class's instance methods" do 
      maker.().class.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { maker.().my_method == "replaced value" }
      end
      assert { maker.().my_method == "value of unmocked method"  }
    end

    should "The overriding of the method ends at the end of the block" do
      initial = "declared local"
      ClassWithMethods.with_replacement_methods(my_method: -> a { merge(value: self.value * a)}) do
        initial = ClassWithMethods.new
      end
      assert { initial.my_method == "value of unmocked method"  }
    end
  end

  context "mocking particular objects" do 
    should "be able to apply the mock function to an object, not just a module." do
      object = ClassWithMethods.new
      object.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { object.my_method == "replaced value" }
      end
      assert { object.my_method == "value of unmocked method"  }
    end

    should_eventually "changing one object's methods doesn't affect another's" do
      mocked = ClassWithMethods.new
      unmocked = ClassWithMethods.new
      mocked.with_replacement_methods(my_method: -> { "replaced value" }) do
        assert { unmocked.my_method == "value of unmocked method" }
      end
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
