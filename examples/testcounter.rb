require 'RHDL'
class MyCounter < RHDL::Design
  include RHDL #mixin RHDL methods
  def initialize()
    inputs  = { 'RST' => Port.new(),
		            'CLK' => Port.new() }
    outputs = { 
		            'COUNTER' => Port.new()
	            }
    super(inputs,outputs)
    #define internal signals
    rst = Signal.new(Bit.new('0')); inputs['RST'].connect(rst)
    clk = Signal.new(Bit.new('0')); inputs['CLK'].connect(clk)
    c = 0
    counter  = Signal.new(BitVector.new('0000000000000000',16)); 
    outputs['COUNTER'].connect(counter)

    clk_events = 0
    define_behavior { 
	    process(counter){
	      puts "counter = #{counter} @ #$simTime"
	    }
	    process(clk) {
	    #synchronous reset
	      if clk == '1' && clk.event 
	        if rst == '1'
		        counter.assign '0000000000000000' 
		      else
		        puts "counter.assign(#{counter})"
		        counter.assign { counter + 1}
		      end
		      clk_events += 1
		    end
		    puts "clk_events = #{clk_events}"
	    }
    }
  end
end


bit_values = ['0','1','Z','X']
  require 'test/unit'

  class TestingMyCounter < Test::Unit::TestCase
    IN_SIGNALS  = ['RST','CLK']
    OUT_SIGNALS = ['COUNTER']
    def each_in_out(file)
      IO.foreach(file) { |line|
	      next if line =~ /^#/
        io = line.strip.split(":")
	      ins = io[0].split
	      outs= io[1].split
	      inHsh = {}
	      IN_SIGNALS.each_with_index { |sig,i|
          inHsh[sig] = ins[i]
        }
	      outHsh = {}
        OUT_SIGNALS.each_with_index { |sig,i|
	        outHsh[sig] = outs[i]
	      }
	      yield inHsh,outHsh
      }
    end

    def test_MyDesign
      md = MyCounter.new()
      each_in_out("simple_data") { |inHsh,outHsh|
	      inputs,outputs = md.step(inHsh)
        OUT_SIGNALS.each { |signal|
          #assert_fail("#{signal} does not match #{outHsh[signal]}") if outputs[signal].to_s != outHsh[signal].to_s
          assert_equal(outputs[signal].to_s,outHsh[signal].to_s,"#{signal} does not match #{outHsh[signal]}") 
        }
      }	

    end

  end
  #RUNIT::CUI::TestRunner.run(TestingMyDesign.suite)

