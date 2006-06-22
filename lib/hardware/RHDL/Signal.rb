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

   def <<(nextValue=Proc.new)
     self.assign(nextValue)
   end

   def <=(nextValue=Proc.new)
     self.assign(nextValue)
   end

  #was commented:
  def method_missing(methID,*args)
    puts "methID is: #{methID}, args are: #{args}" if $DEBUG
    case methID
    when :+,:-,:*,:==,:===,:or,:and,:^,:&,:|,:xor
    	@valObj.send(methID,args[0])
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
      #########################################################
      #Was:
      #case @valObj
      ##Immediate values:
      #when Fixnum,Bignum,Numeric, String, TrueClass, FalseClass
      #	@valObj = @next_value
      #else
      #  @valObj.assign(@next_value) 
      #end
      #Now:
      if @valObj.respond_to?(:assign)
        @valObj.assign(@next_value)
      else
        @valObj = @next_value
      end
      #########################################################

    end
    puts "update value is now: #@valObj" if $DEBUG
    #was even earlier:@valObj <= @driver.call
  end

  def ==(other)
    @valObj == other
  end

  def ===(other)
    puts "Signal::===" if $DEBUG
    @valObj === other
  end

end

def Signal(val,width=1)
  Signal.new(val,width)
end

end #RHDL

if $0 == __FILE__
  require 'Bit'
  include RHDL
  require "runit/testcase"
  require 'runit/cui/testrunner'
  require 'runit/testsuite'

  class Testing_Signal < RUNIT::TestCase
    
  end
c0 = 0 #Integer

a = Signal(Bit('1'))
b = Signal(Bit('1'))
c = Signal(Bit())

c.<< {a + b}
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
