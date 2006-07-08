#########################################################
# ClkGen model
# generates clocks with specified start value and duty 
# cycle (specified by len1 and len2)
#########################################################
require 'RHDL'
include RHDL
ClkGen = model {
  inputs startval, len1, len2
  outputs clk
  init {
    case startval
    when String,Fixnum
      clk_i = Signal(Bit(startval))
    when Bit
      clk_i = Signal(startval)
    when Signal
      clk_i = startval
    end

    define_behavior {
      clk <= clk_i
      process(){
        behavior {
          wait_for len1
          clk_i <= clk_i.inv
          wait_for len2
          clk_i <= clk_i.inv
        } #end process behavior block
      } #end process block
    } #end define_behavior block
  } #end init block
} #end model block


def ClkGen.generator( arg_hsh = {} )
  startval = arg_hsh[:startval] || 0
  len1     = arg_hsh[:len1] || 1
  len2     = arg_hsh[:len2] || len1 
  puts "startval is: #{startval}, len1 is: #{len1}, len2 is: #{len2}"
  cg=ClkGen.new(:clk => Signal(Bit()), :startval => startval, 
		:len1 => len1,         :len2 => len2)
  return cg.clk
end


if $0 == __FILE__
  #usage example:
  require 'RHDL'
  require 'Simulator'
  include RHDL
  include Simulator

  ##############################################################
  # specify the default 50% duty cycle clock (1 cycle high, 
  # 1 cycle low) starting with 0:
  ##############################################################
  clk = ClkGen.generator(  )

  ##############################################################
  # specify a repeating clock (clk2) that starts out at 1 for 3 cycles
  # and then goes to 0 for 1 cycle:
  ##############################################################
  clk2 = ClkGen.generator( :startval => 1, :len1 => 3, :len2 => 1 )

  step { puts "clk is: #{clk}, clk2 is: #{clk2}" }
  20.times do
    step 
  end
end
