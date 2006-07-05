#############################################################
# Signal.rb
#
# Copyright (c) 2002 Phil Tomson
# released under the GNU General Public License (GPL)
# ##################################################

#######################################################
# add a bin method to the built-in String class
# converts a String composed of '1's and '0's to binary
# (note: won't be needed in Ruby 1.7/1.8
# #####################################################
class String
  def bin
    val = self.strip
    pattern = /^([+-]?)(0b)?([01]+)(.*)$/
    parts = pattern.match(val)
    return 0 if not parts
    sign = parts[1]
    num  = parts[3]
    eval(sign+"0b"+num)
  end
end

#####################################################
# add a 'inv' method to the built-in Fixnum class
# 
#####################################################
class Fixnum
  def inv
    binary = sprintf("%b",self) #get a binary representation of 'self'
    ones   = '1'*binary.length  #create a string of '1's the length of binary
    self ^ ones.bin             #invert by XOR'ing with ones
  end
end

module RHDL
###############################################################
# Signal - 
###############################################################
class Signal
  @@signalList = []#everytime we create a new signal we add it to this list
  @@deltaEvents = true 
   
  attr_reader :valObj, :next_value, :event
  attr_writer :event

  def Signal.update_all
    @@signalList.each {|signal|
      signal.update
    }
  end

  def Signal.deltaEvents?
    @@deltaEvents
  end

  def Signal.clear_deltaEvents
    @@deltaEvents = false
  end

  def Signal.set_deltaEvents
    @@deltaEvents = true
  end

  def inspect
    @valObj.inspect
  end

  def value
    #was:
    #self.inspect
    #TODO: should it just be: @valObj
    @valObj
  end

  def value=(n)
    @valObj.assign(n)
  end

  #TODO: do we need Signal.clear_events ?
  def Signal.clear_events
    @@signalList.each { |signal|
      signal.event = false
    }
  end

  def type
    @valObj.class
  end

  def rising_edge
    event && value == '1'
  end

  def falling_edge
    event && value == '0'
  end
  
  #signals have history
  def initialize(valObj,width = 1)
    @valObj = valObj 
    @@signalList << self
    @eventQueue = []
    @event = false
    @next_value = nil
  end

  ####The old assign_at and assign methods:##############
  # define a driver function for this signal:
  #def assign_at (relTime=0,function=nil)
  #  #schedule an event
  #  nextValue = case function
  #  when nil
  #    Proc.new.call
  #  when Proc
  #    function.call
  #  when Signal
  #    proc{function.to_s}.call
  #  else
  #    function
  #  end
  #  @eventQueue[relTime] = nextValue
  #  nextValInQueue = @eventQueue.shift
  #  @next_value = nextValInQueue if nextValInQueue
  #end
  #
  #def assign(function=nil)
  #  if function
  #    assign_at(0,function)
  #  else
  #    assign_at(0,Proc.new)
  #  end
  #end
  #######################################################
   def call
       proc{self.to_s}.call
   end
   #....
   def assign_at (relTime=0,nextValue=Proc.new)
     nextValue = nextValue.call if nextValue.respond_to? :call
     ###Experimental####
     if(relTime < @eventQueue.length)
       @eventQueue.clear
       @eventQueue[0] = nextValue
     else
       @eventQueue[relTime] = nextValue
     end
     #@eventQueue[relTime] = nextValue
     if @@deltaEvents
       nextValInQueue = @eventQueue[0]
       #nextValInQueue = @eventQueue.shift 
     else
       nextValInQueue = @eventQueue.shift 
     end
     ###\Experimental####
     puts "nextValInQueue: #{nextValInQueue}" if $DEBUG
     puts "@eventQueue:" if $DEBUG
     puts @eventQueue if $DEBUG
     @next_value = nextValInQueue if nextValInQueue != nil
   end

   def assign(nextValue=Proc.new)
       puts "assign #{nextValue}" if $DEBUG
       assign_at(0,nextValue)
   end

   #deprecated:
   #def <<(nextValue=Proc.new)
   #  self.assign(nextValue)
   #end

   ###########################################
   # <= means assignment, not les-than-or-equal
   ###########################################
   def <=(nextValue=Proc.new)
     self.assign(nextValue)
   end

   ###########################################
   # less-than-or-equal (since we can't use <= anymore )
   # #########################################
   def lte(other)
     if other.class == Signal
       @valObj <= other.value
     else
       @valObj <= other
     end
   end

   ##########################################
   # greater-than-or-equal
   # ########################################
   def gte(other)
     if other.class == Signal
       @valObj >= other.value
     else
       @valObj >= other
     end
   end


  #was commented:
  def method_missing(methID,*args)
    puts "methID is: #{methID}, args are: #{args}" if $DEBUG
    case methID
    when :+,:-,:*,:==,:===,:<=>,:>,:<,:or,:and,:^,:&,:|,:xor
      other = args[0]   
      if other.class == Signal
        @valObj.send(methID,other.value)
      else
	@valObj.send(methID,other)
      end
    else
      @valObj.send(methID,*args)
    end
  end

  def to_s
    @valObj.to_s
  end

  def update
    puts "update: next_value = #@next_value current value = #{@valObj.inspect}" if $DEBUG
    puts "update: next_value = #@next_value current value = #{@valObj}" if $DEBUG
    puts "update: next_value.class = #{@next_value.class} current value.class = #{@valObj.class}" if $DEBUG
    #TODO: what about using 'inspect' to determine values for events?
    #was:if @next_value && @next_value.to_s != @valObj.inspect.to_s #if changed 
    if @next_value && @valObj != @next_value #if changed 

      puts "update: #{@next_value.to_s} #{valObj.inspect.to_s}" if $DEBUG
      puts "update: #{@next_value} #{valObj}" if $DEBUG
      puts "update: class:#{@next_value.class}!= #{@valObj.class}" if @next_value.class != @valObj.class if $DEBUG
      @event = true
      @@deltaEvents = true
    else
      @event = false
    end
    if @next_value
      if @valObj.respond_to?(:assign)
        @valObj.assign(@next_value)
      else
        @valObj = @next_value
      end
    end
    puts "update value is now: #@valObj" if $DEBUG
  end

  def coerce(other)
    puts "coersion called! other is: #{other}, other.class is: #{other.class}"
    case other
    when Fixnum
      #return [ Signal.new(other), self.value.to_i]
      return [ other, self.value.to_i]
    when String
      puts "Coerce String!!!!!!"
      return [ Signal(BitVector(other)), self]
    end
  end

  #the '==' that comes with all objects must be overridden
  def ==(other)
    if other.class == Signal
      @valObj == other.value
    else
      @valObj == other
    end
  end

  #NOTE: commented to try coerce
  #def ===(other)
  #  puts "Signal::===" if $DEBUG
  #  @valObj === other
  #end


end


def Signal(val,width=1)
  Signal.new(val,width)
end

end #RHDL



if $0 == __FILE__
  require 'Bit'
  include RHDL
  require "test/unit"

  

  puts "Test Signal"
  class Testing_Signal < Test::Unit::TestCase
    def setup
      @a_bit = Signal(Bit('1'))
      @b_bit = Signal(Bit('1'))
      @c_bit = Signal(Bit())
      @counter = Signal(0) 

      @a_bv  = Signal(BitVector('1010'))
      @b_bv  = Signal(BitVector('0101'))
      @c_bv  = Signal(BitVector('XXXX'))
    end

    def test_add_bit
      @c_bit <= @a_bit + @b_bit
      @c_bit.update
      assert_equal(1, @c_bit)
    end

    def test_inv_bit
      @a_bit <= @a_bit.inv
      @a_bit.update
      assert_equal(0, @a_bit)
    end

    def test_compare_bv
      assert_not_equal(@a_bv, @b_bv)
      assert( @a_bv > @b_bv )

      #compare with a string literal:
      assert( @a_bv > '0000')

      #compare with an integer:
      assert( @a_bv < 22 )
      assert( @a_bv == 0b1010 )
      assert( @a_bv.lte(0b1010) )
      assert( @a_bv.gte(@b_bv ))
    end

    def test_add_bv
      @c_bv <= (@a_bv + @b_bv)
      @c_bv.update
      puts "@c_bv.value.class is: #{@c_bv.value.class}"
      #assert_equal( @c_bv, '1111')
      assert_equal( '1111', @c_bv.value.to_s)
      
      #try adding a literal to a Signal:
      @c_bv <= ( @c_bv + '0001' )
      @c_bv.update
      assert_equal( '0000', @c_bv.value.to_s )

      #try adding a BitVector to a BitVector Signal:
      @c_bv <= ( @c_bv + BitVector.new('1000'))
      @c_bv.update
      assert_equal( '1000', @c_bv.value.to_s )

      #try adding an integer to a BitVector Signal:
      @c_bv <= ( @c_bv + 1 )
      @c_bv.update
      assert_equal( '1001', @c_bv.value.to_s )

      #try adding a Signal(BitVector) to an integer:
      @c_bv <= ( 1 + @c_bv )
      @c_bv.update
      assert_equal( '1010', @c_bv.value.to_s )

      #try adding a Bitvector to a Signal:
      @c_bv <= (@c_bv + BitVector('0011') )
      @c_bv.update
      assert_equal( '1101', @c_bv.value.to_s )

      #NOTE: the following doesn't work and probably won't ever
      #try adding Signal to string literal (which represents BitVector):
      #@c_bv <= ('0010' + @c_bv)
      #@c_bv.update
      #assert_equal( '1111', @c_bv.value.to_s )


    end


    def test_reassignment_options
      @a_bit <= 0
      @a_bit.update
      assert_equal(0, @a_bit)
      @a_bit <= '1'
      @a_bit.update
      assert_equal(1, @a_bit)

      @c_bv <= '0000'
      @c_bv.update
      assert_equal(RHDL::Signal, @c_bv.class)
      assert_equal(BitVector, @c_bv.value.class )
      assert_equal('0000', @c_bv.value.to_s)

      
    end

    def test_integer_signal
      @counter <= @counter + 1 
      @counter.update
      assert_equal(1, @counter)

      #try adding two signals:
      val = Signal( 1 )
      @counter <= @counter + val
      @counter.update
      assert_equal(2, @counter)

      
    end

  end
if false
c0 = 0 #Integer

a = Signal(Bit('1'))
b = Signal(Bit('1'))
c = Signal(Bit())

c <= (a + b)
c.update
if c == '1'
  puts "yes"
end
counter = Signal(c0)
counter.<<(counter + 1) 
counter.update
puts counter.inspect
puts c
counter.assign(counter + 8)
counter.update
puts counter.inspect
counter.assign(counter & 5)
counter.update
puts counter.inspect
counter.assign(counter * 0b0101)
counter.update
puts counter.inspect
counter.assign(counter ^ 0xF)
counter.update
puts counter.inspect
if c == '1'
  puts "yes"
end
  end
end
