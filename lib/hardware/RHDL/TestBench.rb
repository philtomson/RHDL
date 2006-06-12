require 'RHDL'
module RHDL

module TestBench
  
  def each_vector_from_file(file,inSigLst, outSigLst)
    IO.foreach(file) { |line|
      next if line =~ /^#/
      io = line.strip.split(":")
      next if io.length == 0
      ins = io[0].split
      outs= io[1].split
      inHsh = {}
      inSigLst.each_with_index { |sig,i|
        inHsh[sig] = ins[i]
      }
      outHsh = {}
      outSigLst.each_with_index { |sig,i|
        outHsh[sig] = outs[i]
      }
      yield inHsh,outHsh
    }
  end
end

end #RHDL

