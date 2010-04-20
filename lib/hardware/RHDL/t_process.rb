
if(RUBY_VERSION.split(".")[0..1].join(".") == "1.9") 
  require 'continuation'
end


class T_Process


  def initialize( &callable )
    @callable = callable
  end

  def call
    callcc do
      | ret_from_call |
      @return_from_call = ret_from_call
      if @retry_wait
        @retry_wait.call
      else
        @callable.call( self )
      end
      @return_from_call.call
    end
    @return_from_call = nil
  end

  def wait( cond )
    until cond.call
      callcc do
        | retry_w |
        @retry_wait = retry_w
        @return_from_call.call
      end
      @retry_wait  = nil
    end
  end


end

if __FILE__ == $0
require 'test/unit'

class T_Process_test < Test::Unit::TestCase

  def test01_no_wait
    out = []
    process = T_Process.new {
      out << 1
    }
    assert_equal( [], out, 'before call' )
    process.call
    assert_equal( [ 1 ], out, 'after call' )
  end

  def test02_single_wait
    out = []
    process = T_Process.new do
      | pr |
      out << 1
      pr.wait { true }
      out << 2
    end
    assert_equal( [], out, 'before call' )
    process.call
    assert_equal( [ 1, 2 ], out, 'after call' )
  end

  def test03_multiple_waits
    out = []
    continue_flag = false
    process = T_Process.new do
      | pr |
      out << 1
      pr.wait do
        out << 2
        continue_flag
      end
      out << 3
    end
    assert_equal( [], out, 'before call' )
    process.call
    assert_equal( [ 1, 2 ], out, 'after 1. call' )
    process.call
    assert_equal( [ 1, 2, 2 ], out, 'after 2. call' )
    process.call
    assert_equal( [ 1, 2, 2, 2 ], out, 'after 3. call' )
    continue_flag = true
    process.call
    assert_equal( [ 1, 2, 2, 2, 2, 3 ], out, 'after 4. call' )
  end
  
  def test04_multiple_calls
    out = []
    continue_flag = false
    process = T_Process.new do
      | pr |
      out << 1
      pr.wait do
        out << 2
        continue_flag
      end
      out << 3
    end
    assert_equal( [], out, 'before call' )
    process.call
    assert_equal( [ 1, 2 ], out, 'after 1. call' )
    process.call
    assert_equal( [ 1, 2, 2 ], out, 'after 2. call' )
    continue_flag = true
    process.call
    assert_equal( [ 1, 2, 2, 2, 3 ], out, 'after 3. call' )
    continue_flag = false
    process.call
    assert_equal( [ 1, 2, 2, 2, 3, 1, 2 ], out, 'after 4. call' )
    continue_flag = true
    process.call
    assert_equal( [ 1, 2, 2, 2, 3, 1, 2, 2, 3 ], out, 'after 5. call' )
  end

end

end

