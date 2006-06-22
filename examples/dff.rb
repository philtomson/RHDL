#deprecated: this is old style RHDL
require 'RHDL'
class DFF < RHDL::Design
  include RHDL
  def initialize(clk,rst,d,q)
    super()
    define_behavior {
      process(clk) {
        if clk == '1' and clk.event
          if rst == '1'
            q << 0
          else
            q << d
          end
        end
      }
    }
  end
end

if $0 == __FILE__
  include RHDL
  include Simulator
  clk = Signal(Bit('0'))
  rst = Signal(Bit('0'))
  d   = Signal(Bit('0'))
  q   = Signal(Bit())
  dff = DFF.new(clk,rst,d,q)

  puts "clk=#{clk}, rst=#{rst}, d=#{d}, q=#{q}" 
  step { puts "clk=#{clk}, rst=#{rst}, d=#{d}, q=#{q}" }
  d   << '1'
  clk << '1'
  step
  clk << '0'
  step
  puts "Now activate RESET:"
  rst << '1'
  step
  clk << '1'
  step
  rst << '0'
  clk << '0'
  puts "Now de-activate RESET:"
  step
  clk << '1'
  step
  clk << '0'
  d   << '0'
  step
  clk << '1'
  step
  

  
end
