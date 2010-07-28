  require '../examples/dff.rb'
  require 'test/unit'
  require 'Simulator'
  require 'clkgen'
  class TestDff < Test::Unit::TestCase
    include RHDL
    include Simulator
    def setup
      @clk = ClkGen.generator
      @rst = Signal(Bit('0'))
      @d   = Signal(Bit('0'))
      @q   = Signal(Bit())
      @dff = DFF.new(:clk=>@clk,:rst=>@rst,:d=>@d,:q=>@q)
      puts "does @dff respond to __do_behavior? #{@dff.respond_to?(:__do_behavior)}"
      puts
    end

    def test_dff
      dummy = 0 #used to check that we can change the block passed to step
      puts "clk=#{@clk}, rst=#{@rst}, d=#{@d}, q=#{@q}" 
      assert_equal("X00X","#@clk#@rst#@d#@q")
      step { puts "clk=#{@clk}, rst=#{@rst}, d=#{@d}, q=#{@q} " }
      assert_equal( 0, dummy)
      assert_equal("000X","#@clk#@rst#@d#@q")
      @d   <= '1'
      step
      assert_equal("1011","#@clk#@rst#@d#@q")
      step
      assert_equal("0011","#@clk#@rst#@d#@q")
      puts "Now activate RESET:"
      @rst <= '1'
      step { puts "Clk=#{@clk}, Rst=#{@rst}, D=#{@d}, Q=#{@q} "; dummy = 1 }
      assert_equal("1110","#@clk#@rst#@d#@q")
      assert_equal( 1, dummy)
      step
      assert_equal("0110","#@clk#@rst#@d#@q")
      @rst <= '0'
      puts "Now de-activate RESET:"
      step
      assert_equal("1011","#@clk#@rst#@d#@q")
      step
      assert_equal("0011","#@clk#@rst#@d#@q")
      @d   <= '0'
      step
      assert_equal("1000","#@clk#@rst#@d#@q")
      step
      assert_equal("0000","#@clk#@rst#@d#@q")
      assert_equal(1, dummy)
    end
  end  


