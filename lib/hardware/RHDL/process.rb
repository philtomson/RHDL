class ProcessHasNoBehavior < SyntaxError
end

module RHDL
  class Process
    def initialize delegate=nil,&block
      @delegate = delegate
      @behavior_defined = false
      instance_eval &block
      unless @behavior_defined
        raise ProcessHasNoBehavior, "No behavior defined for this process!!!"
      end
    end

    def behavior &block
      @block = block
      @behavior_defined = true
    end

    def call
      @block.call if @block
    end

    attr_accessor :block

    def method_missing meth_id, *args
      if @delegate
        @delegate.send(meth_id, *args)
      else
        raise RuntimeError, "no method: #{meth_id}", caller
      end
    end

  end

end

if $0 == __FILE__

require 'test/unit'

class TestProcess < Test::Unit::TestCase
  def test_missing_behavior
    assert_raise(ProcessHasNoBehavior) {
      p1 = RHDL::Process.new {
        x = "foo"
      }
    }
  end

  def test_missing_var
    #this should fail, and it does, but the RuntimeError isn't caught
    #for some reason:
    assert_raise(RuntimeError,
    p=RHDL::Process.new {
      behavior {
        "x is: #{x}"
      }
    }.call )
    #assert_raise(RuntimeError, p.call)

  end

  def test_correct_process
    p = nil #so we can get to the process later

    assert_nothing_raised() { 
       p=RHDL::Process.new { 
         x = "foo"
         behavior {
           "x is: #{x}"
         }
      }
    }
    assert_equal("x is: foo", p.call)

  end
end


end
