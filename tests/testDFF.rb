require '../examples/dff.rb'
require 'test/unit'

class TestDFF < Test::Unit::TestCase
  include RHDL
  include Simulator

  def set_up
    @clk = Signal(Bit('0'))
    @rst = Signal(Bit('0'))
    @d   = Signal(Bit('0'))
    @q   = Signal(Bit())
    @dff = DFF.new(@clk,@rst,@d,@q)
  end

  def test_dff
    step { puts "clk=#{@clk}, rst=#{@rst}, d=#{@d}, q=#{@q}" }
    assert_equal(@clk,'0',"clk should be '0'")
    assert_equal(@rst,'0',"rst should be '0'")
    assert_equal(@q,'X',"q should be 'X'")
    @d   << '1'
    @clk << '1'
    step
    assert_equal(@q,'1',"q should be '1'")
    @clk << '0'
    step
    assert_equal(@q,'1',"q should be '1'")
    @rst << '1'
    step
    assert_equal(@q,'1',"q should be '1'")
    @clk << '1'
    step
    assert_equal(@q,'0',"q should be '0'")
    @rst << '0'
    @clk << '0'
    step
    assert_equal(@q,'0',"q should be '0'")
    @clk << '1'
    step
    assert_equal(@q,'1',"q should be '1'")
    @clk << '0'
    @d   << '0'
    step
    assert_equal(@q,'1',"q should be '1'")
    @clk << '1'
    step
    assert_equal(@q,'0',"q should be '0'")

  end
end
    
    
