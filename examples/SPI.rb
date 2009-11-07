begin
  require 'hardware/RHDL'
rescue LoadError
  #if RHDL hasn't been installed yet:
  require '../lib/hardware/RHDL'
end

include RHDL


SPI_Slave = model {
  DATA_WIDTH = 8
  inputs  mosi, sclk, ss_n, txdata, rst_n
  outputs miso, rxrdy, txrdy, rxdata 
  generics n=>DATA_WIDTH
  init {
    #variables:
    active_n, inactive_n = Bit.new('0'),Bit.new('1')
    idle, transfer       = Bit.new('0'),Bit.new('1')
    cnt  = 0 #BitVector.new('0'*n)
    r_sreg = BitVector.new('0',n)
    t_sreg = BitVector.new('0',n)
    state = idle
    define_behavior {
      process(sclk){ 
        behavior{
          #negative edge of clock:
          if sclk.event && sclk == '0'
            if ss_n == active_n
              r_sreg[1..-1]=r_sreg[0..-2]
              r_sreg[0] = mosi
              if cnt == n-1
                puts "count is now #{cnt}"
                rxrdy <= rxrdy.inv
                rxdata <= r_sreg
              end
            end
            
          elsif sclk.event && sclk == '1'
            if rst_n == '0'
              state = idle
              cnt = 0 #BitVector.new('0'*n) 
              puts "cnt is : #{cnt}"
            else
              if state == idle
                puts "state is idle"
                if ss_n == '0'
                  t_sreg = txdata
                  txrdy <= txrdy.inv
                  state = transfer
                  puts "state is now: #{state}"
                end
              else
                puts "state was not idle"
                t_sreg[1..-1]=t_sreg[0..-2]
                if cnt == n-2
                  puts "state back to idle"
                  state = idle
                end
                cnt = (cnt + 1)%n
                puts "after increment: cnt is now: #{cnt}"
                miso <= t_sreg[-1]
              end
            end
          end
            #end
        }
      }
    }
  }
}

mosi  = Signal(Bit.new('0'))
sclk  = Signal(Bit.new('0'))
ss_n  = Signal(Bit.new('0'))
txdata= Signal(BitVector.new('10101010'))
rst_n = Signal(Bit.new('0'))
miso  = Signal(Bit.new())
txrdy = Signal(Bit.new('0'))
rxrdy = Signal(Bit.new('0'))
rxdata = Signal(BitVector.new())
#  inputs  mosi, sclk, ss_n, txdata, rst_n
#  outputs miso, rxrdy, txrdy, rxdata 
slave = SPI_Slave.new(:mosi=>mosi, :sclk=>sclk, :ss_n=>ss_n, :txdata=>txdata, :rst_n=>rst_n, :miso=>miso, :rxrdy=>rxrdy, :txrdy=>txrdy, :rxdata=>rxdata)

require 'Simulator'
include Simulator
step {puts "mosi=#{mosi}, sclk=#{sclk}, ss_n=#{ss_n}, txdata=#{txdata}, rst_n=#{rst_n}, miso=#{miso}, rxrdy=#{rxrdy}, txrdy=#{txrdy}, rxdata=#{rxdata} "; sclk <= sclk.inv ; }
step 
step
rst_n <= '1'
32.times do 
  step
  step
  mosi <= mosi.inv
end
