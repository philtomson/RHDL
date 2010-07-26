begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end

require '../examples/dff.rb'
require 'test/unit'

class TestBV < Test::Unit::TestCase
  include RHDL

  def setup
    @bv1 = BitVector('0000',4)
    @bv2 = BitVector(12,4)
  end

  def test_compare
    assert_equal(@bv2,12,"Should equal 12")
    assert_equal(@bv2,'1100',"Should equal '1100'")
    assert_equal(@bv2,0xC,"Should equal 0xC")
    assert_not_equal(@bv1,@bv2,"Should not be equal")
    assert_equal((@bv2>@bv1),true, "should be true")
    assert_equal((@bv2<@bv1),false,"should be false")
    assert_equal((@bv2==@bv1),false,"should be false")
    assert_equal((@bv1<@bv2),true,"should be true")
  end

  def test_add
    assert_equal(@bv1+1,1,"Should be 1")
    assert_equal(@bv2+2,14,"Should be 14")
    @bv1 += 1
    assert_equal(@bv1,1,"Should be 1")
    assert_equal(@bv1+@bv2,13,"Should be 13")
    assert_equal(BitVector,(@bv1+@bv2).class,"Should be a BitVector")
    @bv2.assign (@bv2+3)
    assert_equal(@bv2,15,"should be 15")
    @bv2.assign (@bv2+5)
    assert_equal(4,@bv2.length,"length should be 4")
    assert_equal(@bv2,'0100',"should be 4")
  end

  def test_assign
    @bv1.assign '1010'
    assert_equal(@bv1,'1010',"Should be '1010'")
    assert_equal(@bv1,10,"Should be 10")
    @bv1.assign 12
    assert_equal(@bv1,12,"Should be 12")
    assert_equal(@bv1,'1100',"Should be '1100'")
    @bv1.assign [Bit(0),Bit(1),Bit(0),Bit(1)]
    assert_equal(@bv1,'0101',"")
    #try to make one that is too big:
    @bv1.assign [Bit(1),Bit(1),Bit(0),Bit(1),Bit(0),Bit(1)]
    assert_equal(@bv1,'0101',"")
  end

  def test_index
    assert_equal(@bv2[0],0,"Bit 0 should be 0")
    assert_equal(@bv2[1],0,"Bit 1 should be 0")
    assert_equal(@bv2[2],1,"Bit 2 should be 1")
    assert_equal(@bv2[3],1,"Bit 3 should be 1")
    @bv2[0].assign Bit(1)
    assert_equal(@bv2[0],1)
    #TODO: do we want 'each' to work?
    #@bv1.each { |bit|
    #  assert_equal(bit,0,"bit should be 0")
    #}
  end

  def test_mult
    bv3 = (@bv2*2)
    assert_equal(4,bv3.length,"should still be 4 bits")
    assert_equal(bv3,'1000',"Should be 8?")
    bv3 = (@bv2*'10')
    assert_equal(bv3,'1000',"Should be 8?")
    assert_equal(4,bv3.length,"should still be 4 bits")
    bv3 = (@bv2*'010')
    assert_equal(bv3,'1000',"Should be 8?")
    assert_equal(4,bv3.length,"should still be 4 bits")
  end


  def test_sub
    bv3 = (@bv2-2)
    assert_equal(bv3,'1010',"Should be 10")
    bv3.assign bv3-'1011'
    assert_equal(bv3,'0001',"")
  end

  def test_inv
    bv3 = @bv2.inv
    assert_equal(bv3,'0011',"Should be '0011'")
    bv3.assign ~bv3
    assert_equal(bv3,'1100',"Should be '1100'")
  end

  def test_or
    bv3 = @bv2 | '1111'
    assert_equal(bv3,'1111',"Should be 1111")
    assert_equal(bv3.class,BitVector,"Should be a BitVector") 
  end

  def test_and
    bv3 = @bv2 & '0101'
    assert_equal(bv3,'0100',"Should be '0100'")
    assert_equal(bv3.class,BitVector,"Should be BitVector")
    bv4 = @bv2 & @bv1
    assert_equal(bv4,'0000',"Should be '0000'")
  end

  def test_xor
    puts "bv2 is: #@bv2"
    bv3 = (@bv2 ^ '1111')
    assert_equal(bv3,'0011',"Should be '0011'")
    assert_equal(bv3.class,BitVector,"Should be BitVector")
    bv4 = @bv2 ^ bv3
    assert_equal(bv4,'1111',"Should be '1111'")
  end

end
    
    
