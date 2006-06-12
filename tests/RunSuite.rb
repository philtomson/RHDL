Dir["test*.rb"].each { |file| puts "...Running #{file}..."; require file }
