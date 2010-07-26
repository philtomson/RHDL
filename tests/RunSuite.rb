require "test_syntax.rb"
Dir["test*.rb"].each { |file| 
  if (file !~ /test_syntax.rb/ )
    puts "...Running #{file}..."; require file 
  end
}
