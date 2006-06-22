begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end

require 'RHDL'
include RHDL
Counter = model {
  MODULO = 8
  inputs  clk, reset
  outputs count
  generics mod=>MODULO
  init {
    #c = 0
    define_behavior {
      puts "in behavior... clk: #{clk} clk.event is: #{clk.event}"
      process(clk) {
        c = 0 #c is now local to the process
        puts "in process initialization... c is: #{c}"
        behavior {
          #puts "what is the value of: #{fizzle}" #good, we caught this
          if clk.rising_edge
            puts "rising edge of clk"
            if reset == '1' || c== (mod-1)
              c = 0
            else
              c = c+1
            end
            count <= c
          end
        }
      }
    }
  }
}

#include Simulator
require 'Simulator'
include Simulator
clk = Signal(Bit.new('0'))
rst = Signal(Bit.new('1'))
cout= Signal(0)
fsm = Counter.new(clk,rst,cout,4)

step { puts "clk=#{clk}, rst=#{rst}, cout=#{cout}"}
clk <= '0'; rst <= '0'
step 
clk <= '1';
step 
step 
18.times do
  clk <= '0';
  step 
  clk <= '1';
  step
end



