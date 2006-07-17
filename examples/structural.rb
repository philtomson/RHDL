begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end

include RHDL

AndGate = model {
  inputs  a, b
  outputs out
  generics my_generic=>42 
  init {
    foo = "FooBar!"
    puts "in init my_generic is: #{my_generic}"
    bits = '0'*my_generic
    puts "in init: bits is: #{bits}"
    puts "in init: bits.length is: #{bits.length}"
    define_behavior {
      puts "begin AndGate behavior"
      out <= a & b
      #debugging messages:
      print_outputs
      puts "  foo is: #{foo}"
      puts "  bits is: #{bits}"
      puts "  my_generic is: #{my_generic}"
      puts "end AndGate behavior"
    }
  }
  #you can define your own methods within the model:
  def print_outputs
    process(out) { #you can include 'process' here, but is it
                   #a good idea?
      behavior {
        puts "out is: #{out}"
        #puts foo #NO, you can't refer to foo in this scope!
      }
    }
  end
}

Invert = model {
  inputs  a
  outputs not_a
  define_behavior{
    not_a <= a.inv
  }
}

NandGate = model {
  inputs  aa, bb
  outputs a_nand_b
  init {
    sig_type = aa.type
    a_and_b = Signal(sig_type.new) #more generic

    andg = AndGate.new(:a=>aa,:b=>bb,:out=>a_and_b,:my_generic=>22)
    Invert.new(:a=>a_and_b, :not_a=>a_nand_b)
  }
}

require 'Simulator'
include Simulator

a = Signal(Bit.new('1'))
b = Signal(Bit.new('1'))
out = Signal(Bit.new )
arg_hsh = {:aa =>a,:bb =>b,:a_nand_b =>out }
nand = NandGate.new(arg_hsh )
step { puts "a=#{a}, b=#{b}, out=#{out}"}
a <= '0'
step 
b <= '0'
step 
a <= '1'
step 


