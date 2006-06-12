require '../examples/dff.rb'
require 'test/unit'

class TestBit < Test::Unit::TestCase
  include RHDL

  def set_up
    @b1 = Bit('0')
    @b2 = Bit(1)
  end

  def test_compare
    assert_equal(@b2,1,"Should equal 1")
    assert_equal(@b2,'1',"Should equal '1'")
    assert_not_equal(@b1,@b2,"Should not be equal")
    assert_equal((@b2==@b1),false,"should be false")
    assert_equal((@b2!=@b1),true,"should be true")
  end

  def test_or
    b3 = @b1 | @b2
    b4 = @b1 + @b2
    assert_equal(b3,b4,"Should be equal")
    assert_equal(b3,1,"Should be 1")
    assert_equal(b4,1,"Should be 1")
    assert_equal(b3,'1',"Should be '1'")
    assert_equal(b4,'1',"Should be '1'")
    assert_equal(b3.class,Bit,"Should be a Bit")
    assert_equal( ((@b1 | @b2)=='1'),true, "Should be true")
  end

  def test_and
    b3 = @b1 & @b2
    b4 = @b1 * @b2
    assert_equal(b3,b4,"Should be equal")
    assert_equal(b3,0,"Should be 0")
    assert_equal(b4,'0',"Should be 0")
    assert_equal(b3.class,Bit,"should be a Bit")
  end

  def test_xor
    b3 = @b1 ^ @b2
    assert_equal(b3,1,"Should be 1")
    #b3 << @b2 ^ '1'
    #assert_equal(b3,0,"Should be 1")
    b4 = Bit(1)
    b5 = b3 ^ b4
    assert_equal(b5,0,"Should be '0'")
  end

  def test_inv
    b3 = @b1.inv #using .inv
    assert_equal(b3,1,"Should be 1")
    assert_equal(b3.type,Bit,"Should be Bit")
    b4 = ~@b1 #using ~
    assert_equal(b4,1,"Should be 1")
    assert_equal(b4.type,Bit,"Should be Bit")
    b5 = ~(b3 ^ b4) #try ~ on an equation
    assert_equal(b5,1,"Should be 1")
    assert_equal(b5.type,Bit,"Should be Bit")
  end

  def test_assign
    @b1 << '1'
    assert_equal(@b1,'1',"Should be '1'")
    assert_equal(@b1,1,"Should be '1'")
    @b1 << 0 
    assert_equal(@b1,0,"Should be 0")
    assert_equal(@b1,'0',"Should be 0")
    begin
      @b1 << 12
    rescue 
      assert_equal($!.class,ArgumentError,"Should be TypeError")
    end
    begin
      @b1 << (0..3) #check for type error
    rescue 
      assert_equal($!.class,TypeError,"Should be TypeError")
    end
    @b1 << @b2
    assert_equal(@b1,@b2,"Should be equal")
  end

end
    
    
