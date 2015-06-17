# By Raymond Gan

require 'tweetstream'
require 'yaml'

class TwitterChallenge
  attr_reader :duration, :reject, :num_words
  attr_accessor :word_freq, :start_time, :tweets

  def initialize(duration = 300, num_words = 10)
    @start_time = Time.now
    @duration = duration  # collect tweets for this many seconds
    @tweets = 0
    @num_words = num_words
    @reject = ['rt', 'and', 'the', 'me', 'a', 'an', 'of', 'or', 'for',
      'in', 'at', 'on', 'i', 'my', 'you', 'to', 'it', 'is', '&amp']
    @word_freq = Hash.new(0)
  end

  def connect_to_tweet_stream
    configure = YAML.load_file('config/secrets.yml')
    TweetStream.configure do |config|
      config.consumer_key       = configure['consumer_key']
      config.consumer_secret    = configure['consumer_secret']
      config.oauth_token        = configure['oauth_token']
      config.oauth_token_secret = configure['oauth_token_secret']
      config.auth_method        = :oauth
    end
  end

  def examine_tweets
    client = TweetStream::Client.new

    client.sample do |status|
      next unless status.lang == 'en'  # only returns tweets in English
      # puts "#{status.user.screen_name}: #{status.text}"
      @tweets += 1
      word_freq_hash(status.text)
      break if Time.now >= start_time + duration
    end
  end

  def word_freq_hash(text)
    unless text.empty?
      # replaces most non-alphanumeric chars w/ spaces, except if a number/letter follows it
      text = text.downcase.gsub(/[?\.,!\-_;\"`](?!\w+)/, ' ')

      text.split.each do |word|
        next if reject.include?(word)
        next unless word.scan(/^(@|http)/).empty? # rejects all words starting with '@' or 'http'
        @word_freq[word] += 1
      end
    end
    word_freq
  end

  def print_results
    puts "\n#{tweets} tweets. Start: #{start_time.strftime("%I:%M:%S %p")}. End: #{Time.now.strftime("%I:%M:%S %p")}"
    sorted = word_freq.sort_by { |word, freq| freq }.reverse.first(num_words).to_h
    puts "Word frequency: #{sorted}"
    puts "Top #{num_words} most common words: #{sorted.keys}"
  end

  def run
    connect_to_tweet_stream
    examine_tweets
    print_results
  end
end
