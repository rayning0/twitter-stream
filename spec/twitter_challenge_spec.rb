require 'spec_helper'
require 'twitter_challenge'
require 'yaml'

describe TwitterChallenge do
  describe '#change_word_freq_hash' do
    it 'handles empty string' do
      expect(subject.word_freq_hash('')).to eq({})
    end

    it 'handles a few sentences' do
      expect(subject.word_freq_hash('If the shot Shott shot shot
        Nott, Nott was shot. But if the shot Shott shot shot Shott,
        then Shott was shot, not Nott.')).to eq("shot" => 8, "shott" => 4, \
        "nott" => 3, "if" => 2, "was" => 2, "but" => 1, "then" => 1, "not" => 1)
    end

    it 'ignores rejected words like "RT", "the", "I", "is", "it", etc.' do
      expect(subject.word_freq_hash("RT I do not know what's happening,
        you know? It seems like what's happening is not as it seems. Seems
        crazy!")).to eq("seems" => 3, "know" => 2, "not" => 2, "happening" => 2, \
        "what's" => 2, "crazy" => 1, "like" => 1, "as" => 1, "do" => 1)
    end

    it "ignores words starting with '@' or 'http' " do
      expect(subject.word_freq_hash("RT @guy: I do not know what's happening,
        you know? It seems like what's happening is not as it seems. Seems
        crazy! http://t.co/ngrmndmzbm")).to eq("seems" => 3, "know" => 2, "not" => 2, \
        "happening" => 2, "what's" => 2, "crazy" => 1, "like" => 1, "as" => 1, "do" => 1)
    end
  end

  describe 'disconnects from/reconnects to Twitter stream after killing process' do
    before do
      @app_name = 'tchallenge'
      @output_file = File.expand_path('.') + "/#{@app_name}.output"
      @word_frequency_file = File.expand_path('.') + "/word_freq.dat"
    end

    it 'automatically restarts process after killing it multiple times' do
      close_tweets = 0
      old_pid = 0

      # Starts process 'tchallenge.' Just hit 'enter' twice on keyboard.
      system('bundle exec ruby twitter.rb start')
      sleep(1)

      3.times do
        # New process starts
        output = IO.readlines(@output_file)
        expect(output.last.include?('OPEN CONNECTION')).to be true
        puts "\nNew process starts. See OPEN CONNECTION in output file."

        open_tweets = output.last.split('.')[1].scan(/\d+/).first.to_i
        expect(open_tweets).to eq(close_tweets)
        puts "# of tweets for new connection: #{open_tweets} = # of tweets at close of last connection: #{close_tweets}"

        pid = `pgrep -x #{@app_name}`.to_i
        expect(pid).not_to eq(old_pid)
        puts "New process ID: #{pid} != Old process ID: #{old_pid}."

        sleep(10)

        `pkill -x #{@app_name}`
        puts 'Killed process after 10 seconds of tweets'
        old_pid = pid

        sleep(10)

        output = IO.readlines(@output_file)
        expect(output.last.include?('CLOSE CONNECTION')).to be true
        puts 'See CLOSE CONNECTION in output file.'

        expect(File.file?(@word_frequency_file)).to be true
        @word_freq = YAML.load_file(@word_frequency_file)
        puts "See new word frequency file, 'word_freq.dat'."

        close_tweets = output.last.split('.')[1].scan(/\d+/).first.to_i
        expect(close_tweets).to be > open_tweets
        puts "# of tweets read for newly killed process: #{close_tweets} > # of tweets read for last killed process: #{open_tweets}"

        expect(@word_freq['$$']).to eq(close_tweets)
        puts "Total # of tweets read so far (#{close_tweets}) is stored in 'word_freq.dat'."
        puts 'Process should restart after >20 seconds.'

        sleep(20)
      end
    end
  end
end