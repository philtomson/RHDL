###########################################################################
# TestTb.rb - test TestBench and hierarchy and structural style
###########################################################################
begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end


################################################
# not gate
################################################
class My_Not < RHDL::Design
  include RHDL
  def initialize(a,not_a)
    inputs  = { 'A'     => Port(a) }
    outputs = { 'NOT_A' => Port(not_a) } 
    super(inputs,outputs)
    define_behavior {
      not_a.<< { a.inv  }
    }
  end
end

################################################
# Or gate
################################################
class My_Or < RHDL::Design
  include RHDL
  def initialize(a,b,a_and_b)
    inputs  = { 'A' => Port(a),
    	          'B' => Port(b)
    	        }
    outputs = {
      	       'A_AND_B' => Port(a_and_b)
      	      }
    super(inputs,outputs)
    define_behavior {
      a_and_b.<< { a | b }
    }
  end
end

##############################################################################
# My_And is an 'and' gate made in a structural style with an OR gate and three
# NOT gates (to test hierarchy and structural design in RHDL)
##############################################################################
class My_And < RHDL::Design
  include RHDL
  def initialize(a,b,a_and_b)
    inputs  = { 'A' => Port(a),
    	          'B' => Port(b)
    	        }
    outputs = {
      	        'A_AND_B' => Port(a_and_b)
      	      }
    super(inputs,outputs)
    a_not = Signal(Bit())
    b_not = Signal(Bit())
    a_not_OR_b_not = Signal(Bit())
    notGateA = My_Not.new(a,a_not)
    notGateB = My_Not.new(b,b_not)
    orGate = My_Or.new(a_not,b_not,a_not_OR_b_not)
    notGateOut = My_Not.new(a_not_OR_b_not,a_and_b)
  end
end


class My_Counter < RHDL::Design
  include RHDL #mixin RHDL methods
  def initialize(rst,clk,counter)
    inputs  = { 'RST' => Port(rst),
		            'CLK' => Port(clk)}
    outputs = { 
		            'COUNTER' => Port(counter)
	            }
    super(inputs,outputs)

    clk_events = 0 #an integer variable
    define_behavior { 
		      process(counter){
			      puts "-->Start of First Process"
			      wait { clk_events == 3 }
		        puts "counter = #{counter}"
			      puts "<--End of First Process"
		      }
		      process(clk) {
			      puts "--->Start of Second Process"
			      #synchronous reset
			      if clk == '1' && clk.event 
			        if rst == '1'
			          counter.assign 0
			        else
		            counter.assign (counter + 1)
			        end
			        clk_events += 1
			      end
			      puts "clk_events = #{clk_events}"
			      puts "<---End of Second Process"
	    	  }
    }
  end
end


if $0 == __FILE__
  require 'test/unit'
  require 'RHDL'
  require 'Simulator'
  require 'TestBench'

  class TestingMyDesign < Test::Unit::TestCase 
    include RHDL
    include Simulator
    include TestBench

    def setup
      @iN_SIGNALS  = ['A','B','CLK']
      @oUT_SIGNALS = ['COUNTER']
    end

    def test_MyDesign
      a = Signal(Bit('0'))
      b = Signal(Bit('0'))

      rst = Signal(Bit('0'))
      clk = Signal(Bit('0'))
      count = Signal(0)
      
      md = My_Counter.new(rst,clk,count)
      myAnd = My_And.new(a,b,rst)

      each_vector_from_file("testTB_data",@iN_SIGNALS,@oUT_SIGNALS) { |inHsh,outHsh|
	      a.assign(inHsh['A'])
	      b.assign(inHsh['B'])
	      clk.assign(inHsh['CLK'])
	      step
	      puts ">>>a: #{a}, b: #{b}, rst is: #{rst}, clk is: #{clk}, count is: #{count} "
        @oUT_SIGNALS.each { |signal|
	        assert_equal(outHsh[signal].to_s,count.to_s,"#{signal} does not match #{outHsh[signal]}") 
        }
      }	
      
    end

  end
end
