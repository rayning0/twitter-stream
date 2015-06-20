require './lib/twitter_challenge'

puts "Type 'bundle exec ruby twitter.rb start'"
puts
puts "This code streams all tweets (in English) for [time] seconds,"
puts "while tracking the top [num_words] words used. By default,"
puts "we look at tweets for 300 seconds (5 minutes) and show the top 10 words."
puts

begin
  print "Enter time (seconds) [default: 300]: "
  duration = STDIN.gets.strip
  duration = duration.empty? ? 300 : duration.to_i
  print "Enter # of top words [default: 10]: "
  num_words = STDIN.gets.strip
  num_words = num_words.empty? ? 10 : num_words.to_i
end until duration > 0 && num_words > 0

TwitterChallenge.new(duration, num_words).run

# Output from running 6/16/2015, during NBA finals:

# 12625 tweets. Start: 09:01:24 PM. End: 09:06:24 PM

# Word frequency: {"lebron"=>1306, "this"=>1134, "warriors"=>1009, "state"=>788, "golden"=>778, "that"=>768, "nba"=>767, "are"=>688, "so"=>687, "curry"=>654}

# Top 10 most common words: ["lebron", "this", "warriors", "state", "golden", "that", "nba", "are", "so", "curry"]