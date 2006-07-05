#############################################################
#EnumType - an enumerated type for specifying FSMs (and other things)
#usage: st = EnumType(:symbol1,:symbol2,...:symbolN)
#example: 
#  st = EnumType(:start,:wash,:rinse,:spin,:stop)
#(see: state_machine.rb in examples for example)  
#############################################################
module RHDL
class EnumType
  def initialize(*values)
    puts "EnumType::new"
    @values = values
    @value  = values[0]
    puts "--start value is: #{@value}, @value.class is:#{@value.class}"
  end

  def inspect
    @value
  end

  def value
    @value
  end

  def state
    @value
  end

  def ==(value) #other is a symbol
    if value.class == String
      value = value.intern
    end
    raise TypeError, "Not a valid value: #{value}" unless @values.include? value
    @value == value
  end

  def ===(value)
    raise "Not a valid value: #{value}" unless @values.include? value
    @value == value
  end

  def assign(value)
    if value.class == Signal
      value = value.inspect
    elsif value.class == String
      value = value.intern
    end
    raise  TypeError, "Not a valid value for this enumeration: #{value}" unless @values.include? value
    #puts "EnumType::assign(#{value}) value.class is: #{value.class}"
    @value = value
  end

  def <<(value)
    assign(value)
  end

  def to_s
    @value.to_s
  end

end

def EnumType(*values)
  puts "---------------------"
  EnumType.new(*values)
end

end


if $0 == __FILE__
  require 'test/unit'

  class EnumTest < Test::Unit::TestCase
    include RHDL
    def setup
      @statesType = EnumType.new(:start,:wash,:rinse,:spin,:stop)
      puts "@statesType is: #{@statesType.class}"
    end

    def test_initial
      assert_equal(@statesType.value, :start, "the initial value should be :start")
    end

    def test_negative
      assert_raise(TypeError) {
        @statesType << :foogle
      }
    end

    def test_positive
      @statesType << :wash
      assert_equal(@statesType.value, :wash, "the value should be :wash")
    end

  end
end
