require 'RHDL'
require 'test/unit'

class TestSignal < Test::Unit::TestCase
  include RHDL
  include Simulator

  def set_up
    puts "set_up"
    @bvSig= Signal(BitVector('0001',4))
    @fixnumSig = Signal(5)
    @strSig = Signal('string')
    @symSig = Signal(:symbol)
  end

  def test_assign
    puts "test_assign"
    @bvSig << 15
    assert_equal(@bvSig,'0001',"Should be '0001'")
    step
    assert_equal(@bvSig,'1111',"Should be '1111'")
    @fixnumSig << 4
    assert_equal(@fixnumSig,5,"Should be 5")
    step
    assert_equal(@fixnumSig,4,"Should be 4")

  end

  def test_compare
    assert_equal(@bvSig,'0001',"Should equal '0001'")
    assert_equal(@bvSig[0],1,"Should equal 1")
    assert_equal(@bvSig,1,"Should equal 1")
    assert_equal(@fixnumSig,5,"Should equal 5")
    assert_equal(@strSig,'string',"Should equal 'string'")
    assert_equal(@symSig,:symbol,"Should equal 'string'")
  end

  def no_test_add
    assert_equal(@bv1+1,1,"Should be 1")
    assert_equal(@bv2+2,14,"Should be 14")
    @bv1 += 1
    assert_equal(@bv1,1,"Should be 1")
    assert_equal(@bv1+@bv2,13,"Should be 13")
    assert_equal(BitVector,(@bv1+@bv2).class,"Should be a BitVector")
    @bv2<< (@bv2+3)
    assert_equal(@bv2,15,"should be 15")
    @bv2<< (@bv2+5)
    assert_equal(4,@bv2.length,"length should be 4")
    assert_equal(@bv2,'0100',"should be 4")
  end


  def test_index
    assert_equal(@bvSig[0],1,"Bit 0 should be 1")
    assert_equal(@bvSig[1],0,"Bit 1 should be 0")
    assert_equal(@bvSig[2],0,"Bit 2 should be 0")
    assert_equal(@bvSig[3],0,"Bit 3 should be 0")
    @bvSig[1] << Bit(1)
    step
    assert_equal(@bvSig[1],1)
    assert_equal(@fixnumSig[0],1)
    assert_equal(@fixnumSig[1],0)
    assert_equal(@fixnumSig[2],1)
    assert_equal(@fixnumSig[3],0)
    #TODO: do we want 'each' to work?
    #@bv1.each { |bit|
    #  assert_equal(bit,0,"bit should be 0")
    #}
  end

  def test_mult
    bv3 = (@bvSig*2)
    assert_equal(4,bv3.length,"should still be 4 bits")
    assert_equal(bv3,'0010',"Should be 2?")
    bv3 = (@bvSig*'10')
    assert_equal(bv3,'0010',"Should be 2?")
    assert_equal(4,bv3.length,"should still be 4 bits")
    bv3 = (@bvSig*'010')
    assert_equal(bv3,'0010',"Should be 2?")
    assert_equal(4,bv3.length,"should still be 4 bits")
    bv3 << bv3 * 5
    assert_equal(bv3,'1010')
    bv3 << bv3 * 2
    assert_equal(bv3,'0100')
    bv4 = (@fixnumSig*4)
    assert_equal(bv4,20,"Should be 20")
  end


  def no_test_sub
    bv3 = (@bv2-2)
    assert_equal(bv3,'1010',"Should be 10")
    bv3 << bv3-'1011'
    assert_equal(bv3,'0001',"")
  end

  def test_inv
    bv3 = @bvSig.inv
    assert_equal(bv3,'1110',"Should be '1110'")
    bv3 << ~bv3
    assert_equal(bv3,'0001',"Should be '1100'")
    bv3 << bv3.inv
    assert_equal(bv3,'1110',"Should be '1100'")
  end

  def test_or
    bv3 = @bvSig | '1111'
    assert_equal(bv3,'1111',"Should be 1111")
    assert_equal(bv3.class,BitVector,"Should be a BitVector") 
  end

  def test_and
    bv3 = @bvSig & '0101'
    assert_equal(bv3,'0001',"Should be '0001'")
    assert_equal(bv3.class,BitVector,"Should be BitVector")
    bv4 = @bvSig & @fixnumSig #TODO: currently this doesn't work, should it?
    assert_equal(bv4,'0001',"Should be '0001'")
  end

  def test_xor
    bv3 = (@bvSig ^ '1111')
    assert_equal(bv3,'1110',"Should be '0011'")
    assert_equal(bv3.class,BitVector,"Should be BitVector")
    bv4 = @bvSig ^ bv3
    assert_equal(bv4,'1111',"Should be '1111'")
  end

end
    
    
