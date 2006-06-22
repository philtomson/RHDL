#deprecated: this is old style RHDL
#
$: << '../lib'
require 'RHDL'

class My_Clk < RHDL::Design
  include RHDL #mixin RHDL methods
  def initialize(clk)
    inputs  = { 'CLK' => Port(clk)}
    super(inputs,nil)

    clk_events = 0 #an integer variable
    define_behavior { 
		      process(){
            #till = $simTime + 3
            puts "-->Start of First Process #{$simTime}"
            #puts "  clk = #{clk}"
            clk << '0'#(clk.inv)
            wait_for 6 #{$simTime == till}
            #puts "Now we get here"
            clk << '1'#(clk.inv)
            #puts "  after: clk = #{clk}"
            wait_for 3 #{$simTime == till}
            clk << 'X'
            puts "wait till #{$simTime + 2}"
            wait_for 2
            #puts "  end:clk = #{clk}"
            puts "<--End of First Process"
		      }
          process() { puts "simTime is: #{$simTime}"}
            
    }
  end
end


if $0 == __FILE__
  #require 'test/unit'
  include RHDL
  include TestBench

  clk = Signal(Bit('0'))
  cg = My_Clk.new(clk)


  27.times{|i|
    step
    puts "step #{i} clk = #{clk}"
  }
end
