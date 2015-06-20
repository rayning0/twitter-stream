# By Raymond Gan

require 'tweetstream'
require 'yaml'

class TwitterChallenge
  attr_reader :duration, :reject, :num_words, :app_name, :root_dir
  attr_accessor :word_freq, :start_time, :tweets

  def initialize(duration = 300, num_words = 10)
    @duration, @num_words = duration, num_words
    @tweets ||= 0
    @word_freq ||= Hash.new(0)
    @start_time = Time.now
    @reject = ['rt', 'and', 'the', 'me', 'a', 'an', 'of', 'or', 'for',
      'in', 'at', 'on', 'i', 'my', 'you', 'to', 'it', 'is', '&amp', ':']

    @root_dir = File.expand_path('.')
    @secrets_file =  "#{root_dir}/config/secrets.yml"
    @word_frequency_file = "#{root_dir}/word_freq.dat"

    @app_name = 'tchallenge'
    @output_file = "#{root_dir}/#{app_name}.output"
    @monitor_file = "#{root_dir}/#{app_name}_monitor.pid"
    @log_file = "#{root_dir}/#{app_name}.log"

    delete(@word_frequency_file, @monitor_file, @log_file, @output_file)
  end

  def run
    configure_tweet_stream
    examine_tweets
  end

  def configure_tweet_stream
    configure = YAML.load_file(@secrets_file)
    TweetStream.configure do |config|
      config.consumer_key       = configure['consumer_key']
      config.consumer_secret    = configure['consumer_secret']
      config.oauth_token        = configure['oauth_token']
      config.oauth_token_secret = configure['oauth_token_secret']
      config.auth_method        = :oauth
    end
  end

  def examine_tweets
    daemon = TweetStream::Daemon.new(app_name, monitor: true, log_output: true, multiple: false, keep_pid_files: false)

    daemon.on_close do
      puts "CLOSE CONNECTION. #{tweets} tweets. #{Time.now.strftime("%I:%M:%S %p")}"
      @word_freq['$$'] = tweets # stores # of tweets in file under key '$$'
      File.open(@word_frequency_file, 'w') { |file| YAML.dump(word_freq, file) }
    end

    daemon.on_inited do
      @word_freq = YAML.load_file(@word_frequency_file) if File.file?(@word_frequency_file)
      # when connection reopens, keep counting tweets from # at connection close
      @tweets = word_freq['$$'] if tweets == 0
      puts "OPEN CONNECTION. #{tweets} tweets. #{Time.now.strftime("%I:%M:%S %p")}"
    end

    daemon.on_error do |message|
      puts "ON_ERROR #{message}. #{tweets} tweets."
    end

    daemon.on_no_data_received do
      puts "NO DATA RECEIVED for 90 seconds. #{tweets} tweets."
    end

    daemon.sample do |status|
      next unless status.lang == 'en'  # only looks at tweets in English
      #puts "#{status.user.screen_name}: #{status.text}" <-- uncomment to see each tweet
      @tweets += 1
      word_freq_hash(status.text)

      if Time.now >= start_time + duration
        clean_up
        print_results
        break
      end
    end
  end

  def word_freq_hash(text)
    unless text.empty?
      # replaces most non-letters/numbers w/ spaces, except if followed by a letter/number
      text = text.downcase.gsub(/[?\.,!\-_;\"`\(\)\[\]](?!\w+)/, ' ')

      text.split.each do |word|
        next if reject.include?(word)
        # rejects all words starting with '@' or 'http'
        next unless word.scan(/^(@|http)/).empty?
        begin
          @word_freq[word] += 1
        rescue NoMethodError
          @word_freq = Hash.new(0)
        end
      end
    end
    word_freq
  end

  def clean_up
    `pkill -x #{@app_name}_monitor`
    delete(@monitor_file, @log_file)
  end

  def delete(*files)
    files.each do |file|
      File.delete(file) if File.file?(file)
    end
  end

  def print_results
    puts "\n#{tweets} tweets. Start: #{start_time.strftime("%I:%M:%S %p")}. End: #{Time.now.strftime("%I:%M:%S %p")}\n\n"
    sorted = word_freq.sort_by { |word, freq| freq }.reverse.first(num_words).to_h
    puts "Word frequency:\n#{sorted}\n\n"
    puts "After #{duration} seconds, the top #{num_words} most common words:\n#{sorted.keys}\n\n"
    puts "See word_freq.dat file for full word frequency list.\n\n"
  end
end
