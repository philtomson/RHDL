module RHDL
class ClkGen < RHDL::Design
  include RHDL #mixin RHDL methods
  attr_accessor :clk
  def initialize(val1,len1,len2=len1)
    case val1
    when String,Fixnum
      @clk = Signal(Bit(val1))
    when Bit
      @clk = Signal(val1)
    when Signal
      @clk = val1
    end
    @count = 0
    super(nil,nil)
    define_behavior {
      process(){
        wait_for len1
        clk << clk.inv
        wait_for len2
        clk << clk.inv
      }
      #was: (shouldn't need this anymore:
      #puts " assign_at(#{len1}){#{clk.inv}}" if $DEBUG
      #@clk.assign_at(len1){ @clk.inv }
    }
    #was: (shouldn't need this anymore:
    #per_step {
      #  if @count == len1 
      #  puts "-> @count = #{@count}" if $DEBUG
      #  len1,len2 = len2,len1 
      #  puts "now: len1=#{len1}, len2=#{len2}"  if $DEBUG
      #  @count= 0
      #end
      #@count += 1
    #}
  end

  def ClkGen.generator(startVal,len1,len2=len1)
    cg=ClkGen.new(startVal,len1,len2)
    return cg.clk
  end
end
end #module RHDL

