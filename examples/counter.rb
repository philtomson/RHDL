begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end

require 'RHDL'
include RHDL
Counter = model {
  MODULO = 8
  inputs  clk, reset
  outputs count
  generics mod=>MODULO
  init {
    #c = 0
    define_behavior {
      puts "in behavior... clk: #{clk} clk.event is: #{clk.event}" if $DEBUG
      process(clk) {
        c = 0 #c is now local to the process
        puts "in process initialization... c is: #{c}" if $DEBUG
        behavior {
          #puts "what is the value of: #{fizzle}" #good, we caught this
          if clk.rising_edge
            puts "rising edge of clk" if $DEBUG
            if reset == '1' || c== (mod-1)
              c = 0
            else
              c = c+1
            end
            count <= c
          end
        }
      }
    }
  }
}

#Simulate design
if $0 == __FILE__
  require 'Simulator'
  require 'test/unit'
  MODULO = 4 	
  class TestCounter < Test::Unit::TestCase
    include Simulator
    def setup
      @clk = Signal(Bit.new('0'))
      @rst = Signal(Bit.new('1'))
      @cout= Signal(0)
      @counter = Counter.new(:clk=>@clk,:reset => @rst,:count => @cout,:mod => MODULO)
    end
     
    def test_counter
      assert_equal("010","#@clk#@rst#@cout")
      step { puts "clk=#@clk, rst=#@rst, cout=#@cout"}
      assert_equal("010","#@clk#@rst#@cout")
      @clk <= '0';     @rst <= '0'
      step 
      assert_equal("000","#@clk#@rst#@cout")
      @clk <= '1';
      step 
      assert_equal("101","#@clk#@rst#@cout")
      count = 1
      step 
      18.times do
        @clk <= '0';
        step 
        assert_equal("00#{count}","#@clk#@rst#@cout")
	count += 1
	count = 0 if count == MODULO
        @clk <= '1';
        step
        assert_equal("10#{count}","#@clk#@rst#@cout")
      end
    end
  end

end

