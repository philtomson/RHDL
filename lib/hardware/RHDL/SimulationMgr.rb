require 'singleton'
require 'RHDL'
module RHDL
  class SimulationMgr
    #make this a Singleton class
    include Singleton

    def initialize
      @designs = []
    end

    def register_design(design)
      @designs << design
    end

    def update_designs
      @designs.each {|design|
	      #is order important here?
	      design.update
      }
    end

    def step #step through simulation time
      @designs.each { |design|
        design.do_once_per_step
      }
      i = 0
      while Signal.deltaEvents?
        i+=1
        #until there aren't anymore events generated in the delta time
        Signal.clear_deltaEvents
        @designs.each { |design|
	        design.update
        }
        Signal.update_all
        if i > MAX_EVENTS_IN_DELTA
          puts "Oscillation detected!"
          exit
        end
      end
      puts "@behavior.call ==> #{i} times" if $DEBUG
      #Signal.clear_events
      #report_current_state
      $simTime += 1 #increment the simulation time
      Signal.set_deltaEvents #so we get through the first time
      #return @inPorts, @outPorts
    end 

  end 
end
