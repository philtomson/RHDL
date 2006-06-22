#deprecated: this is old style RHDL
#
require 'RHDL'

class WashMachine < RHDL::Design
  include RHDL
  def initialize(clk,rst)
    puts "state_machine::initialize"
    state_type = EnumType(:start,:wash,:rinse,:spin,:stop)
    state_sig = Signal(state_type)
    super()
    define_behavior {
       process(clk,rst) {
         #async reset:
         if rst == '1'
           puts "RESET"
           state_sig << :start 
         elsif clk.event && clk == '1'
           case state_sig.inspect
           when :start
             state_sig << :wash
           when :wash
             state_sig << :rinse
           when :rinse
             state_sig << :spin
           when :spin
             state_sig << :stop
           when :stop
             #stay here till reset
           else
             puts "What's this?"
             raise "invalid state! #{state_sig.value}"
           end
         end
       }
       process(state_sig) {
         #prints message whenever state_sig changes:
         puts "Current state is: #{state_sig}"
       }
    }
  end
end

if $0 == __FILE__
  include RHDL
  include Simulator

  clk = ClkGen.generator('0',2,2)
  rst = Signal(Bit.new('1'))
  fsm = WashMachine.new(clk,rst)

  step { puts "clk=#{clk}, rst=#{rst}" }
  step
  step
  rst << '0'
  18.times do |i|
    step
  end
  rst << '1'
  4.times do |i|
    step
    rst << '0'
  end

end
