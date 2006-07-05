#deprecated: this is old style RHDL
#
begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end

require 'ClkGen'

include RHDL

State_type = EnumType.new(:start,:wash,:rinse,:spin,:stop)

WashMachine = model { 
  inputs clk,rst
  outputs out_state
  init {
    puts "state_machine init"
    #state_type = EnumType.new(:start,:wash,:rinse,:spin,:stop)
    state_sig = Signal(State_type)
    define_behavior {
      process(clk,rst) {
        behavior {
          #async reset:
          if rst == '1'
            puts "RESET"
            state_sig <= :start 
          elsif clk.event && clk == '1'
            case state_sig.inspect
            when :start
              state_sig <= :wash
            when :wash
              state_sig <= :rinse
            when :rinse
              state_sig <= :spin
            when :spin
              state_sig <= :stop
            when :stop
              #stay here till reset
            else
              puts "What's this?"
              raise "invalid state! #{state_sig.value}"
            end
          end
        }
      }
      process(state_sig) {
	behavior {
         #prints message whenever state_sig changes:
         puts "Current state is: #{state_sig}"
	 out_state <= state_sig
        }
      }
    }
  }
}

if $0 == __FILE__
  require 'Simulator'
 
  include RHDL
  include Simulator

  clk = Signal(Bit.new(0))
  rst = Signal(Bit.new(1))
  state = Signal(State_type)
  fsm = WashMachine.new(:clk => clk,:rst => rst, :out_state => state )

  step { puts "clk=#{clk}, rst=#{rst} state=#{state}"; clk <= clk.inv }
  step
  step
  rst <= '0'
  18.times do |i|
    step
  end
  rst <= '1'
  4.times do |i|
    step
    rst <= '0'
  end

end
