begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end

include RHDL
Latch = model {
  inputs  g,rst,d
  outputs q
  init {
    reset_val = 0
    define_behavior {
      process(g,rst,d){
	behavior {
	  if rst == '1'
	    q <= reset_val
	  elsif g == '1'
	    q <= d
	  end
	}
      }
    }
  }
}

if $0 == __FILE__
  require 'test/unit'
  require 'Simulator'
  class TestLatch < Test::Unit::TestCase
    include RHDL
    include Simulator
    def setup
      @gate = Signal(Bit(0))
      @reset= Signal(Bit(0))
      @data = Signal(Bit(0))
      @q    = Signal(Bit())
      @latch= Latch.new(:g => @gate,:rst => @reset,:d => @data,:q =>@q)
    end

    def test_latch
      assert_equal("000X", "#@gate#@reset#@data#@q")
      step {puts "gate=#{@gate},reset=#{@reset},data=#{@data},q=#{@q}"}
      @data <= '1'
      step
      assert_equal("001X", "#@gate#@reset#@data#@q")
      @gate <= '1'
      step
      assert_equal("1011", "#@gate#@reset#@data#@q")
      @data <= '0'
      step
      assert_equal("1000", "#@gate#@reset#@data#@q")
      @data <= '1'
      step
      assert_equal("1011", "#@gate#@reset#@data#@q")
      @gate <= '0'
      step
      assert_equal("0011", "#@gate#@reset#@data#@q")
      step
      assert_equal("0011", "#@gate#@reset#@data#@q")
      @reset <= '1'
      step
      assert_equal("0110", "#@gate#@reset#@data#@q")
      @reset <= '0'
      step
      assert_equal("0010", "#@gate#@reset#@data#@q")
    end
  end
end
