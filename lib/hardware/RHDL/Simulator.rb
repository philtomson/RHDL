module RHDL
  module Simulator

    def step(*cgens,&b )
      @_block_ ||= b 
      if @_block_ 
        if $simTime == 0
          print "step##{$simTime}: "
          @_block_.call 
        end
      end
      sM = RHDL::SimulationMgr.instance
      sM.step
      if @_block_ 
        print "step##{$simTime}: "
         @_block_.call 
      end
      if cgens
        cgens.each {|clkgen|
          clkgen.step if clkgen.respond_to? :step
        }
      end
    end
  end
end
