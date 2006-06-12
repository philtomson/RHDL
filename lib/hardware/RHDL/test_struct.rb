require 'RHDL'
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
      print_outputs
      #fiddle
      puts "  foo is: #{foo}"
      puts "  bits is: #{bits}"
      puts "  my_generic is: #{my_generic}"
      puts "end AndGate behavior"
    }
    self.class.send(:define_method, :fiddle, proc{
      puts "fiddle #{foo}"
    })
  }

  def print_outputs
    process(out) { #you can include 'process' here, but is it
                   #a good idea?
      process_behavior {
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
    #NOTE: for this to work, this 'block' must not be run
    #until instantiation (otherwise the gates instantiated below will
    #be connected to Symbols instead fo Signals resulting in error!
    sig_type = aa.type
    #a_and_b = Signal(Bit.new) #not generic
    a_and_b = Signal(sig_type.new) #more generic

    andg = AndGate.new(aa,bb,a_and_b,22)
    Invert.new(a_and_b, a_nand_b)
  }
}

require 'Simulator'
include Simulator

a = Signal(Bit.new('1'))
b = Signal(Bit.new('1'))
out = Signal(Bit.new )
nand = NandGate.new(a,b, out)
step { puts "a=#{a}, b=#{b}, out=#{out}"}
a <= '0'
step { puts "a=#{a}, b=#{b}, out=#{out}"}


