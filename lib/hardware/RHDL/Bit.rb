####################################################
# Bit.rb
#
# copyright (c) 2002 Phil Tomson
# released under the GNU General Public License (GPL)
#
####################################################
class Integer
  def to_binstr 
    str = ""
    q = self
    begin
      r = q%2
      q = q/2
      str = r.to_s+str
    end while q > 0
    str
  end
  def to_bitvect
    BitVector.new(self.to_binstr)
  end
end
module RHDL
module BitOps
  attr_reader :value

  def inspect
    @value
  end

  def or(bit)
    puts "BitOps::or(#{bit})" if $DEBUG
    val = case [bit.to_s,self.value.to_s]
    when ['1','0'],['0','1'] then Bit.new('1')
    when ['1','1'] then Bit.new('1')
    when ['0','0'] then Bit.new('0')
    else
      Bit.new('X') 
    end
  end

  def xor(bit)
    puts "BitOps::xor(#{bit})" if $DEBUG
    val = case [bit.to_s,self.value]
    when ['1','0'],['0','1'] then Bit.new('1')
    when ['1','1'] then Bit.new('0')
    when ['0','0'] then Bit.new('0')
    else
      Bit.new('X')
    end
  end

  def ^(bit)
    self.xor(bit)
  end

  def +(bit)
    self.or(bit)
  end

  def |(bit)
    self.or(bit)
  end

  def and(bit)
    puts "Bit::and(#{bit})" if $DEBUG
    val = case [bit.to_s,self.value]
    when ['1','0'],['0','1'] then Bit.new('0')
    when ['1','1'] then Bit.new('1')
    when ['0','0'] then Bit.new('0')
    else
      Bit.new('X') 
    end
  end

  def *(bit)
    self.and(bit)
  end

  def &(bit)
    self.and(bit)
  end

  def inv()
    case @value
    when '0'
       Bit.new('1')
    when '1'
       Bit.new('0')
    when 'X','Z'
       Bit.new('X')
    end
  end

  def inv!()
    case @value
    when '0'
       @value = '1'
    when '1'
       @value = '0'
    when 'X','Z'
       @value = 'X'
    end
  end

  def ~()
    self.inv
  end

  # Let assign be the assignment op!
  #def <<(bit)
  #  assign(bit)
  #end

  #def <=(bit)
  #  assign(bit)
  #end

  def assign(bit)
    if bit.class == Signal
      bit = bit.inspect
    end
    case bit
    when String
      @value = bit
    when Bit
      @value = bit.value
    when Fixnum
      if bit > 1 || bit < 0
        raise ArgumentError, "argument must be either 0 or 1"
      else
        @value = bit.to_s
      end
    else 
      raise TypeError, "Can't assign a #{bit.class} to a Bit"
    end
  end

  def ==(bit)
    case bit
    when Bit
      @value == bit.value
    when String
      @value.to_s == bit
    when Fixnum
      @value.to_s == bit.to_s
    end
  end
end 

class Bit
  include BitOps
  def initialize(value='X')
    assign(value) 
  end
  def to_s
    @value
  end
  def to_i
    case value
    when '0'
      0
    when '1'
      1
    else
      nil
    end
  end
end

def Bit(value='X')
  Bit.new(value)
end

class BitVector
  include Comparable
  attr_reader :bitArray, :len
  def initialize(val='X',len=nil)
    #TODO: What about a case like: BitVector.new('0000') ?
    #Experimental:
    if val.class == String && len == nil
      len = val.length
    end
    ##############

    @len = len
    @minVal
    @maxVal
    @minIdx
    @maxIdx
    @bitArray = []
    assign(val,len)
  end

  def [](i)
    case i
    when Fixnum
      raise IndexError, "#{i} out of range!" if i >= @bitArray.length
      @bitArray[i]
    when Range #return another BitVector object
      raise IndexError, "#{i} out of range!" if i.last >= @bitArray.length
      BitVector(@bitArray[i].reverse)
    end
  end

  def msb
    return @bitArray.last
  end

  def lsb
    return @bitArray.first
  end

  def []=(i,v)
    #TODO: What about the case where i is a Range?
    case v
    when Bit
      raise IndexError, "#{i} out of range!" if i >= @bitArray.length
      @bitArray[i]=v
    when String
      str = v.reverse #get it into BitVector order
      if i.class == Range
        raise IndexErrof, "#{i.last} out of range!" if i.last >= @bitArray.length
        i.each_with_index {|n,idx|
          @bitArray[n]=Bit.new(str[idx,1])
        }
      else
        raise IndexError, "#{i} out of range!" if i >= @bitArray.length
        raise IndexError, "#{v} is larger than target BitVector" if v.length > @bitArray.length
        puts  "before: str length was: #{str.length}, str was: #{str}"
        (0..str.length-1).each {|n| 
          #was:@bitArray[i]=Bit.new(v[0,1])
          @bitArray[n]=Bit.new(str[n,1])
        }
        puts "after: str length was: #{str.length}, str was: #{str}"
      end
    when BitVector #on second thought, this isn't so useful...
      if i.class == Range
      elsif i.class == Fixnum #from copy bits i to ...
        if v.length > self.length
          @bitArray = v.bitArray[0.. @bitArray.length-1]
        elsif v.length < self.length
          @bitArray[0..v.length-1] = v.bitArray
        else #they've got to be equal length
          @bitArray = v.bitArray
        end
      end
    else
      puts "unknown type for v: #{v}, class: #{v.class}"
    end
  end

  #convert BitVector to an integer value
  def to_i
    str = self.to_s
    if str !~ /[xXzZ]/
      eval('0b'+self.inspect)
    else
      nil
    end
  end

  #math ops on BitVectors (+-*/)
  def math_ops(op,other)
    #puts "math_ops(#{op}, #{other.class})"
    case other
    when Fixnum
      BitVector.new(self.to_i.send(op,other),@len)
    when BitVector,Bit
      BitVector.new(self.to_i.send(op,other.to_i),@len)
    when String
      BitVector.new(self.to_i.send(op,other.bin),@len)
    else
      #TODO: raise exception
      raise TypeError, "Can't do  BitVector #{op.to_s} #{other.class}"
    end
  end

  def cat(other)
    tmpArray = other.bitArray+@bitArray
    BitVector.new(tmpArray)
  end
 
  def from_String(s)
    str = s.reverse
    str.length.times { |i|
      @bitArray[i] = Bit.new(str[i,1])
    }
  end

  def length
    @bitArray.length
  end

  def reverse
    @bitArray.reverse!
    self
  end

  def shift
  end

  def rotate
  end

  #  def ==(other)
  #  case other
  #  when Fixnum
  #    #convert to BitVector and compare
  #    #OR convert self to Fixnum and compare
  #    self.to_i == other
  #  when BitVector
  #    return false if other.length != self.length
  #    @bitArray.each_with_index{|b,i|
    #        return false if b != other[i]
    #   }
    #  return true      
    # when String
    #  return false if other.length != self.length
    #  os = other.reverse
    #  @bitArray.each_with_index{|b,i|
      #    return false if b.to_s != os[i,1].to_s
      # }
      # return true
      #else
      #raise TypeError, "#{other.class} not comparable to BitVector"
      #end
      #end

  def <=>(other)
    #TODO: check for self containing 'X'
    #if so return false
    case other
    when Fixnum
      self.to_i <=> other
    when BitVector
      #TODO: check for other containing 'X','x','Z' or 'z'
      self.to_i <=> other.to_i
    when String
      #TODO: check for other containing 'X','x','Z' or 'z'
      self.to_i <=> other.bin 
    else
      raise TypeError, "#{other.class} not comparable to BitVector"
    end
  end

  def method_missing(oper,*args)
    puts "args.length #{args.length} args.class #{args.class}" if $DEBUG
    if args.length ==0
      self_op(oper)
    elsif args.length == 1
      #TODO: ^, & shouldn't be mathops, should be bin_arg_ops
      if oper.to_s =~ /[+-\/\*\^\&]/
        math_ops(oper,*args)
      else
        bin_arg_ops(oper,*args)    
      end
    else
      #TODO: raise exception
      puts "No matching op found: #{oper} #{args}"
    end
  end

  
  #TODO: some trouble lurking in here:
  def bin_arg_ops(op,bv)
    #what if it's a string literal?
    tmpArray = @bitArray.clone
    shortestLen = 0
    if @bitArray.length >= bv.length
      shortestLen = bv.length
    else
      shortestLen = @bitArray.length
    end
    case bv
    when BitVector
      (shortestLen).times { |i|
        #was:#tmpArray[i] = (@bitArray[i].or(bv.bitArray[i]))
        tmpArray[i] = (@bitArray[i].send(op,(bv.bitArray[i])))
      }
      #tmpArray.reverse!
    when String
      shortestLen.times { |i|
        #was:#tmpArray[i] = (@bitArray[i].or(Bit.new(bv[i,1])))
        tmpArray[i] = (@bitArray[i].send(op,(Bit.new(bv[i,1]))))
      }
      #tmpArray.reverse!
    else
      #TODO: raise exception
    end
    BitVector.new(tmpArray.reverse!)
  end

  def self_op(op)
    if op[-1, 1] == "!" then
      oldval = @bitArray.join
      @bitArray.each_with_index {|bit,i|
        @bitArray[i].assign @bitArray[i].send(op)
      }
      if @bitArray.join == oldval then
        return nil
      else
        return self
      end
    else
      tmpArray = []
      @bitArray.each_with_index {|bit,i|
        tmpArray[i] = @bitArray[i].send(op)
      }
      return self.class.new tmpArray.reverse.join
    end
  end
    

  def to_s
    @bitArray.reverse.join
  end

  #def assign(bv)
  #  puts "BitVector::assign(#{bv})" if $DEBUG
  #  case bv
  #  when String
  #    puts "BitVector::assign - was a String" if $DEBUG
  #    from_String(bv)
  #  when BitVector
  #    puts "BitVector::assign - was a BitVector" if $DEBUG
  #    @bitArray = bv.bitArray.clone
  #  when Fixnum
  #
  #  else
  #    #TODO: raise exception
  #    puts "BitVector::assign - was a #{bv.type}"
  #  end
  #end

  def assign(val,len=@len)
    if val.class == Signal
      val = val.inspect
    end
    case val
    when String
      if len
        if len > val.length
          #pad with 0's
          val='0'*(len-val.length)+val
        elsif len < val.length
          #truncate it:
          val = val.reverse[0,len].reverse 
          puts "val is: #{val}, len is #{len}"
        end
      end
      from_String(val)
    when BitVector
      @bitArray = val.bitArray.clone
    when Array
      val.reverse.each_with_index {|b,i|
        break if i == len
        if b.class == Bit
          @bitArray[i]=b
        else
          @bitArray[i]=Bit.new(b)
        end
      }
    when Fixnum #TODO: change this to convert num to bitstring
      str = val.to_binstr
      if len
        if len > str.length
          #pad with 0's
          str='0'*(len-str.length)+str
        elsif len < str.length
          #truncate it:
          str = str.reverse[0,len].reverse 
        end
      end
      from_String(str)
    when Range 
      #create a BitVector which is large enough to hold the range of #'s
    else
      raise TypeError, "Can't build/assign a BitVector out of a #{val.class}"
    end
  end

  #def <=(bv)
  #  assign(bv)
  #end

  def inspect
    self.to_s
  end
end #class BitVector

#so you can create a BitVector without the 'new':
def BitVector(val,len=nil)
  BitVector.new(val,len)
end

end #RHDL

if $0 == __FILE__
  require 'RHDL'
  require 'Signal'
  require 'test/unit'
  include RHDL
  class TestBit < Test::Unit::TestCase
    def test_bitvector
      bv = BitVector('0110011')
      bvv = bv[1..3]
      assert_equal(bvv.to_s, '001')
      assert_equal(bv.to_s,  '0110011')

      bv3 =        BitVector('00110011')
      bv3[1..3]='111'
      puts "bv3 is: #{bv3}, length is: #{bv3.length}"
      assert_equal(bv3.to_s, '00111111')

      bv4 = BitVector('0000')
      

      
      bvb = BitVector('1111')
      #bv2 = bv.or('1111')
      bv2 = bv.or(bvb)
      puts "bv2 is: #{bv2}"
      
      assert_equal(bv2.inspect, '0111111')
      bus = Signal(BitVector('01110001'))
      puts "bus is:     #{bus}"
      #puts "bus.inv is: #{bus.inv}"
      bus.assign(bv)
      puts "bus after assign: #{bus}"
      assert_equal(bus.inspect, '01110001')
      assert_equal(true, ( bvb <= bv))
    end

    def test_bit_vector_overflow
      bv = BitVector(0b1110,4)
      assert_equal('1110', bv.to_s)
      assert_equal('1111', (bv + 1).to_s)
      bv.assign bv + 1
      assert_equal('1111', bv.to_s)
      bv.assign bv + 1
      assert_equal('0000', bv.to_s)
    end

    def test_bv_comparisons
      bv1 = BitVector(0b1010,4)
      bv2 = BitVector('11111')
      assert(bv1 < bv2)
      assert(bv2 > bv1)
      assert(bv1 == '1010')
      assert(bv1 == 10 )
      assert(bv2 == 0b11111 )
    end 


    def test_bit
      b = Signal(Bit('0'))
      c = Signal(Bit('0'))
      b.assign c.inv 
      puts "b is #{b} after b.assign(c)"

      e = (Bit('1'))
      f = (Bit('1'))
      d = (Bit())
      d.assign e | f
      puts "e is: #{e}"
      puts "f is: #{f}"
      puts "d is: #{d}"
      assert_equal(d.to_s, '1')
    end
  end


end
