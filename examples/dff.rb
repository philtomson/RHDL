begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end


include RHDL

DFF = RHDL::model {
  inputs clk, rst, d
  outputs q
  define_behavior {
    process(clk) {
      behavior {
        if clk.rising_edge
          if rst == 1
            q <= 0
          else
            q <= d
          end
        end
      }
    }
  }
}

if $0 == __FILE__
  #test it:
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
    end

    def test_dff
      puts "clk=#{@clk}, rst=#{@rst}, d=#{@d}, q=#{@q}" 
      assert_equal("X00X","#@clk#@rst#@d#@q")
      step { puts "clk=#{@clk}, rst=#{@rst}, d=#{@d}, q=#{@q} " }
      assert_equal("000X","#@clk#@rst#@d#@q")
      @d   <= '1'
      step
      assert_equal("1011","#@clk#@rst#@d#@q")
      step
      assert_equal("0011","#@clk#@rst#@d#@q")
      puts "Now activate RESET:"
      @rst <= '1'
      step
      assert_equal("1110","#@clk#@rst#@d#@q")
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
    end
  end  
end
