require './lib/twitter_challenge'

if ARGV.count < 2
  ARGV[0] ||= 300
  ARGV[1] ||= 10
end

TwitterChallenge.new(ARGV[0].to_i, ARGV[1].to_i).run

# Output from running tonight 6/16/2015:

# 12625 tweets. Start: 09:01:24 PM. End: 09:06:24 PM
# Word frequency: {"lebron"=>1306, "this"=>1134, "warriors"=>1009, "state"=>788, "golden"=>778, "that"=>768, "nba"=>767, "are"=>688, "so"=>687, "curry"=>654}
# Top 10 most common words: ["lebron", "this", "warriors", "state", "golden", "that", "nba", "are", "so", "curry"]