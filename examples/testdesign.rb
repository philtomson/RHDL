require 'RHDL'
class My_Design < RHDL::Design
  include RHDL #mixin RHDL methods
  def initialize(a,b,rst,o,o2,o3,clk,counter)
    #clk = ClkGen.generator('0',2,2)
    inputs  = { 'A'   => Port(a),
                'B'   => Port(b),
		            'RST' => Port(rst),
                'CLK' => Port(clk)
	            }
    outputs = { 'NOT_A'   => Port.new(o),
		            'A_OR_B'  => Port.new(o3),
		            'A_AND_B' => Port.new(o2),
		            'COUNTER' => Port.new(counter)
	            }
    super(inputs,outputs)
    clk_events = 0
    define_behavior { 
          o2.assign {a * b} 
          o3.assign {a + b} 
         	o.assign {a.inv }
          ##create a clock that changes every 2 cycles:
          #clk.assign_at(2){ clk.inv }
		      process(clk,rst) {
			      if rst == '1'
			        counter.assign 0
			      elsif clk == '1' && clk.event 
		          counter.assign{counter + 1}
			        clk_events += 1
			      end
			      puts "clk_events = #{clk_events}"
	    	  }

		      process(counter){
		        puts "counter = #{counter}"
		      }
    }
  end
end


bit_values = ['0','1','Z','X']
require 'test/unit' 

  class TestingMyDesign < Test::Unit::TestCase 
    include RHDL
    include TestBench
    include Simulator

    def set_up
      @iN_SIGNALS  = ['A','B','RST','CLK']
      @oUT_SIGNALS = ['NOT_A','A_OR_B','A_AND_B','COUNTER']
    end

    def test_MyDesign
      a = Signal(Bit('1'))
      b = Signal(Bit('0'))
      rst = Signal(Bit('0'))

      clk = Signal(Bit('0'))
      o = Signal(Bit())
      o2= Signal(Bit())
      o3= Signal(Bit())
      c = 0
      counter = Signal(c)
      md = My_Design.new(a,b,rst,o,o2,o3,clk,counter)
      i = 0
      each_vector_from_file("count_test_data",@iN_SIGNALS,@oUT_SIGNALS) { |inHsh,outHsh|
	      a.assign(inHsh['A'])
	      b.assign(inHsh['B'])
	      rst.assign(inHsh['RST'])
        clk.assign(inHsh['CLK'])
	      step
        puts "step #{i}:"
	        puts "a=#{a}, b=#{b}, rst=#{rst}, o=#{o}, o2=#{o2}, o3=#{o3}, clk=#{clk}, counter=#{counter}"
        @oUT_SIGNALS.each { |signal|
          #puts "a=#{a}, b=#{b}, rst=#{rst}, o=#{o}, o2=#{o2}, o3=#{o3}, clk=#{clk}, counter=#{counter}"
	        assert_equal(outHsh[signal].to_s,md.outPorts[signal].to_s,"#{signal} does not match #{outHsh[signal]}")
        }
        i+=1
      }	
    end
  end
