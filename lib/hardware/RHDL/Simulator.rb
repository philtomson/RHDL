module RHDL
  module Simulator

    def do_block
      print "step##{$simTime}: "
      @_block_.call if @_block_
    end

    def step(&b )
      @_block_ = b || @_block_
      do_block if $simTime == 0
      RHDL::SimulationMgr.instance.step
      do_block
    end

  end
end
