require  'test/unit'
begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end


include RHDL

class TestRHDLsyntax < Test::Unit::TestCase
  include RHDL
  def test_no_init_or_behavior
    assert_raise(RHDL_SyntaxError) {
      foo = model {
        inputs x,y
        outputs z
      }
    }
  end

  def test_bad_generic
    assert_raise(RHDL_SyntaxError) {
      foo = model {
        inputs x,y
        outputs z
	generics gen
	init {}
      }
    }
  end



  def test_bogus_funcs
    assert_raise(RHDL_SyntaxError){
    dff = RHDL::model {
      foo aa,bb
      inputs clk, rst, d
      bar
      outputs q
      define_behavior {
	process(clk) {
	  behavior {
	    if clk.rising_edge
	      if rst == 1
		q <= 0
	      else
		q <= d
	      end
	    end
	  }
	}
      }
    }

    }

  end

  def test_bogus_methods_called
    dff = RHDL::model {
      inputs clk, rst, d
      outputs q
      define_behavior {
	process(clk) {
	  behavior {
	    if clk.rising_edge
	      if rst == 1
		q <= 0
	      else
		q <= d
	      end
	    end
	  }
	}
      }
    }
    (class << dff; self; end).class_eval{ define_method(:some_meth) { "FOO" } }
    assert_raise(NoMethodError){
      dff.some_meph
    }
    assert_equal("FOO", dff.some_meth )
  end



end

