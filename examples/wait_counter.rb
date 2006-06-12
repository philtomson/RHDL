#######################################################
# wait_counter.rb - tests the wait style counter
#######################################################
require 'RHDL'
class WaitCounter < RHDL::Design
  include RHDL
  def initialize(clk,rst)#,counter)
    counter = Signal(0)
    #outputs = { :counter => Port(counter) }
    super()
    define_behavior {
      process() {
        puts "  ->Start process"
        wait { clk.event && clk == '1' }
        puts "    got a clock"
        counter.assign { counter + 1}
        puts "  <- End process: counter is: #{counter}"
      }
    }
  end
end

include RHDL
include Simulator
clk = ClkGen.generator('0',1,1)
rst = Signal(Bit('0'))
counter = WaitCounter.new(clk,rst)

10.times {
  step { puts "clk=#{clk}, rst=#{rst}"}
}

