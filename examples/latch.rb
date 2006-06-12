require 'RHDL'
class Latch < RHDL::Design
  include RHDL
  def initialize(g,rst,d,q)
    super()
    define_behavior {
      process(g,rst,d){
        if rst== '1'
          q << '0'
        elsif g == '1'
          q << d
        end
      }
    }
  end
end

if $0 == __FILE__
  include RHDL
  include Simulator
  gate = Signal(Bit(0))
  reset= Signal(Bit(0))
  data = Signal(Bit(0))
  q    = Signal(Bit())
  latch= Latch.new(gate,reset,data,q)

  step {puts "gate=#{gate},reset=#{reset},data=#{data},q=#{q}"}
  data << '1'
  step
  gate << '1'
  step
  data << '0'
  step
  data << '1'
  step
  gate << '0'
  step
  step
  reset << '1'
  step
  reset << '0'
  step
end
